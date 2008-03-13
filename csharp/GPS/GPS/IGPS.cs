using System;

namespace GPS
{
    public interface IGPS
    {
        double getEastUTM();
        double getNorthUTM();
        int getSatUTM();
        double getTimestampUTM();
    }
    struct UTMData
    {
        public double East;
        public double North;
        public int NumSat;
        public double Timestamp;
    }
}
