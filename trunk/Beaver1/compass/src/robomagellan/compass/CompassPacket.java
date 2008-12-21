/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package robomagellan.compass;

/**
 * The compass reading will be wrapped in this class.
 * @author robomagellan
 */
public class CompassPacket {
	/**
	 * The heading read by the compass ranging from 0 to 359 degrees. 0 is north.
	 * Ignore the default value.
	 */
    public int heading = 0xFF;
}
