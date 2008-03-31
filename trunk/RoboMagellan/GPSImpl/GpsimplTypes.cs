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


namespace RoboMagellan.GPSImpl
{
    
    
    /// <summary>
    /// Gpsimpl Contract class
    /// </summary>
    public sealed class Contract
    {
        
        /// <summary>
        /// The Dss Service contract
        /// </summary>
        public const String Identifier = "http://schemas.tempuri.org/2008/03/genericgps/gpsimpl.html";
    }
    /*
    /// <summary>
    /// The Gpsimpl State
    /// </summary>
    [DataContract()]
    public class GpsimplState
    {
    }
    
    /// <summary>
    /// Gpsimpl Main Operations Port
    /// </summary>
    [ServicePort()]
    public class GpsimplOperations : PortSet<DsspDefaultLookup, DsspDefaultDrop, Get>
    {
    }
    
    /// <summary>
    /// Gpsimpl Get Operation
    /// </summary>
    public class Get : Get<GetRequestType, PortSet<GpsimplState, Fault>>
    {
        
        /// <summary>
        /// Gpsimpl Get Operation
        /// </summary>
        public Get()
        {
        }
        
        /// <summary>
        /// Gpsimpl Get Operation
        /// </summary>
        public Get(Microsoft.Dss.ServiceModel.Dssp.GetRequestType body) : 
                base(body)
        {
        }
        
        /// <summary>
        /// Gpsimpl Get Operation
        /// </summary>
        public Get(Microsoft.Dss.ServiceModel.Dssp.GetRequestType body, Microsoft.Ccr.Core.PortSet<GpsimplState,W3C.Soap.Fault> responsePort) : 
                base(body, responsePort)
        {
        }
    }
     */
}
