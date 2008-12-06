/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package robomagellan;

import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.junit.After;
import org.junit.AfterClass;
import org.junit.Assert;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
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
        try {
            motors = new Motors(port);
        } catch (IOException ex) {
            Assert.fail("Failed Attempt to connect to motors (IOException)");
        }
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
        motors.setSpeed(0, 0, 8);
        try {
            Thread.sleep(1000);
        } catch (InterruptedException ex) {
            Logger.getLogger(MotorTest.class.getName()).log(Level.SEVERE, null, ex);
        }
        Assert.assertTrue(true);
    }

}