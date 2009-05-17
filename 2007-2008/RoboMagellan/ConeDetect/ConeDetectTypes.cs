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
using System.Drawing;
using System;
using System.Collections.Generic;
using W3C.Soap;
using conedetect = RoboMagellan.ConeDetect;
using System.ComponentModel;


namespace RoboMagellan.ConeDetect
{
    
    
    /// <summary>
    /// ConeDetect Contract class
    /// </summary>
    public sealed class Contract
    {
        
        /// <summary>
        /// The Dss Service contract
        /// </summary>
        public const String Identifier = "http://schemas.tempuri.org/2008/05/conedetect.html";
    }
    public struct Density_Check
    {
        public Rectangle r;
        public bool pass;
    }
    
    public struct CamData   
    {
        private long _timestamp;
        private bool _detected;
        private int _x;
        private int _y;
        private int _angle;
        private Rectangle _box;
        private Bitmap _image;

        [DataMember]
        public long Timestamp
        {
            get { return _timestamp; }
            set { _timestamp = value; }
        }

        [DataMember]
        public bool Detected
        {
            get { return _detected; }
            set { _detected = value; }
        }

        [DataMember]
        public int X
        {
            get { return _x; }
            set { _x = value; }
        }

        [DataMember]
        public int Y
        {
            get { return _y; }
            set { _y = value; }
        }

        [DataMember]
        public Rectangle Box
        {
            get { return _box; }
            set { _box = value; }

        }
        [DataMember]
        public int Angle
        {
            get { return _angle; }
            set { _angle = value; }
        }

        [DataMember]
        public Bitmap Image
        {
            get { return _image; }
            set { _image = value; }
        }
    }

    public class ConeNotification : Update<CamData, DsspResponsePort<DefaultUpdateResponseType>>
    {
        public ConeNotification(CamData d) { this.Body = d; }

        public ConeNotification() { }
    }

    /// <summary>
    /// The ConeDetect State
    /// </summary>
    [DataContract()]
    public class ConeDetectState
    {

        /// <summary>
        /// Webcam LOS
        /// </summary>
        [DataMember]
        [Description("Specifies the half angle LOS of Webcam.")]
        public const int MAX_ANGLE = 30;

    }
    
    /// <summary>
    /// ConeDetect Main Operations Port
    /// </summary>
    [ServicePort()]
    public class ConeDetectOperations : PortSet<DsspDefaultLookup, 
                                                DsspDefaultDrop, 
                                                Get,
                                                Subscribe,
                                                ConeNotification,
                                                Moving
                                                >
    {
    }
    
    public class Moving : Submit<MovementStatus, DsspResponsePort<DefaultSubmitResponseType>>
    {
        public Moving() { }
        public Moving(MovementStatus a) { this.Body = a; }
    }
    [DataContract()]
    public struct MovementStatus
    {
        [DataMember]
        public bool _status;

    }

    public class Subscribe : Subscribe<SubscribeRequestType, PortSet<SubscribeResponseType, Fault>, ConeDetectOperations> { }
    /// <summary>
    /// ConeDetect Get Operation
    /// </summary>
    public class Get : Get<GetRequestType, PortSet<ConeDetectState, Fault>>
    {
        
        /// <summary>
        /// ConeDetect Get Operation
        /// </summary>
        public Get()
        {
        }
        
        /// <summary>
        /// ConeDetect Get Operation
        /// </summary>
        public Get(Microsoft.Dss.ServiceModel.Dssp.GetRequestType body) : 
                base(body)
        {
        }
        
        /// <summary>
        /// ConeDetect Get Operation
        /// </summary>
        public Get(Microsoft.Dss.ServiceModel.Dssp.GetRequestType body, Microsoft.Ccr.Core.PortSet<ConeDetectState,W3C.Soap.Fault> responsePort) : 
                base(body, responsePort)
        {
        }
    }
}