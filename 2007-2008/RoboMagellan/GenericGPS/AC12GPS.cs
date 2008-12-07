using System;
using System.IO.Ports;
using System.Threading;
using System.Text.RegularExpressions;
using System.Collections.Generic;

using Microsoft.Ccr.Core;
using Microsoft.Dss.Core;
using Microsoft.Dss.Core.Attributes;
using Microsoft.Dss.ServiceModel.Dssp;
using Microsoft.Dss.Core.DsspHttp;
using Microsoft.Dss.ServiceModel.DsspServiceBase;

using RoboMagellan.GenericGPS;

namespace RoboMagellan.GenericGPS
{

    public class GpsDataPort : PortSet<UTMData, Exception> { }

    public class AC12GPS
    {
        static int DEFAULT_BAUD_RATE = 4800;
        static int DEFAULT_DATA_BITS = 8;
        static int DEFAULT_TIMEOUT = 500;
        static Parity DEFAULT_PARITY = Parity.None;
        static StopBits DEFAULT_STOP_BITS = StopBits.One;
        static Handshake DEFAULT_HANDSHAKE = Handshake.None;

        //static Regex GGA = new Regex(@"^\$GPGGA");
        //static Regex GSV = new Regex(@"^\$GPGSV");
        //static Regex GSA = new Regex(@"^\$GPGSA");
        //static Regex VTG = new Regex(@"^\$GPVTG");
        private static Regex UTM = new Regex(@"^\$PASHR,UTM");

        private volatile SerialPort myGPS;

        private GpsDataPort gpsDataPort;


        public AC12GPS(string portName, GpsDataPort dataPort)
        {
            myGPS = new SerialPort();
            gpsDataPort = dataPort;

            //Initialize Serial Port Parameters
            myGPS.PortName = portName;
            myGPS.BaudRate = DEFAULT_BAUD_RATE;
            myGPS.Parity = DEFAULT_PARITY;
            myGPS.DataBits = DEFAULT_DATA_BITS;
            myGPS.StopBits = DEFAULT_STOP_BITS;
            myGPS.Handshake = DEFAULT_HANDSHAKE;

            myGPS.ReadTimeout = DEFAULT_TIMEOUT;
            myGPS.WriteTimeout = DEFAULT_TIMEOUT;


        }

        public bool initializePort()
        {

            myGPS.Open();


            if (myGPS.IsOpen)
            {
                Console.WriteLine("Sucessfully Connected!");
                Console.WriteLine(myGPS.ToString());

                myGPS.RtsEnable = true;

                return true;
            }

            else
            {
                Console.WriteLine("Connection Failed!");    //Oh Shit!
                return false;
            }
        }

        public void activateHandler()
        {
            myGPS.DataReceived += new SerialDataReceivedEventHandler(serialPort_dataRecieved);
        }



        /**
         * Converts a command string into ASCII and send the command
         */
        public void command(string s)
        {
            s = s + "\r\n";
            byte[] asciiString = System.Text.Encoding.ASCII.GetBytes(s.ToCharArray());
            myGPS.Write(asciiString, 0, asciiString.Length);
            Console.WriteLine(s);
        }

        private void serialPort_dataRecieved(object sender, SerialDataReceivedEventArgs e)
        {
            try
            {
                if (e.EventType == SerialData.Chars)
                {
                    string bufferString = myGPS.ReadLine();
                    UTMData d = parseString(bufferString);
                    gpsDataPort.Post(d);
                }
            }
            catch (GPSDataParseException ex)
            {
                //Console.WriteLine(ex);
            }
        }

        class GPSDataParseException : Exception
        {

            public GPSDataParseException() : base() { }

            public GPSDataParseException(string explanation) : base(explanation) { }

            public GPSDataParseException(string exp, Exception ex) : base(exp, ex) { }
        }

        private UTMData parseString(string s)
        {
            Match m;
            m = UTM.Match(s);   //MMmm.. Regular Expressions
            UTMData d = new UTMData();
            if (m.Success)
            {
                String[] utm_data = s.Split(',');
                try
                {
                    //Parse the needed parameters
                    double east = double.Parse(utm_data[4]);
                    double north = double.Parse(utm_data[5]);
                    int sat = int.Parse(utm_data[7]);
                    double time = double.Parse(utm_data[2]);

                    //Set the new data only if the above lines did not generate FormatException
                    //Monitor.Enter(myData);

                    d.East = east;
                    d.North = north;
                    d.NumSat = sat;
                    d.Timestamp = time;
                    //Monitor.Exit(myData);
                }
                catch (FormatException ex) //FUUUUUCK! Shit happened!
                {
                    //Console.WriteLine(s);
                    throw new GPSDataParseException("Format exception!");
                }
                return d;
            }
            throw new GPSDataParseException("Format exception!");
        }

    }
}
