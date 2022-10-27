using System.Runtime.InteropServices;

namespace Infra.LDA
{
    public class LabBrickWrapper
    {
        // The dll imports

        private const string DllPath = "./VNX_atten64.dll";

        [DllImport(DllPath, EntryPoint = "fnLDA_SetTraceLevel")]
        public static extern void fnLDA_SetTraceLevel(int tracelevel, int IOtracelevel, bool verbose);

        [DllImport(DllPath, EntryPoint = "fnLDA_SetTestMode")]
        public static extern void fnLDA_SetTestMode(bool mode);

        [DllImport(DllPath, EntryPoint = "fnLDA_GetNumDevices")]
        public static extern int fnLDA_GetNumDevices();

        [DllImport(DllPath, EntryPoint = "fnLDA_GetDevInfo")]
        public static extern int fnLDA_GetDevInfo([In, Out] uint[] ActiveDevices);

        [DllImport(DllPath, EntryPoint = "fnLDA_GetModelNameA")]
        public static extern int fnLDA_GetModelNameA(uint deviceID, [In, Out] byte[] ModelName);

 //       [DllImport(DllPath, EntryPoint = "fnLDA_GetModelNameW")]
 //       static extern int fnLDA_GetModelNameW(uint deviceID, [In, Out] char[] ModelName);
 //       RD -- this function is not correctly named in some versions of the DLL

        [DllImport(DllPath, EntryPoint = "fnLDA_InitDevice")]
        public static extern int fnLDA_InitDevice(uint deviceID);

        [DllImport(DllPath, EntryPoint = "fnLDA_CloseDevice")]
        public static extern int fnLDA_CloseDevice(uint deviceID);

        [DllImport(DllPath, EntryPoint = "fnLDA_GetSerialNumber")]
        public static extern int fnLDA_GetSerialNumber(uint deviceID);

        [DllImport(DllPath, EntryPoint = "fnLDA_GetDLLVersion")]
        public static extern int fnLDA_GetDLLVersion();

        [DllImport(DllPath, EntryPoint = "fnLDA_GetDeviceStatus")]
        public static extern int fnLDA_GetDeviceStatus(uint deviceID);

        [DllImport(DllPath, EntryPoint = "fnLDA_SetChannel")]
        public static extern int fnLDA_SetChannel(uint deviceID, int channel);

        [DllImport(DllPath, EntryPoint = "fnLDA_SetWorkingFrequency")]
        public static extern int fnLDA_SetWorkingFrequency(uint deviceID, int frequency);

        [DllImport(DllPath, EntryPoint = "fnLDA_SetAttenuation")]
        public static extern int fnLDA_SetAttenuation(uint deviceID, int attenuation);

        [DllImport(DllPath, EntryPoint = "fnLDA_SetAttenuationHR")]
        public static extern int fnLDA_SetAttenuationHR(uint deviceID, int attenuation);

        [DllImport(DllPath, EntryPoint = "fnLDA_SetAttenuationHRQ")]
        public static extern int fnLDA_SetAttenuationHRQ(uint deviceID, int attenuation, int channel);

        [DllImport(DllPath, EntryPoint = "fnLDA_SetRampStart")]
        public static extern int fnLDA_SetRampStart(uint deviceID, int rampstart);

        [DllImport(DllPath, EntryPoint = "fnLDA_SetRampStartHR")]
        public static extern int fnLDA_SetRampStartHR(uint deviceID, int rampstart);

        [DllImport(DllPath, EntryPoint = "fnLDA_SetRampEnd")]
        public static extern int fnLDA_SetRampEnd(uint deviceID, int rampstop);

        [DllImport(DllPath, EntryPoint = "fnLDA_SetRampEndHR")]
        public static extern int fnLDA_SetRampEndHR(uint deviceID, int rampstop);

        [DllImport(DllPath, EntryPoint = "nLDA_SetAttenuationStep")]
        public static extern int nLDA_SetAttenuationStep(uint deviceID, int attenuationstep);

        [DllImport(DllPath, EntryPoint = "nLDA_SetAttenuationStepHR")]
        public static extern int nLDA_SetAttenuationStepHR(uint deviceID, int attenuationstep);

        [DllImport(DllPath, EntryPoint = "fnLDA_SetAttenuationStepTwo")]
        public static extern int fnLDA_SetAttenuationStepTwo(uint deviceID, int attenuationstep2);

        [DllImport(DllPath, EntryPoint = "fnLDA_SetAttenuationStepTwoHR")]
        public static extern int fnLDA_SetAttenuationStepTwoHR(uint deviceID, int attenuationstep2);

        [DllImport(DllPath, EntryPoint = "fnLDA_SetDwellTime")]
        public static extern int fnLDA_SetDwellTime(uint deviceID, int dwelltime);

        [DllImport(DllPath, EntryPoint = "fnLDA_SetDwellTimeTwo")]
        public static extern int fnLDA_SetDwellTimeTwo(uint deviceID, int dwelltime2);

