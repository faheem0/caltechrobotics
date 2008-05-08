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
using reflection = System.Reflection;
using robomagellan = RoboMagellan.Proxy;


namespace RoboMagellan.Proxy
{
    
    
    /// <summary>
    /// MainControl Contract
    /// </summary>
    [XmlTypeAttribute(IncludeInSchema=false)]
    public sealed class Contract
    {
        
        /// The Unique Contract Identifier for the MainControl service
        public const String Identifier = "http://schemas.tempuri.org/2008/03/maincontrol.html";
        
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
    /// Main Control State
    /// </summary>
    [DataContract()]
    [XmlRootAttribute("MainControlState", Namespace="http://schemas.tempuri.org/2008/03/maincontrol.html")]
    public class MainControlState : ICloneable, IDssSerializable
    {
        
        /// <summary>
        /// Copy To Main Control State
        /// </summary>
        public virtual void CopyTo(IDssSerializable target)
        {
            MainControlState typedTarget = target as MainControlState;

            if (typedTarget == null)
                throw new ArgumentException("CopyTo({0}) requires type {0}", this.GetType().FullName);
        }
        
        /// <summary>
        /// Clone Main Control State
        /// </summary>
        public virtual object Clone()
        {
            // For a class without fields, cloning isn't necessary
            return this;

        }
        
        /// <summary>
        /// Serialize Serialize
        /// </summary>
        public virtual void Serialize(System.IO.BinaryWriter writer)
        {
        }
        
        /// <summary>
        /// Deserialize Deserialize
        /// </summary>
        public virtual object Deserialize(System.IO.BinaryReader reader)
        {
            return this;

        }
    }
    
    /// <summary>
    /// Main Control States
    /// </summary>
    [DataContract()]
    [XmlRootAttribute("MainControlStates", Namespace="http://schemas.tempuri.org/2008/03/maincontrol.html")]
    public enum MainControlStates
    {
        
        /// <summary>
        /// STATE_STOPPING
        /// </summary>
        STATE_STOPPING = 0,
        
        /// <summary>
        /// STATE_STOPPED
        /// </summary>
        STATE_STOPPED = 1,
        
        /// <summary>
        /// STATE_TURNING
        /// </summary>
        STATE_TURNING = 2,
        
        /// <summary>
        /// STATE_DRIVING
        /// </summary>
        STATE_DRIVING = 3,
        
        /// <summary>
        /// STATE_ERROR
        /// </summary>
        STATE_ERROR = 4,
    }
    
    /// <summary>
    /// Main Control Operations
    /// </summary>
    [ServicePort()]
    [XmlTypeAttribute(IncludeInSchema=false)]
    public class MainControlOperations : PortSet<Microsoft.Dss.ServiceModel.Dssp.DsspDefaultLookup, Microsoft.Dss.ServiceModel.Dssp.DsspDefaultDrop, Get>
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
        public virtual PortSet<MainControlState,Fault> Get()
        {
            Microsoft.Dss.ServiceModel.Dssp.GetRequestType body = new Microsoft.Dss.ServiceModel.Dssp.GetRequestType();
            Get op = new Get(body);
            this.Post(op);
            return op.ResponsePort;

        }
        
        /// <summary>
        /// Post Get and return the response port.
        /// </summary>
        public virtual PortSet<MainControlState,Fault> Get(Microsoft.Dss.ServiceModel.Dssp.GetRequestType body)
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
    public class Get : Microsoft.Dss.ServiceModel.Dssp.Get<Microsoft.Dss.ServiceModel.Dssp.GetRequestType, PortSet<MainControlState, Fault>>
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
        public Get(Microsoft.Dss.ServiceModel.Dssp.GetRequestType body, Microsoft.Ccr.Core.PortSet<MainControlState,W3C.Soap.Fault> responsePort) : 
                base(body, responsePort)
        {
        }
    }
}
