load 'Operations/FSW/FSW_Config_Types.rb'

# ConfigProperty class for store info about Config Properties
module ConfigProperty
  UINT32_MAX = 0xFFFF_FFFF
  SYNC_PERIOD_MS_MIN = 500
  SYNC_PERIOD_MS_MAX = UINT32_MAX
  SYNC_PERIOD_OFF = 0

  # List of boards for which property info is provided 
  def self.boards
    ['FC_YP', 'APC_YP','FC_YM','APC_YM', 'DPC_1', 'DPC_2', 'DPC_3', 'DPC_4', 'DPC_5']
  end

  def self.board?(board)
    boards.include? board
  end

  # IMPORTANT: Specify all properties and their types and bounds for each board, in the order of their property ids
  # (Should mirror propDescriptors in configHandler.cpp)
  def self.properties_info(board)
    raise "Cannot get properties_info: Invalid board #{board.inspect}" unless ConfigProperty.board? board
    raise "Properties for board #{board.inspect} not implemented" unless board =~ /^(APC|FC)_Y[PM]|DPC_\d$/

    # Add properties to the property_info hash in order of their property id
    # Note: A property is mutable if it is testable. Specific properties that when modified either alter the board-to-cosmos communicate link or
    #   change the overall function of the board cannot be changed from their set value and therefore cannot be tested
    property_info = {
      cspId: { type: 'u8', lower_bound: 1, upper_bound: 15, mutable: false },
      timeSyncPeriodInMs: { type: 'u32', lower_bound: SYNC_PERIOD_MS_MIN, upper_bound: SYNC_PERIOD_MS_MAX, exception: SYNC_PERIOD_OFF, mutable: false },
      stackState: { type: 'u8', mutable: false },
      stackLocation: { type: 'u8', mutable: false },
    }

    # Add in the APC specific properties shared between the stacks
    if board.start_with?('APC')
      property_info[:meOkEnable] = {type: 'u8', mutable: true}
      property_info[:primaryCp] = { type: 'u8', mutable: true}
      property_info[:primaryQvt] = { type: 'u8', mutable: true}
      %w[Qv QvRx QvTx].each do |antenna|
        property_info["primary#{antenna}Antenna".to_sym] = { type: 'u8', mutable: true}
      end

      %w[Sband SbandRx SbandTx].each do |antenna|
        property_info["current#{antenna}Antenna".to_sym] = { type: 'u8', mutable: true}
      end
      property_info[:currentUhfAntenna] = { type: 'u8', mutable: true}
    end

    
    if board.start_with?('APC') or board.start_with?('FC')
      # Add in fdir and thermal properties
      property_info[:fdirConfigNumRows] = 
        { type: 'u32', lower_bound: 0, upper_bound: 500, exception: 12_345, mutable: true }

      # Add fdir and thermal config rows
      # Specify starting indices for each subsystem's config rows
      config_subsystems_index_ranges = board.start_with?('FC') ? { fdir: 0..499 } : { fdir: 0..499, thermal: 1..5 }
      config_subsystems_index_ranges.each do |subsystem, index_range|
        index_range.each do |i|  
          property_info["#{subsystem}ConfigRow#{i}".to_sym] = { type: "#{subsystem}Config", mutable: true } 
        end
      end
    end

    # Add in the micron routing table
    if board.start_with?('APC')
      (1..2).each {|i| property_info["micronRoutingTable#{i}".to_sym] = { type: 'a256', mutable: true } }
    end
    property_info
  end

  # Check if property_info function is valid
  boards.each do |board|
    invalid_properties = properties_info(board).reject { |k, v| (k.is_a? Symbol) && (v.is_a? Hash) }
    raise "Type error(s) with generated property_info: #{invalid_properties.inspect}" unless invalid_properties.empty?
  end

  # Get a Property object for the property of the given name
  def self.from_name(board, name)
    raise "Cannot find property from name #{name.inspect}: Invalid board #{board.inspect}" unless board? board
    raise 'Nil property name' if name.nil?

    name.is_a?(self::Property) ? name : self::Property.new(board, name)
  end

  # Get a Property object for the property of the given id
  def self.from_id(board, id)
    raise "Cannot get property id #{id.inspect}: Invalid board #{board.inspect}" unless board? board

    from_name(board, properties_info(board).keys.fetch(id))
  end

  def self.all_properties(board)
    raise "Cannot get all_properties: Invalid board #{board}" unless board? board

    properties_info(board).keys.map { |name| ConfigProperty.from_name(board, name) }
  end

  # Get all properties whose values can be changed by COSMOS
  def self.testable_properties(board)
    raise "Cannot get testable_properties: Invalid board #{board}" unless board? board

    all_properties(board).select(&:mutable?)
  end

  # Get config row properties 
  def self.config_row_properties(board)
    raise "Invalid board #{board}" unless board? board

    testable_properties(board).select { |property| property.name.to_s.downcase.include? 'configrow' }
  end

  # Get config row properties 
  def self.routing_table_properties(board)
    raise "Invalid board #{board}" unless board? board

    testable_properties(board).select { |property| property.name.include? 'RoutingTable' }
  end

  # Get bounded properties
  # A property is bounded if it is mutable and at least one of a lower bound or upper bound is defined
  def self.bounded_properties(board)
    raise "Invalid board #{board}" unless board? board

    testable_properties(board).reject { |property| property.lower_bound.nil? && property.upper_bound.nil? }
  end

  # Class for representing individual properties (should only be needed within this file)
  class Property
    attr_reader :name, :lower_bound, :upper_bound, :exception, :type, :id, :bounds_with_exception

    def initialize(board, name)
      @name = name.to_s
      raise "Invalid board #{board}" unless ConfigProperty.board? board
      
      props_info = ConfigProperty.properties_info(board)
      raise "Invalid property name #{name.inspect} on #{board}" unless props_info.include?(@name.to_sym)

      @id = props_info.keys.find_index { |prop| prop == @name.to_sym }

      info = props_info.fetch(@name.to_sym)
      @bounds_with_exception = info.values_at(:lower_bound, :upper_bound, :exception)
      @lower_bound, @upper_bound, @exception = @bounds_with_exception
      @type = Type.from_name(info.fetch(:type))
      @mutable = info.fetch(:mutable)
    end

    def mutable?
      @mutable
    end

    # Returns a random value of the property
    def random_value
      bytes = ByteString.from_uint(rand(range))
      bytes.as_type(@type)
    end

    def range
      # Find the intersection between the range of the type and the property bounds
      property_min = [type.range.min, @lower_bound].compact.max
      property_max = [type.range.max, @upper_bound].compact.min
      raise "Nil property bounds (type range is #{type.range})" if property_min.nil? || property_max.nil?
      if property_min > property_max
        raise "Range of #{self} (#{@lower_bound}, #{upper_bound}) and type #{type} (#{type.range}) are disjoint"
      end

      property_min..property_max
    end

    def to_s
      @name
    end

    def to_sym
      @name.to_sym
    end
  end
end
