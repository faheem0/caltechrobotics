/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package robomagellan.main.flowNodes;

import robomagellan.flow.FlowNode;

/**
 *
 * @author robomagellan
 */
public class ObstacleDetectionFlowNode extends FlowNode{

    @Override
    public boolean test() {
        return false;
        //TODO: Implement
    }

    @Override
    public void actionTrue() {
        System.out.println(getName() + ": True, Obstacle Detected");
    }

    @Override
    public void actionFalse() {
        System.out.println(getName() + ": False, No Obstacle");
    }

}