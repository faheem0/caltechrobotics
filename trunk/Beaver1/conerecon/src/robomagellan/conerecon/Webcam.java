/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package robomagellan.conerecon;

import au.edu.jcu.v4l4j.FrameGrabber;
import au.edu.jcu.v4l4j.exceptions.StateException;
import au.edu.jcu.v4l4j.exceptions.V4L4JException;
import com.sun.image.codec.jpeg.JPEGCodec;
import com.sun.image.codec.jpeg.JPEGDecodeParam;
import com.sun.image.codec.jpeg.JPEGImageDecoder;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.imageio.ImageIO;
import sun.awt.image.ImageFormatException;

/**
 *
 * @author robomagellan
 */
public class Webcam {
    private FrameGrabber fg;
    private int initialQuality = 100;
    private ByteBuffer bb;
    private byte[] b;

    public Webcam(String dev) throws Exception{
        int w, h, std, ch;
        w = 320;
        h = 240;
        std = 0;
        ch =  0;
        fg = new FrameGrabber(dev, w, h, ch, std, initialQuality);
        fg.init();
        ImageIO.setUseCache(false);
    }
    public synchronized boolean startCapture(){
        try {
            fg.startCapture();
            return true;
        } catch (StateException ex) {
            Logger.getLogger(Webcam.class.getName()).log(Level.SEVERE, null, ex);
            return false;
        } catch (V4L4JException ex) {
            Logger.getLogger(Webcam.class.getName()).log(Level.SEVERE, null, ex);
            return false;
        }
    }
    public synchronized BufferedImage getFrame(){
        try {
            bb = fg.getFrame();
            b = new byte[bb.limit()];
            bb.get(b);

           // ByteArrayInputStream bais = new ByteArrayInputStream(b);
            return ImageIO.read(new ByteArrayInputStream(b));
        } catch (V4L4JException ex) {
            Logger.getLogger(Webcam.class.getName()).log(Level.SEVERE, null, ex);
        } catch (IOException ex) {
            Logger.getLogger(Webcam.class.getName()).log(Level.SEVERE, null, ex);
        }
        return null;
    }
}
