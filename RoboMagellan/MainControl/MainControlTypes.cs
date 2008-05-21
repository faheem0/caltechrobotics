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
using Microsoft.Dss.Core;
using Microsoft.Dss.Core.Attributes;
using Microsoft.Dss.ServiceModel.Dssp;
using Microsoft.Dss.Core.DsspHttp;
using System;
using System.Collections.Generic;
using W3C.Soap;
using robomagellan = RoboMagellan;
using gps = RoboMagellan.GenericGPS.Proxy;


namespace RoboMagellan
{
    
    
    /// <summary>
    /// MainControl Contract class
    /// </summary>
    public sealed class Contract
    {
        
        /// <summary>
        /// The Dss Service contract
        /// </summary>
        public const String Identifier = "http://schemas.tempuri.org/2008/03/maincontrol.html";
    }

    [DataContract()]
    public enum MainControlStates
    {
        STATE_STOPPING,
        STATE_STOPPED,
        STATE_TURNING,
        STATE_DRIVING,
        STATE_ERROR
    }

    /// <summary>
    /// The MainControl State
    /// </summary>
    [DataContract()]
    public class MainControlState
    {
        public MainControlStates _state;

        public gps.UTMData _location;

        public gps.UTMData _destination;

        public Queue<gps.UTMData> _destinations = new Queue<gps.UTMData>();
    }

    /// <summary>
    /// The MainControl Update State
    /// </summary>
    [DataContract()]
    public struct MainControlUpdateState
    {
        [DataMember]
        public MainControlStates _state;

        [DataMember]
        public gps.UTMData _location;

        [DataMember]
        public gps.UTMData _destination;

        [DataMember]
        public gps.UTMData[] _destinations;
    }

    public class Subscribe : Subscribe<SubscribeRequestType, PortSet<SubscribeResponseType, Fault>, MainControlOperations> { }

    public class StateNotification : Update<MainControlUpdateState, DsspResponsePort<DefaultUpdateResponseType>>
    {
        public StateNotification(MainControlUpdateState s) { this.Body = s; }

        public StateNotification() { }
    }
    /// <summary>
    /// MainControl Main Operations Port
    /// </summary>
    [ServicePort()]
    public class MainControlOperations : PortSet<DsspDefaultLookup, 
                                                DsspDefaultDrop, 
                                                Get, 
                                                Subscribe, 
                                                HttpGet,
                                                HttpPost, 
                                                StateNotification,
                                                Enqueue>
    {
    }

    public class Enqueue : Submit<gps.UTMData, DsspResponsePort<DefaultSubmitResponseType>>
    {
        public Enqueue() { }
        public Enqueue(gps.UTMData a) { this.Body = a; }
    }

    /// <summary>
    /// MainControl Get Operation
    /// </summary>
    public class Get : Get<GetRequestType, PortSet<MainControlState, Fault>>
    {
        
        /// <summary>
        /// MainControl Get Operation
        /// </summary>
        public Get()
        {
        }
        
        /// <summary>
        /// MainControl Get Operation
        /// </summary>
        public Get(Microsoft.Dss.ServiceModel.Dssp.GetRequestType body) : 
                base(body)
        {
        }
        
        /// <summary>
        /// MainControl Get Operation
        /// </summary>
        public Get(Microsoft.Dss.ServiceModel.Dssp.GetRequestType body, Microsoft.Ccr.Core.PortSet<MainControlState,W3C.Soap.Fault> responsePort) : 
                base(body, responsePort)
        {
        }
    }
}
