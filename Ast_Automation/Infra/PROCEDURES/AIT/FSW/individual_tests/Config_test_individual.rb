load 'TestRunnerUtils/AST_Test_Base.rb'
load 'cosmos/tools/test_runner/test.rb'
load 'Operations/FSW/UTIL_ByteString.rb'
load 'Operations/FSW/FSW_Config_Types.rb'
load 'Operations/FSW/FSW_Config_Properties.rb'

load('Operations/FSW/FSW_CSP.rb')
load('Operations/FSW/FSW_FDIR.rb')

def reboot_boards(boards, csp_instance)
  boards.each do |board| 
    csp_instance.reboot(board, true)
  end
  wait(7)
end

def load_default_configs(collector_list, cmd_sender)
  collector_list.each do |board|
    cmd_name = "FSW_LOAD_DEFAULT_FILE_TO_ACTIVE"
    cmd_params = {}
    cmd_sender.send(board, cmd_name, cmd_params, true)
  end
end

def retrieve_original_values(collector_list, cmd_sender)
  # Initialize hash to hold board params, key = board, value = config property hash
  orig_vals = {}
  collector_list.each do | board |
    orig_vals[board] = {}
    props = ConfigProperty.all_properties(board).reject { |property| property.name.to_s.downcase.include? 'configrow' or property.name.to_s.include? 'RoutingTable' }
    props.each do | prop |
      conf_val = read_config(board, ConfigProperty.from_name(board, prop), 'ACTIVE', cmd_sender)
      orig_vals[board][prop] = conf_val
    end
  end

  return orig_vals
end

def restore_original_configs(collector_list, cmd_sender, orig_vals, target)
  # Iterate over each board
  collector_list.each do | board |
    # Iterate over each property for the given board
    orig_vals[board].each do | property, val |
        write_config?(board, property, val, collector_list, target, cmd_sender)
    end

    unlock_and_save_active_configs(board, 'MAIN', cmd_sender)
  end
end


def unlock_and_save_active_configs(board, config_file, cmd_sender)
  cmd_sender.send(board, 'FSW_UNLOCK_CONFIG_SAVING', {}, true)
  cmd_sender.send(board, "FSW_SAVE_ACTIVE_CONFIG_#{config_file}_FILE", {}, true)
end

# Create a list of some in-bound values for a property for bounds testing
def values_in_bounds(property)
  lower_bound, upper_bound, exception = property.bounds_with_exception
  [lower_bound, upper_bound, exception,
   (lower_bound + 1 if lower_bound),
   (upper_bound - 1 if upper_bound),
   ((lower_bound + upper_bound) / 2 if lower_bound && upper_bound)].compact
end

# Test in-bounds values (for every bounded property, over all boards)
def _test_in_bound_values(collector_list, target, cmd_sender)
  test_cases = collector_list.flat_map do |board|
    props_to_test = ConfigProperty.bounded_properties(board)
    props_to_test.flat_map do |prop|
      values_in_bounds(prop).map { |in_bound_val| [board, prop, in_bound_val] }
    end
  end

  test_cases.each do |board, prop, in_bounds|
    raise "Failed writing #{in_bounds} to #{prop} on #{board}" unless write_config?(board, prop, in_bounds, collector_list, target, cmd_sender)
  end
end

# Create a list of some out-of-bound values for a property for bounds testing
def values_out_of_bounds(property)
  lower_bound, upper_bound, exception = property.bounds_with_exception
  [(lower_bound - 1 unless lower_bound.nil?), (upper_bound + 1 unless upper_bound.nil?)] - [nil, exception]
end

# Test out-of-bounds values (for every bounded property, over all boards)
# Test will pass if all test cases fail
# Any kind of failure during the writing/saving process will pass, even if isn't an out-of-bounds error!
def _test_out_of_bound_values(collector_list, target, cmd_sender)
  test_cases = collector_list.flat_map do |board|
    ConfigProperty.bounded_properties(board).flat_map do |prop|
      values_out_of_bounds(prop).map { |out_of_bound_val| [board, prop, out_of_bound_val] }
    end
  end

  test_cases.each do |board, prop, out_bounds|
    puts prop
    if write_config?(board, prop, out_bounds, collector_list, target, cmd_sender)
      raise "Was able to write out-of-bounds value #{out_bounds} to #{prop} on #{board}"
    end
  end
end

