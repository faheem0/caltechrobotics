using System;
using System.Collections.Generic;
using System.Text;
using Microsoft.Robotics.Services;
using Microsoft.Ccr.Core;
using Microsoft.Dss.Core.Attributes;
using Microsoft.Dss.ServiceModel.Dssp;
using System.Windows.Forms;

using RoboMagellan;
using motor = RoboMagellan.MotorControl.Proxy;
using gps = RoboMagellan.GenericGPS.Proxy;
using control = RoboMagellan.Proxy;


namespace RMGUI
{
    class ServiceFetcher
    {
        [Partner("gps", Contract = gps.Contract.Identifier,
            CreationPolicy = PartnerCreationPolicy.UseExistingOrCreate)]
        private gps.GenericGPSOperations _gpsPort = new gps.GenericGPSOperations();
        private gps.GenericGPSOperations _gpsNotify = new gps.GenericGPSOperations();

        [Partner("control", Contract = control.Contract.Identifier,
            CreationPolicy = PartnerCreationPolicy.UseExistingOrCreate)]
        private control.MainControlOperations _controlPort = new control.MainControlOperations();

        private TextBox[] GPSBoxes;

        public ServiceFetcher(TextBox[] gps)
        {
            GPSBoxes = gps;
        }

        public void SubscribeToGPS()
        {
            //Create GPS Notification Port
            gps.GenericGPSOperations gpsNotificationPort = new gps.GenericGPSOperations();

            //Subscribe to GPS Service
            _gpsPort.Subscribe(gpsNotificationPort);

            //Install a notification handler
            Activate<ITask>(
                Arbiter.Receive<gps.UTMNotification>(true, _gpsNotify, NotifyUTMHandler)
                );
            Console.WriteLine("Subscribed to GPS");
        }
        private void NotifyUTMHandler(gps.UTMNotification n)
        {
            gps.UTMData dataReceived = n.Body;
            GPSBoxes[0].Text = "" + dataReceived.NumSat;
            GPSBoxes[1].Text = "" + dataReceived.Timestamp;
            GPSBoxes[2].Text = "" + dataReceived.East;
            GPSBoxes[3].Text = "" + dataReceived.North;
        }

    }
}
