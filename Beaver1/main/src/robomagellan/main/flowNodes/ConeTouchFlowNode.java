/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package robomagellan.main.flowNodes;

import java.awt.EventQueue;
import java.util.logging.Level;
import java.util.logging.Logger;
import robomagellan.flow.FlowNode;
import robomagellan.main.MainApp;
import robomagellan.main.MainView;
import robomagellan.motors.Motors;

/**
 * This class checks to see if the robot has touched the cone and acts accordingly.
 * @author robomagellan
 */
public class ConeTouchFlowNode extends FlowNode{

    public static final int backSpeed = -5;
    @Override
    public boolean test() {
        return MainApp.filter.getObstacle();
    }

    @Override
    public void actionTrue() {
        EventQueue.invokeLater(new Runnable() {

            public void run() {
                MainView.log("ConeTouchFlowNode: Found Cone");
            }
        });
        
        MainApp.motors.setSpeed(Motors.LEFT, backSpeed);
        MainApp.motors.setSpeed(Motors.RIGHT, backSpeed);
        try {
            Thread.sleep(1000);
        } catch (InterruptedException ex) {
            Logger.getLogger(ConeTouchFlowNode.class.getName()).log(Level.SEVERE, null, ex);
        }
        MainApp.motors.setSpeed(Motors.LEFT, 0);
        MainApp.motors.setSpeed(Motors.RIGHT, 0);
    }

    @Override
    public void actionFalse() {
        try {
            Thread.sleep(100);
        } catch (InterruptedException ex) {
            Logger.getLogger(ConeTouchFlowNode.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

}
