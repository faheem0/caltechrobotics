//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated by a tool.
//     Runtime Version:2.0.50727.1433
//
//     Changes to this file may cause incorrect behavior and will be lost if
//     the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

using Microsoft.Ccr.Core;
using Microsoft.Dss.Core.Attributes;
using Microsoft.Dss.ServiceModel.Dssp;
using System;
using System.Collections.Generic;
using W3C.Soap;
using robomagellan = RoboMagellan;


namespace RoboMagellan.MotorControl
{
    
    
    /// <summary>
    /// GenericMotor Contract class
    /// </summary>
    public sealed class Contract
    {
        
        /// <summary>
        /// The Dss Service contract
        /// </summary>
        public const String Identifier = "http://schemas.tempuri.org/2008/03/genericmotor.html";
    }
    
    /// <summary>
    /// The GenericMotor State
    /// </summary>
    [DataContract()]
    public class GenericMotorState
    {
    }
    
    /// <summary>
    /// GenericMotor Main Operations Port
    /// </summary>
    [ServicePort()]
    public class GenericMotorOperations : PortSet<DsspDefaultLookup, 
                                                  DsspDefaultDrop, 
                                                  Get,
                                                  SetSpeed,
                                                  Stop,
                                                  SendAck>
    {
    }

    public class SendAck : Update<object, DsspResponsePort<DefaultUpdateResponseType>>
    {
        public SendAck() { }
    }

    public class Stop : Update<object, DsspResponsePort<DefaultUpdateResponseType>>
    {
        public Stop() { }
    }

    public class SetSpeed : Update<MotorSpeed, DsspResponsePort<DefaultUpdateResponseType>>
    {
        public SetSpeed(MotorSpeed s) { this.Body = s; }

        public SetSpeed() { }
    }

    [DataContract()]
    public struct MotorSpeed
    {
        private SByte _left;
        private SByte _right;

        public SByte Left
        {
            get { return _left; }
            set { _left = value; }
        }

        public SByte Right
        {
            get { return _right; }
            set { _right = value; }
        }
    }
    /// <summary>
    /// GenericMotor Get Operation
    /// </summary>
    public class Get : Get<GetRequestType, PortSet<GenericMotorState, Fault>>
    {
        
        /// <summary>
        /// GenericMotor Get Operation
        /// </summary>
        public Get()
        {
        }
        
        /// <summary>
        /// GenericMotor Get Operation
        /// </summary>
        public Get(Microsoft.Dss.ServiceModel.Dssp.GetRequestType body) : 
                base(body)
        {
        }
        
        /// <summary>
        /// GenericMotor Get Operation
        /// </summary>
        public Get(Microsoft.Dss.ServiceModel.Dssp.GetRequestType body, Microsoft.Ccr.Core.PortSet<GenericMotorState,W3C.Soap.Fault> responsePort) : 
                base(body, responsePort)
        {
        }
    }
}