using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;

namespace AST_Automation.Tests
{
    public static class GetTestsData
    {
        private static Dictionary<string, SortedList> _suitsTestsOrder = new Dictionary<string, SortedList>();
        private static void Init()
        {
            var classList = Assembly.GetExecutingAssembly().GetTypes().Where(t => t.Namespace == "AST_Automation.Tests").ToList();

            for (int i = 0; i < classList.Count; i++)
            {
                var methods = classList[i].GetMethods();
                var sortedTests = new SortedList();
                var addToDictionary = false;

                for (int j = 0; j < methods.Length; j++)
                {
                    var attributesArray = methods[j].GetCustomAttributesData();

                    try
                    {
                        var value = Convert.ToInt32(attributesArray.Where(t => t.AttributeType == typeof(NUnit.Framework.OrderAttribute)).ToList()[0].ConstructorArguments[0].Value);
                        var name = attributesArray.Where(x => x.AttributeType == typeof(NUnit.Framework.DescriptionAttribute)).ToList()[0].ConstructorArguments[0].Value.ToString();
                        AddTestsToSortedList(sortedTests, value, name);
                        addToDictionary = true;
                    }
                    catch
                    {
                        continue;
                    }
                }

                if (addToDictionary)
                {
                    AddSortedlistToDictionary(sortedTests, classList[i].Name);
                }
            }
        }

        private static void AddSortedlistToDictionary(SortedList list, string suit)
        {
            _suitsTestsOrder.Add(suit, new SortedList());
            _suitsTestsOrder[suit] = (SortedList)list.Clone();
        }

        private static void AddTestsToSortedList(SortedList list, int key, string value)
        {
            try
            {
                list.Add(key, value);
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public static List<string> GetSuites()
        {
            Init();
            return _suitsTestsOrder.Keys.ToList();
        }

        public static List<string> GetSuitesTests(string key)
        {
            var order = _suitsTestsOrder[key].GetValueList();
            var testList = new List<string>();
            foreach (var test in order)
            {
                testList.Add(test.ToString());
            }

            return testList;
        }
    }
}
