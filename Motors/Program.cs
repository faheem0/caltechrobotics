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
            Console.Write("Port: ");
            portName = Console.ReadLine();
            portName = portName.Trim();
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
                try
                {
                    motors.command(MotorCommands.MOVE, 
                        (byte) int.Parse(values[0], System.Globalization.NumberStyles.Integer), 
                        (byte) int.Parse(values[1], System.Globalization.NumberStyles.Integer)
                        );
                }
                catch (Exception e)
                {
                    Console.WriteLine(e.ToString());
                    Console.WriteLine("Invalid String");
                }
            }
        }
    }
}
