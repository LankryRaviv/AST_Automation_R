using NUnit.Framework;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AST_Automation.Tests
{
    public class Class1
    {
        [Test]
        public void Main() 
        {
            CPURegTest cpuRegTest = new CPURegTest();
            cpuRegTest.OneTimeSetupCPUReg();

            cpuRegTest.RunFPGAUploadTest();
            cpuRegTest.ChangeAllPowerModeTest();


            cpuRegTest.OneTimeTearDown();
        }
    }
}
