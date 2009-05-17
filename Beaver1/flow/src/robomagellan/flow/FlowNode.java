/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package robomagellan.flow;

/**
 *
 * @author robomagellan
 */
public abstract class FlowNode {
    String name;
    protected FlowNode trueNode, falseNode;

    public FlowNode(){
        this(null);
    }
    public FlowNode(String name){
        this.name = name;
        this.trueNode = null;
        this.falseNode = null;
    }
    
    public abstract boolean test();
    public abstract void actionTrue();
    public abstract void actionFalse();

    public void setTrueNode (FlowNode trueNode){
        this.trueNode = trueNode;
    }
    public void setFalseNode (FlowNode falseNode){
        this.falseNode = falseNode;
    }
    public FlowNode getTrueNode(){
        return trueNode;
    }
    public FlowNode getFalseNode(){
        return falseNode;
    }
    public void setName(String s){
        name = s;
    }
    public String getName(){
        return name;
    }
}
