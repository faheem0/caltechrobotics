/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package robomagellan;

import java.util.regex.Matcher;
import java.util.regex.Pattern;
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

    @Test
    public void testParse2(){
            String master = "$PASHR,UTM,233137.00,11S,396409.30,3778358.84,1,08,01.1,+207.80,M,-31.5,M,,*7E\r\n$PASHR,UTM,233138.00,11S,396409.24,3778358.88,1,08,01.1,+208.08,M,-31.5,M,,*77\r\n$PASHR,UTM,233139.00,11S,396409.17,3778358.91,1,09,00.9,+208.35,M,-31.5,M,,*78\r\n$PASHR,UTM,233140.00,11S,396409.13,3778358.88,1,08,01.1,+208.58,M,-31.5,M,,*79\r\n$PASHR,UTM,233141.00,11S,396409.09,3778358.84,1,08,01.1,+208.84,M,-31.5,M,,*7E\r\n$PASHR,UTM,233142.00,11S,396409.10,3778358.79,1,08,01.1,+209.07,M,-31.5,M,,*7D\r\n$PASHR,UTM,233143.00,11S,396409.09,3778358.75,1,08,01.1,+209.23,M,-31.5,M,,*7E\r\n$PASHR,UTM,233144.00,11S,396409.10,3778358.71,1,08,01.1,+209.41,M,-31.5,M,,*71\r\n$PASHR,UTM,233145.00,11S,396409.09,3778358.68,1,08,01.1,+209.55,M,-31.5,M,,*75\r\n$PASHR,UTM,233146.00,11S,396409.11,3778358.69,1,08,01.1,+209.66,M,-31.5,M,,*7E\r\n$PASHR,UTM,233147.00,11S,396409.13,3778358.68,1,08,01.1,+209.82,M,-31.5,M,,*76\r\n$PASHR,UTM,233148.00,11S,396409.14,3778358.66,1,08,01.1,+209.88,M,-31.5,M,,*7A\r\n";
            Pattern utm = Pattern.compile("^\\$PASHR,UTM");
            Matcher m;
            String str = "";
            String[] strs;
            for (int j = 0; j < master.length(); j=j+4){
                String read;
                if (j+4 < master.length())
                    read = master.substring(j, j+4);
                else read = master.substring(j, master.length());
                str += read;
                //System.out.println(read);
                //str = str.replaceAll("\r","");
                strs = str.split("\r\n", -2);
                //System.out.println(str);
                //System.out.println(strs[strs.length-1]);
                str = strs[strs.length-1];
                //System.out.println(str);
                //System.out.println(strs.length);
                //str = strs[strs.length - 1];
                //System.out.println(str);
                for (int i = 0; i < strs.length - 1; i++) {
                    //System.out.println(strs[i]);
                    m = utm.matcher(strs[i]);
                    if (m.find()) {
                        GPSPacket packet = AC12GPS.getPacket(strs[i]);
                        System.out.println(packet.utmEast + " " + packet.utmNorth);
                    }

                }
            }
                      

    }
    // TODO add test methods here.
    // The methods must be annotated with annotation @Test. For example:
    //
    /*@Test
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
    */
}