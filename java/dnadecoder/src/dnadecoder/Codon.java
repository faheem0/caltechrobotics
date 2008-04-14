/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package dnadecoder;


/**
 *
 * @author Sam
 *  NEED TO CHECK FOR CORRECT TABLES
 */
public class Codon {
    public String[] codonString = {
"ATT", "ATC", "ATA",
"CTT", "CTC", "CTA", "CTG", "TTA", "TTG",
"GTT", "GTC", "GTA", "GTG",
"TTT", "TTC",
"ATG",
"TGT", "TGC",
"GCT", "GCC", "GCA", "GCG",
"GGT", "GGC", "GGA", "GGG",
"CCT", "CCC", "CCA", "CCG",
"ACT", "ACC", "ACA", "ACG", 
"TCT", "TCC", "TCA", "TCG", "AGT", "AGC",
"TAT", "TAC",
"TGG",
"CAA", "CAG",
"AAT", "AAC",
"CAT", "CAC",
"GAA", "GAG",
"GAT", "GAC",
"AAA", "AAG",
"CGT", "CGC", "CGA", "CGG", "AGA", "AGG",
"TAA", "TAG", "TGA"       
    };
    public char[] codonLetter = {
'I','I','I',
'L','L','L','L','L','L',
'V','V','V','V',
'F','F',
'M',
'C','C',
'A','A','A','A',
'G','G','G','G',
'P','P','P','P',
'T','T','T','T',
'S','S','S','S','S','S',
'Y','Y',
'W',
'Q','Q',
'N','N',
'H','H',
'E','E',
'D','D',
'K','K',
'R','R','R','R','R','R',
'Z','Z','Z'
    };
    
    public String[] codonString2 = {
"TTT", "TTC", "TTA", "TTG",
"CTT", "CTC", "CTA", "CTG", 
"ATT", "ATC", "ATA", "ATG", 
"GTT", "GTC", "GTA", "GTG", 
 
"TCT", "TCC", "TCA", "TCG",
"CCT", "CCC", "CCA", "CCG",
"ACT", "ACC", "ACA", "ACG",
"GCT", "GCC", "GCA", "GCG",
 
"TAT", "TAC", "TAA", "TAG",
"CAT", "CAC", "CAA", "CAG", 
"AAT", "AAC", "AAA", "AAG", 
"GAT", "GAC", "GAA", "GAG", 
 
"TGT", "TGC", "TGA", "TGG", 
"CGT", "CGC", "CGA", "CGG", 
"AGT", "AGC", "AGA", "AGG", 
"GGT", "GGC", "GGA", "GGG"};              
    public char[] codonLetter2 = {
 'F', 'F','L','L',
 'L', 'L', 'L', 'L',
 'I', 'I', 'I', 'M',
 'V', 'V', 'V', 'V',
 
 'S', 'S', 'S', 'S',
 'P', 'P', 'P', 'P',
 'T', 'T', 'T', 'T',
 'A', 'A', 'A', 'A',
 
 'Y', 'Y', 'X', 'X',
 'H', 'H', 'G', 'G',
 'N', 'N', 'K', 'K',
 'D', 'D', 'E', 'E',
 
 'C', 'C', 'X', 'W',
 'R', 'R', 'R', 'R',
 'S', 'S', 'R', 'R',
 'G', 'G', 'G', 'G'
    };
    public String myCodon;
    public char myLetter=0;
    public  Codon(char a, char b, char c) {
        myCodon = ""+ a + b + c;
        findLetter();
    }
    public Codon(String s) {
        //System.out.println(s);
        myCodon = s;
        findLetter();
    }
    public void findLetter() {
        for(int i =0; i<codonString.length;i++) {
            if (codonString[i].equals(myCodon)) {
                 myLetter = codonLetter[i];
                 //System.out.println(codonLetter[i]);
        
            }
        }
        if(myLetter==0)
           myLetter='z';
    }
    public char getLetter() {
        return myLetter;
    }
}
