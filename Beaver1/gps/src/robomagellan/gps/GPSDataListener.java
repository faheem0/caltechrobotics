/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package robomagellan.gps;

/**
 * An interface to process packets received from the GPS
 * @author robomagellan
 */
public interface GPSDataListener {

	/**
	 * The event called by the AC12GPS class to process each packet.
	 * @param g the packet to be processed
	 * @see AC12GPS
	 */
	public void processEvent(GPSPacket g);
}
