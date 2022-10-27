load 'Operations/FSW/FSW_Config_Types.rb'

# Adds methods to convert between string of bytes and values
class ByteString < String

  # Create ByteString object from array of bytes represented as ints between [0,255]
  # Width specifies min length of a bytestring (i.e. pads with \x00 if string length is less than width)
  def self.from_bytes(bytes, min_width = 0)
    raise "Byte array #{bytes.inspect} contains out-of-bound values" unless bytes.all? { |byte| byte.between?(0, 255) }

    # Convert from bytes array to string, then pad with zeros
    bytes_str = bytes.pack('C*')
    @min_width = min_width
    padded_bytes_str = bytes_str.ljust(@min_width, "\x00")
    ByteString.new(padded_bytes_str)
  end

  # Create ByteString object from array of hex bytes, e.g. 'FF FF 00' => [255, 255, 0]
  def self.from_hex_string(hex_string)
    config_bytes = hex_string.split.map { |hex_byte| hex_byte.to_i(16) }
    from_bytes(config_bytes)
  end

  def self.from_value(value, type)
    # convert to type if needed
    type = Type.from_name(type) unless type.is_a? Type
    if type.uint?
      from_uint(value)
    elsif type.array?
      from_bytes(value)
    else
      raise "Conversion from type #{type} not implemented"
    end
  end

  # Create ByteString object from uint value (Works for any size uints)
  def self.from_uint(uint)
    raise 'Negative uint value' if uint.negative?

    bytes = []
    until uint.zero?
      next_byte = uint & 0xFF
      bytes.append(next_byte)
      uint >>= 8
    end
    from_bytes(bytes)
  end

  # Interpret byte string as type
  def as_type(type)
    type = Type.from_name(type) unless Type.is_a? Type::TypeClass
    if bytes.length < type.length * type.size
      raise "Attempting to read ByteString of length #{bytes.length} as type #{type} of size #{type.length * type.size}"
    elsif type.array?
      bytes.take(type.length)
    elsif type.uint?
      to_uint(type.size)
    else
      raise "Conversion from ByteString to type #{type.inspect} not implemented"
    end
  end

  def to_uint(size = length)
    uint = 0
    # truncate and start with most significant byte (little endian)
    chars.take(size).reverse_each do |char|
      uint <<= 8
      uint |= char.ord
    end
    raise "Result #{uint} is not a uint (class: #{uint.class}" unless uint.is_a? Integer

    uint
  end

  def pad(width = @min_width)
    # Return another byte string padded with zeros
    ByteString.new(ljust(width, "\x00"))
  end
end
