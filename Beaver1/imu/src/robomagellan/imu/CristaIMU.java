/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package robomagellan.imu;

import gnu.io.SerialPort;
import gnu.io.SerialPortEvent;
import gnu.io.SerialPortEventListener;
import java.io.IOException;
import java.io.InputStream;
import java.util.TooManyListenersException;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.regex.Matcher;
import robomagellan.helpers.SerialPortFactory;

/**
 *
 * @author robomagellan
 */
public class CristaIMU {
    public static final int BAUD_RATE = 115200;
    public static final int DATA_BITS = SerialPort.DATABITS_8;
    public static final int PARITY = SerialPort.PARITY_NONE;
    public static final int STOP_BITS = SerialPort.STOPBITS_1;

    private SerialPort port;
    private boolean hasListener, stop;
    private IMUDataListener listener;
    private InputStream in;
    private Thread helper;
    private static final int BUFFER_SIZE = 128;
    private static final double CONV_GYRO_RESOLUTION = 109.22666666667;
    private static final double CONV_ACC_RESOLUTION = 334.1968383478;
    private static final byte SYNC_SER_0 = (byte) 0x55;
    private static final byte SYNC_SER_1 = (byte) 0xAA;
    private static final byte HS_SERIAL_IMU_MSG = (byte) 0xFF;


    public CristaIMU(String dev){
        hasListener = false;
        stop = false;
        port = SerialPortFactory.openPort(dev, BAUD_RATE, DATA_BITS, STOP_BITS, PARITY);
        try {
            in = port.getInputStream();
        } catch (IOException ex) {
            Logger.getLogger(CristaIMU.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
    public synchronized void addIMUDataListener(IMUDataListener m) throws TooManyListenersException{
        if(hasListener) throw new TooManyListenersException("There's already a listener on " + port.getName());
        listener = m;

        Runnable runnable = new Runnable(){
            byte[] buf = new byte[1];
            byte[] data = new byte[18];
            int state = 0;
            int index = 0;

            public void run() {
                while(!stop){
                    try {
                        while (in.available() != 0) {
                            in.read(buf);
                            if (stop) break;
                            /*if (buf[0] < 0) {
                                break;
                            }*/

                            switch (state){
                                case 0:
                                    if (buf[0] == SYNC_SER_0){
                                        state++;
                                        data[index++] = buf[0];
                                    }
                                    break;
                                case 1:
                                    if (buf[0] == SYNC_SER_1){
                                        state++;
                                        data[index++] = buf[0];
                                    } else state = 0;
                                    break;
                                case 2:
                                    data[index++] = buf[0];
                                    state++;
                                    if(buf[0] != HS_SERIAL_IMU_MSG){
                                        state = 0;
                                    }
                                    break;
                                case 3:
                                    data[index++] = buf[0];
                                    state++;
                                    break;
                                case 4: //X Gyro MSB
                                    data[index++] = buf[0];
                                    state++;
                                    break;
                                case 5: //X Gyro LSB
                                    data[index++] = buf[0];
                                    state++;
                                    break;
                                case 6: //Y Gyro MSB
                                    data[index++] = buf[0];
                                    state++;
                                    break;
                                case 7: //Y Gyro LSB
                                    data[index++] = buf[0];
                                    state++;
                                    break;
                                case 8: //Z Gyro MSB
                                    data[index++] = buf[0];
                                    state++;
                                    break;
                                case 9: //Z Gyro LSB
                                    data[index++] = buf[0];
                                    state++;
                                    break;
                                case 10: //X Acc MSB
                                    data[index++] = buf[0];
                                    state++;
                                    break;
                                case 11: //X Acc LSB
                                    data[index++] = buf[0];
                                    state++;
                                    break;
                                case 12: //Y Acc MSB
                                    data[index++] = buf[0];
                                    state++;
                                    break;
                                case 13: //Y Acc LSB
                                    data[index++] = buf[0];
                                    state++;
                                    break;
                                case 14: //Z Acc MSB
                                    data[index++] = buf[0];
                                    state++;
                                    break;
                                case 15: //Z Acc LSB
                                    data[index++] = buf[0];
                                    state = 0;
                                    index = 0;

                                    IMUPacket packet = new IMUPacket();
                                    packet.gyroX = (((int)data[4] << 8) | (int)data[5])/CONV_GYRO_RESOLUTION;
                                    packet.gyroY = (((int)data[6] << 8) | (int)data[7])/CONV_GYRO_RESOLUTION;
                                    packet.gyroZ = (((int)data[8] << 8) | (int)data[9])/CONV_GYRO_RESOLUTION;
                                    packet.accX = (((int)data[10] << 8) | (int)data[11])/CONV_ACC_RESOLUTION;
                                    packet.accY = (((int)data[12] << 8) | (int)data[13])/CONV_ACC_RESOLUTION;
                                    packet.accZ = (((int)data[14] << 8) | (int)data[15])/CONV_ACC_RESOLUTION;

                                    listener.processEvent(packet);
                                    break;
                                default:
                                    state = 0;
                                    break;
                            }
                        }
                    } catch (IOException ex) {
                        Logger.getLogger(CristaIMU.class.getName()).log(Level.SEVERE, null, ex);
                    }
                }
            }
        };
        helper = new Thread(runnable);
        helper.start();

        hasListener = true;
    }

    public void stop(){
        stop = true;
        try {
            if (helper != null)
                helper.join();
        } catch (InterruptedException ex) {
            Logger.getLogger(CristaIMU.class.getName()).log(Level.SEVERE, null, ex);
        }
        port.close();
    }
}
