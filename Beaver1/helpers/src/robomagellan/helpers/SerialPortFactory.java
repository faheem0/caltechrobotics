/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package robomagellan.helpers;

import gnu.io.CommPortIdentifier;
import gnu.io.SerialPort;
import gnu.io.UnsupportedCommOperationException;
import java.util.Enumeration;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author robomagellan
 */
public class SerialPortFactory {

    private static Enumeration portList;
    private static CommPortIdentifier commID;

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
            Logger.getLogger(SerialPortFactory.class.getName()).log(Level.SEVERE, null, ex);
        } catch (gnu.io.NoSuchPortException e1) {
            //System.exit(2);
        } catch (gnu.io.PortInUseException e2) {
            System.err.println("Port Already in Use!");
            //System.exit(3);
        }
        return port;
    }
}