        [DllImport(DllPath, EntryPoint = "fnLDA_SetIdleTime")]
        public static extern int fnLDA_SetIdleTime(uint deviceID, int idletime);

        [DllImport(DllPath, EntryPoint = "fnLDA_SetHoldTime")]
        public static extern int fnLDA_SetHoldTime(uint deviceID, int holdtime);

        [DllImport(DllPath, EntryPoint = "fnLDA_SetProfileElement")]
        public static extern int fnLDA_SetProfileElement(uint deviceID, int index, int attenuation);

        [DllImport(DllPath, EntryPoint = "fnLDA_SetProfileElementHR")]
        public static extern int fnLDA_SetProfileElementHR(uint deviceID, int index, int attenuation);

        [DllImport(DllPath, EntryPoint = "fnLDA_SetProfileCount")]
        public static extern int fnLDA_SetProfileCount(uint deviceID, int profilecount);

        [DllImport(DllPath, EntryPoint = "fnLDA_SetProfileIdleTime")]
        public static extern int fnLDA_SetProfileIdleTime(uint deviceID, int idletime);

        [DllImport(DllPath, EntryPoint = "fnLDA_SetProfileDwellTime")]
        public static extern int fnLDA_SetProfileDwellTime(uint deviceID, int dwelltime);

        [DllImport(DllPath, EntryPoint = "fnLDA_StartProfile")]
        public static extern int fnLDA_StartProfile(uint deviceID, int mode);

        [DllImport(DllPath, EntryPoint = "fnLDA_SetRFOn")]
        public static extern int fnLDA_SetRFOn(uint deviceID, bool on);

        [DllImport(DllPath, EntryPoint = "fnLDA_SetRampDirection")]
        public static extern int fnLDA_SetRampDirection(uint deviceID, bool up);

        [DllImport(DllPath, EntryPoint = "fnLDA_SetRampMode")]
        public static extern int fnLDA_SetRampMode(uint deviceID, bool mode);

        [DllImport(DllPath, EntryPoint = "fnLDA_SetRampBidirectional")]
        public static extern int fnLDA_SetRampBidirectional(uint deviceID, bool bidir_enable);

        [DllImport(DllPath, EntryPoint = "fnLDA_StartRamp")]
        public static extern int fnLDA_StartRamp(uint deviceID, bool go);

        [DllImport(DllPath, EntryPoint = "fnLDA_SaveSettings")]
        public static extern int fnLDA_SaveSettings(uint deviceID);

        [DllImport(DllPath, EntryPoint = "fnLDA_GetWorkingFrequency")]
        public static extern int fnLDA_GetWorkingFrequency(uint deviceID);

        [DllImport(DllPath, EntryPoint = "fnLDA_GetMinWorkingFrequency")]
        public static extern int fnLDA_GetMinWorkingFrequency(uint deviceID);

        [DllImport(DllPath, EntryPoint = "fnLDA_GetMaxWorkingFrequency")]
        public static extern int fnLDA_GetMaxWorkingFrequency(uint deviceID);

        [DllImport(DllPath, EntryPoint = "fnLDA_GetAttenuation")]
        public static extern int fnLDA_GetAttenuation(uint deviceID);

        [DllImport(DllPath, EntryPoint = "fnLDA_GetAttenuationHR")]
        public static extern int fnLDA_GetAttenuationHR(uint deviceID);

        [DllImport(DllPath, EntryPoint = "fnLDA_GetRampStart")]
        public static extern int fnLDA_GetRampStart(uint deviceID);

        [DllImport(DllPath, EntryPoint = "fnLDA_GetRampStartHR")]
        public static extern int fnLDA_GetRampStartHR(uint deviceID);

        [DllImport(DllPath, EntryPoint = "fnLDA_GetRampEnd")]
        public static extern int fnLDA_GetRampEnd(uint deviceID);

        [DllImport(DllPath, EntryPoint = "fnLDA_getRampEndHR")]
        public static extern int fnLDA_GetRampEndHR(uint deviceID);

        [DllImport(DllPath, EntryPoint = "nLDA_GetAttenuationStep")]
        public static extern int nLDA_GetAttenuationStep(uint deviceID);

        [DllImport(DllPath, EntryPoint = "nLDA_GetAttenuationStepHR")]
        public static extern int nLDA_GetAttenuationStepHR(uint deviceID);

        [DllImport(DllPath, EntryPoint = "fnLDA_GetAttenuationStepTwo")]
        public static extern int fnLDA_GetAttenuationStepTwo(uint deviceID);

        [DllImport(DllPath, EntryPoint = "fnLDA_GetAttenuationStepTwoHR")]
        public static extern int fnLDA_GetAttenuationStepTwoHR(uint deviceID);

        [DllImport(DllPath, EntryPoint = "fnLDA_GetDwellTime")]
        public static extern int fnLDA_GetDwellTime(uint deviceID);

        [DllImport(DllPath, EntryPoint = "fnLDA_GetDwellTimeTwo")]
        public static extern int fnLDA_GetDwellTimeTwo(uint deviceID);

