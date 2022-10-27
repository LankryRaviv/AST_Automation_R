# frozen_string_literal: true

# Direction
module Direction
  SOUTH = 1
  EAST = 2
  WEST = 4
  NORTH = 8
end

# PowerMode
module PowerMode
  PS1 = 0
  PS2 = 1
  OPERATIONAL = 2
  REDUCED = 4
end

module PowerShareMode
  DISABLED = 0
  DONOR = 1
  DONEE = 2
  BRIDGE = 3
end

# Compass
class Compass
  attr_reader :micron_id, :north, :east, :west, :south

  def initialize(directions, micron = nil)
    @micron_id = micron.micron_id unless micron.nil?
    @north = @east = @west = @south = false
    return if directions.nil?

    if [true, false].include? directions
      @north = @east = @west = @south = directions
      return
    end

    if directions.instance_of? String
      paths = directions.upcase.split('/')
      @north = paths.include? 'N'
      @east = paths.include? 'E'
      @west = paths.include? 'W'
      @south = paths.include? 'S'
    end

    return unless micron.instance_of? Micron

    @north = micron.connections.north.micron_id if @north
    @east = micron.connections.east.micron_id if @east
    @west = micron.connections.west.micron_id if @west
    @south = micron.connections.south.micron_id if @south
  end

  def to_s
    [to_s_dir(Direction::NORTH),
     to_s_dir(Direction::EAST),
     to_s_dir(Direction::WEST),
     to_s_dir(Direction::SOUTH)].join
  end

  def ==(other)
    return false if other.nil?

    return false unless compare_dir(@north, other.north)
    return false unless compare_dir(@east, other.east)
    return false unless compare_dir(@west, other.west)
    return false unless compare_dir(@south, other.south)

    true
  end

  def direction(micron_id)
    begin
      return Direction::NORTH if @north == micron_id
      return Direction::EAST if @east == micron_id
      return Direction::WEST if @west == micron_id
      return Direction::SOUTH if @south == micron_id
    rescue StandardError
      return nil
    end

    nil
  end

  private

  def compare_dir(left, right)
    return true if left == right

    left = false if left.nil?
    right = false if right.nil?

    left = left.micron_id if left.instance_of? Micron
    right = right.micron_id if left.instance_of? Micron

    left = true if left.instance_of? Integer
    right = true if right.instance_of? Integer

    left == right
  end

  def to_s_dir(direction)
    return ' ' if direction.nil?

    case direction
    when Direction::NORTH
      letter = 'N'
      value = @north
    when Direction::EAST
      letter = 'E'
      value = @east
    when Direction::WEST
      letter = 'W'
      value = @west
    when Direction::SOUTH
      letter = 'S'
      value = @south
    end

    return value ? letter : ' ' if [true, false].include? value
    return value >= 0 ? letter : ' ' if value.instance_of? Integer

    value.nil? ? ' ' : letter
  end

  def count_active_connections
    link_count = 0
    link_count += 1 if @north
    link_count += 1 if @east
    link_count += 1 if @west
    link_count += 1 if @south

    link_count
  end
end

# ForwardCompass
class ForwardCompass < Compass
  def to_i
    microns = []
    microns += [@west.to_i] if @west
    microns += [@east.to_i] if @east
    microns += [@north.to_i] if @north
    microns += [@south.to_i] if @south

    microns
  end

  def verify
    true
  end
end

# BackwardCompass
class BackwardCompass < Compass
  def to_i
    return @west.to_i if @west
    return @east.to_i if @east
    return @north.to_i if @north
    return @south.to_i if @south

    nil
  end

  def to_s(reverse: false)
    return reverse ? 'S' : 'N' if @north
    return reverse ? 'W' : 'E' if @east
    return reverse ? 'E' : 'W' if @west
    return reverse ? 'N' : 'S' if @south

    '?'
  end

  def verify
    # Verify maximum of one link is active
    link_count = count_active_connections
    if link_count != 1
      puts "ERROR #{@micron_id} #{self.class} (#{link_count} != 1)"
      return false
    end

    true
  end
end

