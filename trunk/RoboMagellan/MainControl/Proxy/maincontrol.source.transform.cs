using System;
using Microsoft.Dss.Core.Attributes;
using Microsoft.Dss.Core.Transforms;

#if NET_CF20
[assembly: ServiceDeclaration(DssServiceDeclaration.Transform, SourceAssemblyKey = @"cf.maincontrol.y2008.m03, version=0.0.0.0, culture=neutral, publickeytoken=00557257f0c3f8b7")]
#else
[assembly: ServiceDeclaration(DssServiceDeclaration.Transform, SourceAssemblyKey = @"maincontrol.y2008.m03, version=0.0.0.0, culture=neutral, publickeytoken=00557257f0c3f8b7")]
#endif
#if !URT_MINCLR
[assembly: System.Security.SecurityTransparent]
[assembly: System.Security.AllowPartiallyTrustedCallers]
#endif

namespace Dss.Transforms.TransformMainControl
{

    public class Transforms: TransformBase
    {

        public static object Transform_RoboMagellan_Proxy_MainControlState_TO_RoboMagellan_MainControlState(object transformFrom)
        {
            RoboMagellan.MainControlState target = new RoboMagellan.MainControlState();
            return target;
        }


        private static RoboMagellan.Proxy.MainControlState _instance_RoboMagellan_Proxy_MainControlState = new RoboMagellan.Proxy.MainControlState();
        public static object Transform_RoboMagellan_MainControlState_TO_RoboMagellan_Proxy_MainControlState(object ignore)
        {
            return _instance_RoboMagellan_Proxy_MainControlState;
        }

        static Transforms()
        {
            Register();
        }
        public static void Register()
        {
            AddProxyTransform(typeof(RoboMagellan.Proxy.MainControlState), Transform_RoboMagellan_Proxy_MainControlState_TO_RoboMagellan_MainControlState);
            AddSourceTransform(typeof(RoboMagellan.MainControlState), Transform_RoboMagellan_MainControlState_TO_RoboMagellan_Proxy_MainControlState);
        }
    }
}

