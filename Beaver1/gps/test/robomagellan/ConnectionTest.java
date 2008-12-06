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
import robomagellan.gps.AC12GPS;
import static org.junit.Assert.*;

/**
 *
 * @author robomagellan
 */
public class ConnectionTest {

    private AC12GPS gps;
    public ConnectionTest() {
    }

    @BeforeClass
    public static void setUpClass() throws Exception {
    }

    @AfterClass
    public static void tearDownClass() throws Exception {
    }

    @Before
    public void setUp() {
        gps = new AC12GPS("/dev/ttyUSB0");
    }

    @After
    public void tearDown() {
        gps.stop();
    }

    // TODO add test methods here.
    // The methods must be annotated with annotation @Test. For example:
    //
    @Test
    public void testCon() {
        try {
            gps.addGPSDataListener(null);
        } catch (TooManyListenersException ex) {
            Logger.getLogger(ConnectionTest.class.getName()).log(Level.SEVERE, null, ex);
            Assert.fail();
        }
        try {
            Thread.sleep(5000);
        } catch (InterruptedException ex) {
            Logger.getLogger(ConnectionTest.class.getName()).log(Level.SEVERE, null, ex);
        }
        Assert.assertTrue(true);
    }

}