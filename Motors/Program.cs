using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using RoboMagellan.MotorControl;

namespace RoboMagellan.MotorControl
{
    class Program
    {

        static void Main(string[] args)
        {
            string portName = "COM1";
            motorcontrol motors = new motorcontrol(portName);
            if(!motors.connect())
                Console.WriteLine("Couldn't connect to " + portName);

            string cmd;
            string[] values;
            while (true)
            {
                Console.Write("Command: ");
                cmd = Console.ReadLine();
                cmd = cmd.Trim();
                values = cmd.Split(' ');
                motors.command(MotorCommands.MOVE, Byte.Parse(values[0]), Byte.Parse(values[1]));
            }
        }
    }
}
