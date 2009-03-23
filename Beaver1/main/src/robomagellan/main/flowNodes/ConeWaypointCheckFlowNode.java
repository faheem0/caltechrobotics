/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package robomagellan.main.flowNodes;

import robomagellan.flow.FlowNode;
import robomagellan.main.MainApp;
import robomagellan.main.MainView;
import robomagellan.main.Waypoint;

/**
 * This flow node checks to see if the current waypoint is of cone type.
 * 
 * @author robomagellan
 */
public class ConeWaypointCheckFlowNode extends FlowNode{

    @Override
    public boolean test() {
        if (MainApp.currentWpt != null && MainApp.currentWpt.type == Waypoint.TYPE_CONE)
            return true;
        return false;
    }

    @Override
    public void actionTrue() {
        MainView.log(getName() + ": True, Waypoint has Cone, No Action");
    }

    @Override
    public void actionFalse() {
        MainView.log(getName() + ": False, Waypoint does not have Cone, No Action");
    }

}
