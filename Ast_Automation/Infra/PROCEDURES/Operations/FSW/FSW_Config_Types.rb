module Type

  unless defined? TYPES 
    # IMPORTANT: This needs to be manually updated if new types are added
    # Array types are given a 'length' field (for number of elements), other types only have 'size'
    # Type names should be lower case symbols, and conversion rules should be given in process_type_name
    TYPES = {
      u8: { size: 1 },
      i8: { size: 1 },
      u16: { size: 2 },
      i16: { size: 2 },
      u32: { size: 4 },
      i32: { size: 4 },
      f: { size: 4},
      d: { size: 8},
      a8: { length: 8 },
      a16: { length: 16 },
      a32: { length: 32 },
      a64: { length: 64 },
      fdirconfig: { length: 38 },
      thermalconfig: { length: 13 },
      a128: { length: 128 },
      gaintableconfig: { length: 178},
      gaintablematrixrow: { length: 104},
      a256: {length: 256},
      s8: { length: 8 },
      s16: { length: 16 },
      s32: { length: 32 },
      s64: { length: 64 },
      s128: { length: 128 },
      unknown: {}
    }.freeze

    # Check formatting of TYPES
    raise 'TYPES table must have symbols as keys and hashes as values' unless TYPES.all? do |k,v|
      (k.is_a? Symbol) && (v.is_a? Hash)
    end

    raise 'TYPES table symbol keys must be lower case' unless TYPES.all? do |k,_|
      k.to_s == k.to_s.downcase
    end
  end

  # Converts a given string into a type symbol in TYPES
  private_class_method def self.process_type_name(name)
    downcase_name = name.to_s.downcase.delete('_')
    case downcase_name
    when 'a76'
      :fdirconfig
    when 'a13'
      :thermalconfig
    when 'a178'
      :gaintableconfig
    when 'a104'
      :gaintablematrixrow
    else
      downcase_name.to_sym
    end
  end

  def self.type?(name)
    TYPES.include?(process_type_name(name))
  end

  # Creates type object from a type name
  def self.from_name(name)
    TypeClass.new(process_type_name(name))
  end

  def self.from_id(id)
    from_name(TYPES.keys.fetch(id))
  end

  # Returns list of all types in order of their ids
  def self.all_types
    TYPES.keys.map { |type| from_name(type) }
  end

  # Class for representing config types
  class TypeClass
    attr_reader :name

    def initialize(name)
      raise "Type #{name} not found" unless Type.type? name.to_s.downcase

      @name = name.to_s.downcase.to_sym
    end

    def info
      TYPES.fetch(@name)
    end

    def id
      TYPES.keys.find_index { |type| type == @name }
    end

    # Returns the length of the type if the type is an array or string, otherwise returns 1
    def length
      info[:length] || 1
    end

    # Returns the size of the type, or 1 if type is an array or string
    def size
      info[:size] || 1
    end

    # Determines if type is an array
    def array?
      to_s.end_with?('config') || (@name.to_s =~ /^a\d*$/)
    end

    # Determines if type is an array
    def uint?
      to_s =~ /^u\d*$/
    end

    # Determines if type is a float
    def float?
      to_s =~ /^f\d*$/
    end

    def to_s
      @name.to_s
    end

    # Convert a name like 'fdirconfig' to 'fdir_config'
    def to_snake_case
      to_s =~ /^(.*)config$/ ? "#{Regexp.last_match(1)}_config" : to_s
    end

    # Convert type name into the format in the cmd spreadsheet
    def data_field_name
      case @name
      when :thermalconfig, :gaintableconfig, :gaintablematrixrow
        "DATA_A#{length}"
      else
        "DATA_#{to_snake_case.upcase}"
      end
    end

    def to_sym
      @name.to_sym
    end

    # Bounds for valid values of the type, when interpreted as a uint. May be very large.
    def range
      raise "Bounds for type #{type} not implemented" unless array? || uint?

      0..(2**(size * length * 8) - 1)
    end
  end
end

