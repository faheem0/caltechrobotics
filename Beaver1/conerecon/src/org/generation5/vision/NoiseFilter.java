/*
 * NoiseFilter.java
 *
 * Created on 04 December 2004, 17:52
 */

package org.generation5.vision;

import java.awt.image.*;

/**
 * Implements simple black-and-white (impulse/salt and pepper) noise and Gaussian
 * noise.
 * @author James Matthews
 */
public class NoiseFilter extends Filter {
    
    /**
     * Create impulse noise.
     */    
    public final static int IMPULSE = 0;
    /**
     * Create Gaussian noise.
     */    
    public final static int GAUSSIAN = 1;
    
    /**
     * The noise type.
     */    
    protected int noiseType = IMPULSE;
    /**
     * The standard deviation used for gaussian noise (default = 10).
     */    
    protected double stdDev = 10.0;
    /**
     * The frequency of the impulse noise.
     */    
    protected double impulseRatio = 0.05;
    
    /** Creates a new instance of NoiseFilter */
    public NoiseFilter() {
    }
    
    /**
     * Create a new instance of NoiseFilter, specifying the noise type.
     * @param noiseType the noise type.
     */    
    public NoiseFilter(int noiseType) {
        setNoiseType(noiseType);
    }
    
    /**
     * Create a new instance of NoiseFilter, specifying the noise type and parameters.
     * @param noiseType the noise type.
     * @param parameter if impule noise, the frequency. If gaussian noise, the standard deviation.
     */    
    public NoiseFilter(int noiseType, double parameter) {
        setNoiseType(noiseType);
        
        if (noiseType == IMPULSE) setImpulseRatio(parameter);
        if (noiseType == GAUSSIAN) setGaussianStdDev(parameter);
    }
    
    /**
     * Set the noise type.
     * @param noiseType the new noise type.
     */    
    public void setNoiseType(int noiseType) {
        this.noiseType = noiseType;
    }
    
    /**
     * Get the noise type.
     * @return the current noise type.
     */    
    public int getNoiseType() {
        return noiseType;
    }
    
    /**
     * Set the gaussian standard deviation.
     * @param stdDev the new standard deviation.
     */    
    public void setGaussianStdDev(double stdDev) {
        this.stdDev = stdDev;
    }
    
    /**
     * Get the gaussian standard deviation.
     * @return the current standard deviation.
     */    
    public double getGaussianStdDev() {
        return stdDev;
    }
    
    /**
     * Set the impulse frequency.
     * @param impulseRatio the new impulse frequency.
     */    
    public void setImpulseRatio(double impulseRatio) {
        this.impulseRatio = impulseRatio;
    }
    
    /**
     * Get the impulse frequency.
     * @return the current impulse frequency.
     */    
    public double getImpulseRatio() {
        return impulseRatio;
    }
    
    /**
     * Simple test function.
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        if (args.length < 2) {
            System.err.println("usage: java NoiseFilter <input> <output> {type} {parameter}");
            return;
        }
        
        try {
            BufferedImage in = javax.imageio.ImageIO.read(new java.io.File(args[0]));
             
            NoiseFilter noise = new NoiseFilter();
            
            //
            // Retrieve any possible optional parameters
            //
            if (args.length > 2) {
                if (args[2].compareToIgnoreCase("impulse") == 0) noise.setNoiseType(noise.IMPULSE);
                if (args[2].compareToIgnoreCase("gaussian") == 0) noise.setNoiseType(noise.GAUSSIAN);
            }
            
            if (args.length > 3) {
                if (noise.getNoiseType() == noise.GAUSSIAN) 
                    noise.setGaussianStdDev(Double.parseDouble(args[3]));
                if (noise.getNoiseType() == noise.IMPULSE)
                    noise.setImpulseRatio(Double.parseDouble(args[3]));
            }
            
            // Do the filtering
            BufferedImage out = noise.filter(in);
            // Write the image (FIXME: currently always JPG...)
            javax.imageio.ImageIO.write(out, "jpg", new java.io.File(args[1]));
            
        } catch (java.io.IOException e) {
            System.err.println(e);
        }
    }
    
    /**
     * Apply noise to the input image.
     * @return the filtered, noisy image.
     * @param output the output image (optional).
     * @param image the input image.
     */    
    public java.awt.image.BufferedImage filter(BufferedImage image, BufferedImage output) {
        output = verifyOutput(output, image);
        
        switch (noiseType) {
            default:
            case IMPULSE: return impulseNoise(image, output);
            case GAUSSIAN: return gaussianNoise(image, output);
        }
    }
    
    /**
     * Add impulse noise to the image.
     * @return the noisy image.
     * @param output the output image.
     * @param image the input image.
     */    
    protected BufferedImage impulseNoise(BufferedImage image, BufferedImage output) {
        output.setData(image.getData());
        
        Raster source = image.getRaster();
        WritableRaster out = output.getRaster();
        
        double rand;
        double halfImpulseRatio = impulseRatio / 2.0;
        int bands  = out.getNumBands();
        int width  = image.getWidth();  // width of the image
        int height = image.getHeight(); // height of the image
        java.util.Random randGen = new java.util.Random();
        
        for (int j=0; j<height; j++) {
            for (int i=0; i<width; i++) {
                rand = randGen.nextDouble();
                if (rand < halfImpulseRatio) {
                    for (int b=0; b<bands; b++) out.setSample(i, j, b, 0);
                } else if (rand < impulseRatio) {
                    for (int b=0; b<bands; b++) out.setSample(i, j, b, 255);
                }
            }
        }
        
        return output;
    }
    
    /**
     * Add gaussian noise to the input image.
     * @return the noisy image.
     * @param output the output image.
     * @param image the input image.
     */    
    protected BufferedImage gaussianNoise(BufferedImage image, BufferedImage output) {
        Raster source = image.getRaster();
        WritableRaster out = output.getRaster();
        
        int currVal;                    // the current value
        double newVal;                  // the new "noisy" value
        double gaussian;                // gaussian number
        int bands  = out.getNumBands(); // number of bands
        int width  = image.getWidth();  // width of the image
        int height = image.getHeight(); // height of the image
        java.util.Random randGen = new java.util.Random();
        
        for (int j=0; j<height; j++) {
            for (int i=0; i<width; i++) {
                gaussian = randGen.nextGaussian();
                
                for (int b=0; b<bands; b++) {
                    newVal = stdDev * gaussian;                    
                    currVal = source.getSample(i, j, b);
                    newVal = newVal + currVal;
                    if (newVal < 0)   newVal = 0.0;
                    if (newVal > 255) newVal = 255.0;
                    
                    out.setSample(i, j, b, (int)(newVal));
                }
            }
        }
        
        return output;
    }
}
