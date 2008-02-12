/*
 * Robot.java
 *
 * Created on October 29, 2007, 11:33 PM
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package serialplot;
import java.io.*;
import gnu.io.*;
import java.util.*;
/**
 * @version 0.3
 * @author tonyfwu
 */
public class Robot {
    /**
     *Control sequence byte to notify the robot that its about to send a command
     */
    public static final int START_BYTE = 0xfe;
    
    private Enumeration  portList;
    private CommPortIdentifier commID;
    /**
     *Serial Port
     */
    protected SerialPort port;
    
    /** Output Stream to send the robot commands
     */
    protected OutputStream output;
    /** Input Stream to recieve data
     */
    protected InputStream input;
    
    /**
     * Creates a new instance of Robot and connects to the Robot.
     * This initiates the serial port and prepares the robot to transmit and recieve data.
     * @param portName the name of the serial port to connect to. (i.e. "/dev/ttyUSB0")
     */
    public Robot(String portName) {
        boolean foundPort = false;
        //recieveListener = new SerialPortRecieveListener();
        portList = CommPortIdentifier.getPortIdentifiers();
        while (portList.hasMoreElements()){
            if (((CommPortIdentifier)portList.nextElement()).getName().equals(portName)){
                System.out.println("Found port " + portName);
                foundPort = true;
                break;
            }
        }
        if (!foundPort){
            System.out.println("Couldn't find port " + portName);
            System.exit(1);
        }
        System.out.println("Attempting to Connect to " + portName);
        try {
            commID = CommPortIdentifier.getPortIdentifier(portName);
            port = (SerialPort)commID.open(portName, 2000);
	    System.out.println("Baud Rate is: " + port.getBaudRate());
        } catch (gnu.io.NoSuchPortException e1){
            System.exit(2);
        } catch (gnu.io.PortInUseException e2) {
            System.err.println("Port Already in Use!");
            System.exit(3);
        }
        System.out.println("Connected!");
        try {
            output = port.getOutputStream();
            input = port.getInputStream();
        } catch (IOException e){
            System.err.println("Caught IO Exception");
            System.exit(4);
        }
    }
    public InputStream getInputStream(){
	    return input;
    }
    /**
     *Disconnects the robot
     */
    public void shutdown(){
        try{
            output.close();
            input.close();
        } catch(IOException e){}
        port.close();
        System.exit(0);
    }
    
}
