using System;
using Microsoft.Dss.Core.Attributes;
using Microsoft.Dss.Core.Transforms;

#if NET_CF20
[assembly: ServiceDeclaration(DssServiceDeclaration.Transform, SourceAssemblyKey = @"cf.genericcompass.y2008.m05, version=0.0.0.0, culture=neutral, publickeytoken=00557257f0c3f8b7")]
#else
[assembly: ServiceDeclaration(DssServiceDeclaration.Transform, SourceAssemblyKey = @"genericcompass.y2008.m05, version=0.0.0.0, culture=neutral, publickeytoken=00557257f0c3f8b7")]
#endif
#if !URT_MINCLR
[assembly: System.Security.SecurityTransparent]
[assembly: System.Security.AllowPartiallyTrustedCallers]
#endif

namespace Dss.Transforms.TransformGenericCompass
{

    public class Transforms: TransformBase
    {

        public static object Transform_RoboMagellan_GenericCompass_Proxy_GenericCompassState_TO_RoboMagellan_GenericCompass_GenericCompassState(object transformFrom)
        {
            RoboMagellan.GenericCompass.GenericCompassState target = new RoboMagellan.GenericCompass.GenericCompassState();
            RoboMagellan.GenericCompass.Proxy.GenericCompassState from = transformFrom as RoboMagellan.GenericCompass.Proxy.GenericCompassState;
            target.currentAngle = (RoboMagellan.GenericCompass.CompassData)Transform_RoboMagellan_GenericCompass_Proxy_CompassData_TO_RoboMagellan_GenericCompass_CompassData(from.currentAngle);
            return target;
        }


        public static object Transform_RoboMagellan_GenericCompass_GenericCompassState_TO_RoboMagellan_GenericCompass_Proxy_GenericCompassState(object transformFrom)
        {
            RoboMagellan.GenericCompass.Proxy.GenericCompassState target = new RoboMagellan.GenericCompass.Proxy.GenericCompassState();
            RoboMagellan.GenericCompass.GenericCompassState from = transformFrom as RoboMagellan.GenericCompass.GenericCompassState;
            target.currentAngle = (RoboMagellan.GenericCompass.Proxy.CompassData)Transform_RoboMagellan_GenericCompass_CompassData_TO_RoboMagellan_GenericCompass_Proxy_CompassData(from.currentAngle);
            return target;
        }


        public static object Transform_RoboMagellan_GenericCompass_Proxy_CompassData_TO_RoboMagellan_GenericCompass_CompassData(object transformFrom)
        {
            RoboMagellan.GenericCompass.CompassData target = new RoboMagellan.GenericCompass.CompassData();
            RoboMagellan.GenericCompass.Proxy.CompassData from = (RoboMagellan.GenericCompass.Proxy.CompassData)transformFrom;
            target.angle = from.angle;
            return target;
        }


        public static object Transform_RoboMagellan_GenericCompass_CompassData_TO_RoboMagellan_GenericCompass_Proxy_CompassData(object transformFrom)
        {
            RoboMagellan.GenericCompass.Proxy.CompassData target = new RoboMagellan.GenericCompass.Proxy.CompassData();
            RoboMagellan.GenericCompass.CompassData from = (RoboMagellan.GenericCompass.CompassData)transformFrom;
            target.angle = from.angle;
            return target;
        }

        static Transforms()
        {
            Register();
        }
        public static void Register()
        {
            AddProxyTransform(typeof(RoboMagellan.GenericCompass.Proxy.GenericCompassState), Transform_RoboMagellan_GenericCompass_Proxy_GenericCompassState_TO_RoboMagellan_GenericCompass_GenericCompassState);
            AddSourceTransform(typeof(RoboMagellan.GenericCompass.GenericCompassState), Transform_RoboMagellan_GenericCompass_GenericCompassState_TO_RoboMagellan_GenericCompass_Proxy_GenericCompassState);
            AddProxyTransform(typeof(RoboMagellan.GenericCompass.Proxy.CompassData), Transform_RoboMagellan_GenericCompass_Proxy_CompassData_TO_RoboMagellan_GenericCompass_CompassData);
            AddSourceTransform(typeof(RoboMagellan.GenericCompass.CompassData), Transform_RoboMagellan_GenericCompass_CompassData_TO_RoboMagellan_GenericCompass_Proxy_CompassData);
        }
    }
}

