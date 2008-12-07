using System;
using Microsoft.Dss.Core.Attributes;
using Microsoft.Dss.Core.Transforms;

#if NET_CF20
[assembly: ServiceDeclaration(DssServiceDeclaration.Transform, SourceAssemblyKey = @"cf.maincontrol.y2008.m03, version=0.0.0.0, culture=neutral, publickeytoken=1ab751c944756d21")]
#else
[assembly: ServiceDeclaration(DssServiceDeclaration.Transform, SourceAssemblyKey = @"maincontrol.y2008.m03, version=0.0.0.0, culture=neutral, publickeytoken=1ab751c944756d21")]
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


        public static object Transform_RoboMagellan_Proxy_MainControlStates_TO_RoboMagellan_MainControlStates(object transformFrom)
        {
            RoboMagellan.MainControlStates target = new RoboMagellan.MainControlStates();
            return target;
        }


        public static object Transform_RoboMagellan_MainControlStates_TO_RoboMagellan_Proxy_MainControlStates(object transformFrom)
        {
            RoboMagellan.Proxy.MainControlStates target = new RoboMagellan.Proxy.MainControlStates();
            return target;
        }

        static Transforms()
        {
            Register();
        }
        public static void Register()
        {
            AddProxyTransform(typeof(RoboMagellan.Proxy.MainControlState), Transform_RoboMagellan_Proxy_MainControlState_TO_RoboMagellan_MainControlState);
            AddSourceTransform(typeof(RoboMagellan.MainControlState), Transform_RoboMagellan_MainControlState_TO_RoboMagellan_Proxy_MainControlState);
            AddProxyTransform(typeof(RoboMagellan.Proxy.MainControlStates), Transform_RoboMagellan_Proxy_MainControlStates_TO_RoboMagellan_MainControlStates);
            AddSourceTransform(typeof(RoboMagellan.MainControlStates), Transform_RoboMagellan_MainControlStates_TO_RoboMagellan_Proxy_MainControlStates);
        }
    }
}

