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
using System;
using System.Collections.Generic;
using System.Xml.Serialization;
using W3C.Soap;
using compression = System.IO.Compression;
using constructor = Microsoft.Dss.Services.Constructor;
using contractmanager = Microsoft.Dss.Services.ContractManager;
using contractmodel = Microsoft.Dss.Services.ContractModel;
using io = System.IO;
using pxgenericcompass = RoboMagellan.GenericCompass.Proxy;
using reflection = System.Reflection;


namespace RoboMagellan.GenericCompass.Proxy
{
    
    
    /// <summary>
    /// GenericCompass Contract
    /// </summary>
    [XmlTypeAttribute(IncludeInSchema=false)]
    public sealed class Contract
    {
        
        /// The Unique Contract Identifier for the GenericCompass service
        public const String Identifier = "http://schemas.tempuri.org/2008/05/genericcompass.html";
        
        /// The Dss Service dssModel Contract(s)
        public static List<contractmodel.ServiceSummary> ServiceModel()
        {
            contractmanager.ServiceSummaryLoader loader = new contractmanager.ServiceSummaryLoader();
            return loader.GetServiceSummaries(typeof(Contract).Assembly);

        }
        
        /// <summary>
        /// Creates an instance of the service associated with this contract
        /// </summary>
        /// <param name="contructorServicePort">Contractor Service that will create the instance</param>
        /// <param name="partners">Optional list of service partners for new service instance</param>
        /// <returns>Result PortSet for retrieving service creation response</returns>
        public static DsspResponsePort<CreateResponse> CreateService(constructor.ConstructorPort contructorServicePort, params PartnerType[] partners)
        {
            DsspResponsePort<CreateResponse> result = new DsspResponsePort<CreateResponse>();
            ServiceInfoType si = new ServiceInfoType(Contract.Identifier, null);
            if (partners != null)
            {
                si.PartnerList = new List<PartnerType>(partners);
            }
            Microsoft.Dss.Services.Constructor.Create create =
                new Microsoft.Dss.Services.Constructor.Create(si, result);
            contructorServicePort.Post(create);
            return result;

        }
        
        /// <summary>
        /// Creates an instance of the service associated with this contract
        /// </summary>
        /// <param name="contructorServicePort">Contractor Service that will create the instance</param>
        /// <returns>Result PortSet for retrieving service creation response</returns>
        public static DsspResponsePort<CreateResponse> CreateService(constructor.ConstructorPort contructorServicePort)
        {
            return Contract.CreateService(contructorServicePort, null);
        }
    }
    
    /// <summary>
    /// Generic Compass State
    /// </summary>
    [DataContract()]
    [XmlRootAttribute("GenericCompassState", Namespace="http://schemas.tempuri.org/2008/05/genericcompass.html")]
    public class GenericCompassState : ICloneable, IDssSerializable
    {
        
        private CompassData _currentAngle;
        
        /// <summary>
        /// Current Angle
        /// </summary>
        [DataMember()]
        public CompassData currentAngle
        {
            get
            {
                return this._currentAngle;
            }
            set
            {
                this._currentAngle = value;
            }
        }
        
        /// <summary>
        /// Copy To Generic Compass State
        /// </summary>
        public virtual void CopyTo(IDssSerializable target)
        {
            GenericCompassState typedTarget = target as GenericCompassState;

            if (typedTarget == null)
                throw new ArgumentException("CopyTo({0}) requires type {0}", this.GetType().FullName);
            typedTarget.currentAngle = this.currentAngle;
        }
        
        /// <summary>
        /// Clone Generic Compass State
        /// </summary>
        public virtual object Clone()
        {
            GenericCompassState target = new GenericCompassState();

            target.currentAngle = this.currentAngle;
            return target;

        }
        
        /// <summary>
        /// Serialize Serialize
        /// </summary>
        public virtual void Serialize(System.IO.BinaryWriter writer)
        {
            ((Microsoft.Dss.Core.IDssSerializable)currentAngle).Serialize(writer);

        }
        
        /// <summary>
        /// Deserialize Deserialize
        /// </summary>
        public virtual object Deserialize(System.IO.BinaryReader reader)
        {
            currentAngle = (CompassData)((Microsoft.Dss.Core.IDssSerializable)new CompassData()).Deserialize(reader);

            return this;

        }
    }
    
    /// <summary>
    /// Compass Data
    /// </summary>
    [DataContract()]
    [XmlRootAttribute("CompassData", Namespace="http://schemas.tempuri.org/2008/05/genericcompass.html")]
    public struct CompassData : ICloneable, IDssSerializable
    {
        
        private Int32 _angle;
        
        /// <summary>
        /// Angle
        /// </summary>
        [DataMember()]
        public Int32 angle
        {
            get
            {
                return this._angle;
            }
            set
            {
                this._angle = value;
            }
        }
        
        /// <summary>
        /// Copy To Compass Data
        /// </summary>
        public void CopyTo(IDssSerializable target)
        {
            throw new ArgumentException("CopyTo() is not valid for structs!");
        }
        
