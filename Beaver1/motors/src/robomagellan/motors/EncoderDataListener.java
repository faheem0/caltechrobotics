/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package robomagellan.motors;

/**
 *
 * @author robomagellan
 */
public interface EncoderDataListener {

    public void processEvent(EncoderPacket p);
}
