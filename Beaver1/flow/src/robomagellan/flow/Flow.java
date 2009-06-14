/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package robomagellan.flow;

import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author robomagellan
 */
public class Flow {
    private FlowNode flowNode;

    public Flow(){
        flowNode = null;
    }
    public Flow(FlowNode head){
        flowNode = head;
    }
    public void setHead(FlowNode head){
        flowNode = head;
    }

    public void execute(){
        while (flowNode != null){
            if (flowNode.test()){
                flowNode.actionTrue();
                flowNode = flowNode.getTrueNode();
            }
            else {
                flowNode.actionFalse();
                flowNode = flowNode.getFalseNode();
            }
            try {
                Thread.sleep(1);
            } catch (InterruptedException ex) {
                //Logger.getLogger(Flow.class.getName()).log(Level.SEVERE, null, ex);
            }
        }
    } 
}
