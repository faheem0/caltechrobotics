using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using RoboMagellan.GenericGPS.Proxy;
using control = RoboMagellan.Proxy;
using cone = RoboMagellan.ConeDetect.Proxy;
using System.Runtime.InteropServices;
using RoboMagellan.Proxy;
using System.IO;
using System.Drawing;

namespace RoboMagellan.RoboMagellanGUI
{
    public partial class MainForm : Form
    {

        private TimeSpan time;
        private long sec;
        private Boolean fileOpened;
        private TextReader tr;
        private control.MainControlOperations _controlPort;
        private cone.ConeDetectOperations _conePort;
        private Bitmap b;
        private Pen p;
        private Pen green;
        private static int CIRCLE_SIZE = 10;

        public MainForm(control.MainControlOperations port, cone.ConeDetectOperations port2)
        {
            InitializeComponent();
            ((System.ComponentModel.ISupportInitialize)(this.camPic)).BeginInit();
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
            _conePort = port2;
            b = new Bitmap(100,100);
            p = new Pen(Color.OrangeRed);
            green = new Pen(Color.LimeGreen);
            p.Width += 1.5f;
        }

        public MainForm(control.MainControlOperations port)
        {
            InitializeComponent();
            ((System.ComponentModel.ISupportInitialize)(this.camPic)).BeginInit();
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
            _conePort = null;
            b = new Bitmap(100, 100);
            p = new Pen(Color.OrangeRed);
            green = new Pen(Color.LimeGreen);
            p.Width += 1.5f;
        }
        public void updateCompass(int angle, int absAngle)
        {
            compass.Text = "" + angle;
            abs_angle.Text = "" + absAngle;
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
        public void updateCam(Bitmap bm)
        {
            //Console.WriteLine("Got Here Too");
            //b = bm;
            Image old = camPic.Image;
            camPic.Image = bm;
            if (old != null) old.Dispose();
            //CamPanel.Refresh();
        }
        public void updateCam(Bitmap bm, int X, int Y)
        {
            Image old = camPic.Image;
            Graphics g = Graphics.FromImage(bm);
            g.DrawEllipse(p,X,Y,CIRCLE_SIZE,CIRCLE_SIZE);
            g.Dispose();
            camPic.Image = bm;
            if (old != null) old.Dispose();
        }/*
        public void updateCam(Bitmap bm, Bitmap org, int X, int Y, Rectangle r)
        {
            Image old = camPic.Image;
            Image oldCam = orgCam.Image;
            Graphics g = Graphics.FromImage(bm);
            try
            {
                g.DrawEllipse(p, X - CIRCLE_SIZE / 2, Y - CIRCLE_SIZE / 2, CIRCLE_SIZE, CIRCLE_SIZE);
                g.DrawRectangle(green, r);

            }
            catch (Exception) { }
            //Console.WriteLine(r.ToString());
            g.Dispose();
            camPic.Image = bm;
            orgCam.Image = org;
            if (oldCam != null) oldCam.Dispose();
            if (old != null) old.Dispose();
        }*/
        public void setDetection(bool b)
        {
            if (b) detected_box.Text = "DETECTED";
            else detected_box.Text = "NO CONE";
        }
        public void setConeAngle(int i)
        {
            cone_angle.Text = "" + i;
        }
        public void setConeAngle()
        {
            cone_angle.Text = "";
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
        /*
        private void calibrateCameraToolStripMenuItem_Click(object sender, EventArgs e)
        {
            Bitmap b = (Bitmap)orgCam.Image;
            int Y = b.Height / 2 - 10;
            int X = b.Width / 2 - 10;
            Color c;
            int cnt = 0;
            int R = 0;
            int G = 0;
            int B = 0;
            
            for (int i = X; i < 20+X; i++)
            {
                for (int j = Y; j < 20+X; j++)
                {
                    c = b.GetPixel(i, j);
                    cnt++;
                    R += c.R;
                    G += c.G;
                    B += c.B;
                }
            }
            R /= cnt;
            G /= cnt;
            B /= cnt;
            cone.CamCalibrate cc = new cone.CamCalibrate();
            cc.Color = Color.FromArgb(R,G,B);
            _conePort.Post(new cone.Calibrate(cc));
            b = new Bitmap(filterColor.Width, filterColor.Height);
            for (int i = 0; i < b.Width; i++)
                for (int j = 0; j < b.Height; j++)
                    b.SetPixel(i, j, cc.Color);
            filterColor.Image = b;
        }*/


    }
}
