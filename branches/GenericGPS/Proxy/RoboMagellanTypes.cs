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
using System.ComponentModel;
using System.Xml.Serialization;
using W3C.Soap;
using compression = System.IO.Compression;
using constructor = Microsoft.Dss.Services.Constructor;
using contractmanager = Microsoft.Dss.Services.ContractManager;
using contractmodel = Microsoft.Dss.Services.ContractModel;
using io = System.IO;
using pxrobomagellan = RoboMagellan.Proxy;
using reflection = System.Reflection;


namespace RoboMagellan.Proxy
{
    
    
    /// <summary>
    /// Contract
    /// </summary>
    [XmlTypeAttribute(IncludeInSchema=false)]
    [DisplayName("Generic GPS Contract")]
    [Description("This is a generic contract for a GPS device")]
    public sealed class Contract
    {
        
        /// The Unique Contract Identifier for the  service
        [DataMember()]
        public const String Identifier = "http://schemas.tempuri.org/2008/03/genericgps.html";
        
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
    /// Specifies the state of a GPS service
    /// </summary>
    [DisplayName("Generic GPS State")]
    [Description("Specifies the state of a GPS service")]
    [DataContract()]
    [XmlRootAttribute("GenericGPSState", Namespace="http://schemas.tempuri.org/2008/03/genericgps.html")]
    public class GenericGPSState : ICloneable, IDssSerializable
    {
        
        private GPSCoordinatesUTM _coords;
        
        private Int64 _timestamp;
        
        /// <summary>
        /// Coords
        /// </summary>
        [DataMember()]
        [DisplayName("Current coordinates in UTM")]
        [Description("This represents the current coordinates in UTM notation")]
        public GPSCoordinatesUTM Coords
        {
            get
            {
                return this._coords;
            }
            set
            {
                this._coords = value;
            }
        }
        
        /// <summary>
        /// Timestamp
        /// </summary>
        [DataMember()]
        [DisplayName("Time in UTC")]
        [Description("The time in UTC of the last update")]
        public Int64 Timestamp
        {
            get
            {
                return this._timestamp;
            }
            set
            {
                this._timestamp = value;
            }
        }
        
        /// <summary>
        /// Copy To GenericGPS State
        /// </summary>
        public virtual void CopyTo(IDssSerializable target)
        {
            GenericGPSState typedTarget = target as GenericGPSState;

            if (typedTarget == null)
                throw new ArgumentException("CopyTo({0}) requires type {0}", this.GetType().FullName);
            typedTarget.Coords = (this.Coords == null) ? null : (GPSCoordinatesUTM)((Microsoft.Dss.Core.IDssSerializable)this.Coords).Clone();
            typedTarget.Timestamp = this.Timestamp;
        }
        
        /// <summary>
        /// Clone Generic GPS State
        /// </summary>
        public virtual object Clone()
        {
            GenericGPSState target = new GenericGPSState();

            target.Coords = (this.Coords == null) ? null : (GPSCoordinatesUTM)((Microsoft.Dss.Core.IDssSerializable)this.Coords).Clone();
            target.Timestamp = this.Timestamp;
            return target;

        }
        
        /// <summary>
        /// Serialize Serialize
        /// </summary>
        public virtual void Serialize(System.IO.BinaryWriter writer)
        {
            if (Coords == null) writer.Write((byte)0);
            else
            {
                // null flag
                writer.Write((byte)1);

                ((Microsoft.Dss.Core.IDssSerializable)Coords).Serialize(writer);
            }

            writer.Write(Timestamp);

        }
        
        /// <summary>
        /// Deserialize Deserialize
        /// </summary>
        public virtual object Deserialize(System.IO.BinaryReader reader)
        {
            if (reader.ReadByte() == 0) {}
            else
            {
                Coords = (GPSCoordinatesUTM)((Microsoft.Dss.Core.IDssSerializable)new GPSCoordinatesUTM()).Deserialize(reader);
            } //nullable

            Timestamp = reader.ReadInt64();

            return this;

        }
    }
    
