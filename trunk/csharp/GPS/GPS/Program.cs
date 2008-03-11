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
            
            System.Threading.Thread.Sleep(60000);
            myGPS.Destroy();
        }
    }
}
