using System;
using System.IO.Ports;
using System.Threading;
using System.Text.RegularExpressions;


public class AC12GPS : IGPS
{
    static int DEFAULT_BAUD_RATE = 4800;
    static int DEFAULT_DATA_BITS = 8;
    static int DEFAULT_TIMEOUT = 500;
    static Parity DEFAULT_PARITY = Parity.None;
    static StopBits DEFAULT_STOP_BITS = StopBits.One;
    static Handshake DEFAULT_HANDSHAKE = Handshake.None;
    static char NORTH = 'N';
    static char SOUTH = 'S';
    static char WEST = 'W';
    static char EAST = 'E';

    private SerialPort myGPS;
    private double latitude;
    private double longitude;
    private char longDirection;
    private char latDirection;
    private Thread readThread;
    private bool _continue;

	public AC12GPS(string portName)
	{
        myGPS = new SerialPort();

        myGPS.PortName = portName;
        myGPS.BaudRate = DEFAULT_BAUD_RATE;
        myGPS.Parity = DEFAULT_PARITY;
        myGPS.DataBits = DEFAULT_DATA_BITS;
        myGPS.StopBits = DEFAULT_STOP_BITS;
        myGPS.Handshake = DEFAULT_HANDSHAKE;

        myGPS.ReadTimeout = DEFAULT_TIMEOUT;
        myGPS.WriteTimeout = DEFAULT_TIMEOUT;
        
        myGPS.Open();
        

        latitude = 0.0;
        longitude = 0.0;
        longDirection = '\0';
        latDirection = '\0';
        
        if (myGPS.IsOpen)
        {
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
            System.Threading.Thread.Sleep(10);
            command("$PASHS,NME,GSV,A,ON");
            System.Threading.Thread.Sleep(10);
            command("$PASHS,NME,GGA,A,ON");
            System.Threading.Thread.Sleep(10);
            command("$PASHS,NME,GSA,A,ON");
            System.Threading.Thread.Sleep(10);
            command("$PASHS,NME,VTG,A,ON");
            _continue = true;
            readThread = new Thread(update);
            readThread.Start();
        }
        else
        {
            Console.WriteLine("Connection Failed!");
        }
	}
    public void command(string s)
    {
        s = s + "\r\n";
        byte[] asciiString = System.Text.Encoding.ASCII.GetBytes(s.ToCharArray());
        myGPS.Write(asciiString, 0, asciiString.Length);
    }
    public void Destroy()
    {
        _continue = false;
        readThread.Join();
        myGPS.Close();
    }
    public void update()
    {
        string bufferString;
        while (_continue)
        {
            try
            {
                bufferString = myGPS.ReadLine();
                Match m = Regex.Match(bufferString, @"^\$GPGGA,.*?,(.*?),(.*?),.*$");
                bufferString = Regex.Replace(bufferString, @"^\$GPGGA,.*?,(.*?),(.*?),.*$", "FOUND: $2 $1");
                Console.WriteLine(bufferString);
                
            }
            catch (TimeoutException)
            {
                //Console.Write(".");
            }
        }
    }
    public double getLatitude()
    {
        return 3.0;
    }
    public double getLongitude()
    {
        return 3.0;
    }
    public double getEastUTM()
    {
        return 3.0;
    }
    public double getNorthUTM()
    {
        return 3.0;
    }
}
