using System;


namespace IMU
{
    struct Packet
    {
        public byte[] contents;
        public int index;
    }
    enum PInf
    {
        MESSAGE_TYPE,
        LENGTH,
        X_GYRO_MSB,
        X_GYRO_LSB,
        Y_GYRO_MSB,
        Y_GYRO_LSB,
        Z_GYRO_MSB,
        Z_GYRO_LSB,
        X_ACC_MSB,
        X_ACC_LSB,
        Y_ACC_MSB,
        Y_ACC_LSB,
        Z_ACC_MSB,
        Z_ACC_LSB,
        TIMER_MMSB,
        TIMER_MSB,
        TIMER_LSB,
        TIMER_LLSB,
        PPS,
        SEQUENCE_NUMBER,
        CRC16H,
        CRC16L
    }
}
