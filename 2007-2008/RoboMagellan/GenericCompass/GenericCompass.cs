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
using Microsoft.Dss.ServiceModel.DsspServiceBase;
using System;
using System.IO.Ports;
using System.Collections.Generic;
using System.ComponentModel;
using System.Xml;
using W3C.Soap;
using genericcompass = RoboMagellan.GenericCompass;
using motor = RoboMagellan.MotorControl.Proxy;
using submgr = Microsoft.Dss.Services.SubscriptionManager;

namespace RoboMagellan.GenericCompass
{
    
    
    /// <summary>
    /// Implementation class for GenericCompass
    /// </summary>
    [DisplayName("GenericCompass")]
    [Description("The GenericCompass Service")]
    [Contract(Contract.Identifier)]
    public class GenericCompassService : DsspServiceBase
    {
        static int DEFAULT_BAUD_RATE = 115200;
        static int DEFAULT_DATA_BITS = 8;
        static int DEFAULT_TIMEOUT = 500;
        static Parity DEFAULT_PARITY = Parity.None;
        static StopBits DEFAULT_STOP_BITS = StopBits.Two;
        static Handshake DEFAULT_HANDSHAKE = Handshake.None;
        private volatile SerialPort myCompass;

        /// <summary>
        /// _state
        /// </summary>
        private GenericCompassState _state = new GenericCompassState();
        
        /// <summary>
        /// _main Port
        /// </summary>
        [ServicePort("/genericcompass", AllowMultipleInstances=false)]
        private GenericCompassOperations _mainPort = new GenericCompassOperations();

        /// <summary>
        /// Subscription Manager port
        /// </summary>
        [Partner("SubMgr", Contract = submgr.Contract.Identifier, CreationPolicy = PartnerCreationPolicy.CreateAlways)]
        submgr.SubscriptionManagerPort _subMgrPort = new submgr.SubscriptionManagerPort();

        private static string COMPASS_PORT = "COM4";

        /// <summary>
        /// Default Service Constructor
        /// </summary>
        public GenericCompassService(DsspServiceCreationPort creationPort) : 
                base(creationPort)
        {

            myCompass = new SerialPort(COMPASS_PORT);
            myCompass.BaudRate = DEFAULT_BAUD_RATE;
            myCompass.Parity = DEFAULT_PARITY;
            myCompass.DataBits = DEFAULT_DATA_BITS;
            myCompass.StopBits = DEFAULT_STOP_BITS;
            myCompass.Handshake = DEFAULT_HANDSHAKE;

            myCompass.ReadTimeout = DEFAULT_TIMEOUT;
            myCompass.WriteTimeout = DEFAULT_TIMEOUT;
        }

        public bool initializePort()
        {

            myCompass.Open();


            if (myCompass.IsOpen)
            {
                Console.WriteLine("Sucessfully Connected!");
                Console.WriteLine(myCompass.ToString());

                myCompass.RtsEnable = true;

                return true;
            }

            else
            {
                Console.WriteLine("Connection Failed!");    //Oh Shit!
                return false;
            }
        }
        
        /// <summary>
        /// Service Start
        /// </summary>
        protected override void Start()
        {
			base.Start();
            initializePort();
            myCompass.DataReceived += new SerialDataReceivedEventHandler(serialPort_dataReceived);
			// Add service specific initialization here.
        }
        
        /// <summary>
        /// Get Handler
        /// </summary>
        /// <param name="get"></param>
        /// <returns></returns>
        [ServiceHandler(ServiceHandlerBehavior.Concurrent)]
        public virtual IEnumerator<ITask> GetHandler(Get get)
        {
            get.ResponsePort.Post(_state);
            yield break;
        }

        [ServiceHandler(ServiceHandlerBehavior.Exclusive)]
        public virtual IEnumerator<ITask> CompassNotificationHandler(CompassNotification c)
        {
            _state.currentAngle = c.Body;
            SendNotification(_subMgrPort, c);
            yield break;
        }

        [ServiceHandler(ServiceHandlerBehavior.Concurrent)]
        public virtual IEnumerator<ITask> SubscribeHandler(Subscribe subscribe)
        {
            SubscribeRequestType request = subscribe.Body;
            Console.WriteLine("Compass received subscribe request");
            yield return Arbiter.Choice(
                SubscribeHelper(_subMgrPort, request, subscribe.ResponsePort),
                delegate(SuccessResult success)
                {
                    Console.WriteLine("Compass subscription confirmed");
                    SendNotification<CompassNotification>(_subMgrPort, request.Subscriber, _state.currentAngle);
                },
                delegate(Exception e)
                {
                    LogError(null, "Subscribe failed", e);
                }
            );

            yield break;
        }


        private void serialPort_dataReceived(object sender, SerialDataReceivedEventArgs e) {
            //Console.WriteLine("Compass received data!");
            if (myCompass.BytesToRead >= 4)
            {                  
                byte[] buf = new byte[4];
                myCompass.Read(buf, 0, 4);
//          make this more good later
//                if (buf[0] != (byte)motor.MotorCommands.COMMAND_START || buf[3] != (byte)motor.MotorCommands.COMMAND_STOP)
                if (buf[0] != (byte)254 || buf[3] != (byte)233)
                
                {
                    // something went wrong
                    Console.WriteLine("Error in compass serial port handler, received: " + buf.ToString());
                    return;
                }
                int angle = ((int)buf[1]) + buf[2];

                if (!(0 <= angle && angle <= 360))
                {
                    Console.WriteLine("Error in compass serial port handler, impossible angle received");
                    return;
                }

                CompassData dat = new CompassData();
                dat.angle = angle;
                CompassNotification not = new CompassNotification(dat);

                _mainPort.Post(not);
            }
        }
    }
}
