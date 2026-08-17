using System.IO;
using System.Text.Encodings.Web;
using System.Text.Json;
using System.Windows;
using EndfieldMaterialStudio.Core;

namespace EndfieldMaterialStudio.App;

public partial class App : System.Windows.Application
{
    protected override void OnStartup(StartupEventArgs e)
    {
        base.OnStartup(e);
        if (TryGetOption(e.Args, "--generate", out var projectPath))
        {
            ShutdownMode = ShutdownMode.OnExplicitShutdown;
            RunHeadlessGeneration(projectPath, TryGetOption(e.Args, "--result", out var resultPath)
                ? resultPath
                : null);
            return;
        }

        MainWindow = new MainWindow();
        MainWindow.Show();
    }

    private void RunHeadlessGeneration(string projectPath, string? resultPath)
    {
        var fullProjectPath = Path.GetFullPath(projectPath);
        var outputPath = string.IsNullOrWhiteSpace(resultPath)
            ? Path.Combine(
                Path.GetDirectoryName(fullProjectPath)!,
                Path.GetFileNameWithoutExtension(fullProjectPath) + ".generate-result.json")
            : Path.GetFullPath(resultPath);

        try
        {
            var project = ProjectFactory.Load(fullProjectPath);
            var validation = ProjectValidator.Validate(project);
            var errors = validation.Where(message => message.IsError).ToArray();
            if (errors.Length > 0)
                throw new InvalidDataException(string.Join(
                    Environment.NewLine,
                    errors.Select(message => message.ToString())));

            var result = new PackageBuilder().Build(project, overwrite: true);
            WriteResult(outputPath, new
            {
                Success = true,
                ProjectPath = fullProjectPath,
                result.OutputDirectory,
                result.EmmPath,
                result.ModelPath,
                result.MaterialMapPath,
                result.ControllerMapPath,
                GeneratedFileCount = result.GeneratedFiles.Count
            });
            Shutdown(0);
        }
        catch (Exception ex)
        {
            WriteResult(outputPath, new
            {
                Success = false,
                ProjectPath = fullProjectPath,
                Error = ex.ToString()
            });
            Shutdown(1);
        }
    }

    private static void WriteResult(string path, object result)
    {
        Directory.CreateDirectory(Path.GetDirectoryName(path)!);
        File.WriteAllText(path, JsonSerializer.Serialize(result, new JsonSerializerOptions
        {
            WriteIndented = true,
            Encoder = JavaScriptEncoder.UnsafeRelaxedJsonEscaping
        }));
    }

    private static bool TryGetOption(string[] args, string name, out string value)
    {
        for (var index = 0; index < args.Length - 1; index++)
        {
            if (!args[index].Equals(name, StringComparison.OrdinalIgnoreCase)) continue;
            value = args[index + 1];
            return !string.IsNullOrWhiteSpace(value);
        }
        value = string.Empty;
        return false;
    }
}
