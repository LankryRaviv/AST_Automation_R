load_utility('Operations/FSW/UTIL_CmdSender')
load_utility('Operations/COMM/COMM_TTC.rb')


class ModuleSBandProperties
    def initialize
        @cmd_sender = CmdSender.new
        @module_ttc = ModuleTTC.new
        @target = "BW3"
        @wait_time = 10

        @sband_standard_properties = {"tx_freq": 2245000000,
                                      "bt": 50,
                                      "p_out": 30,
                                      "tx_rs": 1,
                                      "tx_cc": 1,
                                      "tx_rand": 1,
                                      "tx_crc": 1,
                                      "preamble": 0,
                                      "midamble": 0,
                                      "postamble": 0,
                                      "rx_freq": 2067000000,
                                      "bw": 150,
                                      "rx_rs": 1,
                                      "rx_cc": 1,
                                      "rx_rand": 1,
                                      "rx_crc": 1} # preamble, midamble, and postamble values should be consulted with FSW
    end

    def SBand_set_low_rate_main(board)
        sband_properties = {"ground_watchdog_time": 86400,
                    "tx_rate": 128000,
                    "encrypt_frames": 0,
                    "tx_auth": 0,
                    "decrypt_frames": 0,
                    "rx_auth": 0}

        # Set properties
        set_and_save_properties(board, sband_properties, "MAIN")
    end

    # -------------------------------------------------------
    def SBand_set_low_rate_fallback(board)
        sband_properties = {"ground_watchdog_time": 3600,
                    "tx_rate": 128000,
                    "encrypt_frames": 0,
                    "tx_auth": 0,
                    "decrypt_frames": 0,
                    "rx_auth": 0}

        # Set properties
        set_and_save_properties(board, sband_properties, "FALLBACK")

    end

    # -------------------------------------------------------
    def SBand_set_med_rate_main(board)
        sband_properties = {"ground_watchdog_time": 86400,
                    "tx_rate": 256000,
                    "encrypt_frames": 1,
                    "tx_auth": 1,
                    "decrypt_frames": 1,
                    "rx_auth": 1}


        # Set properties
        set_and_save_properties(board, sband_properties, "MAIN")

    end

    # -------------------------------------------------------
    def SBand_set_med_rate_fallback(board)
        setup("SBand_med_rate_fallback")

        sband_properties = {"ground_watchdog_time": 3600,
                    "tx_rate": 128000,
                    "encrypt_frames": 0,
                    "tx_auth": 0,
                    "decrypt_frames": 0,
                    "rx_auth": 0}

        # Set properties
        set_and_save_properties(board, sband_properties, "FALLBACK")
        
    end

    # -------------------------------------------------------
    def SBand_set_high_rate_main(board)
        sband_properties = {"ground_watchdog_time": 86400,
                    "tx_rate": 512000,
                    "encrypt_frames": 1,
                    "tx_auth": 1,
                    "decrypt_frames": 1,
                    "rx_auth": 1}
        
        # Set properties
        set_and_save_properties(board, sband_properties, "MAIN")

    end

    # -------------------------------------------------------
    def SBand_set_high_rate_fallback(board)
        sband_properties = {"ground_watchdog_time": 3600,
                    "tx_rate": 128000,
                    "encrypt_frames": 0,
                    "tx_auth": 0,
                    "decrypt_frames": 0,
                    "rx_auth": 0}
        
        # Set properties
        set_and_save_properties(board, sband_properties, "FALLBACK")

    end

    # -------------------------------------------------------
    def set_and_save_properties(board, sband_properties, save_location = "MAIN")

        # Set properties
        set_variable_properties(board, sband_properties)

        # Set common properties
        set_shared_config_properties(board)

        # Save properties
        if save_location == "MAIN"
            # Save to sys to main
            @module_ttc.sband_config_param_save_to_boot(board, "SL_CS_SYS_GROUP_ID")

            # Save RX to main
            @module_ttc.sband_config_param_save_to_boot(board, "SL_CS_RX_GROUP_ID")

            # Save TX to main
            @module_ttc.sband_config_param_save_to_boot(board, "SL_CS_TX_GROUP_ID")

        elsif save_location == "FALLBACK"
            # Save to sys to fallback
            @module_ttc.sband_config_param_save_to_fallback(board, "SL_CS_SYS_GROUP_ID")

            # Save RX to fallback
            @module_ttc.sband_config_param_save_to_fallback(board, "SL_CS_SYS_GROUP_ID")

            # Save TX to fallback
            @module_ttc.sband_config_param_save_to_fallback(board, "SL_CS_SYS_GROUP_ID")
        end
        
    end

    # -------------------------------------------------------
    def set_variable_properties(board, sband_properties)

        # Ground Watchdog Timer Timeout Value
        cmd_params = {"INIT": sband_properties[:ground_watchdog_time]}
        @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_GWDTINIT", cmd_params, "COMM", @wait_time)

        # Transmit rate
        cmd_params = {"RATE_TX": sband_properties[:tx_rate]}
        @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_TXRATE", cmd_params, "COMM", @wait_time)

        # Transmit encrypt frames
        cmd_params = {"STATE_SB_TXCDECRYPT": sband_properties[:encrypt_frames]} 
        @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_TXCRYPTOENCRYPT", cmd_params, "COMM", @wait_time)

        # Transmit Crypto Authentication tag
        cmd_params = {"STATE_SB_TXCAUTH": sband_properties[:tx_auth]} 
        @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_TXCRYPTOAUTH", cmd_params, "COMM", @wait_time)

        # Receive Decrpyt frames
        cmd_params = {"STATE_SB_RXCDECRYPT": sband_properties[:decrypt_frames]} 
        @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_RXCRYPTODECRYPT", cmd_params, "COMM", @wait_time)

        # Received Authentication tag
        cmd_params = {"STATE_SB_RXCAUTH": sband_properties[:rx_auth]} 
        @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_RXCRYPTOAUTH", cmd_params, "COMM", @wait_time)

    end

    # -------------------------------------------------------
    def set_shared_config_properties(board)

        # Transmit Frequency
        cmd_params = {"FREQ_TX": @sband_standard_properties[:tx_freq]}
        @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_TXFREQ", cmd_params, "COMM", @wait_time)

        # GMSK
        cmd_params = {"BT": @sband_standard_properties[:bt]}
        @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_TXBT", cmd_params, "COMM", @wait_time)

        # Transmit Power 
        cmd_params = {"POUT": @sband_standard_properties[:p_out]}
        @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_TXPOUT", cmd_params, "COMM", @wait_time)

        # Transmit gain

        # Transmit ALC Mode

        # Transmit RS
        cmd_params = {"STATE_SB_TXRS": @sband_standard_properties[:tx_rs]}
        @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_TXRS", cmd_params, "COMM", @wait_time)

        # Transmit CC
        cmd_params = {"STATE_SB_TXCC": @sband_standard_properties[:tx_cc]}
        @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_TXCC", cmd_params, "COMM", @wait_time)

        # Transmit Rand
        cmd_params = {"STATE_SB_TXRAND": @sband_standard_properties[:tx_rand]}
        @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_TXRAND", cmd_params, "COMM", @wait_time)

        # Transmit CRC
        cmd_params = {"STATE_SB_TXCRC": @sband_standard_properties[:tx_crc]}
        @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_TXCRC", cmd_params, "COMM", @wait_time)

        # Preamble
        cmd_params = {"PREAMBLE": @sband_standard_properties[:preamble]}
        @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_PREAMBLE", cmd_params, "COMM", @wait_time)

        # Midamble
        cmd_params = {"MIDAMBLE": @sband_standard_properties[:midamble]}
        @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_MIDAMBLE", cmd_params, "COMM", @wait_time)

        # Postamble
        cmd_params = {"POSTAMBLE": @sband_standard_properties[:postamble]}
        @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_POSTAMBLE", cmd_params, "COMM", @wait_time)

        # Transmit Crypto Key

        # Receive Frequency
        cmd_params = {"FREQ_RX": @sband_standard_properties[:rx_freq]} 
        @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_RXFREQ", cmd_params, "COMM", @wait_time)

        # Receive Bandwidth
        cmd_params = {"BW": @sband_standard_properties[:bw]} 
        @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_RXBW", cmd_params, "COMM", @wait_time)

        # Receive RS
        cmd_params = {"STATE_SB_RXRS": @sband_standard_properties[:rx_rs]}
        @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_RXRS", cmd_params, "COMM", @wait_time)

        # Receive CC
        cmd_params = {"STATE_SB_RXCC": @sband_standard_properties[:rx_cc]}
        @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_RXCC", cmd_params, "COMM", @wait_time)

        # Receive Rand
        cmd_params = {"STATE_SB_RXRAND": @sband_standard_properties[:rx_rand]} 
        @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_RXRAND", cmd_params, "COMM", @wait_time)

        # Receive CRC
        cmd_params = {"STATE_SB_RXCRC": @sband_standard_properties[:rx_crc]} 
        @cmd_sender.send_with_cmd_count_check(board, "SBAND_SET_RXCRC", cmd_params, "COMM", @wait_time)

        # Receive Crypto key

    end

    def hex_string_to_config(config)
        config = config.split(' ')
        i = 0
        config.each do |x|
            config[i] = config[i].to_i(16)
            i += 1
        end
        config = config.pack('C*')
        return config
      end
end