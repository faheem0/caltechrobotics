using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.IO;

using RoboMagellan.GenericGPS;
using System.Threading;

namespace GPSTestGUI
{
    public partial class gpsform : Form
    {
        private AC12GPS gps;
        private TextWriter tw;
        private Boolean openClicked;
        public gpsform()
        {
            InitializeComponent();
            connect.Click += connect_Click;
            CheckForIllegalCrossThreadCalls = false;
            log.TextChanged += log_TextChanged;
            newToolStripMenuItem.Click += newToolStripMenuItem_Click;
            exitToolStripMenuItem.Click += exitToolStripMenuItem_Click;
            //saveFileDialog1.FileOk += saveFileDialog1_FileOk;
            openClicked = false;
        }

        public void updateData(double north, double east, int sat, double time)
        {

            sat_text.Text = "" + sat;
            time_text.Text = "" + time;
            north_text.Text = "" + north;
            east_text.Text = "" + east;

            try
            {
                tw.WriteLine(east + "\t" + north);
            }
            catch (Exception) { }
        }

        private void connect_Click(object sender, EventArgs e)
        {
            try
            {
                gps = new AC12GPS(portname.Text, log, this);
                gps.initializePort();
                gps.activateHandler();

                gps.command("$PASHS,PWR,ON");
                Thread.Sleep(20);
                gps.command("$PASHQ,PRT");
                Thread.Sleep(20);
                gps.command("$PASHQ,RID");
                Thread.Sleep(20);
                gps.command("$PASHS,OUT,A,NMEA");
                Thread.Sleep(20);
                /*System.Threading.Thread.Sleep(10);
                command("$PASHS,NME,GSV,A,ON");*/
                /*System.Threading.Thread.Sleep(10);
                command("$PASHS,NME,GGA,A,ON");*/
                /*System.Threading.Thread.Sleep(10);
                command("$PASHS,NME,GSA,A,ON");
                System.Threading.Thread.Sleep(10);
                command("$PASHS,NME,VTG,A,ON");*/
                gps.command("$PASHS,NME,UTM,A,ON");     //Make GPS send UTM coordinate string
                Thread.Sleep(20);
                gps.activateHandler();

                portname.ReadOnly = true;
                connect.Text = "Disconnect";
                connect.Click -= connect_Click;
                connect.Click += disconnect_Click;
            }
            catch (Exception)
            {

            }
        }
        private void disconnect_Click(object sender, EventArgs e)
        {
            try
            {
                gps.shutdown();
           
                portname.ReadOnly = false;
                connect.Text = "Connect";
                connect.Click -= disconnect_Click;
                connect.Click += connect_Click;

            }
            catch (Exception)
            {

            }
        }

        private void log_TextChanged(object sender, EventArgs e)
        {
            log.ScrollToCaret();
        }

        private void newToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (!openClicked)
            {
                try
                {
                    saveFileDialog1.ShowDialog();
                    openClicked = true;
                }
                catch (IOException)
                {

                }
            }
            else openClicked = false;
        }

        private void exitToolStripMenuItem_Click(object sender, EventArgs e)
        {
            try
            {
                tw.Close();
            }
            catch (Exception) { }
            System.Environment.Exit(0);
        }

        private void saveFileDialog1_FileOk(object sender, CancelEventArgs e)
        {
            tw = new StreamWriter(((SaveFileDialog)sender).OpenFile());
        }
        

    }
}
