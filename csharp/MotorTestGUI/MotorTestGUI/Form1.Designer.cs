namespace MotorTestGUI
{
    partial class MotorTestGUI
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
            this.connect = new System.Windows.Forms.Button();
            this.label1 = new System.Windows.Forms.Label();
            this.log = new System.Windows.Forms.RichTextBox();
            this.move = new System.Windows.Forms.Button();
            this.turn = new System.Windows.Forms.Button();
            this.stop = new System.Windows.Forms.Button();
            this.left = new System.Windows.Forms.TextBox();
            this.angle = new System.Windows.Forms.TextBox();
            this.label2 = new System.Windows.Forms.Label();
            this.label3 = new System.Windows.Forms.Label();
            this.label4 = new System.Windows.Forms.Label();
            this.label5 = new System.Windows.Forms.Label();
            this.right = new System.Windows.Forms.TextBox();
            this.comports = new System.Windows.Forms.ComboBox();
            this.SuspendLayout();
            // 
            // connect
            // 
            this.connect.Location = new System.Drawing.Point(172, 7);
            this.connect.Name = "connect";
            this.connect.Size = new System.Drawing.Size(75, 23);
            this.connect.TabIndex = 0;
            this.connect.Text = "Connect";
            this.connect.UseVisualStyleBackColor = true;
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(12, 12);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(26, 13);
            this.label1.TabIndex = 2;
            this.label1.Text = "Port";
            // 
            // log
            // 
            this.log.Location = new System.Drawing.Point(3, 121);
            this.log.Name = "log";
            this.log.ReadOnly = true;
            this.log.Size = new System.Drawing.Size(244, 96);
            this.log.TabIndex = 3;
            this.log.Text = "";
            this.log.TextChanged += new System.EventHandler(this.log_TextChanged);
            // 
            // move
            // 
            this.move.Location = new System.Drawing.Point(172, 37);
            this.move.Name = "move";
            this.move.Size = new System.Drawing.Size(75, 23);
            this.move.TabIndex = 4;
            this.move.Text = "Move";
            this.move.UseVisualStyleBackColor = true;
            this.move.Click += new System.EventHandler(this.move_Click);
            // 
            // turn
            // 
            this.turn.Location = new System.Drawing.Point(172, 63);
            this.turn.Name = "turn";
            this.turn.Size = new System.Drawing.Size(75, 23);
            this.turn.TabIndex = 5;
            this.turn.Text = "Turn";
            this.turn.UseVisualStyleBackColor = true;
            this.turn.Click += new System.EventHandler(this.turn_Click);
            // 
            // stop
            // 
            this.stop.Location = new System.Drawing.Point(172, 92);
            this.stop.Name = "stop";
            this.stop.Size = new System.Drawing.Size(75, 23);
            this.stop.TabIndex = 6;
            this.stop.Text = "STOP";
            this.stop.UseVisualStyleBackColor = true;
            this.stop.Click += new System.EventHandler(this.stop_Click);
            // 
            // left
            // 
            this.left.Location = new System.Drawing.Point(66, 39);
            this.left.Name = "left";
            this.left.Size = new System.Drawing.Size(50, 20);
            this.left.TabIndex = 7;
            this.left.Text = "100";
            // 
            // angle
            // 
            this.angle.Location = new System.Drawing.Point(66, 65);
            this.angle.Name = "angle";
            this.angle.Size = new System.Drawing.Size(50, 20);
            this.angle.TabIndex = 9;
            this.angle.Text = "90";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(12, 42);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(38, 13);
            this.label2.TabIndex = 10;
            this.label2.Text = "Speed";
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(118, 68);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(47, 13);
            this.label3.TabIndex = 11;
            this.label3.Text = "Degrees";
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(21, 68);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(29, 13);
            this.label4.TabIndex = 12;
            this.label4.Text = "Turn";
            // 
            // label5
            // 
            this.label5.AutoSize = true;
            this.label5.Location = new System.Drawing.Point(12, 102);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(68, 13);
            this.label5.TabIndex = 13;
            this.label5.Text = "Receive Log";
            // 
            // right
            // 
            this.right.Location = new System.Drawing.Point(119, 39);
            this.right.Name = "right";
            this.right.Size = new System.Drawing.Size(50, 20);
            this.right.TabIndex = 14;
            this.right.Text = "100";
            // 
            // comports
            // 
            this.comports.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.comports.FormattingEnabled = true;
            this.comports.Location = new System.Drawing.Point(44, 9);
            this.comports.Name = "comports";
            this.comports.Size = new System.Drawing.Size(121, 21);
            this.comports.Sorted = true;
            this.comports.TabIndex = 15;
            // 
            // MotorTestGUI
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(256, 222);
            this.Controls.Add(this.comports);
            this.Controls.Add(this.right);
            this.Controls.Add(this.label5);
            this.Controls.Add(this.label4);
            this.Controls.Add(this.label3);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.angle);
            this.Controls.Add(this.left);
            this.Controls.Add(this.stop);
            this.Controls.Add(this.turn);
            this.Controls.Add(this.move);
            this.Controls.Add(this.log);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.connect);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
            this.Name = "MotorTestGUI";
            this.Text = "Motor Test GUI";
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Button connect;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.RichTextBox log;
        private System.Windows.Forms.Button move;
        private System.Windows.Forms.Button turn;
        private System.Windows.Forms.Button stop;
        private System.Windows.Forms.TextBox left;
        private System.Windows.Forms.TextBox angle;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.Label label5;
        private System.Windows.Forms.TextBox right;
        private System.Windows.Forms.ComboBox comports;
    }
}

