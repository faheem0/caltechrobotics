/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package robomagellan.main.flowNodes;

import java.awt.EventQueue;
import java.util.logging.Level;
import java.util.logging.Logger;
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

    private static final int BANDWIDTH = 100;
    private static final int TURN_SPEED = 1;
    private static final double SPIRAL_INC = 0.5;
    private static final double TURN_SPIRAL_MAX = TURN_SPEED+2;
    private static final double TURN_SPIRAL_MIN = -TURN_SPEED - 2;
    private static double SPIRAL = TURN_SPIRAL_MIN;
    private static int MULT = +1;
    
    @Override
    public boolean test() {
        info = MainApp.cam.getInfo();
        if (info.detected) return true;
        else return false;
    }

    public static void updateSpiral(){
        SPIRAL = TURN_SPIRAL_MIN;
    }
    @Override
    public void actionTrue() {
        int center = Webcam.IMAGE_WIDTH / 2;
        if (info.x < center - BANDWIDTH/2) {
            System.out.println("Left: " + info.x);
            MainApp.motors.setSpeed(Motors.RIGHT, -TURN_SPEED);
            MainApp.motors.setSpeed(Motors.LEFT, TURN_SPEED);
            //System.out.println("True, Cone to Left, Turning");
        } else if (info.x > center + BANDWIDTH/2) {
            System.out.println("Right: " + info.x);
            MainApp.motors.setSpeed(Motors.RIGHT, TURN_SPEED);
            MainApp.motors.setSpeed(Motors.LEFT, -TURN_SPEED);
            //System.out.println("True, Cone to Right, Turning");
        } else {
            MainApp.motors.setSpeed(Motors.RIGHT, TURN_SPEED+4);
            MainApp.motors.setSpeed(Motors.LEFT, TURN_SPEED+4);
//            EventQueue.invokeLater(new Runnable() {
//
//                public void run() {
//                    MainView.log(getName() + ": True, Cone to Ahead, Moving Foward");
//                }
//            });
//            System.out.println("True, Cone Ahead, Moving Forward");
        }
        try {
            Thread.sleep(30);
        } catch (InterruptedException ex) {
        }
    }

    @Override
    public void actionFalse() {
        if (SPIRAL >= TURN_SPIRAL_MAX) MULT = -1;
        else if (SPIRAL <= TURN_SPIRAL_MIN) MULT += +1;
        SPIRAL += SPIRAL_INC * MULT;
        System.out.println("Spiral: " + SPIRAL);
        MainApp.motors.setSpeed(Motors.RIGHT, -TURN_SPEED - 2);
        MainApp.motors.setSpeed(Motors.LEFT, TURN_SPEED+2);
        try {
            Thread.sleep(500);
            //System.out.println("False, Turning Right");
        } catch (InterruptedException ex) {
        }
        MainApp.motors.setSpeed(Motors.RIGHT, 0);
        MainApp.motors.setSpeed(Motors.LEFT, 0);
        try {
            Thread.sleep(500);
            //System.out.println("False, Turning Right");
        } catch (InterruptedException ex) {
        }
        //System.out.println("False, Turning Right");
    }

}
