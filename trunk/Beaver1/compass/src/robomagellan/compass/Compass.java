/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package robomagellan.compass;

import gnu.io.SerialPort;
import gnu.io.SerialPortEvent;
import gnu.io.SerialPortEventListener;
import java.io.IOException;
import java.io.InputStream;
import java.util.TooManyListenersException;
import java.util.logging.Level;
import java.util.logging.Logger;
import robomagellan.helpers.SerialPortFactory;

/**
 *
 * @author robomagellan
 */
public class Compass {
    public static final int BAUD_RATE = 9600;
    public static final int DATA_BITS = SerialPort.DATABITS_8;
    public static final int PARITY = SerialPort.PARITY_NONE;
    public static final int STOP_BITS = SerialPort.STOPBITS_1;
    public static final int BUFFER_SIZE = 32;

    private SerialPort port;
    private boolean hasListener;
    private CompassDataListener listener;
    private InputStream in;

    public Compass(String portName){
        hasListener = false;
        port = SerialPortFactory.openPort(portName, BAUD_RATE, DATA_BITS, STOP_BITS, PARITY);
        try {
            in = port.getInputStream();
        } catch (IOException ex) {
            Logger.getLogger(Compass.class.getName()).log(Level.SEVERE, "Could not get InputStream", ex);
        }
    }

     public synchronized void addCompassDataListener(CompassDataListener c) throws TooManyListenersException{
        if(hasListener) throw new TooManyListenersException("There's already a listener on " + port.getName());
        listener = c;
        port.notifyOnDataAvailable(true);
        port.addEventListener(new SerialPortEventListener(){
            String str = "";
            byte[] buffer = new byte[BUFFER_SIZE];
            int bytesRead;
            String[] strs;
            String[] params;

            public void serialEvent(SerialPortEvent arg0) {
                if (arg0.getEventType() == SerialPortEvent.DATA_AVAILABLE){
                    try {
                        bytesRead = in.read(buffer);
                        str = new String(buffer, 0, bytesRead, "ASCII");
                        System.out.print(str);

                        //listener.processEvent(null);
                    } catch (IOException ex) {
                        Logger.getLogger(Compass.class.getName()).log(Level.SEVERE, "Could not read from InputStream", ex);
                    }
                }
            }
        });

        hasListener = true;
    }

    public void stop(){
        port.close();
    }
}
