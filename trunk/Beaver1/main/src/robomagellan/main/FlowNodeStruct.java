/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package robomagellan.main;

import robomagellan.flow.FlowNode;

/**
 * This is a helper class for the Flow Factory.
 * @author robomagellan
 */
public class FlowNodeStruct {
        public String name;
        public Class<? extends FlowNode> class_Name;
        public String trueNode;
        public String falseNode;
        public boolean head;
}
