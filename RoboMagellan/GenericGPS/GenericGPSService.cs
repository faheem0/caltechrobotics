using Microsoft.Ccr.Core;
using Microsoft.Dss.Core;
using Microsoft.Dss.Core.Attributes;
using Microsoft.Dss.ServiceModel.Dssp;
using Microsoft.Dss.Core.DsspHttp;
using Microsoft.Dss.ServiceModel.DsspServiceBase;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Xml;
using W3C.Soap;
using robomagellan = RoboMagellan;

using submgr = Microsoft.Dss.Services.SubscriptionManager;

namespace RoboMagellan.GenericGPS
{
    [DisplayName("GenericGPS")]
    [Description("The GenericGPS Service")]
    [Contract(Contract.Identifier)]
    public class GenericGPSService : DsspServiceBase
    {

        private static string PORT = "COM8";

        private const int MAX_SAT = 12;

        private GenericGPSState _state = new GenericGPSState();
        private AC12GPS _gps = null;
        private GpsDataPort _gpsDataPort = new GpsDataPort();
        private bool first_coord = true;
     
       
        [ServicePort("/gps", AllowMultipleInstances = false)]
        private GenericGPSOperations _mainPort = new GenericGPSOperations();

        [Partner("SubMgr", Contract = submgr.Contract.Identifier, CreationPolicy = PartnerCreationPolicy.CreateAlways)]
        submgr.SubscriptionManagerPort _subMgrPort = new submgr.SubscriptionManagerPort();

        public GenericGPSService(DsspServiceCreationPort creationPort)
            : base(creationPort)
        {
            
        }

        protected override void Start()
        {
            DirectoryInsert();

            
            
            _gps = new AC12GPS(PORT, _gpsDataPort);

            SpawnIterator(activateGPSIterator);

            Interleave mainInterleave = ActivateDsspOperationHandlers();
            mainInterleave.CombineWith(new Interleave(new ExclusiveReceiverGroup(
                Arbiter.Receive<UTMData>(true, _gpsDataPort, DataReceivedHandler)),
                new ConcurrentReceiverGroup()));

            //base.Start();
        }

        public IEnumerator<ITask> activateGPSIterator()
        {
            if (!_gps.initializePort())
            {
                yield break;
            }
            else
            {
                _gps.command("$PASHS,PWR,ON");
                yield return Arbiter.Receive(false, TimeoutPort(10), delegate(DateTime time) { });
                _gps.command("$PASHQ,PRT");
                yield return Arbiter.Receive(false, TimeoutPort(10), delegate(DateTime time) { });
                _gps.command("$PASHQ,RID");
                yield return Arbiter.Receive(false, TimeoutPort(10), delegate(DateTime time) { });
                _gps.command("$PASHS,OUT,A,NMEA");
                yield return Arbiter.Receive(false, TimeoutPort(10), delegate(DateTime time) { });
                _gps.command("$PASHS,NME,UTM,A,ON");     //Make GPS send UTM coordinate string
                yield return Arbiter.Receive(false, TimeoutPort(10), delegate(DateTime time) { });
                _gps.activateHandler();
            }
        }

        [ServiceHandler(ServiceHandlerBehavior.Concurrent)]
        public IEnumerator<ITask> GetHandler(Get get)
        {
            get.ResponsePort.Post(_state);
            yield break;
        }

        [ServiceHandler(ServiceHandlerBehavior.Concurrent)]
        public virtual IEnumerator<ITask> HttpGetHandler(HttpGet httpGet)
        {
            httpGet.ResponsePort.Post(new HttpResponseType(_state.Coords));
            yield break;
        }

        [ServiceHandler(ServiceHandlerBehavior.Concurrent)]
        public IEnumerator<ITask> HttpPostHandler(HttpPost httpPost)
        {
            yield break;
        }

        [ServiceHandler(ServiceHandlerBehavior.Concurrent)]
        public virtual IEnumerator<ITask> SubscribeHandler(Subscribe subscribe)
        {
            SubscribeRequestType request = subscribe.Body;
            Console.WriteLine("GPS received subscribe request");
            yield return Arbiter.Choice(
                SubscribeHelper(_subMgrPort, request, subscribe.ResponsePort),
                delegate(SuccessResult success)
                {
                    Console.WriteLine("Subscription confirmed");
                    SendNotification<UTMNotification>(_subMgrPort, request.Subscriber, _state.Coords);
                },
                delegate(Exception e)
                {
                    LogError(null, "Subscribe failed", e);
                }
            );

            yield break;
        }

        private void DataReceivedHandler(UTMData d)
        {
            //Console.WriteLine("Received GPS data");

            /*Implements a simple filter that uses the DOP (Number of Satellites) 
             * information from the measurements to weight the GPS data */
            /*if (!first_coord)
            {
                float alpha = 2 * (float)d.NumSat / (float)MAX_SAT;
                d.East = (1 - alpha) * _state.Coords.East + d.East;
                d.North = (1 - alpha) * _state.Coords.North + d.North;*/
                _state.Coords = d;
            /*}
            else
            {
                _state.Coords = d;
                first_coord = false;
            }*/
            SendNotification(_subMgrPort, new UTMNotification(_state.Coords)); 
        }
    }
}
