using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static AST_Automation.Callbacks.UI_Delegate;

namespace AST_Automation.Callbacks
{
    public class UI_Callback_Singleton
    {

        UI_Callback_Singleton() { }

        private static readonly object Lock = new object();
        private static UI_Callback_Singleton instance = null;

        public static UI_Callback_Singleton Instance
        {
            get
            {
                lock (Lock)
                {
                    if (instance == null)
                    {
                        instance = new UI_Callback_Singleton();
                    }
                    return instance;
                }
            }
        }

        private UpdateUI ui_delegate;

        public void SetUpdateUIDelegate(UpdateUI update_UI)
        {
            instance.ui_delegate = update_UI;
        }

        public void SendUpdateToUI(UIResponse response)
        {
            instance.ui_delegate.Invoke(response);
        }

    }
}
