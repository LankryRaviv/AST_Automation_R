using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using DataManagement.Models;
using MongoDB.Bson;
using MongoDB.Driver;


namespace DataManagement
{
    internal class DBServices
    {
        public List<User> GetAllUsers()
        {
            List<User> usersList = new List<User>();
            MongoClient dbClient = new MongoClient("mongodb://10.60.0.32:27017");
            var dbList = dbClient.ListDatabases().ToList();
            var db = dbClient.GetDatabase("AST_Automation_DB");
            var coll = db.GetCollection<BsonDocument>("Users");
            var cursor = coll.AsQueryable();
            foreach (var document in cursor.ToEnumerable())
            {
                User user = new User();
                user.UserName = document["user_name"].ToString();
                user.Password = document["password"].ToString();
                user.Access = document["access"].ToString();
                usersList.Add(user);
            }
            return(usersList);
        }
    }
}
