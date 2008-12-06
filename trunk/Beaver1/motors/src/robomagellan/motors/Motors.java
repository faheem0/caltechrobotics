/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package robomagellan.motors;

import gnu.io.CommPortIdentifier;
import gnu.io.SerialPort;
import gnu.io.UnsupportedCommOperationException;
import java.io.IOException;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.logging.Level;
import java.util.logging.Logger;
import robomagellan.helpers.SerialPortFactory;

/**
 *
 * @author robomagellan
 */
public class Motors {

    public static final int FRONT_LEFT = 0;
    public static final int FRONT_RIGHT = 1;
    public static final int BACK_RIGHT = 2;
    public static final int BACK_LEFT = 3;
    public static final int FORWARD = 0;
    public static final int BACKWARD = 1;
    public static final char START_BYTE = '<';
    public static final int BAUD_RATE = 4800;
    public static final int PARITY = SerialPort.PARITY_NONE;
    public static final int DATA_BITS = SerialPort.DATABITS_8;
    public static final int STOP_BITS = SerialPort.STOPBITS_1;
    public static final int PACKET_RATE = 100;

    public static final int NUM_MOTORS = 4;

    private SerialPort port;
    private volatile ArrayList<String> commands;
    private Thread helperThread;
    private volatile boolean stopHelper;

    public Motors(String portName) throws IOException{
        commands = new ArrayList<String>();
        for (int i = 0; i < NUM_MOTORS; i++)
            commands.add("<" + i + "00");
        port = SerialPortFactory.openPort(portName, BAUD_RATE, DATA_BITS, STOP_BITS, PARITY);
        stopHelper = false;
        Runnable helper = new Runnable(){
            final OutputStream stream = port.getOutputStream();
            public void run() {
                String cmd = "" ;
                while(!stopHelper){

                    for (int i = 0; i < commands.size(); i++)
                        cmd = cmd.concat(commands.get(i));
                    try {
                        stream.write(cmd.getBytes("ASCII"));
                    } catch (IOException ex) {
                        Logger.getLogger(Motors.class.getName()).log(Level.SEVERE, null, ex);
                    }
                    cmd = "";
                    try {
                        Thread.sleep(PACKET_RATE);
                    } catch (InterruptedException ex) {
                        //Logger.getLogger(Motors.class.getName()).log(Level.SEVERE, null, ex);
                    }
                }
            }
        };
        helperThread = new Thread(helper);
        helperThread.start();
    }
    public synchronized void setSpeed(int motor, int direction, int speed){
        if (speed > 9) speed = 9;
        if (speed < 0) speed = 0;
        String cmd = START_BYTE + "" +  motor + "" + direction + "" +speed;
        commands.set(motor, cmd);
    }
    public synchronized void stop(){
        stopHelper = true;
        try {
            helperThread.join();
        } catch (InterruptedException ex) {
            Logger.getLogger(Motors.class.getName()).log(Level.SEVERE, null, ex);
        }
        port.close();
    }
/*
    private void initPort(String portName) {
        boolean foundPort = false;
        portList = CommPortIdentifier.getPortIdentifiers();
        while (portList.hasMoreElements()) {
            if (((CommPortIdentifier) portList.nextElement()).getName().equals(portName)) {
                System.out.println("Found port " + portName);
                foundPort = true;
                break;
            }
        }
        if (!foundPort) {
            System.out.println("Couldn't find port " + portName);
            //System.exit(1);
        }
        System.out.println("Attempting to Connect to Motors at" + portName);
        try {
            commID = CommPortIdentifier.getPortIdentifier(portName);
            port = (SerialPort) commID.open(portName, 2000);
            port.setSerialPortParams(BAUD_RATE, DATA_BITS, STOP_BITS, PARITY);
            System.out.println("Baud Rate is: " + port.getBaudRate());
            System.out.println("Data Bits is: " + port.getDataBits());
            System.out.println("Stop Bits is: " + port.getStopBits());
            System.out.println("Parity Bits is: " + port.getParity());
        } catch (UnsupportedCommOperationException ex) {
            Logger.getLogger(Motors.class.getName()).log(Level.SEVERE, null, ex);
        } catch (gnu.io.NoSuchPortException e1) {
            //System.exit(2);
        } catch (gnu.io.PortInUseException e2) {
            System.err.println("Port Already in Use!");
            //System.exit(3);
        }
    }
*/
}
