using System;
using System.IO.Ports;

namespace IMU
{
    class CristaIMU
    {
        public static float CONV_GYRO_RESOLUTION = 109.22666666667f;
        public static float CONV_ACC_RESOLUTION = 334.1968383478f;
        public static uint IMU_CLOCK_FREQ = 10000000;

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
        static uint DT_THRESHOLD = IMU_CLOCK_FREQ / 2; // 1/2 Second
        static float[] DriftOffsets = new float[3] { 0.07f, -0.01f, 0.00f };

        private SerialPort myIMU;
        private int state;
        private int invalidPackets;
        private int invalidMessage;
        private Int16[] rawGyro;
        private Int16[] rawAcc;
        private float[] gyro;
        private float[] acc;
        private float[] DriftyIntegratedAngle;
        private uint lastTimestamp;
        private double temp1;     // DELETE ME!!!1
        private Int64 temp2;     // DELETE ME!!!2

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

            temp1 = 0.0;
            temp2 = 0;


            EmptyPacket = new byte[PACKET_BUFFER_SIZE];

            rawGyro = new Int16[3];
            rawAcc = new Int16[3];
            gyro = new float[3];
            acc = new float[3];
            DriftyIntegratedAngle = new float[3];
            lastTimestamp = 0;

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
                    byte byteRead = (byte)myIMU.ReadByte();

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

                    //Console.Write("Packet: ");

                    byte[] myPacket = PendingPacket.contents;

                    //Get Gyro Data
                    rawGyro[0] = myPacket[(int)PInf.X_GYRO_MSB];
                    rawGyro[0] = (Int16)(((uint)rawGyro[0] << 8) | (UInt16)myPacket[(int)PInf.X_GYRO_LSB]);
                    rawGyro[1] = myPacket[(int)PInf.Y_GYRO_MSB];
                    rawGyro[1] = (Int16)(((uint)rawGyro[1] << 8) | (UInt16)myPacket[(int)PInf.Y_GYRO_LSB]);
                    rawGyro[2] = myPacket[(int)PInf.Z_GYRO_MSB];
                    rawGyro[2] = (Int16)(((uint)rawGyro[2] << 8) | (UInt16)myPacket[(int)PInf.Z_GYRO_LSB]);

                    //Get Accelerometer Data
                    rawAcc[0] = myPacket[(int)PInf.X_ACC_MSB];
                    rawAcc[0] = (Int16)(((uint)rawAcc[0] << 8) | (UInt16)myPacket[(int)PInf.X_ACC_LSB]);
                    rawAcc[1] = myPacket[(int)PInf.Y_ACC_MSB];
                    rawAcc[1] = (Int16)(((uint)rawAcc[1] << 8) | (UInt16)myPacket[(int)PInf.Y_ACC_LSB]);
                    rawAcc[2] = myPacket[(int)PInf.Z_ACC_MSB];
                    rawAcc[2] = (Int16)(((uint)rawAcc[2] << 8) | (UInt16)myPacket[(int)PInf.Z_ACC_LSB]);

                    uint currentTimestamp;
                    currentTimestamp = (uint)myPacket[(int)PInf.TIMER_MMSB] << 24;
                    currentTimestamp |= (uint)myPacket[(int)PInf.TIMER_MSB] << 16;
                    currentTimestamp |= (uint)myPacket[(int)PInf.TIMER_LSB] << 8;
                    currentTimestamp |= (uint)myPacket[(int)PInf.TIMER_LLSB];

                    uint dT = currentTimestamp - lastTimestamp;
                    lastTimestamp = currentTimestamp;
                    for (int i = 0; i < 3; i++)
                    {
                        gyro[i] = rawGyro[i] / CONV_GYRO_RESOLUTION;
                        acc[i] = rawAcc[i] / CONV_ACC_RESOLUTION;
                        if (dT < DT_THRESHOLD)
                        {
                            float dAngle = gyro[i] * (float)dT / (float)IMU_CLOCK_FREQ;     //Get dAngle in degrees
                            //dAngle += DriftOffsets[i];                                      //Compensate for constant drift
                            /*dAngle *= 100.0f;
                            dAngle = (float)Math.Truncate((double)dAngle);
                            dAngle /= 100.0f;*/

                            DriftyIntegratedAngle[i] += dAngle;
                            temp1 += gyro[i];
                            temp2++;
                            //Console.Write(temp1 / temp2 + "\t");
                            //Console.Write(dAngle + "\t");
                            //Console.WriteLine(DriftyIntegratedAngle[i] + "\t");
                        }
                    }


                    /*Console.Write("{0:X4} ", rawGyro[0]);
                    Console.Write("{0:X4} ", rawGyro[1]);
                    Console.Write("{0:X4} ", rawGyro[2]);

                    Console.Write("{0:X4} ", acc[0]);
                    Console.Write("{0:X4} ", acc[1]);
                    Console.Write("{0:X4} ", acc[2]);*/

                    /*Console.Write(gyro[0] + "\t");
                    Console.Write(gyro[1] + "\t");
                    Console.Write(gyro[2] + "\t");*/

                    Console.Clear();
                    Console.WriteLine("gyro X: " + DriftyIntegratedAngle[0] + " degrees");
                    Console.WriteLine("gyro Y: " + DriftyIntegratedAngle[1] + " degrees");
                    Console.WriteLine("gyro Z: " + DriftyIntegratedAngle[2] + " degrees");

                    Console.WriteLine("acc X: " + acc[0] + " m/s^2");
                    Console.WriteLine("acc Y: " + acc[1] + " m/s^2");
                    Console.WriteLine("acc Z: " + acc[2] + " m/s^2");

                    //Console.Write(currentTimestamp / IMU_CLOCK_FREQ + "\t");
                    Console.WriteLine();
                }
                else invalidMessage++;
            }
            else invalidPackets++;

        }
        private void addData(byte i)
        {
            try
            {
                PendingPacket.contents[PendingPacket.index] = i;
                PendingPacket.index++;
            }
            catch (IndexOutOfRangeException) { }
        }
        private void clearPacket()
        {
            EmptyPacket.CopyTo(PendingPacket.contents, 0);
            PendingPacket.index = 0;
        }
    }
}
