/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package robomagellan.main.flowNodes;

import robomagellan.flow.FlowNode;
import robomagellan.main.MainView;

/**
 * This class tests if an alternative route is available and chooses one.
 * @author robomagellan
 */
public class AlternateRouteFlowNode extends FlowNode{

    //TODO: Implement

    
    @Override
    public boolean test() {
        return true;
    }

    @Override
    public void actionTrue() {
        System.out.println(getName() + ": True");
        MainView.log(getName() + ": True");
    }

    @Override
    public void actionFalse() {
        System.out.println(getName() + ": False");
        MainView.log(getName() + ": False");
    }

}
