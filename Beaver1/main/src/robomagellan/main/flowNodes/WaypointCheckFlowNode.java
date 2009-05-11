/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package robomagellan.main.flowNodes;

import robomagellan.flow.FlowNode;
import robomagellan.gps.GPSPacket;
import robomagellan.main.MainApp;
import robomagellan.main.MainView;
import robomagellan.motors.Motors;

/**
 * This flow node checks to see if the robot is at the current waypoint.
 * @author robomagellan
 */
public class WaypointCheckFlowNode extends FlowNode{

    private static final double DIST_THRESHOLD = 2.0;
    private static final double TURN_THRESHOLD = 5.0;
    private static final int FORWARD_SPEED = 5;
    private static final int TURN_SPEED = 2;

    private static boolean first = true;
    
    @Override
    public boolean test() {
        if (first){
            first = false;
            return true;
        }
        if (MainApp.currentWpt != null){
            if (getDistanceFromWpt(MainApp.currentWpt.coord, MainApp.filter.getHorizPosition()) < DIST_THRESHOLD)
                return true;
        }
        return false;
    }

    @Override
    public void actionTrue() {
        if (MainApp.currentWpt != null){
        GPSPacket here = MainApp.filter.getHorizPosition();
        MainView.log(getName() + ": True, At Waypoint,\n\tWaypoint ("
                + MainApp.currentWpt.coord.utmEast + "," + MainApp.currentWpt.coord.utmNorth
                + ")\n\tCurrent Location (" + here.utmEast + "," + here.utmNorth + ")");
        }
    }

    @Override
    public void actionFalse() {
        System.out.println("Got Here");
        //if (MainApp.currentWpt == null) return;
        GPSPacket currentWpt = MainApp.currentWpt.coord;
        GPSPacket here = MainApp.filter.getHorizPosition();
        GPSPacket offset = new GPSPacket();
        offset.utmEast = currentWpt.utmEast - here.utmEast;
        offset.utmNorth = currentWpt.utmNorth - here.utmNorth;
        double bearing = MainApp.filter.getHeading();
        //double bearing_i = //Figure out how to turn


        //TODO: FIGURE OUT HOW TO TURN!!!1
        double phi = Math.atan2(offset.utmNorth, offset.utmEast);
        if (phi < 0) phi += 2*Math.PI;
        phi = 90 - Math.toDegrees(phi);

        double delta = bearing - phi;
        if(delta < 0) delta += 360;
        System.out.println(delta);

        if (delta <= TURN_THRESHOLD || delta > 360-TURN_THRESHOLD){
            //Move forward
            MainView.log("Waypoint is ahead, Moving Forward");
            MainApp.motors.setSpeed(Motors.LEFT, FORWARD_SPEED);
            MainApp.motors.setSpeed(Motors.RIGHT, FORWARD_SPEED);
        } else if (delta > 0 && delta <= 180){
            //Turn right
            MainView.log("Waypoint is to the Right, turning Right");
            MainApp.motors.setSpeed(Motors.LEFT, TURN_SPEED);
            MainApp.motors.setSpeed(Motors.RIGHT, -TURN_SPEED);
        } else if (delta > 180 && delta < 360) {
            //Turn left
            MainView.log("Waypoint is to the Left, turning Left");
            MainApp.motors.setSpeed(Motors.LEFT, -TURN_SPEED);
            MainApp.motors.setSpeed(Motors.RIGHT, TURN_SPEED);
        }

    }

    private static double getDistanceFromWpt(GPSPacket a, GPSPacket b){
        double x = a.utmEast - b.utmEast;
        double y = a.utmNorth - b.utmNorth;
        return Math.sqrt(x*x + y*y);
    }

}
