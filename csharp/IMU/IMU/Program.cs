using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace IMU
{
    class Program
    {
        static void Main(string[] args)
        {
            CristaIMU imu = new CristaIMU("COM6");
            imu.autoupdate();
        }
    }
}
