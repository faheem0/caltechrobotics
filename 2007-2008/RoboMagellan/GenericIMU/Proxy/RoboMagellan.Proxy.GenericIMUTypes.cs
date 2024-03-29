//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated by a tool.
//     Runtime Version:2.0.50727.1434
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
    /// GenericIMU Contract
    /// </summary>
    [XmlTypeAttribute(IncludeInSchema=false)]
    public sealed class Contract
    {
        
        /// The Unique Contract Identifier for the GenericIMU service
        public const String Identifier = "http://schemas.tempuri.org/2008/03/genericimu.html";
        
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
    /// GenericIMU State
    /// </summary>
    [DataContract()]
    [XmlRootAttribute("GenericIMUState", Namespace="http://schemas.tempuri.org/2008/03/genericimu.html")]
    public class GenericIMUState : ICloneable, IDssSerializable
    {
        
        /// <summary>
        /// Copy To GenericIMU State
        /// </summary>
        public virtual void CopyTo(IDssSerializable target)
        {
            GenericIMUState typedTarget = target as GenericIMUState;

            if (typedTarget == null)
                throw new ArgumentException("CopyTo({0}) requires type {0}", this.GetType().FullName);
        }
        
        /// <summary>
        /// Clone GenericIMU State
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
    /// GenericIMU Operations
    /// </summary>
    [ServicePort()]
    [XmlTypeAttribute(IncludeInSchema=false)]
    public class GenericIMUOperations : PortSet<Microsoft.Dss.ServiceModel.Dssp.DsspDefaultLookup, Microsoft.Dss.ServiceModel.Dssp.DsspDefaultDrop, Get>
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
        public virtual PortSet<GenericIMUState,Fault> Get()
        {
            Microsoft.Dss.ServiceModel.Dssp.GetRequestType body = new Microsoft.Dss.ServiceModel.Dssp.GetRequestType();
            Get op = new Get(body);
            this.Post(op);
            return op.ResponsePort;

        }
        
        /// <summary>
        /// Post Get and return the response port.
        /// </summary>
        public virtual PortSet<GenericIMUState,Fault> Get(Microsoft.Dss.ServiceModel.Dssp.GetRequestType body)
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
    public class Get : Microsoft.Dss.ServiceModel.Dssp.Get<Microsoft.Dss.ServiceModel.Dssp.GetRequestType, PortSet<GenericIMUState, Fault>>
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
        public Get(Microsoft.Dss.ServiceModel.Dssp.GetRequestType body, Microsoft.Ccr.Core.PortSet<GenericIMUState,W3C.Soap.Fault> responsePort) : 
                base(body, responsePort)
        {
        }
    }
}
