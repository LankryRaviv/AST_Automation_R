using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Shapes;
using DataManagement.Models;

namespace GUI
{
    /// <summary>
    /// Interaction logic for Window1.xaml
    /// </summary>
    public partial class LoginPage : Window
    {
        List<User> usersList = new List< User > ();
        public LoginPage()
        {
            InitializeComponent();
            Get_All_Users();
        }

        private void Login_btn_Click(object sender, RoutedEventArgs e)
        {
            var userName = comboBoxUsername.SelectedValue.ToString();
            var password = passwordBox.Password;
            if (userName == "" && password == "")
            {
                MessageBox.Show("Please choose username and fill password.", "Login error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
            else if(userName != "" && password == "")
            {
                MessageBox.Show("Please fill password.", "Login error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
            else if (userName == "" && password != "")
            {
                MessageBox.Show("Please choose username.", "Login error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
            else 
            {
                foreach (var user in usersList)
                {
                    if (userName == user.UserName) 
                    {
                        if (password == user.Password)
                        {
                            MainWindow mw = new MainWindow();
                            User loginUser = new User(user.UserName, user.Password, user.Access);
                            mw.SetUser(loginUser);
                            this.Hide();
                            mw.Show();
                            this.Close();
                        }
                        else
                        {
                            MessageBox.Show("Incorrect password", "Login error", MessageBoxButton.OK, MessageBoxImage.Error);
                        }

                    }
                }
            }
        }

        private void Cancel_btn_Click(object sender, RoutedEventArgs e)
        {
            Close();
        }

        private void Get_All_Users() 
        {
            comboBoxUsername.Items.Clear();
            comboBoxUsername.SelectedIndex = 0;
            comboBoxUsername.Items.Add("");
            User user = new User();
            usersList= user.GetAllUsers();
            foreach (var myUser in usersList)
            {
                comboBoxUsername.Items.Add(myUser.UserName);
            }
        }
    }
}
