/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package dnadecoder;

/**
 *
 * @author Sam
 */
public class Main {
    public static String str[]={"GGCGAATGGCGCTTTGCCTGGTTTCCGGCACCAGAAGCGGTGCCGGA",
     "AAGCTGGCTGGAGTGCGATCTTCCTGAGGCCGATACTGTCGTCGTCCC"};
    public static String aminoAcidLetters[]= {"G","C","A","T"};
    public static int counter = 0;
    /**
     * @param args the command line arguments
     * 
     */
    public static void main(String[] args) {
        // TODO code application logic here
        String toTest;
        for(int i=0;i<str.length;i++) {
            toTest=str[i];
            //tests for shifting
            System.out.println("--------BASIC TEST (INCL SHIFTING)------");
            testFrameShift(toTest);            
            
            //tests for single insertions
            System.out.println("--------NOW TESTING FOR SINGLE INSERTIONS------");
            for(int j=0;j<toTest.length();j++) {
                for(int k=0;k<aminoAcidLetters.length;k++) {
                    testFrameShift(toTest.substring(0, j)+aminoAcidLetters[k]+toTest.substring(j, toTest.length()));
                }
            }
             //tests for single deletions
            System.out.println("--------NOW TESTING FOR SINGLE DELETIONS------");
            for(int j=0;j<toTest.length();j++) {               
                    testFrameShift(toTest.substring(0, j)+toTest.substring(j+1, toTest.length()));
            }
        }
        System.out.println("counter:" + counter);
        //decodeString("GAGCTTGCGGCGGGCATGGCTTCAATGGGACGTGCTCTTATGGATGTCATGCTAGGCCTA");
    }
    public static void testFrameShift(String s) {
            decodeString(s);
            decodeString(s.substring(1,s.length()));
            decodeString(s.substring(2,s.length()));
            counter+=3;
    }
    public static String decodeString(String aminoAcidCode) {
        String codonString="";
        String decoded="";
        Codon codon;
        for(int i =0;i<= aminoAcidCode.length();i++) {
            if(i % 3 == 0) {
                codon = new Codon(codonString);
                decoded +=codon.getLetter();
                codonString = "";
                
                
            }
            if(i != aminoAcidCode.length())
                codonString+= aminoAcidCode.charAt(i);
        }
        //System.out.println("done decoding");
        //System.out.println(aminoAcidCode);
        System.out.println(decoded);
        return decoded;
    }

}
