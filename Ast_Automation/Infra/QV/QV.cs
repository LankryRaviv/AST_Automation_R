using System;
using System.Collections.Generic;
using System.IO;
using System.Threading;
using ComLib;
using Newtonsoft.Json;
using SerialComLib;
using System.Reflection;

namespace Infra.QV
{
    public class QV : AppCallback
    {
        private static string _appFolder = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location);
        private static IComObj _comObj;
        private static SerialComObj _serialComObj;
        private static object commandListMutex = new object();
        private static bool _allLocked = true;
        private static string _comPort;
        public QV(string comport)
        {
            _comPort = comport;
        }

        public QV(List<object> initParams)
        {
            try
            {
                _comPort = initParams[0].ToString();
                //OpenPort();
            }
            catch (Exception ex)
            {
                Logger.Logger.Log.Error(ex);
                throw;
            }
        }

        #region Open QV Port and config from file
        public bool OpenPort()
        {
            try
            {
                Logger.Logger.Log.Info($"Try to open connection with QV - ComPort: {_comPort}");
                _serialComObj = new SerialComObj(this, 0);
                _serialComObj.set_port(_comPort.Trim());
                _comObj = _serialComObj;
                if (!_comObj.OpenConnection())
                {
                    Logger.Logger.Log.Error("Device Not Found");
                    return false;
                }
                Logger.Logger.Log.Info($"Connection to QV success");
            }
            catch (Exception ex)
            {
                Logger.Logger.Log.Error(ex);
                throw;
            }

            Thread.Sleep(5000);
            return true;
        }
        #endregion

        #region Close Port
        public bool Close()
        {
            try
            {
                if (_comObj != null && _comObj.IsOpen)
                {
                    Logger.Logger.Log.Info("Closing connection with QV");
                    _comObj.Close();
                }
            }
            catch (Exception ex)
            {
                Logger.Logger.Log.Error(ex);
                return false;
            }

            return true;
        }
        #endregion

        #region Load QV Config File
        public bool ConfigQV(string configFilePath)
        {
            var allMessageSent = true;
            string path = _appFolder + configFilePath;
            try
            {
                Dictionary<string, object> points = new Dictionary<string, object>();
                var text = File.ReadAllText(path);
                points = JsonConvert.DeserializeObject<Dictionary<string, object>>(text);
                state _state = new state();
                _state.val = (bool)points["chk_rx_frontend_enable"];
                allMessageSent &= SendCommand(Commands.cmd_set_rx_frontend_enable, _state);

                _state.val = (bool)points["chk_lo_rx_amp_en"];
                allMessageSent &= SendCommand(Commands.cmd_set_lo_rx_amp_en, _state);

                _state.val = (bool)points["chk_higher_if_rx_en"];
                allMessageSent &= SendCommand(Commands.cmd_set_higher_if_rx_en, _state);

                _state.val = (bool)points["chk_if_rx_en"];
                allMessageSent &= SendCommand(Commands.cmd_set_if_rx_en, _state);

                _state.val = (bool)points["chk_lo_rx_on"];
                allMessageSent &= SendCommand(Commands.cmd_set_lo_rx_on, _state);

                _state.val = (bool)points["chk_lo_tx_on"];
                allMessageSent &= SendCommand(Commands.cmd_set_lo_tx_on, _state);

                _state.val = (bool)points["chk_lo_tx_amp_en"];
                allMessageSent &= SendCommand(Commands.cmd_set_lo_tx_amp_en, _state);

                _state.val = (bool)points["chk_tx_detection_en"];
                allMessageSent &= SendCommand(Commands.cmd_set_tx_detection_on, _state);

                _state.val = (bool)points["chk_if_tx_en"];
                allMessageSent &= SendCommand(Commands.cmd_set_if_tx_en, _state);

                _state.val = (bool)points["chk_higher_if_tx_en"];
                allMessageSent &= SendCommand(Commands.cmd_set_higher_if_tx_en, _state);

                _state.val = (bool)points["chk_tx_frontend_enable"];
                allMessageSent &= SendCommand(Commands.cmd_set_tx_frontend_enable, _state);

                _state.val = (bool)points["chk_lo_if_low_en"];
                allMessageSent &= SendCommand(Commands.cmd_set_lo_if_low_en, _state);

                _state.val = (bool)points["chk_lo_if_mid_en"];
                allMessageSent &= SendCommand(Commands.cmd_set_lo_if_mid_en, _state);

                _state.val = (bool)points["chk_lo_if_high_en"];
                allMessageSent &= SendCommand(Commands.cmd_set_lo_if_high_en, _state);

                dca _dca_state = new dca();
                _dca_state.val = Convert.ToDecimal(points["num_dca_rx"]);
                allMessageSent &= SendCommand(Commands.cmd_set_dca_rx, _dca_state);

                _dca_state.val = Convert.ToDecimal(points["num_dca_tx"]);
                allMessageSent &= SendCommand(Commands.cmd_set_dca_tx, _dca_state);

                _dca_state.val = Convert.ToDecimal(points["num_dca_if_low"]);
                allMessageSent &= SendCommand(Commands.cmd_set_dca_if_low, _dca_state);

                _dca_state.val = Convert.ToDecimal(points["num_dca_if_mid"]);
                allMessageSent &= SendCommand(Commands.cmd_set_dca_if_mid, _dca_state);

                _dca_state.val = Convert.ToDecimal(points["num_dca_if_high"]);
                allMessageSent &= SendCommand(Commands.cmd_set_dca_if_high, _dca_state);

                pll _pll_state = new pll();
                _pll_state.freq_Mhz = Convert.ToDecimal(points["num_pll_rx"]);
                allMessageSent &= SendCommand(Commands.cmd_set_pll_rx_freq, _pll_state);

                _pll_state.freq_Mhz = Convert.ToDecimal(points["num_pll_tx"]);
                allMessageSent &= SendCommand(Commands.cmd_set_pll_tx_freq, _pll_state);

                _pll_state.freq_Mhz = Convert.ToDecimal(points["num_pll_low_if"]);
                allMessageSent &= SendCommand(Commands.cmd_set_pll_low_if_freq, _pll_state);

                _pll_state.freq_Mhz = Convert.ToDecimal(points["num_pll_mid_if"]);
                allMessageSent &= SendCommand(Commands.cmd_set_pll_mid_if_freq, _pll_state);

                _pll_state.freq_Mhz = Convert.ToDecimal(points["num_pll_high_if"]);
                allMessageSent &= SendCommand(Commands.cmd_set_pll_high_if_freq, _pll_state);

            }
            catch (Exception ex)
            {
                Logger.Logger.Log.Error(ex);
                return false;
            }

            Thread.Sleep(5000);
            return allMessageSent;
        }
        #endregion

