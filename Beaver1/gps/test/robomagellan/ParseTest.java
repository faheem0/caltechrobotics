/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package robomagellan;

import junit.framework.Assert;
import org.junit.After;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import robomagellan.gps.AC12GPS;
import robomagellan.gps.GPSPacket;
import static org.junit.Assert.*;

/**
 *
 * @author robomagellan
 */
public class ParseTest {

    public ParseTest() {
    }

    @BeforeClass
    public static void setUpClass() throws Exception {
    }

    @AfterClass
    public static void tearDownClass() throws Exception {
    }

    @Before
    public void setUp() {
    }

    @After
    public void tearDown() {
    }

    // TODO add test methods here.
    // The methods must be annotated with annotation @Test. For example:
    //
    @Test
    public void testTime0() {
        Assert.assertEquals(0, AC12GPS.processTime(0), 0.000001);
    }

    @Test
    public void testTime1() {
        Assert.assertEquals(82800, AC12GPS.processTime(230000.00), 0.001);
    }

    @Test
    public void testTime2() {
        Assert.assertEquals(86340, AC12GPS.processTime(235900.00), 0.001);
    }

    @Test
    public void testTime3() {
        Assert.assertEquals(59.9, AC12GPS.processTime(000059.90), 0.001);
    }

    @Test
    public void testTime4() {
        Assert.assertEquals(86399.9, AC12GPS.processTime(235959.90), 0.001);
    }

    @Test
    public void testGetPacket0(){
        GPSPacket g = AC12GPS.getPacket("$PASHR,UTM,,,,,,,,,,,,*38");
        Assert.assertEquals(0, g.precision, 0.0001);
        Assert.assertEquals(0, g.time, 0.0001);
        Assert.assertEquals(0, g.utmEast, 0.00001);
        Assert.assertEquals(0, g.utmNorth, 0.00001);

    }
     @Test
    public void testGetPacket1(){
        GPSPacket g = AC12GPS.getPacket("$PASHR,UTM,235959.90,0,2.34,3.56,0,0,3.64,0,0,0,0,*38");
        Assert.assertEquals(3.64*3, g.precision, 0.0001);
        Assert.assertEquals(86399.9, g.time, 0.01);
        Assert.assertEquals(2.34, g.utmEast, 0.00001);
        Assert.assertEquals(3.56, g.utmNorth, 0.00001);

    }

}