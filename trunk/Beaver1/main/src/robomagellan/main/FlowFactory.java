/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package robomagellan.main;

import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.xml.parsers.ParserConfigurationException;
import robomagellan.flow.*;
import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import org.w3c.dom.*;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import org.xml.sax.SAXException;

/**
 *
 * @author robomagellan
 */
public class FlowFactory {

    private static final String NODE_TAG = "node";
    private static final String HEAD_TAG = "head";
    private static final String NAME_TAG = "name";
    private static final String CLASS_TAG = "class";
    private static final String TRUE_TAG = "true";
    private static final String FALSE_TAG = "false";

    private FlowFactory(){};

    public static Flow buildFlow(File xmlFile){

        MainView.log("Flow Build Started");
        FlowNode head = null;
        try {
            DocumentBuilderFactory docBuilderFactory = DocumentBuilderFactory.newInstance();
            DocumentBuilder docBuilder = docBuilderFactory.newDocumentBuilder();
            Document doc = docBuilder.parse(xmlFile);
            doc.getDocumentElement().normalize();

            HashMap<String, FlowNode> mapOfNodes = new HashMap<String, FlowNode>();
            ArrayList<FlowNodeStruct> flowNodes = new ArrayList<FlowNodeStruct>();

            NodeList nodes = doc.getElementsByTagName(NODE_TAG);

            for(int i = 0; i < nodes.getLength(); i++){
                Node myNode = nodes.item(i);
                if (myNode.getNodeType() == Node.ELEMENT_NODE){
                    Element myElement = (Element) myNode;
                    FlowNodeStruct fns = new FlowNodeStruct();

                    if (myElement.hasAttribute(HEAD_TAG)) fns.head = true;
                    else fns.head = false;

                    NodeList nameList = myElement.getElementsByTagName(NAME_TAG);
                    Element nameElement = (Element)nameList.item(0);
                    String name = nameElement.getChildNodes().item(0).getNodeValue();
                    fns.name = name;

                    NodeList classList = myElement.getElementsByTagName(CLASS_TAG);
                    Element classElement = (Element)classList.item(0);
                    String classS = classElement.getChildNodes().item(0).getNodeValue();
                    try {
                        fns.class_Name = (Class<? extends FlowNode>) FlowNode.class.getClassLoader().loadClass(classS);
                    } catch (ClassNotFoundException ex) {
                        Logger.getLogger(FlowFactory.class.getName()).log(Level.SEVERE, null, ex);
                    }

                    NodeList trueList = myElement.getElementsByTagName(TRUE_TAG);
                    if (trueList.getLength() > 0){
                            Element trueElement = (Element)trueList.item(0);
                            String trueS = trueElement.getChildNodes().item(0).getNodeValue();
                            fns.trueNode = trueS;
                    }

                    NodeList falseList = myElement.getElementsByTagName(FALSE_TAG);
                    if (falseList.getLength() > 0){
                            Element falseElement = (Element)falseList.item(0);
                            String falseS = falseElement.getChildNodes().item(0).getNodeValue();
                            fns.falseNode = falseS;
                    }

                    flowNodes.add(fns);
                    try {
                        FlowNode myFlowNode = fns.class_Name.newInstance();
                        myFlowNode.setName(fns.name);
                        mapOfNodes.put(fns.name, myFlowNode);
                        MainView.log("Created Node: " + myFlowNode.getName());
                        if (fns.head){
                            head = myFlowNode;
                        }
                    } catch (InstantiationException ex) {
                        Logger.getLogger(FlowFactory.class.getName()).log(Level.SEVERE, null, ex);
                    } catch (IllegalAccessException ex) {
                        Logger.getLogger(FlowFactory.class.getName()).log(Level.SEVERE, null, ex);
                    }
                }

            }
            //Linking the nodes
            for (int i = 0; i < flowNodes.size(); i++) {
                FlowNode myFlowNode = mapOfNodes.get(flowNodes.get(i).name);
                if (flowNodes.get(i).trueNode != null) {
                    myFlowNode.setTrueNode(mapOfNodes.get(flowNodes.get(i).trueNode));
                    MainView.log("Linked Node: " + myFlowNode.getName() + "->true->" + flowNodes.get(i).trueNode);
                }
                if (flowNodes.get(i).falseNode != null) {
                    myFlowNode.setFalseNode(mapOfNodes.get(flowNodes.get(i).falseNode));
                    MainView.log("Linked Node: " + myFlowNode.getName() + "->false->" + flowNodes.get(i).falseNode);
                }
            }
        } catch (SAXException ex) {
            Logger.getLogger(FlowFactory.class.getName()).log(Level.SEVERE, null, ex);
        } catch (IOException ex) {
            Logger.getLogger(FlowFactory.class.getName()).log(Level.SEVERE, null, ex);
        } catch (ParserConfigurationException ex) {
            Logger.getLogger(FlowFactory.class.getName()).log(Level.SEVERE, null, ex);
        }

        MainView.log("Head Node is: " + head.getName());
        MainView.log("Flow Build Done");
        return new Flow(head);

    }
}
