using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using RoboMagellan.GenericGPS.Proxy;
using control = RoboMagellan.Proxy;
using System.Runtime.InteropServices;
using RoboMagellan.Proxy;
using System.IO;

namespace RoboMagellan.RoboMagellanGUI
{
    public partial class MainForm : Form
    {

        private TimeSpan time;
        private long sec;
        private Boolean fileOpened;
        private TextReader tr;
        private control.MainControlOperations _controlPort;

        public MainForm(control.MainControlOperations port)
        {
            InitializeComponent();
            quitToolStripMenuItem.Click += quitToolStripMenuItem_Click;
            //ConsolePipe cp = new ConsolePipe(log);
            //Console.SetOut(cp);
            timer1.Tick += upTimeTextUpdate;
            sec = 0;
            time = new TimeSpan();
            CheckForIllegalCrossThreadCalls = false;
            UpTimeText.Text = "Up Time: 00:00:00";
            timer1.Enabled = true;
            timer1.Start();
            fileOpened = false;
            _controlPort = port;
        }

        public void updateGPS(string sat, string time, string east, string north)
        {
            SatText.Text = sat;
            TimeText.Text = time;
            EastText.Text = east;
            NorthText.Text = north;
        }
        public void updateControl(UTMData c, UTMData[] q, MainControlStates s)
        {
            TargetEast.Text = c.East + "";
            TargetNorth.Text = c.North + "";
            StatusText.Text = s.ToString();
            WaypointQueue.Items.Clear();
            for (int i = 0; i < q.Length; i++)
            {
                WaypointQueue.Items.Add(q[i].East + "\t" + q[i].North);
            }
        }
        public void writeToLog(string s)
        {
            log.AppendText(s);
            log.ScrollToCaret();
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

        private void importToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (!fileOpened)
            {
                try
                {
                    openFileDialog1.ShowDialog();
                    fileOpened = false;
                }
                catch (Exception) { }
            }
            else fileOpened = false;
        }

        private void openFileDialog1_FileOk(object sender, CancelEventArgs e)
        {
            tr = new StreamReader(((OpenFileDialog)sender).OpenFile());
            string read;
            string[] buffer;
            string[] coords;
            char[] delim = new char[1] {'\t'};
            UTMData data;
            Enqueue enq;
            try
            {
                coords = tr.ReadToEnd().Split(new Char[1] { '\n' });
                for (int i = 0; i < coords.Length; i++)
                {
                    buffer = coords[i].Split(delim);
                    Console.WriteLine(buffer[0] + "," + buffer[1]);
                    data = new UTMData();
                    data.East = Double.Parse(buffer[0]);
                    data.North = Double.Parse(buffer[1]);
                    enq = new Enqueue(data);
                    _controlPort.Post(enq);
                }
            }
            catch (Exception) { }
            tr.Close();
        }
        

    }
}
