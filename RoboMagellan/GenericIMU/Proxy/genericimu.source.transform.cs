using System;
using Microsoft.Dss.Core.Attributes;
using Microsoft.Dss.Core.Transforms;

#if NET_CF20
[assembly: ServiceDeclaration(DssServiceDeclaration.Transform, SourceAssemblyKey = @"cf.genericimu.y2008.m03, version=0.0.0.0, culture=neutral, publickeytoken=3f3b6e33a7ff1111")]
#else
[assembly: ServiceDeclaration(DssServiceDeclaration.Transform, SourceAssemblyKey = @"genericimu.y2008.m03, version=0.0.0.0, culture=neutral, publickeytoken=3f3b6e33a7ff1111")]
#endif
#if !URT_MINCLR
[assembly: System.Security.SecurityTransparent]
[assembly: System.Security.AllowPartiallyTrustedCallers]
#endif

namespace Dss.Transforms.TransformGenericIMU
{

    public class Transforms: TransformBase
    {

        public static object Transform_RoboMagellan_GenericIMU_Proxy_GenericIMUState_TO_RoboMagellan_GenericIMU_GenericIMUState(object transformFrom)
        {
            RoboMagellan.GenericIMU.GenericIMUState target = new RoboMagellan.GenericIMU.GenericIMUState();
            RoboMagellan.GenericIMU.Proxy.GenericIMUState from = transformFrom as RoboMagellan.GenericIMU.Proxy.GenericIMUState;
            target.Data = (RoboMagellan.GenericIMU.IMUData)Transform_RoboMagellan_GenericIMU_Proxy_IMUData_TO_RoboMagellan_GenericIMU_IMUData(from.Data);
            return target;
        }


        public static object Transform_RoboMagellan_GenericIMU_GenericIMUState_TO_RoboMagellan_GenericIMU_Proxy_GenericIMUState(object transformFrom)
        {
            RoboMagellan.GenericIMU.Proxy.GenericIMUState target = new RoboMagellan.GenericIMU.Proxy.GenericIMUState();
            RoboMagellan.GenericIMU.GenericIMUState from = transformFrom as RoboMagellan.GenericIMU.GenericIMUState;
            target.Data = (RoboMagellan.GenericIMU.Proxy.IMUData)Transform_RoboMagellan_GenericIMU_IMUData_TO_RoboMagellan_GenericIMU_Proxy_IMUData(from.Data);
            return target;
        }


        public static object Transform_RoboMagellan_GenericIMU_Proxy_IMUData_TO_RoboMagellan_GenericIMU_IMUData(object transformFrom)
        {
            RoboMagellan.GenericIMU.IMUData target = new RoboMagellan.GenericIMU.IMUData();
            RoboMagellan.GenericIMU.Proxy.IMUData from = (RoboMagellan.GenericIMU.Proxy.IMUData)transformFrom;
            target.AngleX = from.AngleX;
            target.AngleY = from.AngleY;
            target.AngleZ = from.AngleZ;
            target.GyroX = from.GyroX;
            target.GyroY = from.GyroY;
            target.GyroZ = from.GyroZ;
            target.AccelX = from.AccelX;
            target.AccelY = from.AccelY;
            target.AccelZ = from.AccelZ;
            return target;
        }


        public static object Transform_RoboMagellan_GenericIMU_IMUData_TO_RoboMagellan_GenericIMU_Proxy_IMUData(object transformFrom)
        {
            RoboMagellan.GenericIMU.Proxy.IMUData target = new RoboMagellan.GenericIMU.Proxy.IMUData();
            RoboMagellan.GenericIMU.IMUData from = (RoboMagellan.GenericIMU.IMUData)transformFrom;
            target.AngleX = from.AngleX;
            target.AngleY = from.AngleY;
            target.AngleZ = from.AngleZ;
            target.GyroX = from.GyroX;
            target.GyroY = from.GyroY;
            target.GyroZ = from.GyroZ;
            target.AccelX = from.AccelX;
            target.AccelY = from.AccelY;
            target.AccelZ = from.AccelZ;
            return target;
        }

        static Transforms()
        {
            Register();
        }
        public static void Register()
        {
            AddProxyTransform(typeof(RoboMagellan.GenericIMU.Proxy.GenericIMUState), Transform_RoboMagellan_GenericIMU_Proxy_GenericIMUState_TO_RoboMagellan_GenericIMU_GenericIMUState);
            AddSourceTransform(typeof(RoboMagellan.GenericIMU.GenericIMUState), Transform_RoboMagellan_GenericIMU_GenericIMUState_TO_RoboMagellan_GenericIMU_Proxy_GenericIMUState);
            AddProxyTransform(typeof(RoboMagellan.GenericIMU.Proxy.IMUData), Transform_RoboMagellan_GenericIMU_Proxy_IMUData_TO_RoboMagellan_GenericIMU_IMUData);
            AddSourceTransform(typeof(RoboMagellan.GenericIMU.IMUData), Transform_RoboMagellan_GenericIMU_IMUData_TO_RoboMagellan_GenericIMU_Proxy_IMUData);
        }
    }
}

