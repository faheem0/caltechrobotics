using System;
using System.IO.Ports;
using System.Threading;
using System.Text.RegularExpressions;

namespace GPS
{
    public class AC12GPS : IGPS
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

        private Mutex mut;
        private volatile SerialPort myGPS;
        private Thread readThread;
        private bool _continue;
        private UTMData myData;

        public AC12GPS(string portName)
        {
            myGPS = new SerialPort();

            //Initialize Serial Port Parameters
            myGPS.PortName = portName;
            myGPS.BaudRate = DEFAULT_BAUD_RATE;
            myGPS.Parity = DEFAULT_PARITY;
            myGPS.DataBits = DEFAULT_DATA_BITS;
            myGPS.StopBits = DEFAULT_STOP_BITS;
            myGPS.Handshake = DEFAULT_HANDSHAKE;

            myGPS.ReadTimeout = DEFAULT_TIMEOUT;
            myGPS.WriteTimeout = DEFAULT_TIMEOUT;

            myGPS.Open();
            
            //Initialize data
            myData = new UTMData();
            myData.East = 0.0;
            myData.North = 0.0;
            myData.NumSat = 0;
            myData.Timestamp = 0.0;

            if (myGPS.IsOpen)
            {
                //Setup GPS
                Console.WriteLine("Sucessfully Connected!");
                Console.WriteLine(myGPS.ToString());
                myGPS.RtsEnable = true;
                command("$PASHS,PWR,ON");
                System.Threading.Thread.Sleep(10);
                command("$PASHQ,PRT");
                System.Threading.Thread.Sleep(10);
                command("$PASHQ,RID");
                System.Threading.Thread.Sleep(10);
                command("$PASHS,OUT,A,NMEA");
                /*System.Threading.Thread.Sleep(10);
                command("$PASHS,NME,GSV,A,ON");*/
                /*System.Threading.Thread.Sleep(10);
                command("$PASHS,NME,GGA,A,ON");*/
                /*System.Threading.Thread.Sleep(10);
                command("$PASHS,NME,GSA,A,ON");
                System.Threading.Thread.Sleep(10);
                command("$PASHS,NME,VTG,A,ON");*/
                System.Threading.Thread.Sleep(10);
                command("$PASHS,NME,UTM,A,ON");     //Make GPS send UTM coordinate string

                // Create a new mutex to make sure manual update and autoupdate don't conflict
                mut = new Mutex();  
            }
            else
            {
                Console.WriteLine("Connection Failed!");    //Oh Shit!
            }
        }
        /**
         * Converts a command string into ASCII and send the command
         */
        public void command(string s)
        {
            s = s + "\r\n";
            byte[] asciiString = System.Text.Encoding.ASCII.GetBytes(s.ToCharArray());
            myGPS.Write(asciiString, 0, asciiString.Length);
        }
        /**
         * Stops the read thread and kills the serial port connection
         */
        public void Destroy()
        {
            _continue = false;
            readThread.Join();
            myGPS.Close();
        }
        /** 
         * Creates a new thread to automatically update the coordinates
         */
        public void enableAutoUpdate()
        {
            _continue = true;
            readThread = new Thread(autoupdate);
            readThread.Start();
        }
        /**
         * Kills the read thread to stop automatic updates
         */
        public void disableAutoUpdate()
        {
            _continue = false;
            readThread.Join();
        }
        private void autoupdate()
        {
            while (_continue)
            {
                update();
            }
        }
        /**
         * Gets new GPS information and updates it
         */
        public void update()
        {
            try
            {
                mut.WaitOne();  //Make sure the current thread is the only one executing these lines
                string bufferString = myGPS.ReadLine(); //Get a string from GPS
                parseString(bufferString);  //Parse the GPS
                mut.ReleaseMutex(); 
            }
            catch (TimeoutException) { }
            catch (FormatException) { }
        }
        private bool parseString(string s)
        {
            Match m;
            m = UTM.Match(s);   //MMmm.. Regular Expressions
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
                    myData.East = east;
                    myData.North = north;
                    myData.NumSat = sat;
                    myData.Timestamp = time;
                        //Monitor.Exit(myData);
                }
                catch (FormatException) //FUUUUUCK! Shit happened!
                {
                    return false;
                }
                return true;
            }
            return false;
        }
        
        public double getEastUTM()
        {
            return myData.East;
        }
        public double getNorthUTM()
        {
            return myData.North;
        }
        public int getSatUTM()
        {
            return myData.NumSat;
        }
        public double getTimestampUTM()
        {
            return myData.Timestamp;
        }
    }
}