        /// <summary>
        /// Clone Compass Data
        /// </summary>
        public object Clone()
        {
            CompassData target = new CompassData();

            target.angle = this.angle;
            return target;

        }
        
        /// <summary>
        /// Serialize Serialize
        /// </summary>
        public void Serialize(System.IO.BinaryWriter writer)
        {
            writer.Write(angle);

        }
        
        /// <summary>
        /// Deserialize Deserialize
        /// </summary>
        public object Deserialize(System.IO.BinaryReader reader)
        {
            angle = reader.ReadInt32();

            return this;

        }
    }
    
    /// <summary>
    /// Generic Compass Operations
    /// </summary>
    [ServicePort()]
    [XmlTypeAttribute(IncludeInSchema=false)]
    public class GenericCompassOperations : PortSet<Microsoft.Dss.ServiceModel.Dssp.DsspDefaultLookup, Microsoft.Dss.ServiceModel.Dssp.DsspDefaultDrop, Get, Subscribe, CompassNotification>
    {
        
        /// <summary>
        /// Required Lookup request body type
        /// </summary>
        public virtual PortSet<Microsoft.Dss.ServiceModel.Dssp.LookupResponse,Fault> DsspDefaultLookup()
        {
            Microsoft.Dss.ServiceModel.Dssp.LookupRequestType body = new Microsoft.Dss.ServiceModel.Dssp.LookupRequestType();
            Microsoft.Dss.ServiceModel.Dssp.DsspDefaultLookup op = new Microsoft.Dss.ServiceModel.Dssp.DsspDefaultLookup(body);
            this.Post(op);
            return op.ResponsePort;

        }
        
        /// <summary>
        /// Post Dssp Default Lookup and return the response port.
        /// </summary>
        public virtual PortSet<Microsoft.Dss.ServiceModel.Dssp.LookupResponse,Fault> DsspDefaultLookup(Microsoft.Dss.ServiceModel.Dssp.LookupRequestType body)
        {
            Microsoft.Dss.ServiceModel.Dssp.DsspDefaultLookup op = new Microsoft.Dss.ServiceModel.Dssp.DsspDefaultLookup();
            op.Body = body ?? new Microsoft.Dss.ServiceModel.Dssp.LookupRequestType();
            this.Post(op);
            return op.ResponsePort;

        }
        
        /// <summary>
        /// A request to drop the service.
        /// </summary>
        public virtual PortSet<Microsoft.Dss.ServiceModel.Dssp.DefaultDropResponseType,Fault> DsspDefaultDrop()
        {
            Microsoft.Dss.ServiceModel.Dssp.DropRequestType body = new Microsoft.Dss.ServiceModel.Dssp.DropRequestType();
            Microsoft.Dss.ServiceModel.Dssp.DsspDefaultDrop op = new Microsoft.Dss.ServiceModel.Dssp.DsspDefaultDrop(body);
            this.Post(op);
            return op.ResponsePort;

        }
        
        /// <summary>
        /// Post Dssp Default Drop and return the response port.
        /// </summary>
        public virtual PortSet<Microsoft.Dss.ServiceModel.Dssp.DefaultDropResponseType,Fault> DsspDefaultDrop(Microsoft.Dss.ServiceModel.Dssp.DropRequestType body)
        {
            Microsoft.Dss.ServiceModel.Dssp.DsspDefaultDrop op = new Microsoft.Dss.ServiceModel.Dssp.DsspDefaultDrop();
            op.Body = body ?? new Microsoft.Dss.ServiceModel.Dssp.DropRequestType();
            this.Post(op);
            return op.ResponsePort;

        }
        
        /// <summary>
        /// Required Get body type
        /// </summary>
        public virtual PortSet<GenericCompassState,Fault> Get()
        {
            Microsoft.Dss.ServiceModel.Dssp.GetRequestType body = new Microsoft.Dss.ServiceModel.Dssp.GetRequestType();
            Get op = new Get(body);
            this.Post(op);
            return op.ResponsePort;

        }
        
        /// <summary>
        /// Post Get and return the response port.
        /// </summary>
        public virtual PortSet<GenericCompassState,Fault> Get(Microsoft.Dss.ServiceModel.Dssp.GetRequestType body)
        {
            Get op = new Get();
            op.Body = body ?? new Microsoft.Dss.ServiceModel.Dssp.GetRequestType();
            this.Post(op);
            return op.ResponsePort;

        }
        
        /// <summary>
        /// Post Subscribe and return the response port.
        /// </summary>
        public virtual PortSet<Microsoft.Dss.ServiceModel.Dssp.SubscribeResponseType,Fault> Subscribe(IPort notificationPort)
        {
            Subscribe op = new Subscribe();
            op.Body = new Microsoft.Dss.ServiceModel.Dssp.SubscribeRequestType();
            op.NotificationPort = notificationPort;
            this.Post(op);
            return op.ResponsePort;

        }
        
