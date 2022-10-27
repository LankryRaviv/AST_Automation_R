using System.Collections.Generic;

namespace Infra.ActionsRunner
{
    public static class ActionsRunner
    {
        public static object RunAction<T>(this T t, string methodName, List<object> parameters)
        {
            if (parameters == null)
            {
                parameters = new List<object>();
            }

            return t.GetType().GetMethod(methodName).Invoke(t, parameters.ToArray());
        }
    }
}
