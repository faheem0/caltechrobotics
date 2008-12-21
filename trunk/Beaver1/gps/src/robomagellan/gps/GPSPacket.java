/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package robomagellan.gps;

/**
 * A GPS Packet
 * @author robomagellan
 */
public class GPSPacket {

	/**
	 * UTM East coordinates in meters
	 */
	public double utmEast = 0;
	/**
	 * UTM North coordinates in meters
	 */
	public double utmNorth = 0;
	/**
	 * Precision of the coordinates in +- meters
	 */
	public double precision = 0;
	/**
	 * Timestamp in seconds that in which a this packet was received.
	 */
	public double time = 0;
}
