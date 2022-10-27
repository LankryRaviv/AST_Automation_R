require 'Date'
require 'json'

module CLogger

    def log_message(message)

        STDOUT.write "#{(DateTime.now).to_s} - #{get_json_string(message)}\n"

    end

    def log_error(message)

        STDERR.write "#{(DateTime.now).to_s} - ERROR: #{get_json_string(message)}\n"

    end


    def log_response(message)

        STDOUT.write "RESPONSE=#{get_json_string(message)}\n"

    end


    private
    def get_json_string(message)
        if message.kind_of?(Hash) || message.kind_of?(Array)
            return message.to_json
        else
            return message
        end
    end


end