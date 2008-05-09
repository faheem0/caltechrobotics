using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.IO.Ports;
using RoboMagellan.MotorControl;

namespace MotorTestGUI
{
    public partial class MotorTestGUI : Form
    {
        public MotorTestGUI()
        {
            InitializeComponent();
            connect.Click += connect_Click;
            /*move.Click += move_Click;
            turn.Click += turn_Click;
            stop.Click += stop_Click;*/
            log.TextChanged += log_TextChanged;

            CheckForIllegalCrossThreadCalls = false;

            string[] ports = SerialPort.GetPortNames();
            
            for (int i = 0; i < ports.Length; i++)
                comports.Items.Add(ports[i]);
        }

        private void connect_Click(object sender, EventArgs e)
        {
            try
            {
                //comports.Text
                Program.mc = new MotorControl(comports.Text, log);
                Program.mc.connect();
                Program.mc.installReceiveHandler();
 //               comports.Read
 //               comport.ReadOnly = true;
                connect.Enabled = false;

            }
            catch (Exception)
            {

            }
        }

        private void move_Click(object sender, EventArgs e)
        {
            try
            {
                int left_speed = int.Parse(left.Text);
                int right_speed = int.Parse(right.Text);
                Program.mc.sendMove((sbyte)left_speed, (sbyte)right_speed);
            }
            catch (Exception)
            {

            }
        }

        private void turn_Click(object sender, EventArgs e)
        {
            try
            {
                int turn_angle = int.Parse(angle.Text);
                Program.mc.sendTurn(turn_angle);
            }
            catch (Exception)
            {

            }
        }

        private void stop_Click(object sender, EventArgs e)
        {
            try
            {
                Program.mc.sendStop();
                log.AppendText("Send Stop\n");
            }
            catch (Exception)
            {

            }
        }

        private void log_TextChanged(object sender, EventArgs e)
        {
            log.ScrollToCaret();
        }



    }
}
