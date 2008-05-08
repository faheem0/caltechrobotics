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
using System.ComponentModel;
using W3C.Soap;
using robomagellan = RoboMagellan;
using System.Collections.Generic;


namespace RoboMagellan.GenericGPS
{


    /// <summary>
    /// GenericGPS Contract class
    /// </summary>
    [DisplayName("Generic GPS Contract")]
    [Description("This is a generic contract for a GPS device")]
    public sealed class Contract
    {

        /// <summary>
        /// The Dss Service contract
        /// </summary>
        [DataMember()]
        public const String Identifier = "http://schemas.tempuri.org/2008/03/genericgps.html";
    }

    /// <summary>
    /// The GenericGPS State
    /// </summary>
    [DataContract()]
    [DisplayName("Generic GPS State")]
    [Description("Specifies the state of a GPS service")]
    public class GenericGPSState
    {
        UTMData _coords;

        [DataMember]
        [DisplayName("Current coordinates in UTM")]
        [Description("This represents the current coordinates in UTM notation")]
        public UTMData Coords
        {
            get { return _coords; }
            set { _coords = value; }
        }

        Queue<UTMData> waypoints;

    }

    /// <summary>
    /// GenericGPS Main Operations Port
    /// </summary>
    [ServicePort()]
    public class GenericGPSOperations : PortSet<DsspDefaultLookup, 
                                                DsspDefaultDrop, 
                                                Get,
                                                Subscribe,
                                                HttpGet,
                                                HttpPost,
                                                UTMNotification>
    {
    }

    public class Subscribe : Subscribe<SubscribeRequestType, PortSet<SubscribeResponseType, Fault>, GenericGPSOperations> { }

    public class UTMNotification : Update<UTMData, DsspResponsePort<DefaultUpdateResponseType>> 
    {
        public UTMNotification(UTMData d) { this.Body = d; }

        public UTMNotification() { }
    }

    /// <summary>
    /// GenericGPS Get Operation
    /// </summary>
    public class Get : Get<GetRequestType, PortSet<GenericGPSState, Fault>>
    {

        /// <summary>
        /// GenericGPS Get Operation
        /// </summary>
        public Get()
        {
        }

        /// <summary>
        /// GenericGPS Get Operation
        /// </summary>
        public Get(Microsoft.Dss.ServiceModel.Dssp.GetRequestType body) :
            base(body)
        {
        }

        /// <summary>
        /// GenericGPS Get Operation
        /// </summary>
        public Get(Microsoft.Dss.ServiceModel.Dssp.GetRequestType body, Microsoft.Ccr.Core.PortSet<GenericGPSState, W3C.Soap.Fault> responsePort) :
            base(body, responsePort)
        {
        }
    }

    [DataContract()]
    [Description("Tuple storing UTM GPS Coordinates")]
    public struct UTMData
    {
        private double _easting;
        private double _northing;

        private int _numSat;
        private double _timestamp;

        [DataMember]
        public int NumSat
        {
            get { return _numSat; }
            set { _numSat = value; }
        }

        [DataMember]
        public double Timestamp
        {
            get { return _timestamp; }
            set { _timestamp = value; }
        }

        [DataMember]
        public double East
        {
            get { return _easting; }
            set { _easting = value; }
        }

        [DataMember]
        public double North
        {
            get { return _northing; }
            set { _northing = value; }
        }

    }

}    
