load_utility('Operations/FSW/UTIL_CmdSender')
load_utility('Operations/FSW/FSW_Config.rb')

require 'yaml'

# 0 - 'U8'
# 1 - 'I8'
# 2 - 'U16'
# 3 - 'I16'
# 4 - 'U32'
# 5 - 'I32'
# 6 - 'F'
# 7 - 'D'
# 8 - 'A8'
# 9 - 'A16'
# 10 - 'A32'
# 11 - 'A64'
# 12 - 'FDIR_CONFIG'
# 13 - 'A128'
# 14 - 'S8'
# 15 - 'S16'
# 16 - 'S32'
# 17 - 'S64'
# 18 - 'S128'
# 19 -'UNKNOWN'

class UHFConfig

    def initialize
        @cmd_sender = CmdSender.new
        @target = "BW3"
        @module_config = ModuleConfig.new

        @uhf_standard_properties = {"encryption_key": "\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0A\x0B\x0C\x0D\x0E\x0F\x10\x22\x22\x13\x14\x15\x16\x17\x18\x19\x1F\x1B\x1C\x1D\x1E\x1F\x20",
                                    "encryption_iv": "\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0A\x0B\x0C\x0D\x0E\x0F\x11",
                                    "rx_frequency": 437500000,
                                    "tx_frequency": 437500000,
                                    "power": 1,
                                    "freq_offset": 0,
                                    "rssi_offset": 0,
                                    "protocol_version": 1,
                                    "general_collection_period": 1000,
                                    "beacon_collection_period": 8000,
                                    "beacon_init_delay": 0,
                                    "beacon_tx_period": 8000,
                                    "beacon_destination_id": 29,
                                    "beacon_destination_port": 7,
                                    "RTCClockSource": 1,
                                    "logSeverity": 4} # freq and rssi not set right now, assumed set by manufacturer, general and beacon collection period need to be updated by FSW

        @uhf_beacon_properties = {"OriginID": 0,
                                  "OriginPort": 0,
                                  "TelemRequest": "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00",
                                  "TelemMask": "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"}
        @uhf_property_list = [ {"ID": 0, "Name": "CSP_ID",  "Type": "U8"},
        {"ID": 1, "Name": "CSP_Routes", "Type": "S128"},
        {"ID": 2, "Name": "Time Sync CSP ID",  "Type": "U8"},
        {"ID": 3, "Name": "Time Sync CSP Port",  "Type": "U8"},
        {"ID": 4, "Name": "Time Sync Period",  "Type": "U32"},
        {"ID": 5, "Name": "Radio Address",  "Type": "U16"},
        {"ID": 6, "Name": "Radio TX On",  "Type": "U8"},
        {"ID": 7, "Name": "Radio Encryption On",  "Type": "U8"},
        {"ID": 8, "Name": "Radio Encryption Key",  "Type": "A32"},
        {"ID": 9, "Name": "Radio Encryption IV",  "Type": "A16"},
        {"ID": 10, "Name": "Radio Power Amplifier Delay",  "Type": "U32"},
        {"ID": 11, "Name": "Radio Chip Oscillator Frequency",  "Type": "U32"},
        {"ID": 12, "Name": "Radio RX Frequency",  "Type": "U32"},
        {"ID": 13, "Name": "Radio TX Frequency",  "Type": "U32"},
        {"ID": 14, "Name": "Radio Power",  "Type": "I8"},
        {"ID": 15, "Name": "Radio Frequency Offset",  "Type": "I32"},
        {"ID": 16, "Name": "Radio RSSI Offset",  "Type": "I32"},
        {"ID": 17, "Name": "Radio Protocol Version",  "Type": "U8"},
        {"ID": 18, "Name": "Radio TX Modulation",  "Type": "U8"},
        {"ID": 19, "Name": "Radio RX Modulation",  "Type": "U8"},
        {"ID": 20, "Name": "GS Watchdog Period",  "Type": "U32"},
        {"ID": 21, "Name": "General TM Collection Period",  "Type": "U32"},
        {"ID": 22, "Name": "Beacon TM Collection Period",  "Type": "U32"},
        {"ID": 23, "Name": "Beacon TX On",  "Type": "U8"},
        {"ID": 24, "Name": "Beacon Initial Delay",  "Type": "U16"},
        {"ID": 25, "Name": "Beacon TX Period",  "Type": "U32"},
        {"ID": 26, "Name": "Beacon Destination ID",  "Type": "U8"},
        {"ID": 27, "Name": "Beacon Destination Port",  "Type": "U8"},
        {"ID": 28, "Name": "Telemetry Origin ID 1",  "Type": "U8"},
        {"ID": 29, "Name": "Telemetry Origing Port 1",  "Type": "U8"},
        {"ID": 30, "Name": "Telemetry Request 1",  "Type": "A16"},
        {"ID": 31, "Name": "Telemetry Mask 1",  "Type": "A16"},
        {"ID": 32, "Name": "Telemetry Origin ID 2",  "Type": "U8"},
        {"ID": 33, "Name": "Telemetry Origing Port 2",  "Type": "U8"},
        {"ID": 34, "Name": "Telemetry Request 2",  "Type": "A16"},
        {"ID": 35, "Name": "Telemetry Mask 2",  "Type": "A16"},
        {"ID": 36, "Name": "Telemetry Origin ID 3",  "Type": "U8"},
        {"ID": 37, "Name": "Telemetry Origing Port 3",  "Type": "U8"},
        {"ID": 38, "Name": "Telemetry Request 3",  "Type": "A16"},
        {"ID": 39, "Name": "Telemetry Mask 3",  "Type": "A16"},
        {"ID": 40, "Name": "Telemetry Origin ID 4",  "Type": "U8"},
        {"ID": 41, "Name": "Telemetry Origing Port 4",  "Type": "U8"},
        {"ID": 42, "Name": "Telemetry Request 4",  "Type": "A16"},
        {"ID": 43, "Name": "Telemetry Mask 5",  "Type": "A16"},
        {"ID": 44, "Name": "Telemetry Origin ID 5",  "Type": "U8"},
        {"ID": 45, "Name": "Telemetry Origing Port 5",  "Type": "U8"},
        {"ID": 46, "Name": "Telemetry Request 5",  "Type": "A16"},
        {"ID": 47, "Name": "Telemetry Mask 5",  "Type": "A16"},
        {"ID": 48, "Name": "Telemetry Origin ID 6",  "Type": "U8"},
        {"ID": 49, "Name": "Telemetry Origing Port 6",  "Type": "U8"},
        {"ID": 50, "Name": "Telemetry Request 6",  "Type": "A16"},
        {"ID": 51, "Name": "Telemetry Mask 6",  "Type": "A16"},
        {"ID": 52, "Name": "Telemetry Origin ID 7",  "Type": "U8"},
        {"ID": 53, "Name": "Telemetry Origing Port 7",  "Type": "U8"},
        {"ID": 54, "Name": "Telemetry Request 7",  "Type": "A16"},
        {"ID": 55, "Name": "Telemetry Mask 7",  "Type": "A16"},
        {"ID": 56, "Name": "Telemetry Origin ID 8",  "Type": "U8"},
        {"ID": 57, "Name": "Telemetry Origing Port 8",  "Type": "U8"},
        {"ID": 58, "Name": "Telemetry Request 8",  "Type": "A16"},
        {"ID": 59, "Name": "Telemetry Mask 8",  "Type": "A16"},
        {"ID": 60, "Name": "RTC Clock Source LSE",  "Type": "U8"},
        {"ID": 61, "Name": "Log Severity",  "Type": "U8"} ]

        @config_property_IDs = ['U8','I8','U16','I16','U32','I32','F','D','A8','A16','A32','A64','FDIR_CONFIG','A128','S8','S16','S32','S64','S128','UNKNOWN']

    end

    # # cspid - uint8
    # # ----------------------------------------------------------------------
    # def uhf_csp_id(value)
    #     type = 0 #'U8'
    #     property_id = 0

    #     set_uhf_config_parameter("UHF CSP ID", type, property_id, value)
    # end

    # # csproutes - string128
    # # ----------------------------------------------------------------------
    # def uhf_csp_routes(value)
    #     type = 18 # 'S128'
    #     property_id = 1

    #     set_uhf_config_parameter("UHF CSP Routes", type, property_id, value)
    # end

    # # timeSyncCspId- uint8
    # # ----------------------------------------------------------------------
    # def uhf_time_sync_csp_id(value)
    #     type = 0 #'U8'
    #     property_id = 2

    #     set_uhf_config_parameter("UHF TIME SYNC CSP ID", type, property_id, value)
    # end

    # # timeSyncCspPort - uint8
    # # ----------------------------------------------------------------------
    # def uhf_time_sync_csp_port(value)
    #     type = 0 #'U8'
    #     property_id = 3

    #     set_uhf_config_parameter("UHF TIME SYNC CSP PORT", type, property_id, value)
    # end

    # # timeSyncPerionInMs - uint32
    # # ----------------------------------------------------------------------
    # def uhf_time_sync_period_in_ms(value)
    #     type = 4 #'U32'
    #     property_id = 4

    #     set_uhf_config_parameter("UHF TIME SYNCE PERIOD IN MS", type, property_id, value)
    # end

    # # radioAddr - uint16
    # # ----------------------------------------------------------------------
    # def uhf_radio_addr(value)
    #     type = 2 #'U16'
    #     property_id = 5

    #     set_uhf_config_parameter("UHF RADIO ADDRESS", type, property_id, value)
    # end

    # radioTxOn - uint8
    # ----------------------------------------------------------------------
    def uhf_radio_tx_on(value)
        type = 0 #'U8'
        property_id =6

        set_uhf_config_parameter("UHF RADIO TX ON", type, property_id, value)
    end

    # radioEncryptionOn - uint8
    # ----------------------------------------------------------------------
    def uhf_radio_encryption_on(value)
        type = 0 #'U8'
        property_id = 7

        set_uhf_config_parameter("UHF RADIO ENCRYPTION ON", type, property_id, value)
    end

    # radioEncryptionKey - array32
    # ----------------------------------------------------------------------
    def uhf_radio_encryption_key(value)
        type = 10 #'A32'
        property_id = 8

        set_uhf_config_parameter("UHF RADION ENCRYPTION KEY", type, property_id, value)
    end   

    # radioEncryptionIV - array16
    # ----------------------------------------------------------------------
    def uhf_radio_encryption_iv(value)
        type = 9 # 'A16'
        property_id = 9

        set_uhf_config_parameter("UHF RADION ENCRYPTION IV", type, property_id, value)
    end       

    # radioPowerAmplifierDelayInMs - uint32
    # ----------------------------------------------------------------------
    def uhf_radio_power_amplifier_delay(value)
        type = 4 # 'U32'
        property_id = 10

        set_uhf_config_parameter("'UHF RADIO POWER AMPLIFIER DELAY'", type, property_id, value)
    end  

    # radioChipOscillatorFrequency - uint32
    # ----------------------------------------------------------------------
    def uhf_radio_chip_oscillator_frequency(value)
        type = 4 # 'U32'
        property_id = 11

        set_uhf_config_parameter("UHF RADIO CHIP OSCILLATOR FREQUENCY", type, property_id, value)
    end

    # radioRxFrequency - uint32
    # ----------------------------------------------------------------------
    def uhf_radio_rx_frequency(value)
        type = 4 # 'U32'
        property_id = 12

        set_uhf_config_parameter("UHF RADIO RX FREQUENCY", type, property_id, value)
    end

    # radioTxFrequency - uint32
    # ----------------------------------------------------------------------
    def uhf_radio_tx_frequency(value)
        type = 4 # 'U32'
        property_id = 13

        set_uhf_config_parameter("UHF RADIO TX FREQUENCY", type, property_id, value)
    end

    # radioPower - int8
    # ----------------------------------------------------------------------
    def uhf_radio_power(value)
        type = 1 # 'I8'
        property_id = 14

        set_uhf_config_parameter("UHF RADIO POWER", type, property_id, value)
    end

    # radioFreqOffset - int32
    # ----------------------------------------------------------------------
    def uhf_radio_freq_offset(value)
        type = 5 # 'I32'
        property_id = 15

        set_uhf_config_parameter("UHF RADIO FREQUENCY OFFSET", type, property_id, value)
    end

    # radioRssiOffset - int32
    # ----------------------------------------------------------------------
    def uhf_radio_rssi_offset(value)
        type = 5 # 'I32'
        property_id = 16

        set_uhf_config_parameter("UHF RADIO RSSI OFFSET", type, property_id, value)
    end

    # radioProtocolVersion - uint8
    # ----------------------------------------------------------------------
    def uhf_radio_protocol_version(value)
        type = 0 # 'U8'
        property_id = 17

        set_uhf_config_parameter("UHF RADIO PROTOCOL VERSION", type, property_id, value)
    end

    # radioTxModulation - uint8
    # ----------------------------------------------------------------------
    def uhf_radio_tx_modulation(value)
        type = 0 # 'U8'
        property_id = 18

        set_uhf_config_parameter("UHF RADIO TX MODULATION", type, property_id, value)
    end

    # radioRxModulation - uint8
    # ----------------------------------------------------------------------
    def uhf_radio_rx_modulation(value)
        type = 0 # 'U8'
        property_id = 19

        set_uhf_config_parameter("UHF RADIO RX MODULATION", type, property_id, value)
    end

    # gsWatchdogPerioInS - uint32
    # ----------------------------------------------------------------------
    def uhf_gs_watchdog_period_in_s(value)
        type = 4 # 'U32'
        property_id = 20

        set_uhf_config_parameter("UHF GS WATCHDOG PERIOD IN SEC", type, property_id, value)
    end

    # generalTmCollectionPeriodInMs - uint32
    # ----------------------------------------------------------------------
    def uhf_general_tm_collection_period_in_ms(value)
        type = 4 # 'U32'
        property_id = 21

        set_uhf_config_parameter("UHF GENERAL TELEM COLLECTION PERIOD", type, property_id, value)
    end

    # beaconTmCollectionPeriodInMs - uint32
    # ----------------------------------------------------------------------
    def uhf_beacon_tm_collection_period_in_ms(value)
        type = 4 # 'U32'
        property_id = 22

        set_uhf_config_parameter("UHF BEACON TM COLLECTION PERIOD", type, property_id, value)
    end

    # beaconTxOn - uint8
    # ----------------------------------------------------------------------
    def uhf_beacon_tx_on(value)
        type = 0 # 'U8'
        property_id = 23

        set_uhf_config_parameter("UHF BEACON TX ON", type, property_id, value)
    end

    # beaconInitialDelayInS - uint16
    # ----------------------------------------------------------------------
    def uhf_beacon_initial_delay_in_s(value)
        type = 2 # 'U16'
        property_id = 24

        set_uhf_config_parameter("UHF BEACON INITIAL DELAY", type, property_id, value)
    end

    # beaconTxPeriodInMs - uint32
    # ----------------------------------------------------------------------
    def uhf_beacon_tx_period_in_ms(value)
        type = 4 # 'U32'
        property_id = 25

        set_uhf_config_parameter("UHF BEACON TX PERIOD IN MS", type, property_id, value)
    end

    # beaconDestinationID - uint8
    # ----------------------------------------------------------------------
    def uhf_beacon_destination_id(value)
        type = 0 # 'U8'
        property_id = 26

        set_uhf_config_parameter("UHF BEACON DESTINATION ID", type, property_id, value)
    end

    # beaconDestinationPort - uint8
    # ----------------------------------------------------------------------
    def uhf_beacon_destination_port(value)
        type = 0 # 'U8'
        property_id = 27

        set_uhf_config_parameter("UHF BEACON DESTINATION PORT", type, property_id, value)
    end

    # telemetryOriginId_1 - uint8
    # ----------------------------------------------------------------------
    def uhf_telemetry_origin_id_1(value)
        type = 0 # 'U8'
        property_id = 28

        set_uhf_config_parameter("UHF TELEMETRY ORIGIN ID 1", type, property_id, value)
    end

    # telemetryOriginPort_1 - uint8
    # ----------------------------------------------------------------------
    def uhf_origin_port_1(value)
        type = 0 # 'U8'
        property_id = 29

        set_uhf_config_parameter("UHF ORIGIN PORT 1", type, property_id, value)
    end

    # telemetryRequest_1 - array16
    # ----------------------------------------------------------------------
    def uhf_telemetry_request_1(value)
        type = 9 # 'A16'
        property_id = 30

        set_uhf_config_parameter("UHF TELEMETRY REQUEST 1", type, property_id, value)
    end

    # telemetryMask_1 - array16
    # ----------------------------------------------------------------------
    def uhf_telemetry_mask_1(value)
        type = 9 # 'A16'
        property_id = 31

        set_uhf_config_parameter("UHF MASK 1", type, property_id, value)
    end

    # telemetryOriginId_2 - uint8
    # ----------------------------------------------------------------------
    def uhf_telemetry_origin_id_2(value)
        type = 0 # 'U8'
        property_id = 32

        set_uhf_config_parameter("UHF TELEMETRY ORIGIN ID 2", type, property_id, value)
    end

    # telemetryOriginPort_2 - uint8
    # ----------------------------------------------------------------------
    def uhf_origin_port_2(value)
        type = 0 # 'U8'
        property_id = 33

        set_uhf_config_parameter("UHF ORIGIN PORT 2", type, property_id, value)
    end

    # telemetryRequest_2 - array16
    # ----------------------------------------------------------------------
    def uhf_telemetry_request_2(value)
        type = 9 # 'A16'
        property_id = 34

        set_uhf_config_parameter("UHF TELEMETRY REQUEST 2", type, property_id, value)
    end

    # telemetryMask_2 - array16
    # ----------------------------------------------------------------------
    def uhf_telemetry_mask_2(value)
        type = 9 # 'A16'
        property_id = 35

        set_uhf_config_parameter("UHF MASK 2", type, property_id, value)
    end

    # telemetryOriginId_3 - uint8
    # ----------------------------------------------------------------------
    def uhf_telemetry_origin_id_3(value)
        type = 0 # 'U8'
        property_id = 36

        set_uhf_config_parameter("UHF TELEMETRY ORIGIN ID 3", type, property_id, value)
    end

    # telemetryOriginPort_3 - uint8
    # ----------------------------------------------------------------------
    def uhf_origin_port_3(value)
        type = 0 # 'U8'
        property_id = 37

        set_uhf_config_parameter("UHF ORIGIN PORT 3", type, property_id, value)
    end

    # telemetryRequest_3 - array16
    # ----------------------------------------------------------------------
    def uhf_telemetry_request_3(value)
        type = 9 # 'A16'
        property_id = 38

        set_uhf_config_parameter("UHF TELEMETRY REQUEST 3", type, property_id, value)
    end

    # telemetryMask_3 - array16
    # ----------------------------------------------------------------------
    def uhf_telemetry_mask_3(value)
        type = 9 # 'A16'
        property_id = 39

        set_uhf_config_parameter("UHF MASK 3", type, property_id, value)
    end

    # telemetryOriginId_4 - uint8
    # ----------------------------------------------------------------------
    def uhf_telemetry_origin_id_4(value)
        type = 0 # 'U8'
        property_id = 40

        set_uhf_config_parameter("UHF TELEMETRY ORIGIN ID 4", type, property_id, value)
    end

    # telemetryOriginPort_4 - uint8
    # ----------------------------------------------------------------------
    def uhf_origin_port_4(value)
        type = 0 # 'U8'
        property_id = 41

        set_uhf_config_parameter("UHF ORIGIN PORT 4", type, property_id, value)
    end

    # telemetryRequest_4 - array16
    # ----------------------------------------------------------------------
    def uhf_telemetry_request_4(value)
        type = 9 # 'A16'
        property_id = 42

        set_uhf_config_parameter("UHF TELEMETRY REQUEST 4", type, property_id, value)
    end

    # telemetryMask_4 - array16
    # ----------------------------------------------------------------------
    def uhf_telemetry_mask_4(value)
        type = 9 # 'A16'
        property_id = 43

        set_uhf_config_parameter("UHF MASK 4", type, property_id, value)
    end

    # telemetryOriginId_5 - uint8
    # ----------------------------------------------------------------------
    def uhf_telemetry_origin_id_5(value)
        type = 0 # 'U8'
        property_id = 44

        set_uhf_config_parameter("UHF TELEMETRY ORIGIN ID 5", type, property_id, value)
    end

    # telemetryOriginPort_5 - uint8
    # ----------------------------------------------------------------------
    def uhf_origin_port_5(value)
        type = 0 # 'U8'
        property_id = 45

        set_uhf_config_parameter("UHF ORIGIN PORT 6", type, property_id, value)
    end

    # telemetryRequest_5 - array16
    # ----------------------------------------------------------------------
    def uhf_telemetry_request_5(value)
        type = 9 # 'A16'
        property_id = 46

        set_uhf_config_parameter("UHF TELEMETRY REQUEST 5", type, property_id, value)
    end

    # telemetryMask_5 - array16
    # ----------------------------------------------------------------------
    def uhf_telemetry_mask_5(value)
        type = 9 # 'A16'
        property_id = 47

        set_uhf_config_parameter("UHF MASK 5", type, property_id, value)
    end

    # telemetryOriginId_6 - uint8
    # ----------------------------------------------------------------------
    def uhf_telemetry_origin_id_6(value)
        type = 0 # 'U8'
        property_id = 48

        set_uhf_config_parameter("UHF TELEMETRY ORIGIN ID 6", type, property_id, value)
    end

    # telemetryOriginPort_6 - uint8
    # ----------------------------------------------------------------------
    def uhf_origin_port_6(value)
        type = 0 # 'U8'
        property_id = 49

        set_uhf_config_parameter("UHF ORIGIN PORT 6", type, property_id, value)
    end

    # telemetryRequest_6 - array16
    # ----------------------------------------------------------------------
    def uhf_telemetry_request_6(value)
        type = 9 # 'A16'
        property_id = 50

        set_uhf_config_parameter("UHF TELEMETRY REQUEST 6", type, property_id, value)
    end

    # telemetryMask_6 - array16
    # ----------------------------------------------------------------------
    def uhf_telemetry_mask_6(value)
        type = 9 # 'A16'
        property_id = 51

        set_uhf_config_parameter("UHF MASK 6", type, property_id, value)
    end

    # telemetryOriginId_7 - uint8
    # ----------------------------------------------------------------------
    def uhf_telemetry_origin_id_7(value)
        type = 0 # 'U8'
        property_id = 52

        set_uhf_config_parameter("UHF TELEMETRY ORIGIN ID 7", type, property_id, value)
    end

    # telemetryOriginPort_7 - uint8
    # ----------------------------------------------------------------------
    def uhf_origin_port_7(value)
        type = 0 # 'U8'
        property_id = 53

        set_uhf_config_parameter("UHF ORIGIN PORT 7", type, property_id, value)
    end

    # telemetryRequest_7 - array16
    # ----------------------------------------------------------------------
    def uhf_telemetry_request_7(value)
        type = 9 # 'A16'
        property_id = 54

        set_uhf_config_parameter("UHF TELEMETRY REQUEST 7", type, property_id, value)
    end

    # telemetryMask_7 - array16
    # ----------------------------------------------------------------------
    def uhf_telemetry_mask_7(value)
        type = 9 # 'A16'
        property_id = 55

        set_uhf_config_parameter("UHF MASK 7", type, property_id, value)
    end

    # telemetryOriginId_8 - uint8
    # ----------------------------------------------------------------------
    def uhf_telemetry_origin_id_8(value)
        type = 0 # 'U8'
        property_id = 56

        set_uhf_config_parameter("UHF TELEMETRY ORIGIN ID 8", type, property_id, value)
    end

    # telemetryOriginPort_8 - uint8
    # ----------------------------------------------------------------------
    def uhf_origin_port_8(value)
        type = 0 # 'U8'
        property_id = 57

        set_uhf_config_parameter("UHF ORIGIN PORT 8", type, property_id, value)
    end

    # telemetryRequest_8 - array16
    # ----------------------------------------------------------------------
    def uhf_telemetry_request_8(value)
        type = 9 # 'A16'
        property_id = 58

        set_uhf_config_parameter("UHF TELEMETRY REQUEST 8", type, property_id, value)
    end

    # telemetryMask_8 - array16
    # ----------------------------------------------------------------------
    def uhf_telemetry_mask_8(value)
        type = 9 # 'A16'
        property_id = 59

        set_uhf_config_parameter("UHF MASK 8", type, property_id, value)
    end

    # rtcClockSourceLSE - uint8
    # ----------------------------------------------------------------------
    def uhf_rtc_clock_source_lse(value)
        type = 0 # 'U8'
        property_id = 60

        set_uhf_config_parameter("UHF RTC CLOCK SOURCE LSE", type, property_id, value)
    end

    # logSeverity - uint8
    # ----------------------------------------------------------------------
    def uhf_log_severity(value)
        type = 0 # 'U8'
        property_id = 61

        set_uhf_config_parameter("UHF LOG SEVERITY", type, property_id, value)
    end



    # ----------------------------------------------------------------------
    def set_uhf_config_parameter(name, type, property_id, value)

        init_set_value = read_config_parameter(property_id, type, "ACTIVE")
        puts "#{name} initial value: #{init_set_value}"

        @module_config.config_set("UHF", property_id, type, value)
        
        #check_config_parameter_active("UHF", property_id, type, value)

        final_set_value_raw = read_config_parameter(property_id, type, "ACTIVE")
        final_set_value_converted = convert_value(final_set_value_raw, type)
        
        puts "#{name} final value raw: #{final_set_value_raw}"
        puts "#{name} final value converted: #{final_set_value_converted}"
        if type !=9 and type !=10 # There's some weird formatting issue with the 'value' variable if type is A16 or A32
          check_expression("#{final_set_value_converted} == #{value}")
        end
    end

    # ----------------------------------------------------------------------
    def check_config_parameter_active(property_id, type, value)

        # Get initial response packet count
        init_cnt = tlm(@target, "UHF-GET_ACTIVE_CONFIG_PARAM_RES", "RECEIVED_COUNT")

        # Send command
        cmd_params = {"ID": property_id,
                      "TYPE_ID": type}
        @cmd_sender.send_with_crc_poll("UHF", "FSW_GET_ACTIVE_CONFIG_PARAMETER", cmd_params)

        # wait until a new response packet arrives
        wait_check(@target, "UHF-GET_ACTIVE_CONFIG_PARAM_RES", "RECEIVED_COUNT", "> #{init_cnt}",5)

        # Check the telemetry equals the expected value
        wait_check(@target, "UHF-GET_ACTIVE_CONFIG_PARAM_RES", "CONFIG_UNION", "== #{value}",2) 

    end

    # ----------------------------------------------------------------------
    def read_config_parameter(property_id, type, location)
        if location == "MAIN" # the MAIN response packet has an extra P and the end of the packet name
          extra_character = "P"
        else
          extra_character = ""
        end    
    
        # Get initial response packet count
        init_cnt = tlm(@target, "UHF-GET_#{location}_CONFIG_PARAM_RES#{extra_character}", "RECEIVED_COUNT")

        # Send command
        cmd_params = {"ID": property_id,
                    "TYPE_ID": type}
        @cmd_sender.send_with_crc_poll("UHF", "FSW_GET_#{location}_CONFIG_PARAMETER", cmd_params)

        # wait until a new response packet arrives
        wait_check(@target, "UHF-GET_#{location}_CONFIG_PARAM_RES#{extra_character}", "RECEIVED_COUNT", "> #{init_cnt}",5)


        return tlm(@target, "UHF-GET_#{location}_CONFIG_PARAM_RES#{extra_character}", "CONFIG_UNION")

    end

    def convert_value(value, type)

        type_array = ['C', 'c', 'S', 's','L','l','F','D','H','H','H','H','H','H','H','H','H','H','H','H']
        type_val = type_array[type]
        unpacked_value = value.unpack("#{type_val}*")
        converted_value = unpacked_value[0]
        
        if type == 9
         converted_value = converted_value[0..31]
        elsif type == 10
         converted_value = converted_value[0..64]
        end         
        return converted_value

    end

    def read_all_properties(location)

        @uhf_property_list.each do|config|

            type = @config_property_IDs.index(config[:Type])

            value_raw = read_config_parameter(config[:ID], type, location)
            value_converted = convert_value(value_raw, type)
            Cosmos::Test.puts("#{config[:Name]} #{location} value:")
            Cosmos::Test.puts("Raw: #{value_raw}")
            Cosmos::Test.puts("Converted: #{value_converted}")

            Cosmos::Test.puts("")

        end

    end

    def uhf_load_fallback_config()

        @cmd_sender.send("UHF", "FSW_LOAD_FALLBACK_FILE_TO_ACTIVE", {})

    end

    def uhf_load_main_config()

        @cmd_sender.send("UHF", "FSW_LOAD_MAIN_FILE_TO_ACTIVE", {})

    end

    def uhf_load_default_config()

        @cmd_sender.send("UHF", "FSW_LOAD_DEFAULT_FILE_TO_ACTIVE", {})

    end

    def uhf_save_active_to_main()

        # Unlock saving
        @cmd_sender.send("UHF", "FSW_UNLOCK_CONFIG_SAVING", {})

        # Save
        @cmd_sender.send("UHF", "FSW_SAVE_ACTIVE_CONFIG_MAIN_FILE", {})

        # Lock saving
        @cmd_sender.send("UHF", "FSW_LOCK_CONFIG_SAVING", {})
    end

    def uhf_save_active_to_fallback()

        # Unlock saving
        @cmd_sender.send("UHF", "FSW_UNLOCK_CONFIG_SAVING", {})

        # Save
        @cmd_sender.send("UHF", "FSW_SAVE_ACTIVE_CONFIG_FALLBACK_FILE", {})

        # Lock saving
        @cmd_sender.send("UHF", "FSW_LOCK_CONFIG_SAVING", {})
    end

    def UHF_set_1st_contact_main()

        uhf_properties = {"tx_on": 1,
                      "encryption_on": 0,
                      "tx_modulation": 1,
                      "rx_modulation": 1,
                      "gs_watchdog_period": 3600,
                      "beacon_tx_on": 1}

        # Ask for user for password
        #-------------------------------------------------------------
        password = ask("Input UHF Password")

        # Set properties and save to main
        #-------------------------------------------------------------
        set_and_save_properties(password, uhf_properties, "MAIN")      
        
    end
    

    def UHF_set_1st_contact_fallback()

        uhf_properties = {"tx_on": 1,
                          "encryption_on": 0,
                          "tx_modulation": 1,
                          "rx_modulation": 1,
                          "gs_watchdog_period": 3600,
                          "beacon_tx_on": 1}

        # Ask for user for password
        #-------------------------------------------------------------
        password = ask("Input UHF Password")

        # Set properties and save to fallback
        #-------------------------------------------------------------
        set_and_save_properties(password, uhf_properties, "FALLBACK")   

    end


    def UHF_set_low_rate_main()

        uhf_properties = {"tx_on": 0,
        "encryption_on": 1,
        "tx_modulation": 1,
        "rx_modulation": 1,
        "gs_watchdog_period": 600000,
        "beacon_tx_on": 0}

        # Ask for user for password
        #-------------------------------------------------------------
        password = ask("Input UHF Password")      

        # Set properties and save to main
        #-------------------------------------------------------------
        set_and_save_properties(password, uhf_properties, "MAIN")   
    end


    def UHF_set_low_rate_fallback()

        uhf_properties = {"tx_on": 1,
        "encryption_on": 0,
        "tx_modulation": 1,
        "rx_modulation": 1,
        "gs_watchdog_period": 600000,
        "beacon_tx_on": 0}

        # Ask for user for password
        #-------------------------------------------------------------
        password = ask("Input UHF Password")

        # Set properties and save to fallback
        #-------------------------------------------------------------
        set_and_save_properties(password, uhf_properties, "FALLBACK")   

    end


    def UHF_set_high_rate_main()

        uhf_properties = {"tx_on": 0,
        "encryption_on": 1,
        "tx_modulation": 1,
        "rx_modulation": 1,
        "gs_watchdog_period": 18400,
        "beacon_tx_on": 0}

        # Ask for user for password
        #-------------------------------------------------------------
        password = ask("Input UHF Password")

        # Set properties and save to main
        #-------------------------------------------------------------
        set_and_save_properties(password, uhf_properties, "MAIN")  

    end


    def UHF_set_high_rate_fallback()

        uhf_properties = {"tx_on": 1,
        "encryption_on": 0,
        "tx_modulation": 1,
        "rx_modulation": 1,
        "gs_watchdog_period": 3600,
        "beacon_tx_on": 0}

        # Ask for user for password
        #-------------------------------------------------------------
        password = ask("Input UHF Password")

        # Set properties and save to fallback
        #-------------------------------------------------------------
        set_and_save_properties(password, uhf_properties, "FALLBACK")  

    end

    def set_and_save_properties(password, uhf_properties, save_location = "MAIN")

        # Elevate access level to super user
        #-------------------------------------------------------------
        cmd_params = {"ROLE": "SUPERUSER",
                    "PASSWORD": password} 
        @cmd_sender.send("UHF", "FSW_ELEVATE_ACCESS_ROLE", cmd_params)
        
        # Change properties
        #-------------------------------------------------------------
        set_variable_properties(uhf_properties)
        set_standard_properties()
        set_beacon_packets()
                
        # Save
        #-------------------------------------------------------------
        if save_location == "FALLBACK"
            uhf_save_active_to_fallback()
        elsif save_location == "MAIN"
            uhf_save_active_to_main()
        end

        # Set access back to user
        #-------------------------------------------------------------
        cmd_params = {"ROLE": "USER",
        "PASSWORD": password} 
        @cmd_sender.send("UHF", "FSW_ELEVATE_ACCESS_ROLE", cmd_params)

    end

    def set_variable_properties(uhf_config)
        # Change config parameters 
        #-------------------------------------------------------------

        # radioTxOn - superuser
        uhf_radio_tx_on(uhf_config[:tx_on])

        # radioEncryptionOn
        uhf_radio_encryption_on(uhf_config[:encryption_on])
        
        # radioTxModulation
        uhf_radio_tx_modulation(uhf_config[:tx_modulation])
        
        # radioRxModulation
        uhf_radio_rx_modulation(uhf_config[:rx_modulation])
        
        # gsWatchdogPerioInS
        uhf_gs_watchdog_period_in_s(uhf_config[:gs_watchdog_period])
                
        # beaconTxOn
        uhf_beacon_tx_on(uhf_config[:beacon_tx_on])

    end

    def set_standard_properties()
        
        #radioEncryptionKey
        uhf_radio_encryption_key(@uhf_standard_properties[:encryption_key])

        # radioEncryptionIV
        uhf_radio_encryption_iv(@uhf_standard_properties[:encryption_iv])
        
        # radioRxFrequency
        uhf_radio_rx_frequency(@uhf_standard_properties[:rx_frequency])
        
        # radioTxFrequency
        uhf_radio_tx_frequency(@uhf_standard_properties[:tx_frequency])
        
        # radioPower
        uhf_radio_power(@uhf_standard_properties[:power])
        
        # radioFreqOffset
        #uhf_radio_freq_offset(@uhf_standard_properties[:freq_offset])
        
        # radioRssiOffset
        #uhf_radio_rssi_offset(@uhf_standard_properties[:rssi_offset])
        
        # radioProtocolVersion
        uhf_radio_protocol_version(@uhf_standard_properties[:protocol_version])
               
        # generalTmCollectionPeriodInMs
        uhf_general_tm_collection_period_in_ms(@uhf_standard_properties[:general_collection_period])
        
        # beaconTmCollectionPeriodInMs
        uhf_beacon_tm_collection_period_in_ms(@uhf_standard_properties[:beacon_collection_period])
        
        # beaconInitialDelayInS
        uhf_beacon_initial_delay_in_s(@uhf_standard_properties[:beacon_init_delay])
        
        # beaconTxPeriodInMs
        uhf_beacon_tx_period_in_ms(@uhf_standard_properties[:beacon_tx_period])
        
        # beaconDestinationID
        uhf_beacon_destination_id(@uhf_standard_properties[:beacon_destination_id])
        
        # beaconDestinationPort
        uhf_beacon_destination_port(@uhf_standard_properties[:beacon_destination_port])
        
        # rtcClockSourceLSE
        uhf_rtc_clock_source_lse(@uhf_standard_properties[:RTCClockSource])
        
        # logSeverity
        uhf_log_severity(@uhf_standard_properties[:logSeverity])

    end

    def set_beacon_packets()
        # telemetryOriginId_1
        uhf_telemetry_origin_id_1(@uhf_beacon_properties[:OriginID])
        
        # telemetryOriginPort_1
        uhf_origin_port_1(@uhf_beacon_properties[:OriginPort])
        
        # telemetryRequest_1
        uhf_telemetry_request_1(@uhf_beacon_properties[:TelemRequest])
        
        # telemetryMask_1
        uhf_telemetry_mask_1(@uhf_beacon_properties[:TelemMask])
        
        # telemetryOriginId_2
        uhf_telemetry_origin_id_2(@uhf_beacon_properties[:OriginID])
        
        # telemetryOriginPort_2
        uhf_origin_port_2(@uhf_beacon_properties[:OriginPort])
        
        # telemetryRequest_2
        uhf_telemetry_request_2(@uhf_beacon_properties[:TelemRequest])
        
        # telemetryMask_2
        uhf_telemetry_mask_2(@uhf_beacon_properties[:TelemMask])
        
        # telemetryOriginId_3
        uhf_telemetry_origin_id_3(@uhf_beacon_properties[:OriginID])
        
        # telemetryOriginPort_3
        uhf_telemetry_origin_port_3(@uhf_beacon_properties[:OriginPort])
        
        # telemetryRequest_3
        uhf_telemetry_request_3(@uhf_beacon_properties[:TelemRequest])
        
        # telemetryMask_3
        uhf_telemetry_mask_3(@uhf_beacon_properties[:TelemMask])
        
        # telemetryOriginId_4
        uhf_telemetry_origin_id_4(@uhf_beacon_properties[:OriginID])
        
        # telemetryOriginPort_4
        uhf_origin_port_4(@uhf_beacon_properties[:OriginPort])
        
        # telemetryRequest_4
        uhf_telemetry_request_4(@uhf_beacon_properties[:TelemRequest])
        
        # telemetryMask_4
        uhf_telemetry_mask_4(@uhf_beacon_properties[:TelemMask])
        
        # telemetryOriginId_5
        uhf_telemetry_origin_id_5(@uhf_beacon_properties[:OriginID])
        
        # telemetryOriginPort_5
        uhf_origin_port_5(@uhf_beacon_properties[:OriginPort])
        
        # telemetryRequest_5
        uhf_telemetry_request_5(@uhf_beacon_properties[:TelemRequest])
        
        # telemetryMask_5
        uhf_telemetry_mask_5(@uhf_beacon_properties[:TelemMask])
        
        # telemetryOriginId_6
        uhf_telemetry_origin_id_6(@uhf_beacon_properties[:OriginID])
        
        # telemetryOriginPort_6
        uhf_origin_port_6(@uhf_beacon_properties[:OriginPort])
        
        # telemetryRequest_6
        uhf_telemetry_request_6(@uhf_beacon_properties[:TelemRequest])
        
        # telemetryMask_6
        uhf_telemetry_mask_6(@uhf_beacon_properties[:TelemMask])
        
        # telemetryOriginId_7
        uhf_telemetry_origin_id_7(@uhf_beacon_properties[:OriginID])
        
        # telemetryOriginPort_7
        uhf_origin_port_7(@uhf_beacon_properties[:OriginPort])
        
        # telemetryRequest_7
        uhf_telemetry_request_7(@uhf_beacon_properties[:TelemRequest])
        
        # telemetryMask_7
        uhf_telemetry_mask_7(@uhf_beacon_properties[:TelemMask])
        
        # telemetryOriginId_8
        uhf_telemetry_origin_id_8(@uhf_beacon_properties[:OriginID])
        
        # telemetryOriginPort_8
        uhf_origin_port_8(@uhf_beacon_properties[:OriginPort])
        
        # telemetryRequest_8
        uhf_telemetry_request_8(@uhf_beacon_properties[:TelemRequest])
        
        # telemetryMask_8
        uhf_telemetry_mask_8(@uhf_beacon_properties[:TelemMask])
        

        
    end

    def read_config_file(file_path)

        yaml_data = YAML.load_file(file_path)

        yaml_data = YAML.load_file(file_path)
        config_data = yaml_data["config"]
        save_location = yaml_data["save_location"]
        access_level = yaml_data["highest_access_role"]
        
        return config_data, save_location, access_level
    end

    def set_config_from_file(file_path)

        config_data, save_location, access_level = read_config_file(file_path)

        # Elevate access level
        #-------------------------------------------------------------

        password = ask("Input UHF #{access_level} Password")
        cmd_params = {"ROLE": access_level,
                    "PASSWORD": password} 
        @cmd_sender.send("UHF", "FSW_ELEVATE_ACCESS_ROLE", cmd_params)

        # Load the configuration
        #-------------------------------------------------------------
        @cmd_sender.send("UHF", "FSW_LOAD_#{save_location}_FILE_TO_ACTIVE", {})

        # Set the config
        #-------------------------------------------------------------
        # Loop through and set the config parameter
        config_data.each do |config|
            #puts c[0] + " with value " + c[1].to_s

            if config[0] == "Radio Encryption Key" || config[0] == "Radio Encryption IV" || config[0].include?("telemetry_request") || config[0].include?("telemetry_mask")
                config[1] = hex_string_to_config(config[1])
            end
            puts "Setting #{config[0]} to #{config[1]}"
            method = "uhf_" + config[0].downcase.tr(" ", "_")
                        
            public_send(method, config[1])
            
        end

        # Save to the correct location
        #-------------------------------------------------------------
        if save_location == "FALLBACK"
            uhf_save_active_to_fallback()
        elsif save_location == "MAIN"
            uhf_save_active_to_main()
        end

        # Set access back to user
        #-------------------------------------------------------------
        cmd_params = {"ROLE": "USER",
        "PASSWORD": password} 
        @cmd_sender.send("UHF", "FSW_ELEVATE_ACCESS_ROLE", cmd_params)

    end

    def check_config_against_file(file_path, location)

        # Read the file
        config_values = read_config_file(file_path)

        fail_count = 0
        @uhf_property_list.each do|config|

            type = @config_property_IDs.index(config[:Type])

            value_raw = read_config_parameter(config[:ID], type, location)
            value_converted = convert_value(value_raw, type)

            Cosmos::Test.puts("#{config[:Name]} #{location}")

            if !config_values[config[:Name]].nil?
                
                if value_converted == config_values[config[:Name]]
                    Cosmos::Test.puts("Check Passed")
                else
                    Cosmos::Test.puts("Check Failed")
                    fail_count +=1
                end

            else
                Cosmos::Test.puts("No value to check against defined")
            end

            Cosmos::Test.puts("Raw: #{value_raw}")
            Cosmos::Test.puts("Converted: #{value_converted}")

            Cosmos::Test.puts("")

        end

        Cosmos::Test.puts("Checking Configuration completed with #{fail_count} failures")

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