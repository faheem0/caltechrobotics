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
        MOVE = 217,
        ACK = 218,
        STOP = 219,
        TURN = 220,
        //To Be Continued...
    }
    public class MotorControl
    {
        static int DEFAULT_BAUD_RATE = 9600;
        static int DEFAULT_DATA_BITS = 8;
        static int DEFAULT_TIMEOUT = 500;
        static Parity DEFAULT_PARITY = Parity.None;
        static StopBits DEFAULT_STOP_BITS = StopBits.Two;
        static Handshake DEFAULT_HANDSHAKE = Handshake.None;

        static byte COMMAND_START = 254;
        static byte COMMAND_STOP = 233;
        static byte MAX_SPEED = 100;

        private volatile SerialPort myMotors;


        public MotorControl(string portName)
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

        /* The only difference is the the below method. The rest of it is very similar to the GPS code */
        public void command(MotorCommands cmd, SByte left, SByte right)
        {
            //Create the packet in the right order
            byte[] cmdString = new byte[5] { COMMAND_START, 
                                            (byte)(int)cmd, 
                                            (byte) (left + MAX_SPEED), 
                                            (byte) (right + MAX_SPEED),
                                            COMMAND_STOP
                                            };

            myMotors.Write(cmdString, 0, cmdString.Length);
        }

        private void serialPort_dataRecieved(object sender, SerialDataReceivedEventArgs e)
        {
            //Does nothing right now. I don't know why I did not delete it.
        }
        //Again, I don't know why I didn't delete the class below.
        class MotorDataParseException : Exception
        {

            public MotorDataParseException() : base() { }

            public MotorDataParseException(string explanation) : base(explanation) { }

            public MotorDataParseException(string exp, Exception ex) : base(exp, ex) { }
        }

    }
}
