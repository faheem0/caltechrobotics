using System;
using System.Collections.Generic;
using System.Linq;
using System.Windows.Forms;
using RoboMagellan.MotorControl;

namespace MotorTestGUI
{
    
    static class Program
    {
        public static MotorControl mc;
        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        [STAThread]
        static void Main()
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.Run(new MotorTestGUI());
        }
    }
}
