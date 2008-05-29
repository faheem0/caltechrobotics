namespace RoboMagellan.RoboMagellanGUI
{
    partial class MainForm
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
            this.components = new System.ComponentModel.Container();
            this.menuStrip1 = new System.Windows.Forms.MenuStrip();
            this.fileToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.importToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.calibrateCameraToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.quitToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.aboutToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.statusStrip1 = new System.Windows.Forms.StatusStrip();
            this.toolStripProgressBar1 = new System.Windows.Forms.ToolStripProgressBar();
            this.ConStatus = new System.Windows.Forms.ToolStripStatusLabel();
            this.WaypointQueue = new System.Windows.Forms.ListBox();
            this.gpsBox = new System.Windows.Forms.GroupBox();
            this.label4 = new System.Windows.Forms.Label();
            this.label3 = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.label1 = new System.Windows.Forms.Label();
            this.NorthText = new System.Windows.Forms.TextBox();
            this.EastText = new System.Windows.Forms.TextBox();
            this.TimeText = new System.Windows.Forms.TextBox();
            this.SatText = new System.Windows.Forms.TextBox();
            this.log = new System.Windows.Forms.RichTextBox();
            this.label5 = new System.Windows.Forms.Label();
            this.statusBox = new System.Windows.Forms.GroupBox();
            this.StatusText = new System.Windows.Forms.TextBox();
            this.label6 = new System.Windows.Forms.Label();
            this.TargetEast = new System.Windows.Forms.TextBox();
            this.label7 = new System.Windows.Forms.Label();
            this.timer1 = new System.Windows.Forms.Timer(this.components);
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.label8 = new System.Windows.Forms.Label();
            this.TargetNorth = new System.Windows.Forms.TextBox();
            this.groupBox2 = new System.Windows.Forms.GroupBox();
            this.UpTimeText = new System.Windows.Forms.Label();
            this.openFileDialog1 = new System.Windows.Forms.OpenFileDialog();
            this.camPic = new System.Windows.Forms.PictureBox();
            this.orgCam = new System.Windows.Forms.PictureBox();
            this.groupBox3 = new System.Windows.Forms.GroupBox();
            this.filterColor = new System.Windows.Forms.PictureBox();
            this.menuStrip1.SuspendLayout();
            this.statusStrip1.SuspendLayout();
            this.gpsBox.SuspendLayout();
            this.statusBox.SuspendLayout();
            this.groupBox1.SuspendLayout();
            this.groupBox2.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.camPic)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.orgCam)).BeginInit();
            this.groupBox3.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.filterColor)).BeginInit();
            this.SuspendLayout();
            // 
            // menuStrip1
            // 
            this.menuStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.fileToolStripMenuItem,
            this.aboutToolStripMenuItem});
            this.menuStrip1.Location = new System.Drawing.Point(0, 0);
            this.menuStrip1.Name = "menuStrip1";
            this.menuStrip1.Size = new System.Drawing.Size(810, 24);
            this.menuStrip1.TabIndex = 2;
            this.menuStrip1.Text = "menuStrip1";
            // 
            // fileToolStripMenuItem
            // 
            this.fileToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.importToolStripMenuItem,
            this.calibrateCameraToolStripMenuItem,
            this.quitToolStripMenuItem});
            this.fileToolStripMenuItem.Name = "fileToolStripMenuItem";
            this.fileToolStripMenuItem.Size = new System.Drawing.Size(35, 20);
            this.fileToolStripMenuItem.Text = "File";
            // 
            // importToolStripMenuItem
            // 
            this.importToolStripMenuItem.Name = "importToolStripMenuItem";
            this.importToolStripMenuItem.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.O)));
            this.importToolStripMenuItem.Size = new System.Drawing.Size(169, 22);
            this.importToolStripMenuItem.Text = "Import...";
            this.importToolStripMenuItem.Click += new System.EventHandler(this.importToolStripMenuItem_Click);
            // 
            // calibrateCameraToolStripMenuItem
            // 
            this.calibrateCameraToolStripMenuItem.Name = "calibrateCameraToolStripMenuItem";
            this.calibrateCameraToolStripMenuItem.Size = new System.Drawing.Size(169, 22);
            this.calibrateCameraToolStripMenuItem.Text = "Calibrate Camera";
            this.calibrateCameraToolStripMenuItem.Click += new System.EventHandler(this.calibrateCameraToolStripMenuItem_Click);
            // 
            // quitToolStripMenuItem
            // 
            this.quitToolStripMenuItem.Name = "quitToolStripMenuItem";
            this.quitToolStripMenuItem.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.Q)));
            this.quitToolStripMenuItem.Size = new System.Drawing.Size(169, 22);
            this.quitToolStripMenuItem.Text = "Quit";
            this.quitToolStripMenuItem.Click += new System.EventHandler(this.quitToolStripMenuItem_Click);
            // 
            // aboutToolStripMenuItem
            // 
            this.aboutToolStripMenuItem.Name = "aboutToolStripMenuItem";
            this.aboutToolStripMenuItem.Size = new System.Drawing.Size(48, 20);
            this.aboutToolStripMenuItem.Text = "About";
            // 
            // statusStrip1
            // 
            this.statusStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.toolStripProgressBar1,
            this.ConStatus});
            this.statusStrip1.Location = new System.Drawing.Point(0, 363);
            this.statusStrip1.Name = "statusStrip1";
            this.statusStrip1.Size = new System.Drawing.Size(810, 22);
            this.statusStrip1.TabIndex = 3;
            this.statusStrip1.Text = "statusStrip1";
            // 
            // toolStripProgressBar1
            // 
            this.toolStripProgressBar1.Name = "toolStripProgressBar1";
            this.toolStripProgressBar1.Size = new System.Drawing.Size(100, 16);
            // 
            // ConStatus
            // 
            this.ConStatus.Name = "ConStatus";
            this.ConStatus.Size = new System.Drawing.Size(71, 17);
            this.ConStatus.Text = "Disconnected";
            // 
            // WaypointQueue
            // 
            this.WaypointQueue.ColumnWidth = 100;
            this.WaypointQueue.FormattingEnabled = true;
            this.WaypointQueue.Location = new System.Drawing.Point(6, 19);
            this.WaypointQueue.MultiColumn = true;
            this.WaypointQueue.Name = "WaypointQueue";
            this.WaypointQueue.Size = new System.Drawing.Size(184, 160);
            this.WaypointQueue.TabIndex = 4;
            // 
            // gpsBox
            // 
            this.gpsBox.Controls.Add(this.label4);
            this.gpsBox.Controls.Add(this.label3);
            this.gpsBox.Controls.Add(this.label2);
            this.gpsBox.Controls.Add(this.label1);
            this.gpsBox.Controls.Add(this.NorthText);
            this.gpsBox.Controls.Add(this.EastText);
            this.gpsBox.Controls.Add(this.TimeText);
            this.gpsBox.Controls.Add(this.SatText);
            this.gpsBox.Location = new System.Drawing.Point(12, 27);
            this.gpsBox.Name = "gpsBox";
            this.gpsBox.Size = new System.Drawing.Size(337, 93);
            this.gpsBox.TabIndex = 6;
            this.gpsBox.TabStop = false;
            this.gpsBox.Text = "GPS Information";
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(169, 60);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(36, 13);
            this.label4.TabIndex = 10;
            this.label4.Text = "North:";
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(169, 26);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(31, 13);
            this.label3.TabIndex = 8;
            this.label3.Text = "East:";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(6, 60);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(61, 13);
            this.label2.TabIndex = 6;
            this.label2.Text = "Timestamp:";
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(6, 26);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(52, 13);
            this.label1.TabIndex = 4;
            this.label1.Text = "Satellites:";
            // 
            // NorthText
            // 
            this.NorthText.Location = new System.Drawing.Point(215, 57);
            this.NorthText.Name = "NorthText";
            this.NorthText.ReadOnly = true;
            this.NorthText.Size = new System.Drawing.Size(100, 20);
            this.NorthText.TabIndex = 3;
            // 
            // EastText
            // 
            this.EastText.Location = new System.Drawing.Point(215, 23);
            this.EastText.Name = "EastText";
            this.EastText.ReadOnly = true;
            this.EastText.Size = new System.Drawing.Size(100, 20);
            this.EastText.TabIndex = 2;
            // 
            // TimeText
            // 
            this.TimeText.Location = new System.Drawing.Point(73, 57);
            this.TimeText.Name = "TimeText";
            this.TimeText.ReadOnly = true;
            this.TimeText.Size = new System.Drawing.Size(74, 20);
            this.TimeText.TabIndex = 1;
            // 
            // SatText
            // 
            this.SatText.Location = new System.Drawing.Point(73, 23);
            this.SatText.Name = "SatText";
            this.SatText.ReadOnly = true;
            this.SatText.Size = new System.Drawing.Size(74, 20);
            this.SatText.TabIndex = 0;
            // 
            // log
            // 
            this.log.Location = new System.Drawing.Point(12, 260);
            this.log.Name = "log";
            this.log.ReadOnly = true;
            this.log.Size = new System.Drawing.Size(542, 96);
            this.log.TabIndex = 7;
            this.log.Text = "Console is broken for now.";
            // 
            // label5
            // 
            this.label5.AutoSize = true;
            this.label5.Location = new System.Drawing.Point(12, 241);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(48, 13);
            this.label5.TabIndex = 8;
            this.label5.Text = "Console:";
            // 
            // statusBox
            // 
            this.statusBox.Controls.Add(this.StatusText);
            this.statusBox.Controls.Add(this.label6);
            this.statusBox.Location = new System.Drawing.Point(12, 126);
            this.statusBox.Name = "statusBox";
            this.statusBox.Size = new System.Drawing.Size(168, 68);
            this.statusBox.TabIndex = 9;
            this.statusBox.TabStop = false;
            this.statusBox.Text = "Status";
            // 
            // StatusText
            // 
            this.StatusText.Location = new System.Drawing.Point(47, 25);
            this.StatusText.Name = "StatusText";
            this.StatusText.ReadOnly = true;
            this.StatusText.Size = new System.Drawing.Size(100, 20);
            this.StatusText.TabIndex = 1;
            // 
            // label6
            // 
            this.label6.AutoSize = true;
            this.label6.Location = new System.Drawing.Point(6, 28);
            this.label6.Name = "label6";
            this.label6.Size = new System.Drawing.Size(40, 13);
            this.label6.TabIndex = 0;
            this.label6.Text = "Status:";
            // 
            // TargetEast
            // 
            this.TargetEast.Location = new System.Drawing.Point(43, 25);
            this.TargetEast.Name = "TargetEast";
            this.TargetEast.ReadOnly = true;
            this.TargetEast.Size = new System.Drawing.Size(100, 20);
            this.TargetEast.TabIndex = 3;
            // 
            // label7
            // 
            this.label7.AutoSize = true;
            this.label7.Location = new System.Drawing.Point(6, 28);
            this.label7.Name = "label7";
            this.label7.Size = new System.Drawing.Size(31, 13);
            this.label7.TabIndex = 2;
            this.label7.Text = "East:";
            // 
            // timer1
            // 
            this.timer1.Interval = 1000;
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this.label8);
            this.groupBox1.Controls.Add(this.TargetNorth);
            this.groupBox1.Controls.Add(this.label7);
            this.groupBox1.Controls.Add(this.TargetEast);
            this.groupBox1.Location = new System.Drawing.Point(186, 126);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(163, 95);
            this.groupBox1.TabIndex = 11;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "Target";
            // 
            // label8
            // 
            this.label8.AutoSize = true;
            this.label8.Location = new System.Drawing.Point(6, 55);
            this.label8.Name = "label8";
            this.label8.Size = new System.Drawing.Size(36, 13);
            this.label8.TabIndex = 4;
            this.label8.Text = "North:";
            // 
            // TargetNorth
            // 
            this.TargetNorth.Location = new System.Drawing.Point(43, 51);
            this.TargetNorth.Name = "TargetNorth";
            this.TargetNorth.ReadOnly = true;
            this.TargetNorth.Size = new System.Drawing.Size(100, 20);
            this.TargetNorth.TabIndex = 5;
            // 
            // groupBox2
            // 
            this.groupBox2.Controls.Add(this.WaypointQueue);
            this.groupBox2.Location = new System.Drawing.Point(355, 27);
            this.groupBox2.Name = "groupBox2";
            this.groupBox2.Size = new System.Drawing.Size(199, 194);
            this.groupBox2.TabIndex = 12;
            this.groupBox2.TabStop = false;
            this.groupBox2.Text = "Waypoint Queue";
            // 
            // UpTimeText
            // 
            this.UpTimeText.AutoSize = true;
            this.UpTimeText.Location = new System.Drawing.Point(571, 369);
            this.UpTimeText.Name = "UpTimeText";
            this.UpTimeText.Size = new System.Drawing.Size(49, 13);
            this.UpTimeText.TabIndex = 13;
            this.UpTimeText.Text = "00:00:00";
            // 
            // openFileDialog1
            // 
            this.openFileDialog1.DefaultExt = "txt";
            this.openFileDialog1.FileName = "openFileDialog1";
            this.openFileDialog1.Filter = "Text Files (*.txt)|*.txt";
            this.openFileDialog1.FileOk += new System.ComponentModel.CancelEventHandler(this.openFileDialog1_FileOk);
            // 
            // camPic
            // 
            this.camPic.Location = new System.Drawing.Point(569, 36);
            this.camPic.Name = "camPic";
            this.camPic.Size = new System.Drawing.Size(174, 144);
            this.camPic.TabIndex = 14;
            this.camPic.TabStop = false;
            // 
            // orgCam
            // 
            this.orgCam.Location = new System.Drawing.Point(569, 198);
            this.orgCam.Name = "orgCam";
            this.orgCam.Size = new System.Drawing.Size(174, 144);
            this.orgCam.TabIndex = 15;
            this.orgCam.TabStop = false;
            // 
            // groupBox3
            // 
            this.groupBox3.Controls.Add(this.filterColor);
            this.groupBox3.Location = new System.Drawing.Point(749, 27);
            this.groupBox3.Name = "groupBox3";
            this.groupBox3.Size = new System.Drawing.Size(50, 64);
            this.groupBox3.TabIndex = 16;
            this.groupBox3.TabStop = false;
            this.groupBox3.Text = "Filter";
            // 
            // filterColor
            // 
            this.filterColor.Location = new System.Drawing.Point(7, 20);
            this.filterColor.Name = "filterColor";
            this.filterColor.Size = new System.Drawing.Size(36, 35);
            this.filterColor.TabIndex = 0;
            this.filterColor.TabStop = false;
            // 
            // MainForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(810, 385);
            this.Controls.Add(this.groupBox3);
            this.Controls.Add(this.orgCam);
            this.Controls.Add(this.camPic);
            this.Controls.Add(this.UpTimeText);
            this.Controls.Add(this.groupBox2);
            this.Controls.Add(this.groupBox1);
            this.Controls.Add(this.statusBox);
            this.Controls.Add(this.label5);
            this.Controls.Add(this.log);
            this.Controls.Add(this.gpsBox);
            this.Controls.Add(this.statusStrip1);
            this.Controls.Add(this.menuStrip1);
            this.MainMenuStrip = this.menuStrip1;
            this.Name = "MainForm";
            this.Text = "RoboMagellan";
            this.menuStrip1.ResumeLayout(false);
            this.menuStrip1.PerformLayout();
            this.statusStrip1.ResumeLayout(false);
            this.statusStrip1.PerformLayout();
            this.gpsBox.ResumeLayout(false);
            this.gpsBox.PerformLayout();
            this.statusBox.ResumeLayout(false);
            this.statusBox.PerformLayout();
            this.groupBox1.ResumeLayout(false);
            this.groupBox1.PerformLayout();
            this.groupBox2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.camPic)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.orgCam)).EndInit();
            this.groupBox3.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.filterColor)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.MenuStrip menuStrip1;
        private System.Windows.Forms.ToolStripMenuItem fileToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem quitToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem aboutToolStripMenuItem;
        private System.Windows.Forms.StatusStrip statusStrip1;
        private System.Windows.Forms.ToolStripProgressBar toolStripProgressBar1;
        private System.Windows.Forms.ToolStripStatusLabel ConStatus;
        private System.Windows.Forms.ListBox WaypointQueue;
        private System.Windows.Forms.GroupBox gpsBox;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.TextBox NorthText;
        private System.Windows.Forms.TextBox EastText;
        private System.Windows.Forms.TextBox TimeText;
        private System.Windows.Forms.TextBox SatText;
        private System.Windows.Forms.RichTextBox log;
        private System.Windows.Forms.Label label5;
        private System.Windows.Forms.GroupBox statusBox;
        private System.Windows.Forms.TextBox StatusText;
        private System.Windows.Forms.Label label6;
        private System.Windows.Forms.Timer timer1;
        private System.Windows.Forms.TextBox TargetEast;
        private System.Windows.Forms.Label label7;
        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.Label label8;
        private System.Windows.Forms.TextBox TargetNorth;
        private System.Windows.Forms.GroupBox groupBox2;
        private System.Windows.Forms.Label UpTimeText;
        private System.Windows.Forms.ToolStripMenuItem importToolStripMenuItem;
        private System.Windows.Forms.OpenFileDialog openFileDialog1;
        private System.Windows.Forms.PictureBox camPic;
        private System.Windows.Forms.PictureBox orgCam;
        private System.Windows.Forms.ToolStripMenuItem calibrateCameraToolStripMenuItem;
        private System.Windows.Forms.GroupBox groupBox3;
        private System.Windows.Forms.PictureBox filterColor;
    }
}

