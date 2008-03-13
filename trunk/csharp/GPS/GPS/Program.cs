using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace GPS
{
    class Program
    {
        static void Main(string[] args)
        {
            AC12GPS myGPS = new AC12GPS("COM1");
            myGPS.enableAutoUpdate();
            while (true)
            {
                Console.WriteLine("UTM E: " + myGPS.getEastUTM() + "m N: " + myGPS.getNorthUTM() + "m");
                Console.WriteLine("Number of Satellites: " + myGPS.getSatUTM());
                Console.WriteLine("UTC Timestamp: " + myGPS.getTimestampUTM());
                System.Threading.Thread.Sleep(100);
                Console.Clear();
            }
            //System.Threading.Thread.Sleep(5*60000);
            //myGPS.Destroy();
        }
    }
}