        #region Send Commands

        private static bool SendCommand(Commands command, MessageBase data)
        {
            return SendCommand(command, data, false);
        }

        private static bool SendCommand(Commands command, MessageBase data, bool wait)
        {
            AppMessage message = new AppMessage(command, data);
            try
            {
                Logger.Logger.Log.Info($"Send: {message.ToString()} to QV.");
                message.Write();
                byte[] bytes = message.ToBytes();

                if (!_comObj.Write(bytes, wait))
                {
                    Logger.Logger.Log.Info("QV Timeout");
                    return false;
                }
            }
            catch (Exception ex)
            {
                Logger.Logger.Log.Error($"Opcode: {message.Opcode}, {ex}");
                return false;
            }

            return true;
        }

        private static bool SendCommand(Commands command)
        {
            return SendCommand(command, null, false);
        }

        public static void GetAllStatus()
        {
            SendCommand(Commands.cmd_get_full_status);
            CommandList cmd = new CommandList(30);
            cmd.AddCommand(Commands.cmd_get_fw_ver);
            cmd.AddCommand(Commands.cmd_get_serial_number);
            cmd.AddCommand(Commands.cmd_get_full_status);
            cmd.AddCommand(Commands.cmd_get_rx_frontend_enable);
            cmd.AddCommand(Commands.cmd_get_higher_if_rx_en);
            cmd.AddCommand(Commands.cmd_get_lo_tx_amp_en);
            cmd.AddCommand(Commands.cmd_get_tx_frontend_enable);
            cmd.AddCommand(Commands.cmd_get_higher_if_tx_en);
            cmd.AddCommand(Commands.cmd_get_clock_ext_int);
            cmd.AddCommand(Commands.cmd_get_lo_rx_amp_en);
            cmd.AddCommand(Commands.cmd_get_if_rx_en);
            cmd.AddCommand(Commands.cmd_get_if_tx_en);
            cmd.AddCommand(Commands.cmd_get_lo_if_low_en);
            cmd.AddCommand(Commands.cmd_get_lo_if_mid_en);
            cmd.AddCommand(Commands.cmd_get_lo_if_high_en);
            cmd.AddCommand(Commands.cmd_get_dca_rx);
            cmd.AddCommand(Commands.cmd_get_dca_tx);
            cmd.AddCommand(Commands.cmd_get_tcxo_on);
            cmd.AddCommand(Commands.cmd_get_lo_rx_on);
            cmd.AddCommand(Commands.cmd_get_lo_tx_on);
            cmd.AddCommand(Commands.cmd_get_tx_detection_on);
            cmd.AddCommand(Commands.cmd_get_pll_rx_freq);
            cmd.AddCommand(Commands.cmd_get_pll_tx_freq);
            cmd.AddCommand(Commands.cmd_get_pll_low_if_freq);
            cmd.AddCommand(Commands.cmd_get_pll_mid_if_freq);
            cmd.AddCommand(Commands.cmd_get_pll_high_if_freq);
            cmd.AddCommand(Commands.cmd_get_dca_if_low);
            cmd.AddCommand(Commands.cmd_get_dca_if_mid);
            cmd.AddCommand(Commands.cmd_get_dca_if_high);
            SendCommandList(cmd);
        }

