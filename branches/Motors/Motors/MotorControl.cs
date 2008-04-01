using System;
using System.IO.Ports;
using System.Threading;
using System.Text.RegularExpressions;
using System.Collections.Generic;


using RoboMagellan.MotorControl;

namespace RoboMagellan.MotorControl
{

    public enum MotorCommands
    {
        MOVE = 104,

    }
    public class motorcontrol
    {
        static int DEFAULT_BAUD_RATE = 9600;
        static int DEFAULT_DATA_BITS = 8;
        static int DEFAULT_TIMEOUT = 500;
        static Parity DEFAULT_PARITY = Parity.None;
        static StopBits DEFAULT_STOP_BITS = StopBits.One;
        static Handshake DEFAULT_HANDSHAKE = Handshake.None;

        static byte COMMAND_START = 0xA9;
        static byte COMMAND_STOP = 0xFF;


        private volatile SerialPort myMotors;


        public motorcontrol(string portName)
        {
            myMotors = new SerialPort();

            //Initialize Serial Port Parameters
            myMotors.PortName = portName;
            myMotors.BaudRate = DEFAULT_BAUD_RATE;
            myMotors.Parity = DEFAULT_PARITY;
            myMotors.DataBits = DEFAULT_DATA_BITS;
            myMotors.StopBits = DEFAULT_STOP_BITS;
            myMotors.Handshake = DEFAULT_HANDSHAKE;

            myMotors.ReadTimeout = DEFAULT_TIMEOUT;
            myMotors.WriteTimeout = DEFAULT_TIMEOUT;


        }

        public bool connect()
        {

            myMotors.Open();


            if (myMotors.IsOpen)
            {
                Console.WriteLine("Sucessfully Connected!");
                Console.WriteLine(myMotors.ToString());

                //myMotors.RtsEnable = true;

                return true;
            }

            else
            {
                Console.WriteLine("Connection Failed!");    //Oh Shit!
                return false;
            }
        }

        public void installReceiveHandler()
        {
            myMotors.DataReceived += new SerialDataReceivedEventHandler(serialPort_dataRecieved);
        }


        public void command(MotorCommands cmd, byte left, byte right)
        {
            byte[] cmdString = new byte[5] { COMMAND_START, 
                                            (byte)(int)cmd, 
                                            left, 
                                            right,
                                            COMMAND_STOP
                                            };
            myMotors.Write(cmdString, 0, cmdString.Length);
        }

        private void serialPort_dataRecieved(object sender, SerialDataReceivedEventArgs e)
        {
            
        }

        class MotorDataParseException : Exception
        {

            public MotorDataParseException() : base() { }

            public MotorDataParseException(string explanation) : base(explanation) { }

            public MotorDataParseException(string exp, Exception ex) : base(exp, ex) { }
        }

    }
}
