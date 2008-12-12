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

    public static final int LEFT = 1;
    public static final int RIGHT = 2;
    public static final char START_BYTE = '<';
    public static final int BAUD_RATE = 115200;
    public static final int PARITY = SerialPort.PARITY_NONE;
    public static final int DATA_BITS = SerialPort.DATABITS_8;
    public static final int STOP_BITS = SerialPort.STOPBITS_1;
    public static final int PACKET_RATE = 100;

    public static final int NUM_MOTORS = 2;
    public static final int BUFFER_SIZE = 32;

    private SerialPort port;
    private volatile ArrayList<String> commands;
    private Thread helperThread;
    private volatile boolean stopHelper;
    private InputStream in;
    private boolean hasListener;
    private EncoderDataListener listener;
    private OutputStream out;
    private volatile String cmd;

    public Motors(String portName){
        cmd = "<0000";
        hasListener = false;
        commands = new ArrayList<String>();
        commands.add(START_BYTE + "");
        for (int i = 0; i < NUM_MOTORS; i++)
            commands.add("00");
        port = SerialPortFactory.openPort(portName, BAUD_RATE, DATA_BITS, STOP_BITS, PARITY);
        stopHelper = false;
        try {
            out = port.getOutputStream();
        } catch (IOException ex) {
            Logger.getLogger(Motors.class.getName()).log(Level.SEVERE, "Could not get OutputStream", ex);
        }
        Runnable helper = new Runnable(){
            public void run() {
                while(!stopHelper){
                    try {
                        out.write(cmd.getBytes("ASCII"));
                    } catch (IOException ex) {
                        Logger.getLogger(Motors.class.getName()).log(Level.SEVERE, "Could not write to OutputStream", ex);
                    }
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

    public synchronized void setSpeed(int motor, int speed){
        if (speed > 10) speed = 10;
        if (speed < 0) speed = 0;
        if (speed == 10) commands.set(motor, speed + "");
        else commands.set(motor, "0" + speed);
        String newCmd = "";
        for (int i = 0; i < commands.size(); i++)
            newCmd = newCmd.concat(commands.get(i));
        this.cmd = newCmd;
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
