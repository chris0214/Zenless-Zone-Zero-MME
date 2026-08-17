using System.Globalization;
using System.Text.Json;

namespace EndfieldMaterialStudio.Core;

public sealed class OfficialMaterialDocument
{
    public string SourcePath { get; init; } = string.Empty;
    public string? ShaderName { get; init; }
    public Dictionary<string, OfficialTextureBinding> Textures { get; init; } = new(StringComparer.Ordinal);
    public Dictionary<string, double> Floats { get; init; } = new(StringComparer.Ordinal);
    public Dictionary<string, int> Ints { get; init; } = new(StringComparer.Ordinal);
    public Dictionary<string, ZzzColorValue> Colors { get; init; } = new(StringComparer.Ordinal);
    public Dictionary<string, string> RawProperties { get; init; } = new(StringComparer.Ordinal);
}

public static class OfficialMaterialJsonReader
{
    public static OfficialMaterialDocument Read(string path)
    {
        if (string.IsNullOrWhiteSpace(path)) throw new ArgumentException("官方材质 JSON 路径不能为空。", nameof(path));
        var fullPath = Path.GetFullPath(path);
        if (!File.Exists(fullPath)) throw new FileNotFoundException("找不到官方材质 JSON。", fullPath);

        using var document = JsonDocument.Parse(File.ReadAllText(fullPath), new JsonDocumentOptions
        {
            AllowTrailingCommas = true,
            CommentHandling = JsonCommentHandling.Skip
        });
        var root = document.RootElement;
        var result = new OfficialMaterialDocument
        {
            SourcePath = fullPath,
            ShaderName = ReadString(root, "m_Shader", "Name")
        };

        if (!TryGet(root, out var savedProperties, "m_SavedProperties") || savedProperties.ValueKind != JsonValueKind.Object)
            return result;

        ParseTextureEnvironments(savedProperties, result);
        ParseFloats(savedProperties, result);
        ParseInts(savedProperties, result);
        ParseColors(savedProperties, result);
        return result;
    }

    public static IReadOnlyList<string> FindCandidatePaths(string root, MaterialAssignment material)
    {
        if (!Directory.Exists(root)) return Array.Empty<string>();
        var wanted = new[] { material.MaterialName, material.EnglishName }
            .Where(value => !string.IsNullOrWhiteSpace(value))
            .Select(NormalizeName)
            .Where(value => value.Length > 0)
            .Distinct(StringComparer.Ordinal)
            .ToArray();
        if (wanted.Length == 0) return Array.Empty<string>();

        return Directory.EnumerateFiles(root, "*.json", SearchOption.AllDirectories)
            .Where(path => NormalizeName(Path.GetFileNameWithoutExtension(path)) is var name &&
                           wanted.Any(candidate => name == candidate))
            .OrderBy(path => path.Length)
            .ThenBy(path => path, StringComparer.OrdinalIgnoreCase)
            .ToArray();
    }

    private static void ParseTextureEnvironments(JsonElement saved, OfficialMaterialDocument result)
    {
        if (!TryGet(saved, out var texEnvs, "m_TexEnvs") || texEnvs.ValueKind != JsonValueKind.Object) return;
        foreach (var property in texEnvs.EnumerateObject())
        {
            if (property.Value.ValueKind != JsonValueKind.Object) continue;
            var texture = new OfficialTextureBinding { PropertyName = property.Name };
            if (TryGet(property.Value, out var textureData, "m_Texture"))
            {
                texture.IsNull = ReadBool(textureData, "IsNull") ?? false;
                var name = ReadString(textureData, "Name");
                texture.TextureName = texture.IsNull || string.IsNullOrWhiteSpace(name) ? null : name;
            }
            if (TryGet(property.Value, out var scale, "m_Scale"))
            {
                texture.ScaleX = ReadNumber(scale, "X") ?? 1.0;
                texture.ScaleY = ReadNumber(scale, "Y") ?? 1.0;
            }
            if (TryGet(property.Value, out var offset, "m_Offset"))
            {
                texture.OffsetX = ReadNumber(offset, "X") ?? 0.0;
                texture.OffsetY = ReadNumber(offset, "Y") ?? 0.0;
            }
            result.Textures[property.Name] = texture;
            result.RawProperties[property.Name] = property.Value.GetRawText();
        }
    }

