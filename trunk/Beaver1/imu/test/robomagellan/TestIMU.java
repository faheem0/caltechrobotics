/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package robomagellan;

import java.util.TooManyListenersException;
import java.util.logging.Level;
import java.util.logging.Logger;
import junit.framework.Assert;
import org.junit.After;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import robomagellan.imu.CristaIMU;
import robomagellan.imu.IMUDataListener;
import static org.junit.Assert.*;
import robomagellan.imu.IMUPacket;

/**
 *
 * @author robomagellan
 */
public class TestIMU {

    private CristaIMU imu;
    public TestIMU() {
    }

    @BeforeClass
    public static void setUpClass() throws Exception {
    }

    @AfterClass
    public static void tearDownClass() throws Exception {
    }

    @Before
    public void setUp() {
        imu = new CristaIMU("/dev/ttyUSB0");
    }

    @After
    public void tearDown() {
        imu.stop();
    }

    // TODO add test methods here.
    // The methods must be annotated with annotation @Test. For example:
    //
    @Test
    public void testGyro() {
        try {
            imu.addIMUDataListener(new IMUDataListener() {

                public void processEvent(IMUPacket p) {
                    System.out.println(p.gyroX + "\t" + p.gyroY + "\t" + p.gyroZ);
                }
            });
        } catch (TooManyListenersException ex) {
            Logger.getLogger(TestIMU.class.getName()).log(Level.SEVERE, null, ex);
            Assert.fail();
        }
        try {
            Thread.sleep(1000);
        } catch (InterruptedException ex) {
            Logger.getLogger(TestIMU.class.getName()).log(Level.SEVERE, null, ex);
            Assert.fail();
        }
        Assert.assertTrue(true);
    }

    @Test
    public void testAcc() {
        try {
            imu.addIMUDataListener(new IMUDataListener() {

                public void processEvent(IMUPacket p) {
                    System.out.println(p.accX + "\t" + p.accY + "\t" + p.accZ);
                }
            });
        } catch (TooManyListenersException ex) {
            Logger.getLogger(TestIMU.class.getName()).log(Level.SEVERE, null, ex);
            Assert.fail();
        }
        try {
            Thread.sleep(1000);
        } catch (InterruptedException ex) {
            Logger.getLogger(TestIMU.class.getName()).log(Level.SEVERE, null, ex);
            Assert.fail();
        }
        Assert.assertTrue(true);
    }
}