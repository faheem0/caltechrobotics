    /*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package robomagellan.main.flowNodes;

import java.awt.EventQueue;
import robomagellan.flow.FlowNode;
import robomagellan.main.MainApp;
import robomagellan.main.MainView;

/**
 * This part of the flow asks, "Is there another waypoint available?"
 * Test is true when there is another waypoint available, and false
 * when there is not.
 * @author robomagellan
 */
public class NextWaypointFlowNode extends FlowNode{

    private static int reached = -1;
    @Override
    public boolean test() {
        if (MainApp.wpts.isEmpty()) return false;
        else return true;
    }

    /**
     * When there is a waypoint available, it dequeues a waypoint and sets it
     * as the current waypoint.
     */
    @Override
    public void actionTrue() {

        reached++;
        EventQueue.invokeLater(new Runnable(){
            final int n = reached;
            public void run() {
                MainView.wpTableData.setValueAt(true, n, MainView.WPTABLE_REACHED_COL_LOC);
            }
        });
        MainApp.currentWpt = MainApp.wpts.poll();
        MainView.log(getName() + ": True, New Waypoint Acquired");
    }

    @Override
    public void actionFalse() {
        MainView.log(getName() + ": False, No Waypoints Left");
    }

}
