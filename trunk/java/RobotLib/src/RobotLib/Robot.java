/*
 * Robot.java
 *
 * Created on October 29, 2007, 11:33 PM
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package RobotLib;
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
    /**
     *Maximum angle the servo can turn to the right
     */
    public static final int MAX_SERVO1_ANGLE = 90;
    /**
     *Maximum angle the servo can turn to the left
     */
    public static final int MIN_SERVO1_ANGLE = -90;
    /**
     *The current angle of Servo 1
     */
    public int SERVO1_ANGLE;
    
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
        this.SERVO1_ANGLE = 0;
        this.setServo1(this.SERVO1_ANGLE);
    }
    /**
     * Sets the speed of the left wheel
     * @param   speed   the speed ranging from -100 to +100
     * @return    true if reasonable speed, false if not or false if couldn't send command.
     */
    public boolean setLeftWheelSpeed(int speed){
        if (speed >= -100 && speed <= 100){
            this.sendCommandStart();
            return this.sendCommand(1,speed+100);
        }
        else return false;
    }
    
     /** 
     * Sets the speed of the right wheel
     * @param   speed   the speed ranging from -100 to +100
     * @return    true if reasonable speed, false if not or false if couldn't send command
     */
    public boolean setRightWheelSpeed(int speed){
        if (speed >= -100 && speed <= 100){
            this.sendCommandStart();
            return this.sendCommand(2,speed+100);
        }
        else return false;
    }
     /**
     * Sets the position of Servo 1
     * @param   position   position of the servo in degrees ranging from -90 to 90 where 0 is directly forward and positive is to the right.
     * @return    true if reasonable position, false if not or false if couldn't send command
     */
    public boolean setServo1(int position){
        if (position >= MIN_SERVO1_ANGLE && position <= MAX_SERVO1_ANGLE){
            this.sendCommandStart();
            return this.sendCommand(3, position + 90);
        }
        else return false;
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
    /** Sends a specified command to the robot
     *For each command, it sends the command sequence and a corresponding value for that sequence
     */
    private boolean sendCommand(int command, int value){
        try {
            output.write(command);
            output.write(value);
        } catch (IOException e){
            return false;
        }
        return true;
    }
    private boolean sendCommandStart(){
        try {
            output.write(this.START_BYTE);
            return true;
        }
        catch(IOException e){
            return false;
        }
    }
    
}