        private static void SendCommandList(CommandList cmd)
        {
            ThreadPool.QueueUserWorkItem(new WaitCallback(SendMultCommand), cmd);
        }

        private static void SendMultCommand(object cmd)
        {
            lock (commandListMutex)
            {
                try
                {
                    CommandList _cmd = (CommandList)cmd;

                    for (int i = 0; i < _cmd.Command.Length; i++)
                    {
                        if (_cmd.Command[i] != 0)
                            if (SendCommand(_cmd.Command[i], _cmd.Message[i], true) == false)
                                return;
                    }
                }
                catch (Exception ex)
                {
                    Logger.Logger.Log.Error(ex);
                }
            }
        }

        public void NewMessage(AppMessage message)
        {
            switch (message.Opcode)
            {
                case Commands.cmd_report_full_status:
                    HandleMessage(message.Payload as DeviceState);
                    break;
            }
        }

        private void HandleMessage(DeviceState data)
        {
            _allLocked = true;

            if (data.pll_tx_lock == 0)
            {
                _allLocked &= false;
                Log($"pll_tx_lock is not locked");
            }
            else
            {
                _allLocked &= true;
                Log($"pll_tx_lock is locked");

            }

            if (data.pll_rx_lock == 0)
            {
                _allLocked &= false;
                Log($"pll_rx_lock is not locked");

            }
            else
            {
                Log($"pll_rx_lock is locked");
                _allLocked &= true;
            }

            if (data.pll_low_if_lock == 0)
            {
                Log($"pll_low_if_lock is not locked");

                _allLocked &= false;
            }
            else
            {
                Log($"pll_low_if_lock is locked");

                _allLocked &= true;
            }

            if (data.pll_mid_if_lock == 0)
            {
                Log($"pll_mid_if_lock is not locked");

                _allLocked &= false;
            }
            else
            {
                Log($"pll_mid_if_lock is locked");

                _allLocked &= true;
            }

            if (data.pll_high_if_lock == 0)
            {
                Log($"pll_high_if_lock is not locked");

                _allLocked &= false;
            }
            else
            {
                Log($"pll_high_if_lock is locked");

                _allLocked &= true;
            }
        }

        public void OnError(string p)
        {
            Logger.Logger.Log.Error(p);
        }

        public void Log(string p)
        {
            Logger.Logger.Log.Info(p);
        }

        public void DeviceArrival(string sn)
        {
            throw new NotImplementedException();
        }

        public void DeviceRemove(string sn)
        {
            throw new NotImplementedException();
        }

        private struct CommandList
        {
            public Commands[] Command;
            public MessageBase[] Message;
            public int len;

            public CommandList(int count)
            {
                Command = new Commands[count];
                Message = new MessageBase[count];
                len = 0;
            }

            public void AddCommand(Commands cmd)
            {
                Command[len] = cmd;
                Message[len] = null;
                len++;
            }

            public void AddCommand(Commands cmd, MessageBase data)
            {
                Command[len] = cmd;
                Message[len] = data;
                len++;
            }
        }
        #endregion

        #region Verify All States Locked
        public bool AllLocked()
        {
            GetAllStatus();
            Thread.Sleep(2000);
            Log($"QV all locked = {_allLocked}");
            return _allLocked;
        }
        #endregion
    }
}
