/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package robomagellan.helpers;

import gnu.io.CommPortIdentifier;
import gnu.io.SerialPort;
import gnu.io.UnsupportedCommOperationException;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * A convenience class for connecting to a serial port.
 * @author robomagellan
 */
public class SerialPortFactory {

    private static Enumeration portList;
    private static CommPortIdentifier commID;

    /**
     * Retrieves a list of the available serial ports
     * @return list of serial port names available
     */
    public static List<String> getPortList(){
        portList = CommPortIdentifier.getPortIdentifiers();
        List<String> list = new ArrayList<String>();
        while(portList.hasMoreElements()){
            list.add(((CommPortIdentifier)portList.nextElement()).getName());
        }
        return list;
    }
    /**
     * Opens a serial port for reading with the specified parameters.
     * @param portName the port name (ie. "COM1" or "/dev/ttyUSB0")
     * @param baud The baud rate to be used
     * @param data The number of data bits to be used. This should be a standard baud rate.
     * @param stop The number of stop bits to be used. This should be a standard stop bit number.
     * @param parity The number of parity bits to be used. This should be a standard parity bit number.
     * @return an open serial port, ready to be read from or sent data.
     */
    public static SerialPort openPort(String portName, int baud, int data, int stop, int parity) {
        SerialPort port = null;
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
        System.out.println("Attempting to Connect to SerialPort at" + portName);
        try {
            commID = CommPortIdentifier.getPortIdentifier(portName);
            port = (SerialPort) commID.open(portName, 2000);
            port.setSerialPortParams(baud, data, stop, parity);
            System.out.println("Baud Rate is: " + port.getBaudRate());
            System.out.println("Data Bits is: " + port.getDataBits());
            System.out.println("Stop Bits is: " + port.getStopBits());
            System.out.println("Parity Bits is: " + port.getParity());
        } catch (UnsupportedCommOperationException ex) {
            Logger.getLogger(SerialPortFactory.class.getName()).log(Level.SEVERE, "Could not Set a Serial Port Parameter for " + portName, ex);
        } catch (gnu.io.NoSuchPortException e1) {
            Logger.getLogger(SerialPortFactory.class.getName()).log(Level.SEVERE, "Port " + portName + " does not exist", e1);
        } catch (gnu.io.PortInUseException e2) {
             Logger.getLogger(SerialPortFactory.class.getName()).log(Level.SEVERE, "Port " + portName + " is already in use!", e2);
            //System.exit(3);
        }
        return port;
    }
}