# LSRoutingDefines
module LSRoutingDefines
  LS_B_MASK  = 0b11100000                # 1110.0000
  LS_F_MASK  = 0b00011111                # 0001.1111

  LS_B_WEST  = (1 << 5)                  # 0010.0000
  LS_B_EAST  = (1 << 6)                  # 0100.0000
  LS_B_NORTH = (LS_B_WEST | LS_B_EAST)   # 0110.0000
  LS_B_SOUTH = (1 << 7)                  # 1000.0000
  LS_B_FPGA  = (LS_B_WEST | LS_B_SOUTH)  # 1010.0000

  LS_F_WEST  = (1 << 0)                  # 0000.0001
  LS_F_EAST  = (1 << 1)                  # 0000.0010
  LS_F_NORTH = (1 << 2)                  # 0000.0100
  LS_F_SOUTH = (1 << 3)                  # 0000.1000
  LS_F_FPGA  = (1 << 4)                  # 0001.0000
  LS_NO_DIR  = 0                         # 0000.0000
end

# LSForwardCompass
class LSForwardCompass < ForwardCompass
  def initialize(directions, micron)
    super(directions, micron)

    verify
  end

  def bitmask(bitmask = 0)
    bitmask |= LSRoutingDefines::LS_F_NORTH if @north
    bitmask |= LSRoutingDefines::LS_F_EAST if @east
    bitmask |= LSRoutingDefines::LS_F_WEST if @west
    bitmask |= LSRoutingDefines::LS_F_SOUTH if @south

    bitmask
  end

  def reroute_enable(dest_micron_id, new_forward)
    @north = dest_micron_id if new_forward.north == dest_micron_id
    @east =  dest_micron_id if new_forward.east ==  dest_micron_id
    @west =  dest_micron_id if new_forward.west ==  dest_micron_id
    @south = dest_micron_id if new_forward.south == dest_micron_id

    verify
  end

  def reroute_disable(dest_micron_id)
    @north = nil if @north == dest_micron_id
    @east = nil  if @east ==  dest_micron_id
    @west = nil  if @west ==  dest_micron_id
    @south = nil if @south == dest_micron_id

    verify
  end

  def verify
    # Verify maximum of three links are active
    link_count = count_active_connections
    if !super || link_count > 3
      puts "ERROR #{@micron_id} #{self.class} (#{link_count} > 3)"
      return false
    end

    true
  end
end

# LSBackwardCompass
class LSBackwardCompass < BackwardCompass
  def initialize(directions, micron)
    super(directions, micron)

    verify
  end

  def bitmask(bitmask = 0)
    bitmask &= LSRoutingDefines::LS_B_MASK # Clear backward bitmasks

    return bitmask | LSRoutingDefines::LS_B_NORTH if @north
    return bitmask | LSRoutingDefines::LS_B_EAST if @east
    return bitmask | LSRoutingDefines::LS_B_WEST if @west
    return bitmask | LSRoutingDefines::LS_B_SOUTH if @south

    bitmask
  end
end

# HSRoutingDefines
module HSRoutingDefines
  HS_B_MASK     = 0b00000011                  # 0000.0011
  HS_F1_MASK    = 0b00011100                  # 0001.1100
  HS_F2_MASK    = 0b11100000                  # 1110.0000
  HS_F_MASK     = (HS_F1_MASK | HS_F2_MASK)   # 1111.1100

  HS_B_WEST     = 0                           # 0000.0000
  HS_B_EAST     = (1 << 0)                    # 0000.0001
  HS_B_NORTH    = (1 << 1)                    # 0000.0010
  HS_B_SOUTH    = (HS_B_EAST | HS_B_NORTH)    # 0000.0011

  HS_F1_WEST    = 0                           # 0000.0000
  HS_F1_EAST    = (1 << 2)                    # 0000.0100
  HS_F1_NORTH   = (1 << 3)                    # 0000.1000
  HS_F1_SOUTH   = (HS_F1_EAST | HS_F1_NORTH)  # 0000.1100
  HS_F1_DISABLE = (1 << 4)                    # 0001.0000

  HS_F2_WEST    = 0                           # 0000.0000
  HS_F2_EAST    = (1 << 5)                    # 0010.0000
  HS_F2_NORTH   = (1 << 6)                    # 0100.0000
  HS_F2_SOUTH   = (HS_F2_EAST | HS_F2_NORTH)  # 0110.0000
  HS_F2_DISABLE = (1 << 7)                    # 1000.0000
end

