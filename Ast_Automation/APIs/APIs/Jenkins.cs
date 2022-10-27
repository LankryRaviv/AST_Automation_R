using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Threading.Tasks;

namespace APIs.Jenkins
{
    public class Jenkins : ApiBase
    {
        private string _jenkinsJsonApi = "api/json?pretty=true";
        private string _runJobWithParameters = "job/Automation/buildWithParameters?token=TokenTest";

        public Jenkins(string host = "http://10.60.0.32:27527/", string user = "admin", string token = "1191606c0fc47fbf4797ba5114e17df8df") : base(host, user, token)
        {

        }

        public async Task<bool> CheckJenkinsCommunication()
        {
            try
            {
                var requset = new HttpRequestMessage(new HttpMethod("GET"), $"{_host}{_jenkinsJsonApi}");
                SetAuthorizationString(requset);
                var response = await _httpClient.SendAsync(requset);
                return response.EnsureSuccessStatusCode().StatusCode == System.Net.HttpStatusCode.OK;
            }
            catch (Exception ex)
            {
                return false;
            }
        }

        public async Task<bool> RunJob(string suiteToRun = "AdditionFeature")
        {
            var requset = new HttpRequestMessage(new HttpMethod("POST"), $"{_host}{_runJobWithParameters}");
            SetAuthorizationString(requset);

            var contentList = new List<string>();

            contentList.Add($"TestCategory={suiteToRun}");
            contentList.Add($"BuildName={suiteToRun} build");
            contentList.Add("MachineName=Lab18");

            requset.Content = new StringContent(string.Join("&", contentList));
            requset.Content.Headers.ContentType = MediaTypeHeaderValue.Parse("application/x-www-form-urlencoded");

            var response = await _httpClient.SendAsync(requset);
            return response.EnsureSuccessStatusCode().IsSuccessStatusCode;
        }

        private void SetAuthorizationString(HttpRequestMessage requset)
        {
            var base64authorization = Convert.ToBase64String(Encoding.ASCII.GetBytes($"{_user}:{_token}"));
            requset.Headers.TryAddWithoutValidation("Authorization", $"Basic {base64authorization}");
        }
    }
}
