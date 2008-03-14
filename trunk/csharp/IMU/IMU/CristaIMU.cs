using System;
using System.IO.Ports;

namespace IMU
{
    class CristaIMU
    {
        public static float CONV_GYRO_RESOLUTION = 109.22666666667f;
        public static float CONV_ACC_RESOLUTION = 334.1968383478f;

        static int DEFAULT_BAUD_RATE = 115000;
        static int DEFAULT_DATA_BITS = 8;
        static int DEFAULT_TIMEOUT = 500;
        static Parity DEFAULT_PARITY = Parity.None;
        static StopBits DEFAULT_STOP_BITS = StopBits.One;
        static Handshake DEFAULT_HANDSHAKE = Handshake.None;
        static byte SYNC_SER_0 = 0x55;
        static byte SYNC_SER_1 = 0xAA;
        static int PACKET_SIZE = 22;
        static int PACKET_BUFFER_SIZE = PACKET_SIZE * 2;
        static byte HI_SPEED_SERIAL_MSG = 0xFF;

        private SerialPort myIMU;
        private int state;
        private int invalidPackets;
        private int invalidMessage;
        private Int16[] gyro;
        private Int16[] acc;
        

        private Packet PendingPacket;
        private byte[] EmptyPacket;

        

        public CristaIMU(string portName)
        {
            myIMU = new SerialPort();
            state = 0;

            PendingPacket = new Packet();
            PendingPacket.contents = new byte[PACKET_BUFFER_SIZE];
            PendingPacket.index = 0;

            invalidPackets = 0;
            invalidMessage = 0;

            EmptyPacket = new byte[PACKET_BUFFER_SIZE];

            gyro = new Int16[6];
            acc = new Int16[6];

            myIMU.PortName = portName;
            myIMU.BaudRate = DEFAULT_BAUD_RATE;
            myIMU.Parity = DEFAULT_PARITY;
            myIMU.DataBits = DEFAULT_DATA_BITS;
            myIMU.StopBits = DEFAULT_STOP_BITS;
            myIMU.Handshake = DEFAULT_HANDSHAKE;

            myIMU.ReadTimeout = DEFAULT_TIMEOUT;
            myIMU.WriteTimeout = DEFAULT_TIMEOUT;

            myIMU.Open();
        }
        public void autoupdate()
        {
            while (true)
            {
                try
                {
                    //string bufferString = myIMU.ReadLine();
                    byte byteRead = (byte) myIMU.ReadByte();

                    //Console.WriteLine("{0:X2}", byteRead);

                    switch (state)
                    {

                        case 0:
                            //Console.WriteLine("State: " + state);
                            if (byteRead == SYNC_SER_0)
                                state = 1;
                            break;
                        case 1:
                            //Console.WriteLine("State: " + state);
                            if (byteRead == SYNC_SER_1)
                                state = 2;
                            else state = 0;
                            break;
                        case 2:
                            if (byteRead == SYNC_SER_0)
                            {
                                //Console.WriteLine("State: " + state);
                                state = 3;
                            }
                            else
                            {
                                addData(byteRead);
                                //Console.WriteLine("State: " + state + "\t{0:X2}", byteRead);
                            }
                            break;
                        case 3:
                            if (byteRead == SYNC_SER_1)
                            {
                                //Console.WriteLine("State: " + state);
                                state = 2;
                                processPacket();
                                clearPacket();
                            }
                            else
                            {
                                addData(SYNC_SER_0);
                                //Console.WriteLine("State: " + state + "\t{0:X2}", byteRead);
                                if (byteRead == SYNC_SER_0)
                                    state = 3;
                                else
                                {
                                    addData(byteRead);
                                    state = 2;
                                }
                            }
                            break;
                    }

                }
                catch (TimeoutException)
                {
                    Console.WriteLine("Error");
                }
                //System.Threading.Thread.Sleep(10);
            }

        }
        private void processPacket()
        {
            /*for (int i = 0; i < PendingPacket.index; i++)
                Console.Write("{0:X2} ", PendingPacket.contents[i]);
            Console.WriteLine();*/
            if (PendingPacket.index == PACKET_SIZE)
            {
                if (PendingPacket.contents[0] == HI_SPEED_SERIAL_MSG)
                {
                    Console.Clear();
                    Console.Write("Packet: ");
                    //Get Gyro Data
                    gyro[0] = PendingPacket.contents[(int)PInf.X_GYRO_MSB];
                    gyro[0] = (Int16)(((uint)gyro[0] << 8) | (UInt16)PendingPacket.contents[(int)PInf.X_GYRO_LSB]);
                    gyro[1] = PendingPacket.contents[(int)PInf.Y_GYRO_MSB];
                    gyro[1] = (Int16)(((uint)gyro[1] << 8) | (UInt16)PendingPacket.contents[(int)PInf.Y_GYRO_LSB]);
                    gyro[2] = PendingPacket.contents[(int)PInf.Z_GYRO_MSB];
                    gyro[2] = (Int16)(((uint)gyro[2] << 8) | (UInt16)PendingPacket.contents[(int)PInf.Z_GYRO_LSB]);

                    //Get Accelerometer Data
                    acc[0] = PendingPacket.contents[(int)PInf.X_ACC_MSB];
                    acc[0] = (Int16)(((uint)acc[0] << 8) | (UInt16)PendingPacket.contents[(int)PInf.X_ACC_LSB]);
                    acc[1] = PendingPacket.contents[(int)PInf.Y_ACC_MSB];
                    acc[1] = (Int16)(((uint)acc[1] << 8) | (UInt16)PendingPacket.contents[(int)PInf.Y_ACC_LSB]);
                    acc[2] = PendingPacket.contents[(int)PInf.Z_ACC_MSB];
                    acc[2] = (Int16)(((uint)acc[2] << 8) | (UInt16)PendingPacket.contents[(int)PInf.Z_ACC_LSB]);

                    /*Console.Write("{0:X4} ", gyro[0]);
                    Console.Write("{0:X4} ", gyro[1]);
                    Console.Write("{0:X4} ", gyro[2]);

                    Console.Write("{0:X4} ", acc[0]);
                    Console.Write("{0:X4} ", acc[1]);
                    Console.Write("{0:X4} ", acc[2]);*/

                    Console.Write(gyro[0] / CONV_GYRO_RESOLUTION + "\t");
                    Console.Write(gyro[1] / CONV_GYRO_RESOLUTION + "\t");
                    Console.Write(gyro[2] / CONV_GYRO_RESOLUTION + "\t");

                    Console.Write(acc[0] / CONV_ACC_RESOLUTION + "\t");
                    Console.Write(acc[1] / CONV_ACC_RESOLUTION + "\t");
                    Console.Write(acc[2] / CONV_ACC_RESOLUTION + "\t");

                    Console.WriteLine();
                }
                else invalidMessage++;
            } else  invalidPackets++;
        }
        private void addData(byte i)
        {
            PendingPacket.contents[PendingPacket.index] = i;
            PendingPacket.index++;
        }
        private void clearPacket()
        {
            EmptyPacket.CopyTo(PendingPacket.contents, 0);
            PendingPacket.index = 0;
        }
    }
}