def check_update_bounded_configs(collector_list, cmd_sender, orig_vals, target)
  _test_in_bound_values(collector_list, target, cmd_sender)
  _test_out_of_bound_values(collector_list, target, cmd_sender)
  restore_original_configs(collector_list, cmd_sender, orig_vals, target)  
end

def check_update_config_rows(collector_list, cmd_sender, orig_vals, target)
  puts "Retreiving the config properties"
  test_cases = collector_list.flat_map do |board|
    config_props = ConfigProperty.config_row_properties(board)
    # Take the first, middle, and last properties for each type, e.g. [fdirRow0, fdirRow388, thermalRow1, thermalRow5]
    # Split into groups, eg. [[fdirRow0, ... fdirRow388 ], [thermalRow1, ..., thermalRow5] ]
    config_row_groups = config_props.slice_when { |prop1, prop2| prop1.to_s.tr('0-9','') != prop2.to_s.tr('0-9','')}
    # Select representatives from each config row group (first, middle, and last elements)
    properties_to_test = config_row_groups.flat_map { |config_group| config_group.values_at(0, config_group.length / 2, -1)}
    properties_to_test.map { |property| [board, property, ByteString.from_bytes(property.random_value)] }
  end

  puts "Testing the updating of config rows"
  test_cases.each do |board, prop, config_row|
    puts "Setting the config row #{prop} (prop id: #{prop.id}, prop type: #{prop.type}, prop type id: #{prop.type.id})"
    name_of_cmd_to_set = "FSW_SET_CONFIG_PARAMETER_#{prop.type.to_snake_case.upcase}"
    cmd_sender.send(board, name_of_cmd_to_set, ID: prop.id, TYPE_ID: prop.type.id, prop.type.data_field_name => config_row.to_s)
    raise if config_row.is_a?(String) && !config_row.is_a?(ByteString)
    wait(2)
    res = config_val_eq?(board, prop, config_row, 'ACTIVE', cmd_sender)
    current = read_config(board, prop, 'ACTIVE', cmd_sender)
    puts "Checking newly set config value"
    # check_expression("config_val_eq?(#{board.to_s.inspect}, #{prop.to_s.inspect}, #{config_row.to_s.inspect}, 'ACTIVE') == true")
    raise "Active #{prop} on #{board} is not #{config_row.inspect}" unless res
  end
  restore_original_configs(collector_list, cmd_sender, orig_vals, target)
end

def check_main_config_save(collector_list, cmd_sender, target, csp_instance, orig_vals)
  test_cases = collector_list.flat_map do |board|
    ConfigProperty.bounded_properties(board).map do |prop|
      value_to_save = generate_test_val(board, prop, 'MAIN', cmd_sender)
      puts prop
      puts value_to_save
      value_to_overwrite = generate_test_val(board, prop, 'MAIN', [value_to_save], cmd_sender)
      [board, prop, value_to_save, value_to_overwrite]
    end
  end

  test_cases.each do |board, prop, val_to_save, val_to_overwrite|
    # Write initial value to ACTIVE
    raise "Value #{val_to_save} not written to #{prop} on #{board} while writing initial value to ACTIVE" unless write_config?(board, prop, val_to_save, collector_list, target, cmd_sender)

    # Save ACTIVE configs to MAIN
    unlock_and_save_active_configs(board, 'MAIN', cmd_sender)
    wait(1)
    # Overwrite ACTIVE with another value
    raise "Value #{val_to_overwrite} not written to #{board} while overwriting ACTIVE value" unless write_config?(board, prop, val_to_overwrite, collector_list, target, cmd_sender)

    # Rebooting board should result in MAIN configs replacing ACTIVE ones
    reboot_boards([board], csp_instance)
    raise "Active config for #{prop} not loaded from file" unless config_val_eq?(board, prop, val_to_save, 'ACTIVE', cmd_sender)
  end
  restore_original_configs(collector_list, cmd_sender, orig_vals, target)
end

