using System;
using System.IO.Ports;
using System.Threading;


public class AC12GPS : IGPS
{
    private SerialPort myGPS;
    static int DEFAULT_BAUD_RATE = 4800;
    static int DEFAULT_DATA_BITS = 8;
    static Parity DEFAULT_PARITY = Parity.None;
    static StopBits DEFAULT_STOP_BITS = StopBits.One;
    static Handshake DEFAULT_HANDSHAKE = Handshake.None;

	public AC12GPS(string portName)
	{
        myGPS = new SerialPort();

        myGPS.PortName = portName;
        myGPS.BaudRate = DEFAULT_BAUD_RATE;
        myGPS.Parity = DEFAULT_PARITY;
        myGPS.DataBits = DEFAULT_DATA_BITS;
        myGPS.StopBits = DEFAULT_STOP_BITS;
        myGPS.Handshake = DEFAULT_HANDSHAKE;

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
