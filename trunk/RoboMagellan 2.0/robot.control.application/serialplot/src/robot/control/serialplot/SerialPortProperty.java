/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package robot.control.serialplot;

/**
 *
 * @author tonyfwu
 */
public class SerialPortProperty {
	public String ID;
	public int Value;
	
	public SerialPortProperty(String id, int value){
		ID = id;
		Value = value;
	}
	
	public String toString(){
		return ID;
	}
}
