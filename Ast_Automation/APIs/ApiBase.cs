using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;

namespace APIs
{
    public class ApiBase
    {
        protected  readonly  string _host;
        protected readonly string _user;
        protected readonly string _token;

        protected readonly HttpClient _httpClient;

        public ApiBase(string host, string user, string token)
        {
            _host = host;
            _user = user;
            _token = token;
            _httpClient = new HttpClient();
            InitClient();
        }

        private void InitClient()
        {
            _httpClient.Timeout = TimeSpan.FromSeconds(5);
        }
    }
}
