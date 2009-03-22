/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package robomagellan.main;

import robomagellan.gps.GPSPacket;

/**
 * This is a waypoint structure for the waypoint queue.
 * @author robomagellan
 */
public class Waypoint {

    /**
     * This type of waypoint indicates a cone.
     */
    public static final int TYPE_CONE = 0;
    /**
     * This type of waypoint indicates a normal waypoint.
     */
    public static final int TYPE_NORM = 1;

    /**
     * GPS Coordinates of the waypoint.
     */
    public GPSPacket coord;
    
    /**
     * Type of waypoint.
     */
    public int type;
}
