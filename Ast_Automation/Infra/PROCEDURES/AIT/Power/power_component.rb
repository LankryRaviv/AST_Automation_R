load_utility('Operations/EPS/EPS_PCDU')
load_utility('Operations/FSW/FSW_Telem')

# Step 1 - Turn on telem
telem = ModuleTelem.new
realtime_destination = 'COSMOS_UMBILICAL'
telem.set_realtime("APC_YP", "FSW_TLM_APC", realtime_destination, 1)
telem.set_realtime("APC_YP", "POWER_PCDU_LVC_TLM", realtime_destination, 1)
telem.set_realtime("APC_YP", "POWER_CSBATS_TLM", realtime_destination, 1)

# Step 2 - Get component
component = combo_box("Component Name?", "RWA_YP0_Z", "RWA_YM0_Z", "RWA_YP1_X", "RWA_YM1_X", "ROD_POS", "ROD_NEG", "ST_XP", "ST_XM", "HDRM_MICRON_XM_P1", "HDRM_MICRON_XM_P2", "HDRM_MICRON_XM_P3", "HDRM_MICRON_XM_P4", "HDRM_MICRON_XM_R1", "HDRM_MICRON_XM_R2", "HDRM_MICRON_XM_R3", "HDRM_MICRON_XM_R4", "HDRM_MICRON_XP_P1", "HDRM_MICRON_XP_P2", "HDRM_MICRON_XP_P3", "HDRM_MICRON_XP_P4", "HDRM_MICRON_XP_R1", "HDRM_MICRON_XP_R2", "HDRM_MICRON_XP_R3", "HDRM_MICRON_XP_R4", "HDRM_LVA_P1", "HDRM_LVA_P2", "HDRM_LVA_P3", "HDRM_LVA_R1", "HDRM_LVA_R2", "HDRM_LVA_R3", "UHF_NADIR_V28_A", "UHF_NADIR_V5_B", "QVA_SW_RX", "QVA_SW_TX", "QVA_YM_V28", "QVA_YP_V28", "QVA_YM_V5", "QVA_YP_V5", "QVA_YM_V12", "QVA_YP_V12", "QV_TRANSCEIVER_YM_5V", "QV_TRANSCEIVER_YP_5V", "QVA_YP_LNA_RH", "QVA_YP_LNA_LH", "QVA_YM_LNA_RH", "QVA_YM_LNA_LH", "QVA_YP_PA_RH", "QVA_YP_PA_LH", "QVA_YM_PA_RH", "QVA_YM_PA_LH", "SBAND_YM", "SBAND_YP", "POWER_SHARE_MICRON1", "POWER_SHARE_MICRON2", "POWER_SHARE_MICRON3", "POWER_SHARE_MICRON4", "POWER_SHARE_MICRON5", "POWER_SHARE_MICRON6", "POWER_SHARE_MICRON7", "POWER_SHARE_MICRON8", "HEATER_SSYPXM_SSYPXP", "HEATER_CAMYPXM_CAMYPXP", "TTC_SW_SBAND", "TTC_SW_UHF", "HEATER_SSYMXM_SSYMXP", "HEATER_CAMYMXM_CAMYMXP", "HEATER_GPSXM_GPSYM", "HEATER_EIGHT", "BFCP_XP", "BFCP_XM", "QV_TRANSCEIVER_YM_12V", "QV_TRANSCEIVER_YP_12V", "UHF_NADIR_V28_B", "UHF_NADIR_V5_A", "LVC_BACKUP_12V_YM", "LVC_BACKUP_12V_YP")

# Step 3 - Get Value
val = combo_box("Turn on or off?", "ON", "OFF")
if val == "ON"
    val = 1
elsif val == "OFF"
    val = 0
else
    wait
end

# Step 4 - Construct method name
method_name = "set_#{component}"
pcdu = PCDU.new

pcdu.public_send(method_name, "APC_YP", val)




