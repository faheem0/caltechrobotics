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
using Microsoft.Dss.Core.DsspHttp;
using Microsoft.Dss.ServiceModel.DsspServiceBase;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Xml;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;
using System.IO;
using W3C.Soap;
using conedetect = RoboMagellan.ConeDetect;
using webcam = Microsoft.Robotics.Services.WebCam.Proxy;
using multiwebcam = Microsoft.Robotics.Services.MultiDeviceWebCam.Proxy;
using physics = Microsoft.Robotics.PhysicalModel.Proxy;
using submgr = Microsoft.Dss.Services.SubscriptionManager;
using roborealm = RoboRealm.Proxy;

namespace RoboMagellan.ConeDetect
{
    
    
    /// <summary>
    /// Implementation class for ConeDetect
    /// </summary>
    [DisplayName("ConeDetect")]
    [Description("The ConeDetect Service")]
    [Contract(Contract.Identifier)]
    public class ConeDetectService : DsspServiceBase
    {

        private static float DIMENSION_X = 640;
        private static float DIMENSION_Y = 480;

        private static physics.Vector2 SIZE;
        private static float TOLERANCE_H = 20.0f;
        private static float TOLERANCE_S = 0.38f;
        private static float TOLERANCE_B = 0.42f;
        private static int DETECT_THRESHOLD = (int)(DIMENSION_X * DIMENSION_Y) / 17;
        private static int FPS = 10;
        private static Color ConeColor = Color.FromArgb(239,58,31);//Color.OrangeRed;//Color.FromArgb(239,58,31);
        private static Color MaskColor = Color.Black;
        private static float SMALL_DENSITY_THRESHOLD = 0.5f;
        private static int SMALL_DENSITY_BOX = 15;
        private static int CONFIDENCE_THRESHOLD = 75;
        private static int MAX_ANGLE = ConeDetectState.MAX_ANGLE;
        private const int FRAMES_MAX = 5;
        private const int FRAME_PAUSE = 100;
        private const int CONE_HIT_THRESHOLD = 3;
        private CamData dataPacket;
        private bool moving = false;
        private const int NULL = int.MaxValue;
        
        /// <summary>
        /// _state
        /// </summary>
        private ConeDetectState _state = new ConeDetectState();
        private int cone_hits = 0;
        private int cam_frames = 0;
        /// <summary>
        /// _main Port
        /// </summary>
        [ServicePort("/conedetect", AllowMultipleInstances=false)]
        private ConeDetectOperations _mainPort = new ConeDetectOperations();

        
        [Partner("SubMgr", Contract = submgr.Contract.Identifier, CreationPolicy = PartnerCreationPolicy.CreateAlways)]
        submgr.SubscriptionManagerPort _subMgrPort = new submgr.SubscriptionManagerPort();

        /*[Partner("MultiWebcam", Contract = multiwebcam.Contract.Identifier, CreationPolicy = PartnerCreationPolicy.UseExistingOrCreate)]
        multiwebcam.WebCamServiceOperations _multiWebcam = new multiwebcam.WebCamServiceOperations();*/

        [Partner("RoboRealm", Contract = roborealm.Contract.Identifier, CreationPolicy = PartnerCreationPolicy.UseExistingOrCreate)]
        roborealm.InterfaceOperations _rrPort = new roborealm.InterfaceOperations();
        roborealm.InterfaceOperations _rrNotify = new roborealm.InterfaceOperations();

        /*[Partner("Webcam", Contract = webcam.Contract.Identifier, CreationPolicy = PartnerCreationPolicy.UseExistingOrCreate)]
        webcam.WebCamOperations _camData = new webcam.WebCamOperations();
        webcam.WebCamOperations _camNotify = new webcam.WebCamOperations();*/

        /// <summary>
        /// Default Service Constructor
        /// </summary>
        public ConeDetectService(DsspServiceCreationPort creationPort) : 
                base(creationPort)
        {
        }
        