    private static void ParseFloats(JsonElement saved, OfficialMaterialDocument result)
    {
        if (!TryGet(saved, out var values, "m_Floats") || values.ValueKind != JsonValueKind.Object) return;
        foreach (var property in values.EnumerateObject())
        {
            var value = ReadNumber(property.Value);
            if (value is null) continue;
            result.Floats[property.Name] = value.Value;
            result.RawProperties[property.Name] = property.Value.GetRawText();
        }
    }

    private static void ParseInts(JsonElement saved, OfficialMaterialDocument result)
    {
        if (!TryGet(saved, out var values, "m_Ints") || values.ValueKind != JsonValueKind.Object) return;
        foreach (var property in values.EnumerateObject())
        {
            var value = ReadNumber(property.Value);
            if (value is null) continue;
            result.Ints[property.Name] = Convert.ToInt32(Math.Round(value.Value, MidpointRounding.AwayFromZero));
            result.RawProperties[property.Name] = property.Value.GetRawText();
        }
    }

    private static void ParseColors(JsonElement saved, OfficialMaterialDocument result)
    {
        if (!TryGet(saved, out var values, "m_Colors") || values.ValueKind != JsonValueKind.Object) return;
        foreach (var property in values.EnumerateObject())
        {
            if (property.Value.ValueKind != JsonValueKind.Object) continue;
            var color = new ZzzColorValue
            {
                R = ReadNumber(property.Value, "r") ?? ReadNumber(property.Value, "R") ?? 1.0,
                G = ReadNumber(property.Value, "g") ?? ReadNumber(property.Value, "G") ?? 1.0,
                B = ReadNumber(property.Value, "b") ?? ReadNumber(property.Value, "B") ?? 1.0,
                A = ReadNumber(property.Value, "a") ?? ReadNumber(property.Value, "A") ?? 1.0
            };
            result.Colors[property.Name] = color;
            result.RawProperties[property.Name] = property.Value.GetRawText();
        }
    }

    private static bool TryGet(JsonElement element, out JsonElement value, string propertyName)
    {
        foreach (var property in element.EnumerateObject())
        {
            if (!property.Name.Equals(propertyName, StringComparison.OrdinalIgnoreCase)) continue;
            value = property.Value;
            return true;
        }
        value = default;
        return false;
    }

    private static string? ReadString(JsonElement element, params string[] path)
    {
        var current = element;
        foreach (var part in path)
        {
            if (!TryGet(current, out current, part)) return null;
        }
        return current.ValueKind == JsonValueKind.String ? current.GetString() : null;
    }

    private static bool? ReadBool(JsonElement element, string propertyName)
    {
        if (!TryGet(element, out var value, propertyName)) return null;
        return value.ValueKind switch
        {
            JsonValueKind.True => true,
            JsonValueKind.False => false,
            JsonValueKind.Number when value.TryGetInt32(out var number) => number != 0,
            _ => null
        };
    }

    private static double? ReadNumber(JsonElement element, string? propertyName = null)
    {
        if (propertyName is not null && !TryGet(element, out element, propertyName)) return null;
        if (element.ValueKind != JsonValueKind.Number) return null;
        return element.TryGetDouble(out var value) ? value :
            double.TryParse(element.GetRawText(), NumberStyles.Float, CultureInfo.InvariantCulture, out value) ? value : null;
    }

    private static string NormalizeName(string value)
    {
        var name = Path.GetFileNameWithoutExtension(value).Trim();
        if (name.StartsWith("MAT_", StringComparison.OrdinalIgnoreCase)) name = name[4..];
        if (name.EndsWith("_UI", StringComparison.OrdinalIgnoreCase)) name = name[..^3];
        return new string(name.Where(char.IsLetterOrDigit).Select(char.ToLowerInvariant).ToArray());
    }
}
