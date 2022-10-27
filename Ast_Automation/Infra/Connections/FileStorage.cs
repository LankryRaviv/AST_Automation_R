using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml;
using System.IO;

namespace Infra.Connections
{
    public class FileStorage
    {
        public Dictionary<string, string> xmlgeneralNodesDic { get; set; }
        public Dictionary<string, string> xmlFPGANodesDic { get; set; }
        public Dictionary<string, string> xmlMBNodesDic { get; set; }
        public Dictionary<string, string> xmlGeneralFEMDNodesDic { get; set; }
        public Dictionary<string, string> xmlDSAPerFEMDUplinkNodesDic { get; set; }
        public Dictionary<string, string> xmlDSAPerFEMDDownlinkNodesDic { get; set; }
        public Boolean MBtoInclude;
        public Boolean FPGAtoInclude;
        public Boolean FEMDtoInclude;
        public Boolean DSAperFEMDtoInclude;
        XmlDocument doc;


        const string UNIVERSE_EMPTY_CONFIG = "..\\..\\Sources\\Configuration_XML\\UniverseConfigrationXML_empty.xml";
        public string UNIVERSE_CONFIG_XML_PATH = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "UniverseConfigrationXML.xml");

        public FileStorage()
        {
            doc = new XmlDocument();
            xmlgeneralNodesDic = new Dictionary<string, string>();
            xmlGeneralFEMDNodesDic = new Dictionary<string, string>();
            xmlDSAPerFEMDDownlinkNodesDic = new Dictionary<string, string>();
            xmlDSAPerFEMDUplinkNodesDic = new Dictionary<string, string>();
            xmlFPGANodesDic = new Dictionary<string, string>();
            xmlMBNodesDic = new Dictionary<string, string>();
        }

        public void load(string filePath)
        {
            loadDics(filePath);
        }

        public void loadDics(string filePath)
        {
            initXMLdocAndDics();
            if (!File.Exists(filePath))
            {
                File.Copy(UNIVERSE_EMPTY_CONFIG, UNIVERSE_CONFIG_XML_PATH);
                filePath = UNIVERSE_CONFIG_XML_PATH;
            }
            doc.Load(filePath);
            XmlNode root = doc.DocumentElement;
            XmlNode myNode = root.SelectSingleNode("descendant::general");
            loadSpecific(myNode, xmlgeneralNodesDic);

            myNode = root.SelectSingleNode("descendant::MainBoardConfig");
            string toIncludeMB = myNode.Attributes["toInclude"].Value;
            if (toIncludeMB == "true")
                MBtoInclude = true;
            else MBtoInclude = false;
            loadSpecific(myNode, xmlMBNodesDic);

            myNode = root.SelectSingleNode("descendant::FEMDConfig");
            string toIncludeFEMD = myNode.Attributes["toInclude"].Value;
            if (toIncludeFEMD == "true")
                FEMDtoInclude = true;
            else FEMDtoInclude = false;

            myNode = root.SelectSingleNode("descendant::generalFEMDS");
            loadSpecific(myNode, xmlGeneralFEMDNodesDic);

            myNode = root.SelectSingleNode("/configuration/FEMDConfig/dsaPerFEMD");
            string toIncludedsaPERFEMD = myNode.Attributes["toInclude"].Value;
            if (toIncludedsaPERFEMD == "true")
                DSAperFEMDtoInclude = true;
            else DSAperFEMDtoInclude = false;

            myNode = root.SelectSingleNode("descendant::uplink");
            loadSpecific(myNode, xmlDSAPerFEMDUplinkNodesDic);
            myNode = root.SelectSingleNode("descendant::downlink");
            loadSpecific(myNode, xmlDSAPerFEMDDownlinkNodesDic);

            myNode = root.SelectSingleNode("descendant::FPGAConfig");
            string toIncludeFPGA = myNode.Attributes["toInclude"].Value;
            if (toIncludeFPGA == "true")
                FPGAtoInclude = true;
            else FPGAtoInclude = false;
            loadSpecific(myNode, xmlFPGANodesDic);
        }


        public void initXMLdocAndDics()
        {
            doc = new XmlDocument();
            xmlgeneralNodesDic = new Dictionary<string, string>()
            { { "comPort","" }, {"mode","" },{"IP","" },{"port","" },{"cablesInterconection","" },{"pcb","" } };
            xmlGeneralFEMDNodesDic = new Dictionary<string, string>()
            { { "list_Of_General_FEMDS",""}, { "uplink_band",""}, { "uplink_dsa",""}, { "downlink_band",""}, { "downlink_dsa",""}, { "control_Unit_LDO",""},{ "FemdsToBypassUplink",""},{ "FemdsToBypassDownlink",""} };
            xmlDSAPerFEMDDownlinkNodesDic = new Dictionary<string, string>()
            {{ "dsaFem_0",""},{ "dsaFem1",""},{ "dsaFem2",""},{ "dsaFem3",""},{ "dsaFem4",""},{ "dsaFem5",""},{ "dsaFem6",""},{ "dsaFem7",""},{ "dsaFem8",""},{ "dsaFem9",""},{ "dsaFem10",""},{ "dsaFem11",""},{ "dsaFem12",""},{ "dsaFem13",""},{ "dsaFem14",""},{ "dsaFem15",""} };
            xmlDSAPerFEMDUplinkNodesDic = new Dictionary<string, string>()
            { { "dsaFem0",""},{ "dsaFem1",""},{ "dsaFem2",""},{ "dsaFem3",""},{ "dsaFem4",""},{ "dsaFem5",""},{ "dsaFem6",""},{ "dsaFem7",""},{ "dsaFem8",""},{ "dsaFem9",""},{ "dsaFem10",""},{ "dsaFem11",""},{ "dsaFem12",""},{ "dsaFem13",""},{ "dsaFem14",""},{ "dsaFem15",""} };
            xmlFPGANodesDic = new Dictionary<string, string>()
            { { "linkageNumber","" }, { "micronLocation","" },{ "PCS_DL_in_UL_out","" },{ "PCS_UL_in_UD_out1","" },{ "PCS_UL_in_UD_out2","" },{ "local_en","" } ,{ "transmitZerosFromBF","" }, { "AGC_backoff","" },{ "AGC_average_shift","" },{ "enabled_chanins","" },{ "DL_subchannel0_bandwidth","" },{ "DL_FDD_center_frequency","" } ,{ "subchannel0_DL_center_frequency_offset","" }, { "UL_subchannel0_bandwith","" },{ "UL_FDD_center_frequency","" },{ "subchannel0_UL_center_frequency_offset","" }};
            xmlMBNodesDic = new Dictionary<string, string>()
            { { "configurationScript","" }, { "autoLoadConfigScript","" },{ "sourcePath","" },{ "criteriaLevelsPath","" },{ "micronID","" },{ "sendPacketsWithMicronID","" } };
        }

