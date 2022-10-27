
load_utility('Operations/FSW/UTIL_CmdSender')


class SetHeaterConfig

    def initialize(target = "BW3")
        @target = target
        @cmd_sender = CmdSender.new
        @wait_time = 5
    end


    def set_heater_row(board, heater_name, cold_setpoint, hot_setpoint, mode, rtd_1, rtd_2 = "RTD_UNUSED", rtd_3 = "RTD_UNUSED", rtd_4 = "RTD_UNUSED", rtd_5 = "RTD_UNUSED", rtd_6 = "RTD_UNUSED", rtd_7 = "RTD_UNUSED", rtd_8 = "RTD_UNUSED")

        cmd_params = {"HEATER_NUM": heater_name,
                      "COLD_SETPOINT": cold_setpoint,
                      "HOT_SETPOINT": hot_setpoint,
                      "MODE": mode,
                      "RTD_LABEL1": rtd_1,
                      "RTD_LABEL2": rtd_2,
                      "RTD_LABEL3": rtd_3,
                      "RTD_LABEL4": rtd_4,
                      "RTD_LABEL5": rtd_5,
                      "RTD_LABEL6": rtd_6,
                      "RTD_LABEL7": rtd_7,
                      "RTD_LABEL8": rtd_8
                    }
        @cmd_sender.send(board, "THERMAL_SET_CONFIG_ROW", cmd_params)

        # Verify values were set correctly
        init_cnt = tlm(@target, "#{board}-THERMAL_GET_ROW_RESP", "RECEIVED_COUNT")
        cmd_params = {"HEATER_NUM": heater_name}
        @cmd_sender.send_with_crc_poll(board, "THERMAL_GET_CONFIG_ROW", cmd_params)
        wait_check(@target, "#{board}-THERMAL_GET_ROW_RESP", "RECEIVED_COUNT", ">#{init_cnt}", @wait_time)

        check(@target, "#{board}-THERMAL_GET_ROW_RESP", "HEATER_NUM", "== '#{heater_name}'")
        check(@target, "#{board}-THERMAL_GET_ROW_RESP", "COLD_SETPOINT", "==#{cold_setpoint}")
        check(@target, "#{board}-THERMAL_GET_ROW_RESP", "HOT_SETPOINT", "==#{hot_setpoint}")
        check(@target, "#{board}-THERMAL_GET_ROW_RESP", "HEATER_MODE", "=='#{mode}'")
        check(@target, "#{board}-THERMAL_GET_ROW_RESP", "RTD_LABEL1", "=='#{rtd_1}'")
        check(@target, "#{board}-THERMAL_GET_ROW_RESP", "RTD_LABEL2", "=='#{rtd_2}'")
        check(@target, "#{board}-THERMAL_GET_ROW_RESP", "RTD_LABEL3", "=='#{rtd_3}'")
        check(@target, "#{board}-THERMAL_GET_ROW_RESP", "RTD_LABEL4", "=='#{rtd_4}'")
        check(@target, "#{board}-THERMAL_GET_ROW_RESP", "RTD_LABEL5", "=='#{rtd_5}'")
        check(@target, "#{board}-THERMAL_GET_ROW_RESP", "RTD_LABEL6", "=='#{rtd_6}'")
        check(@target, "#{board}-THERMAL_GET_ROW_RESP", "RTD_LABEL7", "=='#{rtd_7}'")
        check(@target, "#{board}-THERMAL_GET_ROW_RESP", "RTD_LABEL8", "=='#{rtd_8}'")
        
    end

    def load_heater_config(board)

        @cmd_sender.send(board, "THERMAL_CONFIG_RELOAD", {}, )

    end


end