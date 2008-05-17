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
        private TimeSpan time;
        private long sec;

        public MainForm()
        {
            InitializeComponent();
            connectToolStripMenuItem.Click += connectToolStripMenuItem_Click;
            quitToolStripMenuItem.Click += quitToolStripMenuItem_Click;
            ConsolePipe cp = new ConsolePipe(log);
            Console.SetOut(cp);
            timer1.Tick += upTimeTextUpdate;
            sec = 0;
            time = new TimeSpan();
        }

        private void connectToolStripMenuItem_Click(object sender, EventArgs e)
        {
            sf = new ServiceFetcher(new TextBox[4] { SatText, TimeText, EastText, NorthText });
            UpTimeText.Text = "Up Time: 00:00:00";
            timer1.Start();
            connectToolStripMenuItem.Text = "Disconnect";
        }

        private void quitToolStripMenuItem_Click(object sender, EventArgs e)
        {
            System.Environment.Exit(0);
        }

        private void upTimeTextUpdate(object sender, EventArgs e)
        {
            sec++;
            time = new TimeSpan(sec * 10000000);
            UpTimeText.Text = "Up Time: "
                + String.Format("{0:00}",time.Hours)
                + ":" + String.Format("{0:00}",time.Minutes)
                + ":" + String.Format("{0:00}",time.Seconds);

        }
        

    }
}
