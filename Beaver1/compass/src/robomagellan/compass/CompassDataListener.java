/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package robomagellan.compass;

/**
 * An interface describing a processor for each CompassPacket. Each time the Compass receives data
 * it will call processEvent.
 * @see Compass
 * @author robomagellan
 */
public interface CompassDataListener {
	/**
	 * This method should process the CompassPacket in any way.
	 * @param c The most recent compass reading.
	 */
    public void processEvent(CompassPacket c);
}
