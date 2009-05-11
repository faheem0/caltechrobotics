/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package robomagellan.main.flowNodes;

import robomagellan.gps.GPSPacket;

/**
 *
 * @author robomagellan
 */
public class Test {

    /**
     * @param args the command line arguments
     */
    private static final double TURN_THRESHOLD = 4;
    public static void main(String[] args) {
        GPSPacket currentWpt = new GPSPacket();
        currentWpt.utmEast = 0;
        currentWpt.utmNorth = 0;
        GPSPacket here = new GPSPacket();
        here.utmEast = 0;
        here.utmNorth = 0;
        GPSPacket offset = new GPSPacket();
        offset.utmEast = currentWpt.utmEast - here.utmEast;
        offset.utmNorth = currentWpt.utmNorth - here.utmNorth;
        double bearing = 45;
        //double bearing_i = //Figure out how to turn


        //TODO: FIGURE OUT HOW TO TURN!!!1
        double phi = Math.atan2(offset.utmNorth, offset.utmEast);
        System.out.println(phi);
        if (phi < 0) phi += 2*Math.PI;
        System.out.println(phi);
        phi = 90 - Math.toDegrees(phi);

        double delta = bearing - phi;
        if(delta < 0) delta += 360;
        System.out.println(delta);

        if (delta <= TURN_THRESHOLD || delta > 360-TURN_THRESHOLD){
            //Move forward
            System.out.println("Waypoint is ahead, Moving Forward");
        } else if (delta > 0 && delta <= 180){
            //Turn right
            System.out.println("Waypoint is to the Right, turning Right");
        } else if (delta > 180 && delta < 360) {
            //Turn left
            System.out.println("Waypoint is to the Left, turning Left");
        }
    }

}
