/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package robomagellan.main.flowNodes;

import robomagellan.flow.FlowNode;
import robomagellan.gps.GPSPacket;
import robomagellan.main.MainApp;
import robomagellan.main.MainView;
import robomagellan.main.Waypoint;

/**
 * This flow node checks to see if the current waypoint is of cone type and
 * if the robot is near the cone.
 * 
 * @author robomagellan
 */
public class ConeWaypointCheckFlowNode extends FlowNode{

    private static final double DIST_THRESHOLD = 4.0;

    @Override
    public boolean test() {
        if (MainApp.currentWpt != null && MainApp.currentWpt.type == Waypoint.TYPE_CONE){
            if (getDistanceFromWpt(MainApp.currentWpt.coord, MainApp.filter.getCoordinates()) < DIST_THRESHOLD)
                return true;
        }
        return false;
    }

    @Override
    public void actionTrue() {
        MainView.log(getName() + ": True, No Action");
    }

    @Override
    public void actionFalse() {
        MainView.log(getName() + ": False, No Action");
    }

    private static double getDistanceFromWpt(GPSPacket a, GPSPacket b){
        double x = a.utmEast - b.utmEast;
        double y = a.utmNorth - b.utmNorth;
        return Math.sqrt(x*x + y*y);
    }

}
