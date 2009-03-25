/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package robomagellan.main;

import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.xml.parsers.ParserConfigurationException;
import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import org.w3c.dom.*;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import org.xml.sax.SAXException;
import robomagellan.gps.GPSPacket;

/**
 * This class is a helper class that creates waypoints from a file.
 * @author robomagellan
 */
public class WaypointFactory {

    private static final String WPT_TAG = "wpt";
    private static final String NUMBER_TAG = "number";
    private static final String EAST_TAG = "east";
    private static final String NORTH_TAG = "north";
    private static final String TYPE_TAG = "type";

    private WaypointFactory(){};

    /**
     * Parses an XML File and generates a list of waypoints
     * @param xmlFile The XML File to be parsed
     * @return The list of waypoints
     */
    public static ArrayList<Waypoint> importWaypoints(File xmlFile){

        MainView.log("Waypoint Import Started");
        ArrayList<Waypoint> wpts = new ArrayList<Waypoint>();
        try {
            DocumentBuilderFactory docBuilderFactory = DocumentBuilderFactory.newInstance();
            DocumentBuilder docBuilder = docBuilderFactory.newDocumentBuilder();
            Document doc = docBuilder.parse(xmlFile);
            doc.getDocumentElement().normalize();

            HashMap<Integer, Waypoint> mapOfWpts = new HashMap<Integer, Waypoint>();

            NodeList nodes = doc.getElementsByTagName(WPT_TAG);

            for(int i = 0; i < nodes.getLength(); i++){
                Node myNode = nodes.item(i);
                if (myNode.getNodeType() == Node.ELEMENT_NODE){
                    Element myElement = (Element) myNode;

                    NodeList numberList = myElement.getElementsByTagName(NUMBER_TAG);
                    Element numberElement = (Element)numberList.item(0);
                    String numberS = numberElement.getChildNodes().item(0).getNodeValue();

                    NodeList eastList = myElement.getElementsByTagName(EAST_TAG);
                    Element eastElement = (Element)eastList.item(0);
                    String eastS = eastElement.getChildNodes().item(0).getNodeValue();

                    NodeList northList = myElement.getElementsByTagName(NORTH_TAG);
                    Element northElement = (Element)northList.item(0);
                    String northS = northElement.getChildNodes().item(0).getNodeValue();

                    NodeList typeList = myElement.getElementsByTagName(TYPE_TAG);
                    Element typeElement = (Element)typeList.item(0);
                    String typeS = typeElement.getChildNodes().item(0).getNodeValue();


                    Waypoint w = new Waypoint();
                    w.coord = new GPSPacket();
                    w.coord.utmEast = Double.parseDouble(eastS);
                    w.coord.utmNorth = Double.parseDouble(northS);
                    w.type = Integer.parseInt(typeS);

                    mapOfWpts.put(Integer.parseInt(numberS), w);

                    MainView.log("Parsed Waypoint: " + numberS + " (" + eastS + "," + northS + ") Type-" + typeS);
                }

            }
            //Sorting Waypoints
            Integer[] keys = mapOfWpts.keySet().toArray(new Integer[0]);
            MainView.log("Sorting Waypoints");
            Arrays.sort(keys);
            for (int i = 0; i < keys.length; i++) {
                wpts.add(mapOfWpts.get(keys[i]));
            }
        } catch (SAXException ex) {
            Logger.getLogger(WaypointFactory.class.getName()).log(Level.SEVERE, null, ex);
        } catch (IOException ex) {
            Logger.getLogger(WaypointFactory.class.getName()).log(Level.SEVERE, null, ex);
        } catch (ParserConfigurationException ex) {
            Logger.getLogger(WaypointFactory.class.getName()).log(Level.SEVERE, null, ex);
        }
        MainView.log("Waypoint Import Done");
        return wpts;

    }
}
