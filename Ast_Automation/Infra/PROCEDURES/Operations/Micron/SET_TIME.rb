#load_utility('Operations/MICRON/MICRON_MODULE.rb')
require_relative 'MICRON_MODULE'

require 'date'

def epoch(microns)
    mic = MICRON_MODULE.new
    result = Array.new(microns.length) {false}
    microns.each_with_index do |micron_id, i|
        epoch_time = Time.now.to_i #Time in seconds since epoch
        converted_time = Time.at(epoch_time).strftime "%d%m%Y%H%M%S" #Epoch seconds converted to ddmmyyyyhourminuteseconds
        #there is an option of broadcast all
        mic.set_mic_time("MIC_LSL", micron_id, epoch_time, converted=true, raw=true, wait_check_timeout=0.1)
        value = mic.get_mic_time("MIC_LSL", micron_id)
        if !value.empty?    
            ret = value[0]['MIC_UNIX_TIME_STAMP']
            puts epoch_time + 1
            puts ret
            if ret == epoch_time + 1
                result[i] = true
            end
        end
    end
    result.all?
end
