/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package robomagellan.flow;

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
        }
    } 
}
