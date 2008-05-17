using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using RoboMagellan.GenericGPS.Proxy;
using System.Runtime.InteropServices;

namespace RMGUI
{
    public partial class MainForm : Form
    {

        private ServiceFetcher sf;

        public MainForm()
        {
            InitializeComponent();
            connectToolStripMenuItem.Click += connectToolStripMenuItem_Click;
            quitToolStripMenuItem.Click += quitToolStripMenuItem_Click;
            ConsolePipe cp = new ConsolePipe(log);
            Console.SetOut(cp);
        }

        private void connectToolStripMenuItem_Click(object sender, EventArgs e)
        {
            sf = new ServiceFetcher(new TextBox[4] { SatText, TimeText, EastText, NorthText });
        }

        private void quitToolStripMenuItem_Click(object sender, EventArgs e)
        {
            System.Environment.Exit(0);
        }
        
        

    }
}