        public void save(string filePath, Boolean MB, Boolean FPGA, Boolean FEMD, Boolean dsaPerFEMD)
        {
            doc.Load(UNIVERSE_EMPTY_CONFIG);
            XmlNode root = doc.DocumentElement;
            XmlNode myNode;
            myNode = root.SelectSingleNode("descendant::general");
            savepecific(myNode, xmlgeneralNodesDic);

            myNode = root.SelectSingleNode("descendant::FPGAConfig");
            if (FPGA)
            {
                savepecific(myNode, xmlFPGANodesDic);
                myNode.Attributes["toInclude"].Value = "true";
                FPGAtoInclude = true;
            }
            else
            {
                myNode.Attributes["toInclude"].Value = "false";
                FPGAtoInclude = false;
                saveBlanks(myNode, xmlFPGANodesDic);
            }
            myNode = root.SelectSingleNode("descendant::MainBoardConfig");
            if (MB)
            {
                myNode.Attributes["toInclude"].Value = "true";
                MBtoInclude = true;
                savepecific(myNode, xmlMBNodesDic);
            }
            else
            {
                myNode.Attributes["toInclude"].Value = "false";
                MBtoInclude = false;
                saveBlanks(myNode, xmlMBNodesDic);
            }
            myNode = root.SelectSingleNode("descendant::FEMDConfig");
            if (FEMD)
            {
                myNode.Attributes["toInclude"].Value = "true";
                FEMDtoInclude = true;
                myNode = root.SelectSingleNode("descendant::generalFEMDS");
                savepecific(myNode, xmlGeneralFEMDNodesDic);
                if (dsaPerFEMD)
                {
                    myNode = root.SelectSingleNode("descendant::dsaPerFEMD");
                    myNode.Attributes["toInclude"].Value = "true";
                    DSAperFEMDtoInclude = true;
                    myNode = root.SelectSingleNode("descendant::uplink");
                    savepecific(myNode, xmlDSAPerFEMDUplinkNodesDic);
                    myNode = root.SelectSingleNode("descendant::downlink");
                    savepecific(myNode, xmlDSAPerFEMDDownlinkNodesDic);
                }
                else
                {
                    myNode = root.SelectSingleNode("descendant::dsaPerFEMD");
                    myNode.Attributes["toInclude"].Value = "false";
                    DSAperFEMDtoInclude = false;
                    myNode = root.SelectSingleNode("descendant::uplink");
                    saveBlanks(myNode, xmlDSAPerFEMDUplinkNodesDic);
                    myNode = root.SelectSingleNode("descendant::downlink");
                    saveBlanks(myNode, xmlDSAPerFEMDDownlinkNodesDic);
                }
            }
            else
            {
                myNode = root.SelectSingleNode("descendant::FEMDConfig");
                myNode.Attributes["toInclude"].Value = "false";
                FEMDtoInclude = false;
                myNode = root.SelectSingleNode("descendant::generalFEMDS");
                saveBlanks(myNode, xmlGeneralFEMDNodesDic);
                myNode = root.SelectSingleNode("descendant::uplink");
                saveBlanks(myNode, xmlDSAPerFEMDUplinkNodesDic);
                myNode = root.SelectSingleNode("descendant::downlink");
                saveBlanks(myNode, xmlDSAPerFEMDDownlinkNodesDic);
            }

            doc.Save(UNIVERSE_CONFIG_XML_PATH);
        }

        public void saveBlanks(XmlNode node, Dictionary<string, string> dic)
        {
            XmlNodeList childs = node.ChildNodes;
            string name = "", value = "";
            foreach (XmlNode child in childs)
            {
                child.InnerText = "";
            }
            foreach (var pair in dic.ToList())
            {
                var key = pair.Key;
                dic.Remove(key);
                dic.Add(key, "");
            }
        }

        public void loadSpecific(XmlNode node, Dictionary<string, string> dic)
        {
            XmlNodeList childs = node.ChildNodes;
            string name = "", value = "";
            foreach (XmlNode child in childs)
            {
                name = child.Name;
                value = child.InnerText;
                if (!dic.ContainsKey(name))
                    dic.Add(name, value);
                else dic[name] = value;
            }
        }

        public void savepecific(XmlNode node, Dictionary<string, string> dic)
        {
            XmlNodeList childs = node.ChildNodes;
            string name = "", value = "";
            foreach (XmlNode child in childs)
            {
                name = child.Name;
                if (dic.ContainsKey(name))
                    child.InnerText = dic[name];
                else
                    child.InnerText = "";
            }
        }
    }
}
