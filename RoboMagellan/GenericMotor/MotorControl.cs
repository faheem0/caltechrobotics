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
    /// <summary>
    /// This contains the command bytes used for communication with the microcontrollers
    /// </summary>
    public enum MotorCommands
    {
        MOVE = 217,
        ACK = 218,
        STOP = 219,
        TURN = 220,
        TURNREL = 221,
        COMMAND_START = 254,
        COMMAND_STOP = 233,
        HAS_STOPPED = 216,
        TURN_COMPLETE = 215
        //To Be Continued...
    }

    /// <summary>
    /// This class handles actually communicating with the microcontrollers.
    /// Synchronization and concurrency must be handled outside the class!
    /// </summary>
    public class MotorControl
    {
        static int DEFAULT_BAUD_RATE = 115200;
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

        private
            PortSet<SendAck, Stop, Turn, SetSpeed, StopComplete, TurnComplete> motorAckRecieve;

        private DispatcherQueue dq;

        /// <summary>
        /// Constructor for the class.
        /// </summary>
        /// <param name="portName">The port for communication</param>
        /// <param name="queue">The robotics runtime DispatcherQueue</param>
        public MotorControl(string portName, DispatcherQueue queue)
        {
            myMotors = new SerialPort();
            state = 0;
            receive_ack = "";
            dq = queue;
            motorAckRecieve = new
            PortSet<SendAck, Stop, Turn, SetSpeed, StopComplete, TurnComplete>();

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

        /// <summary>
        /// Intializes the communication channels
        /// </summary>
        /// <returns></returns>
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
                Console.WriteLine("Connection Failed!");    // Dohh
                return false;
            }
        }

        /// <summary>
        /// Puts a handler on incoming data from the microcontroller
        /// </summary>
        public void installReceiveHandler()
        {
            myMotors.DataReceived += new SerialDataReceivedEventHandler(serialPort_dataRecieved);
        }

        /// <summary>
        /// Sends the "move" command to the motor microcontroller with the given left
        /// and right powers
        /// </summary>
        /// <param name="left">The left power</param>
        /// <param name="right">The right power</param>
        public void sendMove(SByte left, SByte right)
        {
            byte[] bytes = new byte[2];
            bytes[0] = (byte)(left + MAX_SPEED);
            bytes[1] = (byte)(right + MAX_SPEED);
            command(MotorCommands.MOVE, bytes);
        }

        /// <summary>
        /// Sends the "stop" command to the motor microcontroller. A response will be sent to the given
        /// response port when the stop is complete.
        /// </summary>
        /// <param name="responsePort">The response port to respond on.</param>
        public void sendStop(Port<DefaultSubmitResponseType> responsePort)
        {
            command(MotorCommands.STOP, null);
            Arbiter.Activate(dq,
                Arbiter.Receive<StopComplete>(false, motorAckRecieve,
                    delegate(StopComplete a)
                    {
                        responsePort.Post(new DefaultSubmitResponseType());
                    }));
        }

        /// <summary>
        /// Sends a "turn" command to the microcontroller. This post to the response port when
        /// the turn is complete.
        /// </summary>
        /// <param name="bearing">The absolute bearing (in degrees) to turn to (will be truncated to integer)</param>
        /// <param name="responsePort">The response port to post completion on</param>
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
                Arbiter.Receive<TurnComplete>(false, motorAckRecieve, 
                    delegate(TurnComplete a)
                    {
                        responsePort.Post(new DefaultSubmitResponseType());
                    }));
        }

        /// <summary>
        /// Sends an ack to the motor
        /// </summary>
        public void sendAck()
        {
            command(MotorCommands.ACK, null);
        }

        /// <summary>
        /// Sends the passed command and arguments to the microcontroller. If the array
        /// is null, then it is assumed the command does not take arguments.
        /// </summary>
        /// <param name="cmd">The command to send</param>
        /// <param name="bytes">The arguments to the command. If null, no arguments are sent</param>
        protected void command(MotorCommands cmd, byte[] bytes)
        {
            int size = (bytes == null ? 3 : bytes.Length + 3);
            byte[] cmdString = new byte[size];
            cmdString[0] = (byte)MotorCommands.COMMAND_START;
            cmdString[1] = (byte) cmd;
            if (bytes != null) System.Array.Copy(bytes, 0, cmdString,2, bytes.Length);
            cmdString[size-1] = (byte)MotorCommands.COMMAND_STOP;
            Console.WriteLine("Sending Command: ");
            for (int i = 0; i < cmdString.Length; i++)
            {
                Console.WriteLine(cmdString[i]);
            }
            myMotors.Write(cmdString, 0, cmdString.Length);
        }

        /// <summary>
        /// Receives input from the microcontroller (used for acks informing of turn/stop complete).
        /// 
        /// This method is NOT CURRENTLY COMPLETE, due to changes in the specification.
        /// </summary>
        /// <param name="sender">The sending object</param>
        /// <param name="e">The event</param>
        private void serialPort_dataRecieved(object sender, SerialDataReceivedEventArgs e)
        {
            while (myMotors.BytesToRead > 0)
            {
                int b = myMotors.ReadByte();
                switch (state)
                {
                    case 0:
                        if (b == (int)MotorCommands.COMMAND_START) state = 1;
                        break;
                    case 1:
                        switch (b)
                        {
                            case (int)MotorCommands.ACK:
                                receive_ack = "Acknowledged";
                                SendAck a = new SendAck();
                                motorAckRecieve.Post(a);
                                state = 2;
                                break;
                            case (int)MotorCommands.STOP:
                                receive_ack = "STOP Acknowledged";
                                Stop stop = new Stop();
                                motorAckRecieve.Post(stop);
                                state = 2;
                                break;
                            case (int)MotorCommands.TURN:
                                receive_ack = "TURN Acknowledged";
                                Turn turn = new Turn();
                                motorAckRecieve.Post(turn);
                                state = 2;
                                break;
                            case (int)MotorCommands.MOVE:
                                receive_ack = "MOVE Acknowledged";
                                SetSpeed ss = new SetSpeed();
                                motorAckRecieve.Post(ss);
                                state = 2;
                                break;
                            case (int)MotorCommands.HAS_STOPPED:
                                receive_ack = "Has Stopped";
                                StopComplete sc = new StopComplete();
                                motorAckRecieve.Post(sc);
                                state = 2;
                                break;
                            case (int)MotorCommands.TURN_COMPLETE:
                                receive_ack = "Turn complete";
                                TurnComplete tc = new TurnComplete();
                                motorAckRecieve.Post(tc);
                                state = 2;
                                break;
                            default:
                                receive_ack = "Unexpected input from motors!";
                                state = 0;
                                break;
                        }
                        Console.WriteLine(receive_ack);
                        break;
                    case 2:
                        if (b == (int)MotorCommands.COMMAND_STOP) state = 0;
//                        motorAckRecieve.Post(a);
                        Console.WriteLine(receive_ack);
                        break;
                    default:
                        state = 0;
                        break;
                }
            }
        }

        /// <summary>
        /// Exception class for motor data parsing errors.
        /// </summary>
        class MotorDataParseException : Exception
        {

            public MotorDataParseException() : base() { }

            public MotorDataParseException(string explanation) : base(explanation) { }

            public MotorDataParseException(string exp, Exception ex) : base(exp, ex) { }
        }

    }
}
