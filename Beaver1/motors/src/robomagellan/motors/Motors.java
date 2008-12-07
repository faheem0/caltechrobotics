/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package robomagellan.motors;

import gnu.io.SerialPort;
import gnu.io.SerialPortEvent;
import gnu.io.SerialPortEventListener;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.TooManyListenersException;
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
    public static final int BUFFER_SIZE = 32;

    private SerialPort port;
    private volatile ArrayList<String> commands;
    private Thread helperThread;
    private volatile boolean stopHelper;
    private InputStream in;
    private boolean hasListener;
    private EncoderDataListener listener;
    private OutputStream out;

    public Motors(String portName){
        commands = new ArrayList<String>();
        hasListener = false;
        for (int i = 0; i < NUM_MOTORS; i++)
            commands.add("<" + i + "00");
        port = SerialPortFactory.openPort(portName, BAUD_RATE, DATA_BITS, STOP_BITS, PARITY);
        stopHelper = false;
        try {
            out = port.getOutputStream();
        } catch (IOException ex) {
            Logger.getLogger(Motors.class.getName()).log(Level.SEVERE, "Could not get OutputStream", ex);
        }
        Runnable helper = new Runnable(){
            public void run() {
                String cmd = "" ;
                while(!stopHelper){

                    for (int i = 0; i < commands.size(); i++)
                        cmd = cmd.concat(commands.get(i));
                    try {
                        out.write(cmd.getBytes("ASCII"));
                    } catch (IOException ex) {
                        Logger.getLogger(Motors.class.getName()).log(Level.SEVERE, "Could not write to OutputStream", ex);
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
        try {
            in = port.getInputStream();
        } catch (IOException ex) {
            Logger.getLogger(Motors.class.getName()).log(Level.SEVERE, "Could not get InputStream", ex);
        }
    }
    
    public synchronized void addEncoderDataListener(EncoderDataListener d) throws TooManyListenersException{
        if(hasListener) throw new TooManyListenersException("There's already a listener on " + port.getName());
        listener = d;
        port.notifyOnDataAvailable(true);
        port.addEventListener(new SerialPortEventListener(){
            String str = "";
            byte[] buffer = new byte[BUFFER_SIZE];
            int bytesRead;

            public void serialEvent(SerialPortEvent arg0) {
                if (arg0.getEventType() == SerialPortEvent.DATA_AVAILABLE){
                    try {
                        bytesRead = in.read(buffer);
                        str = new String(buffer, 0, bytesRead, "ASCII");

                        System.out.print(str);

                        //listener.processEvent(null);
                    } catch (IOException ex) {
                        Logger.getLogger(Motors.class.getName()).log(Level.SEVERE, "Could not read from InputStream", ex);
                    }
                }
            }
        });

        hasListener = true;
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
            if (helperThread != null)
                helperThread.join();
        } catch (InterruptedException ex) {
            Logger.getLogger(Motors.class.getName()).log(Level.SEVERE, null, ex);
        }
        port.close();
    }
}
