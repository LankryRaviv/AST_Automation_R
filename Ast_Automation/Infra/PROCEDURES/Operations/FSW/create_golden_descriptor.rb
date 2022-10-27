def create_golden_image(layer_to_update, size, mcu_id_0, mcu_id_1, mcu_id_2)
    mcu_id_0_hex = int32_to_hex(mcu_id_0)
    mcu_id_1_hex = int32_to_hex(mcu_id_1)
    mcu_id_2_hex = int32_to_hex(mcu_id_2)
    mcu_id = mcu_id_0_hex + mcu_id_1_hex + mcu_id_2_hex
    mcu_id_file =  mcu_id_0.to_s(16)+ mcu_id_1.to_s(16)+ mcu_id_2.to_s(16)

    size_bytes = int32_to_hex(size)

    bytes_to_write = '0'

    if layer_to_update.casecmp('BL1') == 0
        bytes_to_write = '00'
    elsif layer_to_update.casecmp('BL2') == 0
        bytes_to_write = '01'
    elsif layer_to_update.casecmp('APP') == 0
        bytes_to_write = '02'
    end

    bytes_to_file = bytes_to_write.bytes
    #puts("bytes to write is #{bytes_to_write}")
    bytes_to_write = bytes_to_write + mcu_id + size_bytes + '01'
    #puts("bytes to write is #{bytes_to_write}")
    #bytes_to_write = 'ABCD'
    check = calc_crc32mpeg2(bytes_to_write)
    bytes_to_write = bytes_to_write + int32_to_hex(check)
    #puts("final bytes to write: #{bytes_to_write}")

    name_of_file = "#{Cosmos::USERPATH}/../../PROCEDURES/AIT/FSW/image_bins/goldenUpdDescr.#{mcu_id_file}.#{layer_to_update}.#{size}.bin"
    
    begin
        bytes_to_file = [bytes_to_write].pack('H*')
        File.open(name_of_file, 'wb') do |f|
            f.write(bytes_to_file)
        end
        return [name_of_file, true]
    rescue => error
        puts("Error encountered while building golden descriptor file: #{error.message}")
        return ["", false]
    end
end

def int32_to_hex(val)
    # val is a 32 bit number that needs to be converted to a little endian 32 bit hex with zero fill
    val_arr = [sprintf("%08X",val)]
    res = val_arr.pack('H*').unpack('N').pack('V*').unpack('H*')[0]
    return res
end

def calc_crc32mpeg2(in_str)
    crc = 'FFFFFFFF'.hex
    str_arr = in_str.each_char.each_slice(2).map(&:join)
    #str_arr = ['01','23','45','67','89','AB','CD','EF']
    str_arr.each do |byte|
        crc = (byte.hex<<24) ^ crc
        8.times {
            crc = (crc & '80000000'.hex) == 0 ? crc << 1 : (crc << 1) ^ '104C11DB7'.hex
        }
    end
    puts(crc.to_s(16))
    return crc
end
    

