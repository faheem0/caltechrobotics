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


namespace RoboMagellan.MotorControl
{
    
    
    /// <summary>
    /// Implementation class for GenericMotor
    /// </summary>
    [DisplayName("GenericMotor")]
    [Description("The GenericMotor Service")]
    [Contract(Contract.Identifier)]
    public class GenericMotorService : DsspServiceBase
    {
        
        /// <summary>
        /// _state
        /// </summary>
        private GenericMotorState _state = new GenericMotorState();
        
        /// <summary>
        /// _main Port
        /// </summary>
        [ServicePort("/genericmotor", AllowMultipleInstances=false)]
        private GenericMotorOperations _mainPort = new GenericMotorOperations();

        private static string MOTOR_PORT = "COM2";

        private MotorControl _motor;

        /// <summary>
        /// Default Service Constructor
        /// </summary>
        public GenericMotorService(DsspServiceCreationPort creationPort) : 
                base(creationPort)
        {
            _motor = new MotorControl(MOTOR_PORT, TaskQueue);
        }
        
        /// <summary>
        /// Service Start
        /// </summary>
        protected override void Start()
        {
			base.Start();
			// Add service specific initialization here.
            SpawnIterator(activateMotorIterator);




        }

        public IEnumerator<ITask> activateMotorIterator()
        {
            if (!_motor.connect())
            {
                LogError("Failed to initialize motor control!");
                yield break;
            }
            else
            {
                yield return Arbiter.Receive(false, TimeoutPort(10), delegate(DateTime time) { });
                _motor.installReceiveHandler();
            }

        }

        [ServiceHandler(ServiceHandlerBehavior.Exclusive)]
        public IEnumerator<ITask> SetMotorSpeedHandler(SetSpeed s)
        {
            MotorSpeed sp = s.Body;
            _motor.sendMove(sp.Left, sp.Right);
            yield break;
        }

        [ServiceHandler(ServiceHandlerBehavior.Exclusive)]
        public IEnumerator<ITask> StopHandler(Stop s)
        {
            _motor.sendStop(s);
            yield break;
        }

        [ServiceHandler(ServiceHandlerBehavior.Exclusive)]
        public IEnumerator<ITask> SendAckHandler(SendAck s)
        {
            _motor.sendAck();
            yield break;
        }

        // NEEDS TO RESPOND ON TURN COMPLETE
        [ServiceHandler(ServiceHandlerBehavior.Exclusive)]
        public IEnumerator<ITask> TurnHandler(Turn t)
        {
            int heading = (int)t.Body.heading;
            _motor.sendTurn(heading, t);
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
