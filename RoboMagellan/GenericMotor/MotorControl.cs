using System;
using System.IO.Ports;
using System.Threading;
using System.Text.RegularExpressions;
using System.Collections.Generic;
using Microsoft.Ccr.Core;
using Microsoft.Dss.Core;
using Microsoft.Dss.ServiceModel.Dssp;

using RoboMagellan.MotorControl;

namespace RoboMagellan.MotorControl
{

    public enum MotorCommands
    {
        MOVE = 217,
        ACK = 218,
        STOP = 219,
        TURN = 220,
        TURNREL = 221,
        COMMAND_START = 254,
        COMMAND_STOP = 233,
        HAS_STOPPED = 216
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

        static byte MAX_SPEED = 100;

        private static int state;
        private static String receive_ack;
        private static SendAck a;

        private volatile SerialPort myMotors;

        private Port<SendAck> motorAckRecieve;

        private DispatcherQueue dq;

        public MotorControl(string portName, DispatcherQueue queue)
        {
            myMotors = new SerialPort();
            state = 0;
            receive_ack = "";
            dq = queue;
            motorAckRecieve = new Port<SendAck>();

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

        public void sendMove(SByte left, SByte right)
        {
            byte[] bytes = new byte[2];
            bytes[0] = (byte)(left + MAX_SPEED);
            bytes[1] = (byte)(right + MAX_SPEED);
            command(MotorCommands.MOVE, bytes);
        }

        public void sendStop(Port<DefaultSubmitResponseType> responsePort)
        {
            command(MotorCommands.STOP, null);
            Arbiter.Activate(dq,
                Arbiter.Receive(false, motorAckRecieve,
                    delegate(SendAck a)
                    {
                        responsePort.Post(new DefaultSubmitResponseType());
                    }));
        }

        public void sendTurn(int bearing, Port<DefaultSubmitResponseType> responsePort)
        {
            byte[] bytes = new byte[2];

            if (bearing > 255)
            {
                bytes[0] = 255;
                bytes[1] = (byte)(bearing - 255);
            }
            else
            {
                bytes[0] = (byte)bearing;
                bytes[1] = 0;
            }
            command(MotorCommands.TURN, bytes);
            Arbiter.Activate(dq,
                Arbiter.Receive(false, motorAckRecieve, 
                    delegate(SendAck a)
                    {
                        responsePort.Post(new DefaultSubmitResponseType());
                    }));
        }

        public void sendAck()
        {
            command(MotorCommands.ACK, null);
        }

        /* The only difference is the the below method. The rest of it is very similar to the GPS code */
        protected void command(MotorCommands cmd, byte[] bytes)
        {
            int size = (bytes == null ? 3 : bytes.Length + 3);
            byte[] cmdString = new byte[size];
            cmdString[0] = (byte)MotorCommands.COMMAND_START;
            cmdString[1] = (byte) cmd;
            if (bytes != null) System.Array.Copy(bytes, 0, cmdString,2, bytes.Length);
            cmdString[size-1] = (byte)MotorCommands.COMMAND_STOP;
            
            myMotors.Write(cmdString, 0, cmdString.Length);
        }

        private void serialPort_dataRecieved(object sender, SerialDataReceivedEventArgs e)
        {
            if (myMotors.BytesToRead > 0)
            {
                int b = myMotors.ReadByte();
                switch (state)
                {
                    case 0:
                        if (b == (int)MotorCommands.COMMAND_START) state = 1;
                        break;
                    case 1:
                        AckInfo info;
                        switch (b)
                        {
                            case (int)MotorCommands.ACK:
                                receive_ack = "Acknowledged";
                                info = new AckInfo();
                                info.Type = MotorCommands.ACK;
                                a = new SendAck(info);
                                motorAckRecieve.Post(a);
                                state = 2;
                                break;
                            case (int)MotorCommands.STOP:
                                receive_ack = "STOP Acknowledged";
                                info = new AckInfo();
                                info.Type = MotorCommands.STOP;
                                a = new SendAck(info);
                                motorAckRecieve.Post(a);
                                state = 2;
                                break;
                            case (int)MotorCommands.TURN:
                                receive_ack = "TURN Acknowledged";
                                info = new AckInfo();
                                info.Type = MotorCommands.TURN;
                                a = new SendAck(info);
                                motorAckRecieve.Post(a);
                                state = 2;
                                break;
                            case (int)MotorCommands.MOVE:
                                receive_ack = "MOVE Acknowledged";
                                info = new AckInfo();
                                info.Type = MotorCommands.MOVE;
                                a = new SendAck(info);
                                motorAckRecieve.Post(a);
                                state = 2;
                                break;
                            case (int)MotorCommands.HAS_STOPPED:
                                receive_ack = "Has Stopped";
                                info = new AckInfo();
                                info.Type = MotorCommands.HAS_STOPPED;
                                a = new SendAck(info);
                                motorAckRecieve.Post(a);
                                state = 2;
                                break;
                            default:
                                receive_ack = "Unexpected input from motors!";
                                state = 0;
                                break;
                        }
                        break;
                    case 2:
                        if (b == (int)MotorCommands.COMMAND_STOP) state = 0;
                        motorAckRecieve.Post(a);
                        Console.WriteLine(receive_ack);
                        break;
                    default:
                        state = 0;
                        break;
                }
            }
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
