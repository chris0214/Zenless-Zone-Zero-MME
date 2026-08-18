using System.IO;

namespace ZzzMaterialStudio.App.Infrastructure;

public static class AppDiagnostics
{
    private static readonly object SyncRoot = new();

    public static string LogDirectory { get; } = Path.Combine(
        Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
        "ZZZMaterialStudio",
        "Logs");

    public static string CurrentLogPath { get; } = Path.Combine(
        LogDirectory,
        $"ZZZMaterialStudio-{DateTime.Now:yyyyMMdd}.log");

    public static void Write(string context, Exception exception)
    {
        try
        {
            lock (SyncRoot)
            {
                Directory.CreateDirectory(LogDirectory);
                File.AppendAllText(
                    CurrentLogPath,
                    $"[{DateTime.Now:yyyy-MM-dd HH:mm:ss}] {context}{Environment.NewLine}{exception}{Environment.NewLine}{Environment.NewLine}");
            }
        }
        catch
        {
            // Diagnostics must never become a second application failure.
        }
    }
}
