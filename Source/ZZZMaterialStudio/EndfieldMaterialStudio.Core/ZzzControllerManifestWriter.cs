using System.Text;
using System.Text.Encodings.Web;
using System.Text.Json;

namespace EndfieldMaterialStudio.Core;

public static class ZzzControllerManifestWriter
{
    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        WriteIndented = true,
        Encoder = JavaScriptEncoder.UnsafeRelaxedJsonEscaping
    };

    public static byte[] Build(StudioProject project)
    {
        var document = new ZzzControllerManifest
        {
            ProjectName = project.ProjectName,
            ControllerFiles = project.ControllerFiles
                .Where(file => !string.IsNullOrWhiteSpace(file))
                .Select(Path.GetFileName)
                .Where(file => !string.IsNullOrWhiteSpace(file))
                .Select(file => file!)
                .Distinct(StringComparer.OrdinalIgnoreCase)
                .ToList(),
            Bindings = project.ControllerBindings
                .OrderBy(binding => binding.ControllerFile, StringComparer.OrdinalIgnoreCase)
                .ThenBy(binding => binding.Group, StringComparer.Ordinal)
                .ThenBy(binding => binding.MorphName, StringComparer.Ordinal)
                .Select(binding => binding.Clone())
                .ToList()
        };
        return new UTF8Encoding(false).GetBytes(JsonSerializer.Serialize(document, JsonOptions) + Environment.NewLine);
    }
}

public sealed class ZzzControllerManifest
{
    public int SchemaVersion { get; init; } = 1;
    public string Format { get; init; } = "ZZZMaterialStudio.ControllerMap";
    public string ProjectName { get; init; } = string.Empty;
    public List<string> ControllerFiles { get; init; } = new();
    public List<ZzzControllerBinding> Bindings { get; init; } = new();
}