# HSForwardCompass
class HSForwardCompass < ForwardCompass
  attr_reader :forward1, :forward2

  def initialize(directions, micron)
    super(directions, micron)

    remap_forwards
    verify
  end

  def bitmask(bitmask = 0)
    bitmask &= HSRoutingDefines::HS_B_MASK

    bitmask |= case @forward1
               when nil
                 HSRoutingDefines::HS_F1_DISABLE
               when @north
                 HSRoutingDefines::HS_F1_NORTH
               when @east
                 HSRoutingDefines::HS_F1_EAST
               when @west
                 HSRoutingDefines::HS_F1_WEST
               when @south
                 HSRoutingDefines::HS_F1_SOUTH
               end

    bitmask |= case @forward2
               when nil
                 HSRoutingDefines::HS_F2_DISABLE
               when @north
                 HSRoutingDefines::HS_F2_NORTH
               when @east
                 HSRoutingDefines::HS_F2_EAST
               when @west
                 HSRoutingDefines::HS_F2_WEST
               when @south
                 HSRoutingDefines::HS_F2_SOUTH
               end

    bitmask
  end

  def override(directions)
    @north = nil unless directions[:north]
    @east = nil unless directions[:east]
    @west = nil unless directions[:west]
    @south = nil unless directions[:south]

    remap_forwards
  end

  def verify
    # Verify maximum of two links are active
    link_count = count_active_connections
    if !super || link_count > 3
      puts "ERROR #{@micron_id} #{self.class} (#{link_count} > 2)"
      return false
    end

    true
  end

  private

  def remap_forwards
    @forward1 = if @west
                  @west
                elsif @east
                  @east
                elsif @north
                  @north
                elsif @south
                  @south
                end

    @forward2 = if @east && @forward1 != @east
                  @east
                elsif @north && @forward1 != @north
                  @north
                elsif @south && @forward1 != @south
                  @south
                end
  end
end

# HSBackwardCompass
class HSBackwardCompass < BackwardCompass
  def initialize(directions, micron)
    super(directions, micron)

    # Verify maximum of one link is active
    link_count = count_active_connections
    puts "ERROR HS Backward links (#{link_count} != 1)" if link_count != 1
  end

  def bitmask(bitmask = 0)
    bitmask &= HSRoutingDefines::HS_B_MASK # Clear backward bitmasks

    return bitmask | HSRoutingDefines::HS_B_NORTH if @north
    return bitmask | HSRoutingDefines::HS_B_EAST if @east
    return bitmask | HSRoutingDefines::HS_B_WEST if @west
    return bitmask | HSRoutingDefines::HS_B_SOUTH if @south

    bitmask
  end
end

# PowerCompass
class PowerCompass < Compass
  attr_reader :power_mode, :power_share_mode, :north_power, :east_power, :west_power, :south_power, :sticky_bit

  def initialize(directions, micron)
    @power_mode = PowerMode::PS1
    @power_share_mode = PowerShareMode::DISABLED
    @sticky_bit = false
    @north_power = @east_power = @west_power = @south_power = false
    super(directions, micron)
  end

  def to_i
    microns = []
    microns += [@west.to_i] if @west_power
    microns += [@east.to_i] if @east_power
    microns += [@north.to_i] if @north_power
    microns += [@south.to_i] if @south_power

    microns
  end

  def power_mode_set(power)
    puts "ON #{@micron_id}"
    @power_mode = power
  end

  def share_enable(share_direction)
    share(share_direction, true)
  end

  def share_disable(share_direction)
    share(share_direction, false)
  end

  def to_s(enabled: false)
    return super() unless enabled

    [
      @north_power ? to_s_dir(Direction::NORTH) : ' ',
      @east_power ? to_s_dir(Direction::EAST) : ' ',
      @west_power ? to_s_dir(Direction::WEST) : ' ',
      @south_power ? to_s_dir(Direction::SOUTH) : ' '
    ].join
  end

  private

  def share(share_direction, state)
    share_direction = direction(share_direction.micron_id) if share_direction.instance_of? MicronRoute
    raise StandardError, 'Invalid Direction' unless share_direction.is_a? Integer

    case share_direction
    when Direction::NORTH
      puts "SHARE #{@micron_id} N #{state}"
      return false unless @north

      @north_power = state

    when Direction::EAST
      puts "SHARE #{@micron_id} E #{state}"
      return false unless @east

      @east_power = state

    when Direction::WEST
      puts "SHARE #{@micron_id} W #{state}"
      return false unless @west

      @west_power = state

    when Direction::SOUTH
      puts "SHARE #{@micron_id} S #{state}"
      return false unless @south

      @south_power = state

    else
      puts "SHARE #{@micron_id} FAIL"
      return false
    end

    true
  end
end

# MatrixCompass
class MatrixCompass < Compass
  # attr_accessor :north, :east, :west, :south

  def map_connections(north:, east:, west:, south:)
    @north = north
    @east = east
    @west = west
    @south = south
  end
end
