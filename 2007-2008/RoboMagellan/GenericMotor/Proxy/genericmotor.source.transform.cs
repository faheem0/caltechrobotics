using System;
using Microsoft.Dss.Core.Attributes;
using Microsoft.Dss.Core.Transforms;

#if NET_CF20
[assembly: ServiceDeclaration(DssServiceDeclaration.Transform, SourceAssemblyKey = @"cf.genericmotor.y2008.m03, version=0.0.0.0, culture=neutral, publickeytoken=1ab751c944756d21")]
#else
[assembly: ServiceDeclaration(DssServiceDeclaration.Transform, SourceAssemblyKey = @"genericmotor.y2008.m03, version=0.0.0.0, culture=neutral, publickeytoken=1ab751c944756d21")]
#endif
#if !URT_MINCLR
[assembly: System.Security.SecurityTransparent]
[assembly: System.Security.AllowPartiallyTrustedCallers]
#endif

namespace Dss.Transforms.TransformGenericMotor
{

    public class Transforms: TransformBase
    {

        public static object Transform_RoboMagellan_MotorControl_Proxy_GenericMotorState_TO_RoboMagellan_MotorControl_GenericMotorState(object transformFrom)
        {
            RoboMagellan.MotorControl.GenericMotorState target = new RoboMagellan.MotorControl.GenericMotorState();
            return target;
        }


        private static RoboMagellan.MotorControl.Proxy.GenericMotorState _instance_RoboMagellan_MotorControl_Proxy_GenericMotorState = new RoboMagellan.MotorControl.Proxy.GenericMotorState();
        public static object Transform_RoboMagellan_MotorControl_GenericMotorState_TO_RoboMagellan_MotorControl_Proxy_GenericMotorState(object ignore)
        {
            return _instance_RoboMagellan_MotorControl_Proxy_GenericMotorState;
        }


        public static object Transform_RoboMagellan_MotorControl_Proxy_MotorSpeed_TO_RoboMagellan_MotorControl_MotorSpeed(object transformFrom)
        {
            RoboMagellan.MotorControl.MotorSpeed target = new RoboMagellan.MotorControl.MotorSpeed();
            RoboMagellan.MotorControl.Proxy.MotorSpeed from = (RoboMagellan.MotorControl.Proxy.MotorSpeed)transformFrom;
            target.Left = from.Left;
            target.Right = from.Right;
            return target;
        }


        public static object Transform_RoboMagellan_MotorControl_MotorSpeed_TO_RoboMagellan_MotorControl_Proxy_MotorSpeed(object transformFrom)
        {
            RoboMagellan.MotorControl.Proxy.MotorSpeed target = new RoboMagellan.MotorControl.Proxy.MotorSpeed();
            RoboMagellan.MotorControl.MotorSpeed from = (RoboMagellan.MotorControl.MotorSpeed)transformFrom;
            target.Left = from.Left;
            target.Right = from.Right;
            return target;
        }


        public static object Transform_RoboMagellan_MotorControl_Proxy_StopInfo_TO_RoboMagellan_MotorControl_StopInfo(object transformFrom)
        {
            RoboMagellan.MotorControl.StopInfo target = new RoboMagellan.MotorControl.StopInfo();
            return target;
        }


        public static object Transform_RoboMagellan_MotorControl_StopInfo_TO_RoboMagellan_MotorControl_Proxy_StopInfo(object transformFrom)
        {
            RoboMagellan.MotorControl.Proxy.StopInfo target = new RoboMagellan.MotorControl.Proxy.StopInfo();
            return target;
        }


        public static object Transform_RoboMagellan_MotorControl_Proxy_AckInfo_TO_RoboMagellan_MotorControl_AckInfo(object transformFrom)
        {
            RoboMagellan.MotorControl.AckInfo target = new RoboMagellan.MotorControl.AckInfo();
            return target;
        }


        public static object Transform_RoboMagellan_MotorControl_AckInfo_TO_RoboMagellan_MotorControl_Proxy_AckInfo(object transformFrom)
        {
            RoboMagellan.MotorControl.Proxy.AckInfo target = new RoboMagellan.MotorControl.Proxy.AckInfo();
            return target;
        }


        public static object Transform_RoboMagellan_MotorControl_Proxy_TurnData_TO_RoboMagellan_MotorControl_TurnData(object transformFrom)
        {
            RoboMagellan.MotorControl.TurnData target = new RoboMagellan.MotorControl.TurnData();
            RoboMagellan.MotorControl.Proxy.TurnData from = (RoboMagellan.MotorControl.Proxy.TurnData)transformFrom;
            target.heading = from.heading;
            return target;
        }


        public static object Transform_RoboMagellan_MotorControl_TurnData_TO_RoboMagellan_MotorControl_Proxy_TurnData(object transformFrom)
        {
            RoboMagellan.MotorControl.Proxy.TurnData target = new RoboMagellan.MotorControl.Proxy.TurnData();
            RoboMagellan.MotorControl.TurnData from = (RoboMagellan.MotorControl.TurnData)transformFrom;
            target.heading = from.heading;
            return target;
        }

        static Transforms()
        {
            Register();
        }
        public static void Register()
        {
            AddProxyTransform(typeof(RoboMagellan.MotorControl.Proxy.GenericMotorState), Transform_RoboMagellan_MotorControl_Proxy_GenericMotorState_TO_RoboMagellan_MotorControl_GenericMotorState);
            AddSourceTransform(typeof(RoboMagellan.MotorControl.GenericMotorState), Transform_RoboMagellan_MotorControl_GenericMotorState_TO_RoboMagellan_MotorControl_Proxy_GenericMotorState);
            AddProxyTransform(typeof(RoboMagellan.MotorControl.Proxy.MotorSpeed), Transform_RoboMagellan_MotorControl_Proxy_MotorSpeed_TO_RoboMagellan_MotorControl_MotorSpeed);
            AddSourceTransform(typeof(RoboMagellan.MotorControl.MotorSpeed), Transform_RoboMagellan_MotorControl_MotorSpeed_TO_RoboMagellan_MotorControl_Proxy_MotorSpeed);
            AddProxyTransform(typeof(RoboMagellan.MotorControl.Proxy.StopInfo), Transform_RoboMagellan_MotorControl_Proxy_StopInfo_TO_RoboMagellan_MotorControl_StopInfo);
            AddSourceTransform(typeof(RoboMagellan.MotorControl.StopInfo), Transform_RoboMagellan_MotorControl_StopInfo_TO_RoboMagellan_MotorControl_Proxy_StopInfo);
            AddProxyTransform(typeof(RoboMagellan.MotorControl.Proxy.AckInfo), Transform_RoboMagellan_MotorControl_Proxy_AckInfo_TO_RoboMagellan_MotorControl_AckInfo);
            AddSourceTransform(typeof(RoboMagellan.MotorControl.AckInfo), Transform_RoboMagellan_MotorControl_AckInfo_TO_RoboMagellan_MotorControl_Proxy_AckInfo);
            AddProxyTransform(typeof(RoboMagellan.MotorControl.Proxy.TurnData), Transform_RoboMagellan_MotorControl_Proxy_TurnData_TO_RoboMagellan_MotorControl_TurnData);
            AddSourceTransform(typeof(RoboMagellan.MotorControl.TurnData), Transform_RoboMagellan_MotorControl_TurnData_TO_RoboMagellan_MotorControl_Proxy_TurnData);
        }
    }
}

