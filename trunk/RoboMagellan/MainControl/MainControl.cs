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
using System.Collections.Generic;
using System.ComponentModel;
using System.Xml;
using W3C.Soap;
using robomagellan = RoboMagellan;
using gps = RoboMagellan.GenericGPS.Proxy;
using motor = RoboMagellan.MotorControl.Proxy;
namespace RoboMagellan
{
    
    
    /// <summary>
    /// Implementation class for MainControl
    /// </summary>
    [DisplayName("MainControl")]
    [Description("The MainControl Service")]
    [Contract(Contract.Identifier)]
    public class MainControlService : DsspServiceBase
    {
        private static double DISTANCE_THRESHOLD = 10;

        private static double ANGLE_THRESHOLD = 2;


        [Partner("Gps", Contract = gps.Contract.Identifier, CreationPolicy = PartnerCreationPolicy.UseExistingOrCreate)]
        private gps.GenericGPSOperations _gpsPort = new gps.GenericGPSOperations();
        private gps.GenericGPSOperations _gpsNotify = new gps.GenericGPSOperations();


        // NEEDS PARTNER!
        [Partner("Motor", Contract = motor.Contract.Identifier, CreationPolicy = PartnerCreationPolicy.UseExistingOrCreate)]
        private motor.GenericMotorOperations _motorPort = new motor.GenericMotorOperations();
        

        /// <summary>
        /// _state
        /// </summary>
        private MainControlState _state = new MainControlState();
        
        /// <summary>
        /// _main Port
        /// </summary>
        [ServicePort("/maincontrol", AllowMultipleInstances=false)]
        private MainControlOperations _mainPort = new MainControlOperations();
        
        /// <summary>
        /// Default Service Constructor
        /// </summary>
        public MainControlService(DsspServiceCreationPort creationPort) : 
                base(creationPort)
        {
            _state._state = MainControlStates.STATE_STOPPED;
        }
        
        /// <summary>
        /// Service Start
        /// MODIFIES STATE!
        /// </summary>
        protected override void Start()
        {
			base.Start();
			// Add service specific initialization here.
            Console.WriteLine("MainControl initializing");
            _state._destination = new gps.UTMData();
            _state._destination.East = 396508.02;
            _state._destination.North = 3777901.85;

            _state._destinations.Enqueue(_state._destination);

            _state._destination = _state._destinations.Dequeue();
            Activate<ITask>(
                Arbiter.Receive<gps.UTMNotification>(true, _gpsNotify, NotifyUTMHandler)
                );

            _gpsPort.Subscribe(_gpsNotify);
            Console.WriteLine("Subscribed to GPS, standing by");
        }

        // UPDATES STATE!
        // fix concurrency!
        public void NotifyUTMHandler(gps.UTMNotification n)
        {
            Console.WriteLine("Received GPS notification, current state: " + _state._state);
            _state._location = n.Body;

            switch (_state._state)
            {
                case MainControlStates.STATE_STOPPING :
                    return;
                    break;
                case MainControlStates.STATE_STOPPED:
                    if (_state._destination.East == 0.0) break;
                    if (GetDistanceSquared(_state._destination, n.Body) < DISTANCE_THRESHOLD)
                    {
                        return;
                    }
                    else
                    {
                        double absoluteBearing = GetAbsoluteBearing(n.Body, _state._destination);
                        Console.WriteLine("Beginning turn");
                        motor.TurnData td = new motor.TurnData();
                        td.heading = (int)absoluteBearing;
                        motor.Turn t = new motor.Turn(td);


                        _state._state = MainControlStates.STATE_TURNING;



                        Arbiter.Activate(this.TaskQueue, Arbiter.Receive<DefaultSubmitResponseType>(false, t.ResponsePort,
                            delegate(DefaultSubmitResponseType s)
                            {
                                Console.WriteLine("Received turn complete!");
                                _state._state = MainControlStates.STATE_DRIVING;
                                motor.MotorSpeed ms = new motor.MotorSpeed();
                                ms.Left = 60;
                                ms.Right = 60;
                                motor.SetSpeed setspeed = new motor.SetSpeed(ms);
                                _motorPort.Post(setspeed);
                            }));
//                            delegate(Exception ex) { _state._state = MainControlStates.STATE_ERROR; }));

                        _motorPort.Post(t);
                    }
                    break;
                case MainControlStates.STATE_TURNING:
                    return;
                    break;
                case MainControlStates.STATE_DRIVING:
                    if (GetDistanceSquared(_state._destination, n.Body) < DISTANCE_THRESHOLD)
                    {
                        motor.Stop stop = new motor.Stop();

                        Console.WriteLine("Stopping!");
                        _state._state = MainControlStates.STATE_STOPPING;

                        _motorPort.Post(stop);

                        Arbiter.Activate(this.TaskQueue, Arbiter.Receive<DefaultSubmitResponseType>(false, stop.ResponsePort,
                            delegate(DefaultSubmitResponseType a) { 
                                _state._state = MainControlStates.STATE_STOPPED;
                                Console.WriteLine("Received stop!");
                                if (_state._destinations.Count > 0)
                                {
                                    _state._destination = _state._destinations.Dequeue();
                                }
                                else
                                {
                                    gps.UTMData empty = new gps.UTMData();
                                    empty.East = 0.0;
                                    empty.North = 0.0;
                                    _state._destination = empty;
                                }
                            }));
//                            delegate(Exception ex) { _state._state = STATE_ERROR; }));
                        
                    }
                    else
                    {
                        return;
                    }
                    break;
                case MainControlStates.STATE_ERROR:
                    return;
                    break;
            }
        }

        public double GetDistance(gps.UTMData a, gps.UTMData b)
        {
            return Math.Sqrt(GetDistanceSquared(a, b));
        }

        public double GetDistanceSquared(gps.UTMData a, gps.UTMData b)
        {
            double de = b.East - a.East;
            double dn = b.North - a.North;
            return de * de + dn * dn;
        }
        public double GetAbsoluteBearing(gps.UTMData loc, gps.UTMData dest)
        {
            double dx = dest.East - loc.East;
            double dy = dest.North - loc.North;

            return 180 * (Math.Atan(dy / dx) / Math.PI);
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
    }
}
