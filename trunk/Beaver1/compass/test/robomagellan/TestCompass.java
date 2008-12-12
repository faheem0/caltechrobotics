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
import robomagellan.compass.Compass;
import robomagellan.compass.CompassDataListener;
import robomagellan.compass.CompassPacket;
import static org.junit.Assert.*;

/**
 *
 * @author robomagellan
 */
public class TestCompass {

    private Compass compass;
    public TestCompass() {
    }

    @BeforeClass
    public static void setUpClass() throws Exception {
    }

    @AfterClass
    public static void tearDownClass() throws Exception {
    }

    @Before
    public void setUp() {
        compass = new Compass("/dev/ttyUSB0");
    }

    @After
    public void tearDown() {
        compass.stop();
    }

    // TODO add test methods here.
    // The methods must be annotated with annotation @Test. For example:
    //
    @Test
    public void testCompass() {
        try {
            compass.addCompassDataListener(new CompassDataListener() {

                public void processEvent(CompassPacket p) {
                    System.out.println(p.heading);
                }
            });
        } catch (TooManyListenersException ex) {
            Logger.getLogger(TestCompass.class.getName()).log(Level.SEVERE, null, ex);
            Assert.fail();
        }
        try {
            Thread.sleep(5000);
        } catch (InterruptedException ex) {
            Logger.getLogger(TestCompass.class.getName()).log(Level.SEVERE, null, ex);
            Assert.fail();
        }
        Assert.assertTrue(true);
    }

}