using System;
using SnmpSharpNet;
using System.Net;
using static Infra.Logger.Logger;
using System.Collections.Generic;

namespace Infra.Up_Down_Converter
{
    public class Converter
    {
        private readonly string _ip;
        private readonly int _port;
        private readonly string _name;
        public const string OutputOnOff = "5.3.1.1.1";
        public const string BandIndex = "5.3.1.1.7";
        private Band _currentBand;

        UdpTarget _target;
        public Converter(string ip, string name)
        {
            _ip = ip;
            _port = 161;
            _name = name;
        }
   
        public Converter(List<object> initParams)
        {
            try
            {
                _ip = initParams[0].ToString();
                _port = 161;
                _name = initParams[1].ToString();
                Open();
            }
            catch(Exception ex)
            {
                Log.Error(ex);
            }
        }

        #region Open SNMP connection
        public bool Open()
        {
            try
            {
                Log.Info($"SNMP Connection for: {_name} ,[IP] = {_ip} , [Port] = {_port}");
                _target = new UdpTarget((IPAddress)new IpAddress(_ip), _port, 6000, 1);
            }
            catch (Exception ex)
            {
                Log.Error(ex);
                throw;
            }
            return true;
        }
        #endregion

        #region Set by oid  , value
        private void Set(string oid, string value)
        {
            string startOfOid = "1.3.6.1.4.1.29890.1.";
            string fullOid = startOfOid + oid + ".0";
            Pdu pdu = new Pdu(PduType.Set);
            pdu.VbList.Add(new Oid(fullOid), new Integer32(value));
            AgentParameters agentParameters = new AgentParameters(SnmpVersion.Ver2, new OctetString("private"));
            SnmpV2Packet response;
            try
            {
                response = _target.Request(pdu, agentParameters) as SnmpV2Packet;
            }
            catch (Exception ex)
            {
                Log.Error(ex);
                throw;
            }

            Log.Info($"Oid is: {fullOid}, Set Value is: {value}");

            if (response.Pdu.ErrorStatus != 0)
            {
                Log.Error(String.Format("SNMP agent returned ErrorStatus {0} on index {1}",
                                         response.Pdu.ErrorStatus, response.Pdu.ErrorIndex));
            }
            else
            {
                Log.Info(String.Format("SNMP agent returned ErrorStatus {0} on index {1}",
                                        response.Pdu.ErrorStatus, response.Pdu.ErrorIndex));
            }
        }
        #endregion

        #region Get by oid
        private string Get(string oid)
        {
            try
            {
                string startOfOid = "1.3.6.1.4.1.29890.1.";
                string fullOid = startOfOid + oid + ".0";
                OctetString community = new OctetString("public");
                AgentParameters param = new AgentParameters(community);
                param.Version = SnmpVersion.Ver2;
                Pdu pdu = new Pdu(PduType.Get);
                pdu.VbList.Add(fullOid);
                SnmpV2Packet result = (SnmpV2Packet)_target.Request(pdu, param);
                Log.Info($"Oid is: {fullOid}");

                if (result != null)
                {
                    if (result.Pdu.ErrorStatus != 0)
                    {

                        Log.Error($"Error in SNMP reply. Error {result.Pdu.ErrorStatus} index {result.Pdu.ErrorIndex}");
                    }
                    else
                    {
                        Log.Info($"Return value type: {result.Pdu.VbList[0].Value.Type} ,Value:{result.Pdu.VbList[0].Value.ToString()}");
                    }

                    return result.Pdu.VbList[0].Value.ToString();
                }
            }
            catch (Exception ex)
            {
                Log.Error(ex);
                throw;
            }

            return null;
        }
        #endregion

        #region Select conveter band
        public bool SelectBand(Band band)
        {
            _currentBand = band;
            Log.Info($"The selected band is: {band}");
            return SetAndValidate(BandIndex, ((int)band).ToString());
        }
        #endregion

        #region Sum conveters LOs
        public double SumLOs()
        {
            var sumOfLOs = GetLOsOidByBand(_currentBand);
            Log.Info($"The sum of {_name} LOs is: {sumOfLOs}");
            return sumOfLOs;
        }
        #endregion

        #region Change output ON/OFF
        public bool SetOutput(OutputValue output)
        {
            Log.Info($"Set output = {output}");
            return SetAndValidate(OutputOnOff, ((int)output).ToString());
        }
        #endregion

        #region sum LOs by selected band
        private double GetLOsOidByBand(Band band)
        {
            string lo1Oid = string.Empty;
            string lo2Oid = string.Empty;
            try
            {

                switch (band)
                {
                    case Band.Band1:
                        {
                            lo1Oid = "5.3.1.1.8.5";
                            lo2Oid = "5.3.1.1.8.6";
                            break;
                        }
                    case Band.Band2:
                        {
                            lo1Oid = "5.3.1.1.9.5";
                            lo2Oid = "5.3.1.1.9.6";
                            break;
                        }
                    case Band.Band3:
                        {
                            lo1Oid = "5.3.1.1.10.5";
                            lo2Oid = "5.3.1.1.10.6";
                            break;
                        }
                }

                var sum = double.Parse(Get(lo1Oid));
                if (_name.Equals("Up Converter"))
                {
                    sum += double.Parse(Get(lo2Oid));
                }

                sum += 3000;

                return sum;
            }
            catch (Exception ex)
            {
                Log.Error(ex);
                throw;
            }
        }
        #endregion

        #region Set and validate
        public bool SetAndValidate(string oid, string value)
        {
            Log.Info($"Set and validate , Expected result: {value}");
            Set(oid, value);
            return Get(oid).Equals(value);
        }
        #endregion

        #region Close SNMP connection
        public bool Close()
        {
            try
            {
                _target.Close();
                Log.Info("Connection with converter is closed");
            }
            catch (Exception ex)
            {
                Log.Error(ex);
                throw;
            }
            return true;
        }
        #endregion

        public enum Band
        {
            Band1 = 0,
            Band2,
            Band3
        }

        public enum OutputValue
        {
            OFF = 0,
            ON
        }
    }
}
