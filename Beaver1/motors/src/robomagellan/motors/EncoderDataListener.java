/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package robomagellan.motors;

/**
 * An interface to process packets received from the motors.
 * @author robomagellan
 */
public interface EncoderDataListener {

	/**
	 * This event is called by the Motors class to process each packet.
	 * @param p the packet to be processed
	 * @see Motors
	 */
    public void processEvent(EncoderPacket p);
}
