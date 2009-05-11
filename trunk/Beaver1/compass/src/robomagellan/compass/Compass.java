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
 * The primary class in the robomagellan.compass package.
 * Use this class to listen on a serial port for compass data.
 * @author robomagellan
 */
public class Compass {

    /**
     * The Serial Port Baud Rate.
     */
    public static final int BAUD_RATE = 115200;
    /**
     * 8 Data Bits
     */
    public static final int DATA_BITS = SerialPort.DATABITS_8;
    /**
     * No Parity
     */
    public static final int PARITY = SerialPort.PARITY_NONE;
    /**
     * 1 Stop Bit
     */
    public static final int STOP_BITS = SerialPort.STOPBITS_1;
    /**
     * The event handler will try to read this many bytes every interrupt.
     */
    public static final int BUFFER_SIZE = 32;
    /**
     * Constant for parsing data
     */
    public static final int ASCII_ZERO = 48;
    /**
     * The start byte of each packet received.
     */
    public static final int START_BYTE = 0x3c;

    public static final double COMPASS_OFFSET = 245.47;
    private SerialPort port;
    private boolean hasListener;
    private CompassDataListener listener;
    private InputStream in;

    /**
     * Opens a serial port for the compass. Does not start reading yet.
     * @param portName a String containing the port name (ie. "COM1" or "/dev/ttyUSB0")
     */
    public Compass(String portName) {
        hasListener = false;
        port = SerialPortFactory.openPort(portName, BAUD_RATE, DATA_BITS, STOP_BITS, PARITY);
        try {
            in = port.getInputStream();
        } catch (IOException ex) {
            Logger.getLogger(Compass.class.getName()).log(Level.SEVERE, "Could not get InputStream", ex);
        }
    }

    /**
     * Starts reading from the serial port.
     * @param c every CompassPacket received will be fed to the processEvent method of this object.
     * @throws java.util.TooManyListenersException
     */
    public synchronized void addCompassDataListener(CompassDataListener c) throws TooManyListenersException {
        if (hasListener) {
            throw new TooManyListenersException("There's already a listener on " + port.getName());
        }
        listener = c;
        port.notifyOnDataAvailable(true);
        port.addEventListener(new SerialPortEventListener() {

            int bytesRead;
            int heading;
            int state = 0;
            byte[] buffer = new byte[BUFFER_SIZE];

            public void serialEvent(SerialPortEvent arg0) {
                if (arg0.getEventType() == SerialPortEvent.DATA_AVAILABLE) {
                    try {
                        bytesRead = in.read(buffer);
                        for (int i = 0; i < bytesRead; i++) {
                            switch (state) {
                                case 0:
                                    if (buffer[i] == START_BYTE) {
                                        state = 1;
                                    }
                                    break;
                                case 1:
                                    heading = (buffer[i] - ASCII_ZERO) * 100;
                                    state = 2;
                                    break;
                                case 2:
                                    heading += (buffer[i] - ASCII_ZERO) * 10;
                                    state = 3;
                                    break;
                                case 3:
                                    heading += buffer[i] - ASCII_ZERO;
                                    state = 0;
                                    CompassPacket packet = new CompassPacket();
                                    packet.heading = fixHeading(heading);
                                    listener.processEvent(packet);
                                    break;
                                default:
                                    break;
                            }
                        }
                    //listener.processEvent(null);
                    } catch (IOException ex) {
                        Logger.getLogger(Compass.class.getName()).log(Level.SEVERE, "Could not read from InputStream", ex);
                    }
                }
            }
        });

        hasListener = true;
    }

    private double fixHeading(double heading) {
        double p = 5.231385274123706e-19 * Math.pow(heading, 9) - 6.218953948332928e-16 * Math.pow(heading, 8) + 2.322886145119141e-13 * Math.pow(heading, 7) - 6.794376144017877e-12 * Math.pow(heading, 6) - 1.481702814817513e-8 * Math.pow(heading, 5) + 3.144354611235679e-6 * Math.pow(heading, 4) - 0.0001603213940593420 * Math.pow(heading, 3) - 0.004294731463280004 * Math.pow(heading, 2) + 0.6910771218335755 * heading + 0.6827721997181959;
        p -= COMPASS_OFFSET;
        if (p < 0) p+= 360;
        return p;
    }

    /**
     * Stop reading from the serial port and close the port. Once this is called,
     * the port will not be able to be opened from this object again. Another instance of this class
     * will have to be instantiated.
     */
    public void stop() {
        port.close();
    }
}
