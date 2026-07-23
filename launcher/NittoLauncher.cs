using System;
using System.Diagnostics;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.IO;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Threading;
using System.Windows.Forms;

internal sealed class NittoLauncher : Form
{
    [DllImport("user32.dll", SetLastError = true)]
    private static extern bool SetWindowPos(IntPtr hwnd, IntPtr after, int x, int y, int cx, int cy, uint flags);

    private readonly Image hero;
    private readonly Button scale = new Button();
    private readonly double[] scaleValues = { 1.25, 1.50, 1.75, 2.00 };
    private int scaleIndex = 1;
    private readonly Label status = new Label();
    private readonly Button launch = new Button();
    private string gamePath;

    private NittoLauncher()
    {
        Text = "Open 1320 Legends";
        ClientSize = new Size(860, 560);
        FormBorderStyle = FormBorderStyle.FixedSingle;
        MaximizeBox = false;
        StartPosition = FormStartPosition.CenterScreen;
        BackColor = Color.FromArgb(7, 8, 10);
        Font = new Font("Segoe UI", 9F);
        DoubleBuffered = true;

        using (var stream = Assembly.GetExecutingAssembly().GetManifestResourceStream("launcher.hero.png"))
            hero = Image.FromStream(stream);

        gamePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "Open1320Legends", "NittoLegendsBeta.exe");

        var title = MakeLabel("OPEN 1320 LEGENDS", 22F, FontStyle.Bold, Color.White);
        title.Location = new Point(32, 382); title.AutoSize = true;
        var subtitle = MakeLabel("THE STREETS NEVER CLOSED", 10F, FontStyle.Bold, Color.FromArgb(187, 195, 205));
        subtitle.Location = new Point(35, 422); subtitle.AutoSize = true;

        var scaleLabel = MakeLabel("WINDOW SCALE", 9F, FontStyle.Bold, Color.FromArgb(187, 195, 205));
        scaleLabel.Location = new Point(402, 388); scaleLabel.AutoSize = true;
        scale.Text = "1.50×";
        scale.Location = new Point(405, 414); scale.Size = new Size(110, 31);
        scale.FlatStyle = FlatStyle.Flat;
        scale.FlatAppearance.BorderColor = Color.FromArgb(75, 82, 92);
        scale.BackColor = Color.FromArgb(19, 21, 25); scale.ForeColor = Color.White;
        scale.Cursor = Cursors.Hand;
        scale.Click += delegate { scaleIndex = (scaleIndex + 1) % scaleValues.Length; scale.Text = scaleValues[scaleIndex].ToString("0.00") + "×"; };

        launch.Text = "LAUNCH GAME";
        launch.Location = new Point(548, 388); launch.Size = new Size(278, 58);
        launch.FlatStyle = FlatStyle.Flat;
        launch.FlatAppearance.BorderSize = 1;
        launch.FlatAppearance.BorderColor = Color.FromArgb(235, 49, 55);
        launch.BackColor = Color.FromArgb(119, 12, 19);
        launch.ForeColor = Color.White;
        launch.Font = new Font("Segoe UI Semibold", 12F, FontStyle.Bold);
        launch.Cursor = Cursors.Hand;
        launch.Click += LaunchClicked;

        status.Location = new Point(35, 492); status.Size = new Size(790, 28);
        status.ForeColor = Color.FromArgb(165, 172, 182);
        status.Text = File.Exists(gamePath) ? "READY TO RACE" : "GAME CLIENT NOT FOUND";

        Controls.AddRange(new Control[] { title, subtitle, scaleLabel, scale, launch, status });
        Paint += PaintLauncher;
    }

    private static Label MakeLabel(string text, float size, FontStyle style, Color color)
    {
        return new Label { Text = text, Font = new Font("Segoe UI", size, style), ForeColor = color, BackColor = Color.Transparent };
    }

    private void PaintLauncher(object sender, PaintEventArgs e)
    {
        e.Graphics.InterpolationMode = InterpolationMode.HighQualityBicubic;
        e.Graphics.PixelOffsetMode = PixelOffsetMode.HighQuality;
        var heroBox = new Rectangle(0, 0, ClientSize.Width, 354);
        DrawCover(e.Graphics, hero, heroBox);
        using (var shade = new LinearGradientBrush(heroBox, Color.FromArgb(12, 0, 0, 0), Color.FromArgb(105, 0, 0, 0), LinearGradientMode.Vertical))
            e.Graphics.FillRectangle(shade, heroBox);
        using (var red = new SolidBrush(Color.FromArgb(205, 33, 39))) e.Graphics.FillRectangle(red, 0, 354, ClientSize.Width, 2);
        using (var panel = new SolidBrush(Color.FromArgb(238, 7, 8, 10))) e.Graphics.FillRectangle(panel, 0, 356, ClientSize.Width, 204);
        using (var line = new Pen(Color.FromArgb(46, 255, 255, 255))) e.Graphics.DrawLine(line, 32, 468, 828, 468);
    }

    private static void DrawCover(Graphics g, Image image, Rectangle box)
    {
        float s = Math.Max((float)box.Width / image.Width, (float)box.Height / image.Height);
        int w = (int)Math.Round(image.Width * s), h = (int)Math.Round(image.Height * s);
        var dest = new Rectangle(box.X + (box.Width - w) / 2, box.Y + (box.Height - h) / 2, w, h);
        g.DrawImage(image, dest);
    }

    private void LaunchClicked(object sender, EventArgs e)
    {
        if (!File.Exists(gamePath))
        {
            using (var dialog = new OpenFileDialog { Filter = "Nitto Legends|NittoLegendsBeta.exe", Title = "Locate the game client" })
                if (dialog.ShowDialog(this) == DialogResult.OK) gamePath = dialog.FileName; else return;
        }

        launch.Enabled = false;
        status.Text = "STARTING GAME…";
        Refresh();
        try
        {
            var process = Process.Start(new ProcessStartInfo(gamePath) { WorkingDirectory = Path.GetDirectoryName(gamePath) });
            double factor = scaleValues[scaleIndex];
            for (int i = 0; i < 120 && process.MainWindowHandle == IntPtr.Zero; i++) { Thread.Sleep(50); process.Refresh(); }
            if (process.MainWindowHandle != IntPtr.Zero)
            {
                int width = (int)Math.Round(800 * factor), height = (int)Math.Round(600 * factor) + 39;
                var area = Screen.FromHandle(process.MainWindowHandle).WorkingArea;
                int x = area.Left + Math.Max(0, (area.Width - width) / 2), y = area.Top + Math.Max(0, (area.Height - height) / 2);
                SetWindowPos(process.MainWindowHandle, IntPtr.Zero, x, y, width, height, 0x0004 | 0x0010);
            }
            Close();
        }
        catch (Exception ex)
        {
            status.Text = "COULD NOT START: " + ex.Message;
            launch.Enabled = true;
        }
    }

    [STAThread]
    private static void Main()
    {
        Application.EnableVisualStyles();
        Application.SetCompatibleTextRenderingDefault(false);
        Application.Run(new NittoLauncher());
    }
}
