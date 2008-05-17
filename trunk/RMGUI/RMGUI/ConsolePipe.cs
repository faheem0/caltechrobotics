using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using System.Windows.Forms;

namespace RMGUI
{
    internal sealed class ConsolePipe : TextWriter
    {
        private RichTextBox _textbox;

        internal ConsolePipe(RichTextBox tb)
        {
            _textbox = tb;
        }

        public override Encoding Encoding
        {
            get { return Encoding.Default; }
        }
        public override void Write(string value)
        {
            _textbox.AppendText(value.Replace("\n", base.NewLine));
        }
        public override void WriteLine(string value)
        {
            this.Write(value);
            _textbox.AppendText(base.NewLine);
        }
    }
}