        /// <summary>
        /// Service Start
        /// </summary>
        protected override void Start()
        {

	        base.Start();
            DirectoryInsert();
            Console.WriteLine("Webcam Starting");
            //DirectoryInsert();
            /*webcam.WebCamState f = new Microsoft.Robotics.Services.WebCam.WebCamState();
            f.ImageSize.X = DIMENSION_X;
            f.ImageSize.X = DIMENSION_Y;
            mdwebcam.
            webcam.*/
            SIZE.X = DIMENSION_X;
            SIZE.Y = DIMENSION_Y;
            moving = false;
            //Activate(Arbiter.ReceiveWithIterator(false, TimeoutPort(2000), GetFrame));

            _rrPort.Subscribe(_rrNotify);

            roborealm.LoadProgramRequest cone_detect = new RoboRealm.Proxy.LoadProgramRequest();
            cone_detect.Filename = "C:\\Documents and Settings\\tonyfwu\\Desktop\\cone.robo";
            _rrPort.LoadProgram(cone_detect);

            //roborealm.ExecuteProgramRequest ep = new roborealm.ExecuteProgramRequest();

            Activate(
                    Arbiter.Receive<roborealm.UpdateFrame>(true, _rrNotify,
                    delegate(roborealm.UpdateFrame hasframe)
                    {
                        SpawnIterator(GetFrame);
                    })
            );

            //_camData.Subscribe(_camNotify);
            Console.WriteLine("Webcam started");
	        // Add service specific initialization here.
        }
        public IEnumerator<ITask> GetFrame()
        {
            //Console.WriteLine("New Frame is ready, fetching and calculating angle");
            roborealm.QueryVariablesRequest varReq = new roborealm.QueryVariablesRequest();
            roborealm.QueryFrameRequest frameReq = new roborealm.QueryFrameRequest();
            varReq._names = new List<String>();
            varReq._names.Add("IMAGE_WIDTH");
            varReq._names.Add("IMAGE_HEIGHT");
            //varReq._names.Add("COG_X");
            //varReq._names.Add("COG_Y");
            varReq._names.Add("SHAPE_X_COORD");
            varReq._names.Add("SHAPE_Y_COORD");
            varReq._names.Add("SHAPE_CONFIDENCE");
            frameReq.Format = ImageFormat.Bmp.Guid;
            int x = 0;
            int y = 0;
            int width = 0;
            int height = 0;
            int confidence = 0;

            CamData d = new CamData();
            d.X = NULL;
            if (varReq != null)
            {
                // send of the request and process the results
                yield return Arbiter.Choice(
                    _rrPort.QueryVariables(varReq),
                    delegate(roborealm.QueryVariablesResponse res)
                    {
                        // for now just print the results in the command console. You could
                        // use these values to futher partner with a robotic drive system
                        // and move the robot based on COG values.
                        //Console.WriteLine("COG: " + res._values[0] + "," + res._values[1]);
                        try
                        {
                            width = int.Parse(res._values[0]);
                            height = int.Parse(res._values[1]);
                            
                            if (res._values.Count == 5)
                            {
                                x = int.Parse(res._values[2]);
                                y = int.Parse(res._values[3]);
                                confidence = int.Parse(res._values[4]);
                            }
                        }
                        catch (Exception) { };
                    },
                    delegate(Fault f)
                    {
                        LogError(LogGroups.Console, "Could not query variables", f);
                    });
                frameReq.Size = new Size(width, height);
                yield return Arbiter.Choice(
                       _rrPort.QueryFrame(frameReq),
                       delegate(roborealm.QueryFrameResponse fres)
                       {
                           d = new CamData();
                           System.IO.MemoryStream ms = new System.IO.MemoryStream(fres.Frame);
                           d.Image = new Bitmap(ms);
                           d.X = x;
                           d.Y = height - y;
                           if (confidence > CONFIDENCE_THRESHOLD)
                           {
                               d.Detected = true;
                               d.Angle = calculateAngle(x, width);
                               //Console.WriteLine("Cone Detected, " + d.Angle);
                               cone_hits++;
                               dataPacket = d;
                           }
                           cam_frames++;
                           //Console.WriteLine(confidence);
                           //if (!moving)
                           //{
                           //    Console.WriteLine("Not moving, sending notification");
                           //}
                       },
                       delegate(Fault f)
                       {
                           LogError(LogGroups.Console, "Could not query frame", f);
                       });
                if (cam_frames >= FRAMES_MAX)
                {
                    if (cone_hits >= CONE_HIT_THRESHOLD)
                    {
                        SendNotification<ConeNotification>(_subMgrPort, dataPacket);
                    }
                    else if (d.X != NULL)
                    {
                        SendNotification<ConeNotification>(_subMgrPort, d);
                    }
                    cone_hits = 0;
                    cam_frames = 0;
                }
            }

            //System.Threading.Thread.Sleep(FRAME_PAUSE);

        }
        private int calculateAngle(int x, int width)
        {
            x -= (int)(width/2);
            x /= (int)((width / 2) / MAX_ANGLE);
            //if (x < 0) x += 360;
            return x;
        }
        
        [ServiceHandler(ServiceHandlerBehavior.Concurrent)]
        public virtual IEnumerator<ITask> SubscribeHandler(Subscribe subscribe)
        {
            SubscribeRequestType request = subscribe.Body;
            Console.WriteLine("Cone Detection received subscribe request");
            yield return Arbiter.Choice(
                SubscribeHelper(_subMgrPort, request, subscribe.ResponsePort),
                delegate(SuccessResult success)
                {
                    Console.WriteLine("Cone Detection Subscription confirmed");
                    SendNotification<ConeNotification>(_subMgrPort, request.Subscriber, new CamData());
                },
                delegate(Exception e)
                {
                    LogError(null, "Cone Detection Subscribe failed", e);
                }
            );

            yield break;
        }
        
        [ServiceHandler(ServiceHandlerBehavior.Exclusive)]
        public IEnumerator<ITask> MovementHandler(Moving s)
        {
            if (moving != s.Body._status && !s.Body._status) //If it just stopped moving,
                System.Threading.Thread.Sleep(FRAME_PAUSE);
            moving = s.Body._status;
            yield break;
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