        [DllImport(DllPath, EntryPoint = "fnLDA_GetIdleTime")]
        public static extern int fnLDA_GetIdleTime(uint deviceID);

        [DllImport(DllPath, EntryPoint = "fnLDA_GetHoldTime")]
        public static extern int fnLDA_GetHoldTime(uint deviceID);

        [DllImport(DllPath, EntryPoint = "fnLDA_GetProfileElement")]
        public static extern int fnLDA_GetProfileElement(uint deviceID, int index);

        [DllImport(DllPath, EntryPoint = "fnLDA_GetProfileElementHR")]
        public static extern int fnLDA_GetProfileElementHR(uint deviceID, int index);

        [DllImport(DllPath, EntryPoint = "fnLDA_GetProfileCount")]
        public static extern int fnLDA_GetProfileCount(uint deviceID);

        [DllImport(DllPath, EntryPoint = "fnLDA_GetProfileIdleTime")]
        public static extern int fnLDA_GetProfileIdleTime(uint deviceID);

        [DllImport(DllPath, EntryPoint = "fnLDA_GetProfileDwellTime")]
        public static extern int fnLDA_GetProfileDwellTime(uint deviceID);

        [DllImport(DllPath, EntryPoint = "fnLDA_GetProfileIndex")]
        public static extern int fnLDA_GetProfileIndex(uint deviceID);

        [DllImport(DllPath, EntryPoint = "fnLDA_GetRFOn")]
        public static extern int fnLDA_GetRFOn(uint deviceID);

        [DllImport(DllPath, EntryPoint = "fnLDA_GetMaxAttenuation")]
        public static extern int fnLDA_GetMaxAttenuation(uint deviceID);

        [DllImport(DllPath, EntryPoint = "fnLDA_GetMaxAttenuationHR")]
        public static extern int fnLDA_GetMaxAttenuationHR(uint deviceID);

        [DllImport(DllPath, EntryPoint = "fnLDA_GetMinAttenuation")]
        public static extern int fnLDA_GetMinAttenuation(uint deviceID);

        [DllImport(DllPath, EntryPoint = "fnLDA_GetMinAttenuationHR")]
        public static extern int fnLDA_GetMinAttenuationHR(uint deviceID);

        [DllImport(DllPath, EntryPoint = "fnLDA_GetMinAttenStep")]
        public static extern int fnLDA_GetMinAttenStep(uint deviceID);

        [DllImport(DllPath, EntryPoint = "fnLDA_GetMinAttenStepHR")]
        public static extern int fnLDA_GetMinAttenStepHR(uint deviceID);

        [DllImport(DllPath, EntryPoint = "fnLDA_GetFeatures")]
        public static extern int fnLDA_GetFeatures(uint deviceID);

        [DllImport(DllPath, EntryPoint = "fnLDA_GetNumChannels")]
        public static extern int fnLDA_GetNumChannels(uint deviceID);

        // -- Variables --

        // an array to store handles for every LDA device we find
        public uint[] MyDevices = new uint[64];




        // -- Examples of Customized Methods --

        public void SetTraceLevel(int tracelevel, int IOtracelevel, bool verbose)
        {
            fnLDA_SetTraceLevel(tracelevel, IOtracelevel, verbose);
        }

        public void SetTestMode(bool mode)
        {
            fnLDA_SetTestMode(mode);
        }

        public int GetNumberOfDevices()
        {
            return fnLDA_GetNumDevices();
        }

        // -- GetDevices returns the number of devices found and a set of deviceID handles in MyDevices
        //    by allocating the array of deviceID handles in this class it will be created and destroyed without
        //    higher level code managing it.

        public int GetDevices()
        {
            return fnLDA_GetDevInfo(MyDevices);
        }

        public int GetModelNameA(uint deviceID, byte[] ModelName)
        {
            return fnLDA_GetModelNameA(deviceID, ModelName); 
        }

        public int InitDevice(uint deviceID)
        {
            return fnLDA_InitDevice(deviceID);
        }

        public int CloseDevice(uint deviceID)
        {
            return fnLDA_CloseDevice(deviceID);
        }

        public int GetSerialNumber(uint deviceID)
        {
            return fnLDA_GetSerialNumber(deviceID);
        }

        public int GetDLLVersion()
        {
            return fnLDA_GetDLLVersion();
        }

        public int GetDeviceStatus(uint deviceID)
        {
            return fnLDA_GetDeviceStatus(deviceID);
        }

        // This is an example of adding functionality to the wrapper class
        public int SetAttenuationInDb(uint deviceID, float attenuation)
        {
            return fnLDA_SetAttenuationHR(deviceID, (int)(attenuation * 20));
        }

        public int SetAttenuationHR(uint deviceID, int attenuation)
        {
            return fnLDA_SetAttenuationHR(deviceID, attenuation);
        }

        public int GetAttenuationHR(uint deviceID)
        {
            return fnLDA_GetAttenuationHR(deviceID);
        }

        public int SetWorkingFrequency(uint deviceID, int frequency)
        {
            return fnLDA_SetWorkingFrequency(deviceID, frequency);
        }







    }
}
