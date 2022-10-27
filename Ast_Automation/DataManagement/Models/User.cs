using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DataManagement.Models
{
    public class User
    {
        string userName;
        string password;
        string access;

        public string UserName { get => userName; set => userName = value; }
        public string Password { get => password; set => password = value; }
        public string Access { get => access; set => access = value; }

        public List<User> GetAllUsers() 
        {
            DBServices dbs = new DBServices();
            List<User> users = dbs.GetAllUsers();
            return users;
        }
        public User() { }

        public User(string userName, string password, string access)
        {
            UserName = userName;
            Password = password;
            Access = access;
        }
    }
}
