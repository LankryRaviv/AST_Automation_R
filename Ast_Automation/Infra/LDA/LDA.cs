namespace Infra.LDA
{
    public static class LDA
    {
        private static LabBrickWrapper _labBrickWrapper;
        private static bool _ldaIsOpen = false;
        private static int _numberOfDevices = 0;

        #region LDA Initialize 
        public static void InitLDA()
        {
            _labBrickWrapper = new LabBrickWrapper();
            SetLDATestMode(false);
        }
        #endregion


        public static void SetLDATestMode(bool mode)
        {
            _labBrickWrapper.SetTestMode(mode);
        }
    }
}
