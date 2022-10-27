using Microsoft.Win32;
using System;
using System.Collections.Generic;
using System.IO;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Threading;
using DataManagement.Models;
using AST_Automation.Tests;
using AST_Automation.Callbacks;
using APIs;
using APIs.Jenkins;

namespace GUI
{
    public partial class MainWindow : Window
    {
        private readonly DispatcherTimer _dispatchTimer = new DispatcherTimer();

        private int _totalTimeCounter = 0;
        private int _currentTimeCounter = 0;
        private User onlineUser;

        private readonly Jenkins _jenkins;

        public MainWindow()
        {
            InitializeComponent();           
            InitDispatcherTimer();
            PopulateComboBox();
            GenerateTestsDataGridHeader();
            _jenkins = new Jenkins();
        }

        public void SetUser(User user) 
        {
            onlineUser = user;  
        }
        private void BtnOpenFile_Click(object sender, RoutedEventArgs e)
        {
            OpenFileDialog fd = new OpenFileDialog();
            if (fd.ShowDialog() == true)
            {
                TestsDataGrid.ItemsSource = TestStep.AllSteps(fd.FileName);
            }
        }

        private void InitDispatcherTimer()
        {
            _dispatchTimer.Interval = TimeSpan.FromSeconds(1);
            _dispatchTimer.Tick += DtTicker;
        }

        private async void BtnStartTest_Click(object sender, RoutedEventArgs e)
        {
            if (await _jenkins.CheckJenkinsCommunication())
            {
                if (await _jenkins.RunJob())
                {
                    BtnStartTest.IsEnabled = false;
                    _dispatchTimer.Start();
                    UI_Callback_Singleton.Instance.SetUpdateUIDelegate(new UI_Delegate.UpdateUI(UpdateUI));
                }
            }

        }

        //to be replace with test end function
        private void BtnStopTest_Click(object sender, RoutedEventArgs e)
        {
            _dispatchTimer.Stop();
            _currentTimeCounter = 0;
            BtnStartTest.IsEnabled = true;
        }

        private void DtTicker(object sender, EventArgs e)
        {
            _currentTimeCounter++;
            _totalTimeCounter++;
            LblDurationTime.Content = _currentTimeCounter.ToString();
            LblTotaltime.Content = _totalTimeCounter.ToString();
        }

        private void BtnViewLog_Click(object sender, RoutedEventArgs e)
        {
            OpenFileDialog fd = new OpenFileDialog();
            if (fd.ShowDialog() == true)
            {
                StreamReader reader = new StreamReader(fd.FileName);
                txbStatusLog.Text = "";
                txbStatusLog.AppendText(reader.ReadToEnd());
                reader.Close();
            }
        }

        private void UpdateUI(UIResponse response)
        {
            Dispatcher.Invoke(() =>
            {
                Paragraph paragraph = new Paragraph();
                paragraph.Inlines.Add(new Run($"{response.GetTestName()} | {response.GetStatus()}"));
                //flowDoc.Blocks.Add(paragraph);
                txbStatusLog.ScrollToEnd();
            });
        }

        private void PopulateComboBox()
        {
            SuiteComboBox.Items.Clear();
            SuiteComboBox.SelectedIndex = 0;

            var test_suites = GetTestsData.GetSuites();
            foreach (string elem in test_suites)
            {
                SuiteComboBox.Items.Add(elem);
            }
        }

        private void BtnLoadTestSuite_Click(object sender, RoutedEventArgs e)
        {
            List<TestEntry> testEntries = new List<TestEntry>();
            string selected_suite = SuiteComboBox.SelectedItem.ToString();
            List<string> suite_tests = GetTestsData.GetSuitesTests(selected_suite);

            var i = 1;
            foreach (var elem in suite_tests)
            {
                testEntries.Add(new TestEntry()
                {
                    RunTest = true,
                    Num = i++,
                    TestDescription = elem,
                    Status = "Ready"
                });
            }

            ChangeTestDataGridView();

            TestsDataGrid.ItemsSource = testEntries;
        }

        private void ChangeTestDataGridView()
        {
            TestsDataGrid.Columns[0].Width = DataGridLength.Auto;
            TestsDataGrid.Columns[1].Width = DataGridLength.Auto;
            TestsDataGrid.Columns[2].Width = DataGridLength.SizeToCells;
            TestsDataGrid.Columns[3].Width = DataGridLength.Auto;
        }

        private void GenerateTestsDataGridHeader()
        {
            TestsDataGrid.Columns.Add(new DataGridCheckBoxColumn { Header = "Run", Binding = new Binding("RunTest"), Width = DataGridLength.SizeToHeader, CanUserResize = false, IsReadOnly = false, CanUserSort = false });
            TestsDataGrid.Columns.Add(new DataGridTextColumn { Header = "#", Binding = new Binding("Num"), Width = DataGridLength.SizeToHeader, CanUserResize = false, CanUserSort = false });
            TestsDataGrid.Columns.Add(new DataGridTextColumn { Header = "Description", Binding = new Binding("TestDescription"), Width = DataGridLength.SizeToHeader, CanUserSort = false });
            TestsDataGrid.Columns.Add(new DataGridTextColumn { Header = "Status", Binding = new Binding("Status"), Width = DataGridLength.SizeToHeader, CanUserResize = false, CanUserSort = false });
        }
    }
}
