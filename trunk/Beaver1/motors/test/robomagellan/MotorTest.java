/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package robomagellan;

import java.io.IOException;
import java.util.TooManyListenersException;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.junit.After;
import org.junit.AfterClass;
import org.junit.Assert;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import robomagellan.motors.EncoderDataListener;
import robomagellan.motors.EncoderPacket;
import robomagellan.motors.Motors;
import static org.junit.Assert.*;

/**
 *
 * @author robomagellan
 */
public class MotorTest {
    private Motors motors;
    private final String port = "/dev/ttyUSB0";

    public MotorTest() {
    }

    @BeforeClass
    public static void setUpClass() throws Exception {
    }

    @AfterClass
    public static void tearDownClass() throws Exception {
    }

    @Before
    public void setUp() {
        motors = new Motors(port);
        Assert.assertNotNull("Sucessfully Connected to "  + port, motors);
    }

    @After
    public void tearDown() {
        motors.stop();
    }

    // TODO add test methods here.
    // The methods must be annotated with annotation @Test. For example:
    //
    // @Test
    // public void hello() {}

    @Test
    public void testSetSpeed(){
        motors.setSpeed(Motors.LEFT, 8);
        motors.setSpeed(Motors.RIGHT, 9);
        try {
            Thread.sleep(10000);
        } catch (InterruptedException ex) {
            Logger.getLogger(MotorTest.class.getName()).log(Level.SEVERE, null, ex);
        }
        Assert.assertTrue(true);
    }

    @Test
    public void testEncoder(){
        try {
            motors.addEncoderDataListener(new EncoderDataListener() {

                public void processEvent(EncoderPacket p) {
                    System.out.println(p.velLeft + "\t" + p.velRight );
                }
            });
        } catch (TooManyListenersException ex) {
            Logger.getLogger(MotorTest.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

}