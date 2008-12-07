namespace GPSTestGUI
{
    partial class gpsform
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.portname = new System.Windows.Forms.TextBox();
            this.sat_text = new System.Windows.Forms.TextBox();
            this.time_text = new System.Windows.Forms.TextBox();
            this.north_text = new System.Windows.Forms.TextBox();
            this.connect = new System.Windows.Forms.Button();
            this.log = new System.Windows.Forms.RichTextBox();
            this.label1 = new System.Windows.Forms.Label();
            this.sat = new System.Windows.Forms.Label();
            this.time = new System.Windows.Forms.Label();
            this.north = new System.Windows.Forms.Label();
            this.east = new System.Windows.Forms.Label();
            this.east_text = new System.Windows.Forms.TextBox();
            this.menuStrip1 = new System.Windows.Forms.MenuStrip();
            this.fileToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.newToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.exitToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.saveFileDialog1 = new System.Windows.Forms.SaveFileDialog();
            this.menuStrip1.SuspendLayout();
            this.SuspendLayout();
            // 
            // portname
            // 
            this.portname.Location = new System.Drawing.Point(45, 27);
            this.portname.Name = "portname";
            this.portname.Size = new System.Drawing.Size(100, 20);
            this.portname.TabIndex = 0;
            // 
            // sat_text
            // 
            this.sat_text.Location = new System.Drawing.Point(71, 83);
            this.sat_text.Name = "sat_text";
            this.sat_text.ReadOnly = true;
            this.sat_text.Size = new System.Drawing.Size(65, 20);
            this.sat_text.TabIndex = 1;
            // 
            // time_text
            // 
            this.time_text.Location = new System.Drawing.Point(71, 109);
            this.time_text.Name = "time_text";
            this.time_text.ReadOnly = true;
            this.time_text.Size = new System.Drawing.Size(65, 20);
            this.time_text.TabIndex = 2;
            // 
            // north_text
            // 
            this.north_text.Location = new System.Drawing.Point(197, 83);
            this.north_text.Name = "north_text";
            this.north_text.ReadOnly = true;
            this.north_text.Size = new System.Drawing.Size(100, 20);
            this.north_text.TabIndex = 3;
            // 
            // connect
            // 
            this.connect.Location = new System.Drawing.Point(151, 25);
            this.connect.Name = "connect";
            this.connect.Size = new System.Drawing.Size(75, 23);
            this.connect.TabIndex = 4;
            this.connect.Text = "Connect";
            this.connect.UseVisualStyleBackColor = true;
            this.connect.Click += new System.EventHandler(this.connect_Click);
            // 
            // log
            // 
            this.log.Location = new System.Drawing.Point(12, 158);
            this.log.Name = "log";
            this.log.ReadOnly = true;
            this.log.Size = new System.Drawing.Size(285, 96);
            this.log.TabIndex = 7;
            this.log.Text = "";
            this.log.TextChanged += new System.EventHandler(this.log_TextChanged);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(10, 30);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(29, 13);
            this.label1.TabIndex = 8;
            this.label1.Text = "Port:";
            // 
            // sat
            // 
            this.sat.AutoSize = true;
            this.sat.Location = new System.Drawing.Point(4, 86);
            this.sat.Name = "sat";
            this.sat.Size = new System.Drawing.Size(49, 13);
            this.sat.TabIndex = 9;
            this.sat.Text = "Satellites";
            // 
            // time
            // 
            this.time.AutoSize = true;
            this.time.Location = new System.Drawing.Point(4, 112);
            this.time.Name = "time";
            this.time.Size = new System.Drawing.Size(58, 13);
            this.time.TabIndex = 10;
            this.time.Text = "Timestamp";
            // 
            // north
            // 
            this.north.AutoSize = true;
            this.north.Location = new System.Drawing.Point(158, 86);
            this.north.Name = "north";
            this.north.Size = new System.Drawing.Size(33, 13);
            this.north.TabIndex = 11;
            this.north.Text = "North";
            // 
            // east
            // 
            this.east.AutoSize = true;
            this.east.Location = new System.Drawing.Point(158, 112);
            this.east.Name = "east";
            this.east.Size = new System.Drawing.Size(28, 13);
            this.east.TabIndex = 12;
            this.east.Text = "East";
            // 
            // east_text
            // 
            this.east_text.Location = new System.Drawing.Point(197, 109);
            this.east_text.Name = "east_text";
            this.east_text.ReadOnly = true;
            this.east_text.Size = new System.Drawing.Size(100, 20);
            this.east_text.TabIndex = 13;
            // 
            // menuStrip1
            // 
            this.menuStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.fileToolStripMenuItem});
            this.menuStrip1.Location = new System.Drawing.Point(0, 0);
            this.menuStrip1.Name = "menuStrip1";
            this.menuStrip1.Size = new System.Drawing.Size(312, 24);
            this.menuStrip1.TabIndex = 14;
            this.menuStrip1.Text = "menuStrip1";
            // 
            // fileToolStripMenuItem
            // 
            this.fileToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.newToolStripMenuItem,
            this.exitToolStripMenuItem});
            this.fileToolStripMenuItem.Name = "fileToolStripMenuItem";
            this.fileToolStripMenuItem.Size = new System.Drawing.Size(35, 20);
            this.fileToolStripMenuItem.Text = "File";
            // 
            // newToolStripMenuItem
            // 
            this.newToolStripMenuItem.Name = "newToolStripMenuItem";
            this.newToolStripMenuItem.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.N)));
            this.newToolStripMenuItem.Size = new System.Drawing.Size(157, 22);
            this.newToolStripMenuItem.Text = "New...";
            this.newToolStripMenuItem.Click += new System.EventHandler(this.newToolStripMenuItem_Click);
            // 
            // exitToolStripMenuItem
            // 
            this.exitToolStripMenuItem.Name = "exitToolStripMenuItem";
            this.exitToolStripMenuItem.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.Q)));
            this.exitToolStripMenuItem.Size = new System.Drawing.Size(157, 22);
            this.exitToolStripMenuItem.Text = "Exit";
            this.exitToolStripMenuItem.Click += new System.EventHandler(this.exitToolStripMenuItem_Click);
            // 
            // saveFileDialog1
            // 
            this.saveFileDialog1.DefaultExt = "txt";
            this.saveFileDialog1.FileName = "gps_waypoints.txt";
            this.saveFileDialog1.Filter = "Text Files (*.txt)|*.txt";
            this.saveFileDialog1.FileOk += new System.ComponentModel.CancelEventHandler(this.saveFileDialog1_FileOk);
            // 
            // gpsform
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(312, 266);
            this.Controls.Add(this.east_text);
            this.Controls.Add(this.east);
            this.Controls.Add(this.north);
            this.Controls.Add(this.time);
            this.Controls.Add(this.sat);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.log);
            this.Controls.Add(this.connect);
            this.Controls.Add(this.north_text);
            this.Controls.Add(this.time_text);
            this.Controls.Add(this.sat_text);
            this.Controls.Add(this.portname);
            this.Controls.Add(this.menuStrip1);
            this.MainMenuStrip = this.menuStrip1;
            this.Name = "gpsform";
            this.Text = "GPS Test GUI";
            this.menuStrip1.ResumeLayout(false);
            this.menuStrip1.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.TextBox portname;
        private System.Windows.Forms.TextBox sat_text;
        private System.Windows.Forms.TextBox time_text;
        private System.Windows.Forms.TextBox north_text;
        private System.Windows.Forms.Button connect;
        private System.Windows.Forms.RichTextBox log;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label sat;
        private System.Windows.Forms.Label time;
        private System.Windows.Forms.Label north;
        private System.Windows.Forms.Label east;
        private System.Windows.Forms.TextBox east_text;
        private System.Windows.Forms.MenuStrip menuStrip1;
        private System.Windows.Forms.ToolStripMenuItem fileToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem newToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem exitToolStripMenuItem;
        private System.Windows.Forms.SaveFileDialog saveFileDialog1;
    }
}