        /// <summary>
        /// Post Subscribe and return the response port.
        /// </summary>
        public virtual PortSet<Microsoft.Dss.ServiceModel.Dssp.SubscribeResponseType,Fault> Subscribe(Microsoft.Dss.ServiceModel.Dssp.SubscribeRequestType body, IPort notificationPort)
        {
            Subscribe op = new Subscribe();
            op.Body = body ?? new Microsoft.Dss.ServiceModel.Dssp.SubscribeRequestType();
            op.NotificationPort = notificationPort;
            this.Post(op);
            return op.ResponsePort;

        }
        
        /// <summary>
        /// Compass Data
        /// </summary>
        public virtual Microsoft.Dss.ServiceModel.Dssp.DsspResponsePort<Microsoft.Dss.ServiceModel.Dssp.DefaultUpdateResponseType> CompassNotification()
        {
            CompassData body = new CompassData();
            CompassNotification op = new CompassNotification(body);
            this.Post(op);
            return op.ResponsePort;

        }
        
        /// <summary>
        /// Post Compass Notification and return the response port.
        /// </summary>
        public virtual Microsoft.Dss.ServiceModel.Dssp.DsspResponsePort<Microsoft.Dss.ServiceModel.Dssp.DefaultUpdateResponseType> CompassNotification(CompassData body)
        {
            CompassNotification op = new CompassNotification();
            op.Body = body;
            this.Post(op);
            return op.ResponsePort;

        }
    }
    
    /// <summary>
    /// Get
    /// </summary>
    [XmlTypeAttribute(IncludeInSchema=false)]
    public class Get : Microsoft.Dss.ServiceModel.Dssp.Get<Microsoft.Dss.ServiceModel.Dssp.GetRequestType, PortSet<GenericCompassState, Fault>>
    {
        
        /// <summary>
        /// Get
        /// </summary>
        public Get()
        {
        }
        
        /// <summary>
        /// Get
        /// </summary>
        public Get(Microsoft.Dss.ServiceModel.Dssp.GetRequestType body) : 
                base(body)
        {
        }
        
        /// <summary>
        /// Get
        /// </summary>
        public Get(Microsoft.Dss.ServiceModel.Dssp.GetRequestType body, Microsoft.Ccr.Core.PortSet<GenericCompassState,W3C.Soap.Fault> responsePort) : 
                base(body, responsePort)
        {
        }
    }
    
    /// <summary>
    /// Subscribe
    /// </summary>
    [XmlTypeAttribute(IncludeInSchema=false)]
    public class Subscribe : Microsoft.Dss.ServiceModel.Dssp.Subscribe<Microsoft.Dss.ServiceModel.Dssp.SubscribeRequestType, PortSet<Microsoft.Dss.ServiceModel.Dssp.SubscribeResponseType, Fault>, GenericCompassOperations>
    {
        
        /// <summary>
        /// Subscribe
        /// </summary>
        public Subscribe()
        {
        }
        
        /// <summary>
        /// Subscribe
        /// </summary>
        public Subscribe(Microsoft.Dss.ServiceModel.Dssp.SubscribeRequestType body) : 
                base(body)
        {
        }
        
        /// <summary>
        /// Subscribe
        /// </summary>
        public Subscribe(Microsoft.Dss.ServiceModel.Dssp.SubscribeRequestType body, Microsoft.Ccr.Core.PortSet<Microsoft.Dss.ServiceModel.Dssp.SubscribeResponseType,W3C.Soap.Fault> responsePort) : 
                base(body, responsePort)
        {
        }
        
        /// <summary>
        /// Subscribe
        /// </summary>
        public Subscribe(Microsoft.Dss.ServiceModel.Dssp.SubscribeRequestType body, Microsoft.Ccr.Core.PortSet<Microsoft.Dss.ServiceModel.Dssp.SubscribeResponseType,W3C.Soap.Fault> responsePort, GenericCompassOperations notificationPort) : 
                base(body, responsePort, notificationPort)
        {
        }
    }
    
    /// <summary>
    /// Compass Notification
    /// </summary>
    [XmlTypeAttribute(IncludeInSchema=false)]
    public class CompassNotification : Microsoft.Dss.ServiceModel.Dssp.Update<CompassData, Microsoft.Dss.ServiceModel.Dssp.DsspResponsePort<Microsoft.Dss.ServiceModel.Dssp.DefaultUpdateResponseType>>
    {
        
        /// <summary>
        /// Compass Notification
        /// </summary>
        public CompassNotification()
        {
        }
        
        /// <summary>
        /// Compass Notification
        /// </summary>
        public CompassNotification(CompassData body) : 
                base(body)
        {
        }
        
        /// <summary>
        /// Compass Notification
        /// </summary>
        public CompassNotification(CompassData body, Microsoft.Dss.ServiceModel.Dssp.DsspResponsePort<Microsoft.Dss.ServiceModel.Dssp.DefaultUpdateResponseType> responsePort) : 
                base(body, responsePort)
        {
        }
    }
}