/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package robomagellan.main.flowNodes;

import robomagellan.conerecon.ConeRecon.ConeInfo;
import robomagellan.conerecon.Webcam;
import robomagellan.flow.FlowNode;
import robomagellan.main.MainApp;
import robomagellan.main.MainView;
import robomagellan.motors.Motors;

/**
 * This flow node checks to see if the cone is in sight. If it is, it will try
 * to make the robot turn towards the cone. If the cone is directly ahead, it
 * will drive foward. If the cone is not in sight, it will turn until it finds it.
 * @author robomagellan
 */
public class ConeDetectFlowNode extends FlowNode{

    private ConeInfo info;

    private static final int BANDWIDTH = 5;
    private static final int TURN_SPEED = 2;
    
    @Override
    public boolean test() {
        info = MainApp.cam.getInfo();
        if (info.detected) return true;
        else return false;
    }

    @Override
    public void actionTrue() {
        int center = Webcam.IMAGE_WIDTH/2;
        if (info.x < center - BANDWIDTH){
            MainApp.motors.setSpeed(Motors.RIGHT, TURN_SPEED);
            MainApp.motors.setSpeed(Motors.LEFT, -TURN_SPEED);
            MainView.log(getName() + ": True, Cone to Left, Turning");
        } else if (info.x > center + BANDWIDTH){
            MainApp.motors.setSpeed(Motors.RIGHT, -TURN_SPEED);
            MainApp.motors.setSpeed(Motors.LEFT, TURN_SPEED);
            MainView.log(getName() + ": True, Cone to Right, Turning");
        } else {
            MainApp.motors.setSpeed(Motors.RIGHT, TURN_SPEED);
            MainApp.motors.setSpeed(Motors.LEFT, TURN_SPEED);
            MainView.log(getName() + ": True, Cone to Ahead, Moving Foward");
        }
    }

    @Override
    public void actionFalse() {
        MainApp.motors.setSpeed(Motors.RIGHT, -TURN_SPEED);
        MainApp.motors.setSpeed(Motors.LEFT, TURN_SPEED);
        MainView.log(getName() + ": False, Turning Right");
    }

}
