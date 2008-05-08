using System;
using Microsoft.Dss.Core.Attributes;
using Microsoft.Dss.Core.Transforms;

#if NET_CF20
[assembly: ServiceDeclaration(DssServiceDeclaration.Transform, SourceAssemblyKey = @"cf.genericgps.y2008.m03, version=0.0.0.0, culture=neutral, publickeytoken=1ab751c944756d21")]
#else
[assembly: ServiceDeclaration(DssServiceDeclaration.Transform, SourceAssemblyKey = @"genericgps.y2008.m03, version=0.0.0.0, culture=neutral, publickeytoken=1ab751c944756d21")]
#endif
#if !URT_MINCLR
[assembly: System.Security.SecurityTransparent]
[assembly: System.Security.AllowPartiallyTrustedCallers]
#endif

namespace Dss.Transforms.TransformGenericGPS
{

    public class Transforms: TransformBase
    {

        public static object Transform_RoboMagellan_GenericGPS_Proxy_GenericGPSState_TO_RoboMagellan_GenericGPS_GenericGPSState(object transformFrom)
        {
            RoboMagellan.GenericGPS.GenericGPSState target = new RoboMagellan.GenericGPS.GenericGPSState();
            RoboMagellan.GenericGPS.Proxy.GenericGPSState from = transformFrom as RoboMagellan.GenericGPS.Proxy.GenericGPSState;
            target.Coords = (RoboMagellan.GenericGPS.UTMData)Transform_RoboMagellan_GenericGPS_Proxy_UTMData_TO_RoboMagellan_GenericGPS_UTMData(from.Coords);
            return target;
        }


        public static object Transform_RoboMagellan_GenericGPS_GenericGPSState_TO_RoboMagellan_GenericGPS_Proxy_GenericGPSState(object transformFrom)
        {
            RoboMagellan.GenericGPS.Proxy.GenericGPSState target = new RoboMagellan.GenericGPS.Proxy.GenericGPSState();
            RoboMagellan.GenericGPS.GenericGPSState from = transformFrom as RoboMagellan.GenericGPS.GenericGPSState;
            target.Coords = (RoboMagellan.GenericGPS.Proxy.UTMData)Transform_RoboMagellan_GenericGPS_UTMData_TO_RoboMagellan_GenericGPS_Proxy_UTMData(from.Coords);
            return target;
        }


        public static object Transform_RoboMagellan_GenericGPS_Proxy_UTMData_TO_RoboMagellan_GenericGPS_UTMData(object transformFrom)
        {
            RoboMagellan.GenericGPS.UTMData target = new RoboMagellan.GenericGPS.UTMData();
            RoboMagellan.GenericGPS.Proxy.UTMData from = (RoboMagellan.GenericGPS.Proxy.UTMData)transformFrom;
            target.NumSat = from.NumSat;
            target.Timestamp = from.Timestamp;
            target.East = from.East;
            target.North = from.North;
            return target;
        }


        public static object Transform_RoboMagellan_GenericGPS_UTMData_TO_RoboMagellan_GenericGPS_Proxy_UTMData(object transformFrom)
        {
            RoboMagellan.GenericGPS.Proxy.UTMData target = new RoboMagellan.GenericGPS.Proxy.UTMData();
            RoboMagellan.GenericGPS.UTMData from = (RoboMagellan.GenericGPS.UTMData)transformFrom;
            target.NumSat = from.NumSat;
            target.Timestamp = from.Timestamp;
            target.East = from.East;
            target.North = from.North;
            return target;
        }

        static Transforms()
        {
            Register();
        }
        public static void Register()
        {
            AddProxyTransform(typeof(RoboMagellan.GenericGPS.Proxy.GenericGPSState), Transform_RoboMagellan_GenericGPS_Proxy_GenericGPSState_TO_RoboMagellan_GenericGPS_GenericGPSState);
            AddSourceTransform(typeof(RoboMagellan.GenericGPS.GenericGPSState), Transform_RoboMagellan_GenericGPS_GenericGPSState_TO_RoboMagellan_GenericGPS_Proxy_GenericGPSState);
            AddProxyTransform(typeof(RoboMagellan.GenericGPS.Proxy.UTMData), Transform_RoboMagellan_GenericGPS_Proxy_UTMData_TO_RoboMagellan_GenericGPS_UTMData);
            AddSourceTransform(typeof(RoboMagellan.GenericGPS.UTMData), Transform_RoboMagellan_GenericGPS_UTMData_TO_RoboMagellan_GenericGPS_Proxy_UTMData);
        }
    }
}

