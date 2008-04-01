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

        private static string PORT = "COM1";

        private GenericGPSState _state = new GenericGPSState();
        private AC12GPS _gps = null;
        private GpsDataPort _gpsDataPort = new GpsDataPort();

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
            //base.Start();
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
                /*System.Threading.Thread.Sleep(10);
                command("$PASHS,NME,GSV,A,ON");*/
                /*System.Threading.Thread.Sleep(10);
                command("$PASHS,NME,GGA,A,ON");*/
                /*System.Threading.Thread.Sleep(10);
                command("$PASHS,NME,GSA,A,ON");
                System.Threading.Thread.Sleep(10);
                command("$PASHS,NME,VTG,A,ON");*/
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

            yield return Arbiter.Choice(
                SubscribeHelper(_subMgrPort, request, subscribe.ResponsePort),
                delegate(SuccessResult success)
                {
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
            _state.Coords = d;

            SendNotification(_subMgrPort, new UTMNotification(d)); 
        }
    }
}
