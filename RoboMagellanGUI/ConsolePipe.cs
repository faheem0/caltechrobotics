using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using System.Windows.Forms;

namespace RoboMagellan.RoboMagellanGUI
{
    internal sealed class ConsolePipe : TextWriter
    {
        private TextWriter tw;

        internal ConsolePipe()
        {
            //_textbox = tb;
            tw = new StreamWriter("C:\\Documents and Settings\\tonyfwu\\Desktop\\log.txt");
        }

        public override Encoding Encoding
        {
            get { return Encoding.Default; }
        }
        public override void Write(string value)
        {
            tw.Write(value.Replace("\n", base.NewLine));
        }
        public override void WriteLine(string value)
        {
            tw.WriteLine(value.Replace("\n", base.NewLine));
        }
        
    }
}