def check_fallback_config_update(collector_list, cmd_sender, target, orig_vals)
  puts 'FSW_config_property.rb: listing all properties:'
  ConfigProperty.all_properties('FC_YP').each_with_index { |i,v| puts "#{i}\t\t#{v}" }

  test_cases = collector_list.flat_map do |board|
    props_to_test = ConfigProperty.bounded_properties(board) + ConfigProperty.config_row_properties(board).sample(5)
    props_to_test.map { |prop| [board, prop, generate_test_val(board, prop, 'MAIN', cmd_sender)] }
  end

  test_cases.each do |board, prop, save_val|
    raise "Could not write #{save_val} to #{prop} on #{board}" unless write_config?(board, prop, save_val, collector_list, target, cmd_sender)

    unlock_and_save_active_configs(board, 'FALLBACK', cmd_sender)
    wait(1)
    raise 'Fallback config not loaded from file' unless config_val_eq?(board, prop, save_val, 'FALLBACK', cmd_sender)
  end
  restore_original_configs(collector_list, cmd_sender, orig_vals, target)
end

# Returns a random value of the given property distinct from both the current value of the config
def generate_test_val(board, property, config_file, more_exclusions = [], cmd_sender)
  forbidden = ByteString.from_value(read_config(board, property, config_file,cmd_sender), property.type).to_uint
  uint_to_save = random_value_with_exclusions(property.range, [forbidden] + more_exclusions)
  property.type.uint? ? uint_to_save : ByteString.from_uint(uint_to_save)
end

# Returns true if the value of property on board matches the given expected value
def config_val_eq?(board, property, expected, config_file, cmd_sender)
  # property = ConfigProperty.from_name(board, property)
  expected = expected.as_type(property.type) if expected.is_a? ByteString
  current = read_config(board, property, config_file, cmd_sender)
  current = current.as_type(property.type) if current.is_a? ByteString

  puts "Value of #{property} on #{board}: expected #{expected} and current value: #{current}"
  expected == current
end

# Read the current bytes in the CONFIG_UNION in the result packet
def read_config_union(board, config_file, cmd_sender)
  res_packet = "GET_#{config_file}_CONFIG_PARAM_RES#{'P' if config_file == 'MAIN'}"
  wait(0.1)
  byteObj = ByteString.new(cmd_sender.get_current_val(board, res_packet, 'CONFIG_UNION'))
  return byteObj
end

def load_config_union(board, property, config_file = 'ACTIVE', cmd_sender)

  config_files = %w[ACTIVE MAIN DEFAULT FALLBACK]
  raise "Invalid config type #{config_file}" unless config_files.include? config_file

  cmd_to_load_param = "FSW_GET_#{config_file.to_s.upcase}_CONFIG_PARAMETER"
  cmd_sender.send(board, cmd_to_load_param, ID: property.id, TYPE_ID: property.type.id)
end

# Retrieve and convert a config property from a board
def read_config(board, property, config_file = 'ACTIVE', cmd_sender)
  load_config_union(board, property, config_file, cmd_sender)
  bytes_string = read_config_union(board, config_file, cmd_sender)
  puts "read_config: on #{property} #{board} #{config_file} read bytes #{bytes_string.inspect}"
  bytes_string.as_type(property.type)
end

# Sets a config value and outputs whether that value was saved successfully
# This is similar to module_config.config_set but with exception handling,
# (for some reason runtime errors weren't being caught in COSMOS)
def write_config?(board, property, value, collector_list, target, cmd_sender)
  property = ConfigProperty.from_name(board, property) unless property.is_a? ConfigProperty
  raise "Invalid board #{board}" unless collector_list.include? board

  puts "Writing to property #{board} #{property} (ID: #{property.id})"
  full_cmd_name = "#{board}-FSW_SET_CONFIG_PARAMETER_#{property.type.to_snake_case.upcase}"
  val_to_send = value.is_a?(ByteString) ? value.to_s : value # Avoid sending bytestring to cmd
  cmd_params = { ID: property.id, TYPE_ID: property.type.id, property.type.data_field_name => val_to_send }
  begin
    cmd(target, full_cmd_name, cmd_params)
  rescue RuntimeError => e
    puts "Found error while setting config #{property} on #{board} to #{value}: #{e}"
    return false
  else
    return config_val_eq?(board, property, value, 'ACTIVE', cmd_sender)
  end
end

# Return a random value in range, and ensure the result isn't one of the excluded values
def random_value_with_exclusions(range, exclusions)
  # Ensure that valid values exist
  raise "No valid random vals in #{range}" if range.size <= exclusions.size && (range.to_a - exclusions.to_a).empty?

  loop do
    rand_val = rand(range)
    return rand_val unless exclusions.include? rand_val
  end
end
