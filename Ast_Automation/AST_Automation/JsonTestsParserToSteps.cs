using DataManagement;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.IO;

namespace AST_Automation
{
    public static class JsonTestsParserToSteps
    {
        private static List<Step> GetStepsListFromJson(string testJson)
        {
            var testSteps = JsonFileParser.GetDictionaryFromPath(testJson);
            var stepsList = new List<Step>();

            for (int i = 0; i < testSteps.Count; i++)
            {
                stepsList.Add(GetStepObject(testSteps[(i + 1).ToString()]));
            }

            return stepsList;
        }

        public static List<Step> GetStepsList(string path)
        {
            if (Path.GetExtension(path).Length > 0)
            {
                return GetStepsListFromJson(path);
            }

            return CombineJsonsFolderToStepsList(path);
        }

        private static List<Step> CombineJsonsFolderToStepsList(string path)
        {
            var steps = new List<Step>();
            var jsonsInFolder = Directory.GetFiles(path);

            for (int i = 0; i < jsonsInFolder.Length; i++)
            {
                steps.AddRange(GetStepsList(jsonsInFolder[i]));
            }

            return steps;
        }

        private static Step GetStepObject(JObject keyValues)
        {
            string step_Name = keyValues["Step_Name"].ToString();
            string device = keyValues["Device"].ToString();
            string remote = keyValues["Remote"].ToString();
            var parameters = GetParametersList(((JArray)keyValues["Parameters"]));
            return new Step(step_Name, device, remote, parameters);
        }

        private static List<object> GetParametersList(JArray jsonParameters)
        {
            List<object> parameters = new List<object>();
            for (int i = 0; i < jsonParameters.Count; i++)
            {
                JTokenType type = jsonParameters[i].Type;

                switch (type)
                {
                    case JTokenType.Integer:
                        {
                            parameters.Add(int.Parse(jsonParameters[i].ToString()));
                            break;
                        }
                    case JTokenType.Boolean:
                        {
                            parameters.Add(bool.Parse(jsonParameters[i].ToString()));
                            break;
                        }
                    case JTokenType.String:
                        {
                            parameters.Add(jsonParameters[i].ToString());
                            break;
                        }
                    case JTokenType.Array:
                        {
                            parameters.Add((JArray)jsonParameters[i]);
                            break;
                        }
                    case JTokenType.Float:
                        {
                            parameters.Add(double.Parse(jsonParameters[i].ToString()));
                            break;
                        }
                }
            }

            return parameters;
        }
    }


}
