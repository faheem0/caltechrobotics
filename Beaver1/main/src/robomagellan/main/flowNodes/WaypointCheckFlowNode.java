/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package robomagellan.main.flowNodes;

import robomagellan.flow.FlowNode;
import robomagellan.gps.GPSPacket;
import robomagellan.main.MainApp;
import robomagellan.main.MainView;

/**
 * This flow node checks to see if the robot is at the current waypoint.
 * @author robomagellan
 */
public class WaypointCheckFlowNode extends FlowNode{

    private static final double DIST_THRESHOLD = 2.0;
    
    @Override
    public boolean test() {
        if (MainApp.currentWpt != null){
            if (getDistanceFromWpt(MainApp.currentWpt.coord, MainApp.filter.getCoordinates()) < DIST_THRESHOLD)
                return true;
        }
        return false;
    }

    @Override
    public void actionTrue() {
        GPSPacket here = MainApp.filter.getCoordinates();
        MainView.log(getName() + ": True, At Waypoint,\n\tWaypoint ("
                + MainApp.currentWpt.coord.utmEast + "," + MainApp.currentWpt.coord.utmNorth
                + ")\n\tCurrent Location (" + here.utmEast + "," + here.utmNorth + ")");
    }

    @Override
    public void actionFalse() {
        GPSPacket here = MainApp.filter.getCoordinates();
        double bearing = MainApp.filter.getBearing();
        //double bearing_i = //Figure out how to turn

        MainView.log(getName() + ": False");
    }

    private static double getDistanceFromWpt(GPSPacket a, GPSPacket b){
        double x = a.utmEast - b.utmEast;
        double y = a.utmNorth - b.utmNorth;
        return Math.sqrt(x*x + y*y);
    }

}