    /// <summary>
    /// Tuple storing UTM GPS Coordinates
    /// </summary>
    [DisplayName("UTM GPS Coordinates")]
    [Description("Tuple storing UTM GPS Coordinates")]
    [DataContract()]
    [XmlRootAttribute("GPSCoordinatesUTM", Namespace="http://schemas.tempuri.org/2008/03/genericgps.html")]
    public class GPSCoordinatesUTM : ICloneable, IDssSerializable
    {
        
        private Double _easting;
        
        private Double _northing;
        
        /// <summary>
        /// Easting
        /// </summary>
        [DataMember()]
        public Double Easting
        {
            get
            {
                return this._easting;
            }
            set
            {
                this._easting = value;
            }
        }
        
        /// <summary>
        /// Northing
        /// </summary>
        [DataMember()]
        public Double Northing
        {
            get
            {
                return this._northing;
            }
            set
            {
                this._northing = value;
            }
        }
        
        /// <summary>
        /// Copy To GPS CoordinatesUTM
        /// </summary>
        public virtual void CopyTo(IDssSerializable target)
        {
            GPSCoordinatesUTM typedTarget = target as GPSCoordinatesUTM;

            if (typedTarget == null)
                throw new ArgumentException("CopyTo({0}) requires type {0}", this.GetType().FullName);
            typedTarget.Easting = this.Easting;
            typedTarget.Northing = this.Northing;
        }
        
        /// <summary>
        /// Clone UTM GPS Coordinates
        /// </summary>
        public virtual object Clone()
        {
            GPSCoordinatesUTM target = new GPSCoordinatesUTM();

            target.Easting = this.Easting;
            target.Northing = this.Northing;
            return target;

        }
        
        /// <summary>
        /// Serialize Serialize
        /// </summary>
        public virtual void Serialize(System.IO.BinaryWriter writer)
        {
            writer.Write(Easting);

            writer.Write(Northing);

        }
        
        /// <summary>
        /// Deserialize Deserialize
        /// </summary>
        public virtual object Deserialize(System.IO.BinaryReader reader)
        {
            Easting = reader.ReadDouble();

            Northing = reader.ReadDouble();

            return this;

        }
    }
    
    /// <summary>
    /// GenericGPS Operations
    /// </summary>
    [ServicePort()]
    [XmlTypeAttribute(IncludeInSchema=false)]
    public class GenericGPSOperations : PortSet<Microsoft.Dss.ServiceModel.Dssp.DsspDefaultLookup, Microsoft.Dss.ServiceModel.Dssp.DsspDefaultDrop, Get>
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
        public virtual PortSet<GenericGPSState,Fault> Get()
        {
            Microsoft.Dss.ServiceModel.Dssp.GetRequestType body = new Microsoft.Dss.ServiceModel.Dssp.GetRequestType();
            Get op = new Get(body);
            this.Post(op);
            return op.ResponsePort;

        }
        
        /// <summary>
        /// Post Get and return the response port.
        /// </summary>
        public virtual PortSet<GenericGPSState,Fault> Get(Microsoft.Dss.ServiceModel.Dssp.GetRequestType body)
        {
            Get op = new Get();
            op.Body = body ?? new Microsoft.Dss.ServiceModel.Dssp.GetRequestType();
            this.Post(op);
            return op.ResponsePort;

        }
    }
    
    /// <summary>
    /// Get
    /// </summary>
    [XmlTypeAttribute(IncludeInSchema=false)]
    public class Get : Microsoft.Dss.ServiceModel.Dssp.Get<Microsoft.Dss.ServiceModel.Dssp.GetRequestType, PortSet<GenericGPSState, Fault>>
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
        public Get(Microsoft.Dss.ServiceModel.Dssp.GetRequestType body, Microsoft.Ccr.Core.PortSet<GenericGPSState,W3C.Soap.Fault> responsePort) : 
                base(body, responsePort)
        {
        }
    }
}
