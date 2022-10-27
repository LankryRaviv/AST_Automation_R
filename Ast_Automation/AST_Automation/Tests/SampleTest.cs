using NUnit.Framework;
using Infra.Logger;

namespace AST_Automation.Tests
{
    [TestFixture]
    public class SampleTest : TestBase
    {
        [Test]
        [Category("Regression")]
        [Category("Sanity")]
        [Category("AdditionFeature")]
        public void checkaddition()
        {
            var logger = Logger.Log;

            NUnit.Engine.ITestEngine engine1 = NUnit.Engine.TestEngineActivator.CreateInstance();
            engine1.Initialize();
            var package = new NUnit.Engine.TestPackage("AST_Automation.dll");
            var runner = engine1.GetRunner(package);
            var filter = new NUnit.Engine.TestFilter("<filter><cat>Regression</cat></filter>");
            var node = runner.Explore(filter);

            while (node.NextSibling != null)
            {
                node = node.NextSibling;
                System.Console.WriteLine($"name:{node.Name} type:{node.NodeType} text:{node.InnerText}");
                foreach (var att in node.Attributes)
                {
                    System.Xml.XmlAttribute attr = (System.Xml.XmlAttribute)att;
                    System.Console.WriteLine($"attr {attr.Name}={attr.Value}");
                }
            }

            System.Console.WriteLine($"name:{node.Name} type:{node.NodeType} text:{node.InnerText}");

            Assert.AreEqual(5+5, 10);
           
            logger.Error("step 1 is failed");
            logger.Info("step 2 is ok");
        }

        [Test]
        [Category("Regression")]
        [Category("Sanity")]
        [Category("SubtractionFeature")]
        public void subtraction()
        {
            Assert.AreEqual(5 - 5, 0);
        }

        [Test]
        [Category("Regression")]
        [Category("AdditionFeature")]

        public void additionEdgeCase()
        {
            Assert.AreEqual(0 + -2, -2);
        }

        [Test]
        [Category("Regression")]
        public void divisionEdgeCase()
        {
            Assert.AreEqual(5 / 3, 1);
        }
    }
}
