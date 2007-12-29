/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package webcamjava;
import javax.swing.*;
import java.awt.event.*;
/**
 *
 * @author tonyfwu
 */
public class Actions implements ActionListener{
	public Actions(){

	}
	public void actionPerformed(ActionEvent e){
		if(e.getActionCommand().equals("exit")){
			Webcam.stop_camera();
			System.exit(0);
		}
	}
}
