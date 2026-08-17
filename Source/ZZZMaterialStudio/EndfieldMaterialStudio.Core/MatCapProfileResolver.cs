namespace EndfieldMaterialStudio.Core;

public sealed class TextureAssetIndex
{
    private readonly Dictionary<string, string> _exact = new(StringComparer.OrdinalIgnoreCase);
    private readonly HashSet<string> _ambiguous = new(StringComparer.OrdinalIgnoreCase);

    private TextureAssetIndex() { }

    public static TextureAssetIndex Build(IEnumerable<string> roots)
    {
        var index = new TextureAssetIndex();
        foreach (var root in roots.Where(Directory.Exists).Distinct(StringComparer.OrdinalIgnoreCase))
        {
            foreach (var file in Directory.EnumerateFiles(root, "*", SearchOption.AllDirectories)
                         .Where(IsTextureFile))
            {
                foreach (var key in KeysFor(file))
                {
                    if (index._exact.TryGetValue(key, out var existing) &&
                        !existing.Equals(file, StringComparison.OrdinalIgnoreCase))
                    {
                        index._ambiguous.Add(key);
                        continue;
                    }
                    index._exact[key] = file;
                }
            }
        }
        return index;
    }

    public bool TryResolve(string textureName, out string path)
    {
        path = string.Empty;
        if (string.IsNullOrWhiteSpace(textureName)) return false;
        var key = Normalize(textureName);
        if (key.Length == 0 || _ambiguous.Contains(key) || !_exact.TryGetValue(key, out path!))
        {
            path = string.Empty;
            return false;
        }
        return true;
    }

    private static IEnumerable<string> KeysFor(string path)
    {
        yield return Normalize(Path.GetFileName(path));
        yield return Normalize(Path.GetFileNameWithoutExtension(path));
    }

    private static bool IsTextureFile(string path) =>
        new[] { ".png", ".jpg", ".jpeg", ".bmp", ".tga", ".dds", ".exr", ".webp" }
            .Contains(Path.GetExtension(path), StringComparer.OrdinalIgnoreCase);

    private static string Normalize(string value) => value.Trim().Replace('\\', '/').ToLowerInvariant();
}

public sealed class OfficialMaterialApplyResult
{
    public OfficialMaterialDocument Document { get; init; } = new();
    public IReadOnlyList<ValidationMessage> Messages { get; init; } = Array.Empty<ValidationMessage>();
}

public static class MatCapProfileResolver
{
    public static OfficialMaterialApplyResult Apply(
        MaterialAssignment material,
        string jsonPath,
        IEnumerable<string>? textureRoots = null,
        bool overwriteManual = false)
    {
        var document = OfficialMaterialJsonReader.Read(jsonPath);
        material.Zzz ??= new ZzzMaterialProfile();
        var profile = material.Zzz;
        profile.OfficialJsonPath = document.SourcePath;
        profile.OfficialMaterialName = Path.GetFileNameWithoutExtension(document.SourcePath);
        profile.OfficialShaderName = document.ShaderName;
        profile.OfficialTextures = new Dictionary<string, string>(StringComparer.Ordinal);
        profile.OfficialTextureBindings = document.Textures.ToDictionary(
            pair => pair.Key,
            pair => pair.Value.Clone(),
            StringComparer.Ordinal);
        profile.OfficialFloats = new Dictionary<string, double>(document.Floats, StringComparer.Ordinal);
        profile.OfficialInts = new Dictionary<string, int>(document.Ints, StringComparer.Ordinal);
        profile.OfficialColors = document.Colors.ToDictionary(pair => pair.Key, pair => pair.Value.Clone(), StringComparer.Ordinal);
        profile.OfficialRawProperties = new Dictionary<string, string>(document.RawProperties, StringComparer.Ordinal);

        var roots = (textureRoots ?? Array.Empty<string>())
            .Where(path => !string.IsNullOrWhiteSpace(path))
            .Select(Path.GetFullPath)
            .Distinct(StringComparer.OrdinalIgnoreCase)
            .ToArray();
        var assets = TextureAssetIndex.Build(roots);
        var messages = new List<ValidationMessage>();

        foreach (var pair in document.Textures)
        {
            if (!string.IsNullOrWhiteSpace(pair.Value.TextureName))
                profile.OfficialTextures[pair.Key] = pair.Value.TextureName!;
            if (assets.TryResolve(pair.Value.TextureName ?? string.Empty, out var resolved))
            {
                pair.Value.ResolvedPath = resolved;
                profile.OfficialTextureBindings[pair.Key].ResolvedPath = resolved;
            }
        }

        for (var slot = 1; slot <= 5; slot++)
        {
            var propertyName = MatCapPropertyName(slot);
            var binding = profile.GetMatCap(slot);
            if (!document.Textures.TryGetValue(propertyName, out var official))
            {
                binding.OfficialProperty = propertyName;
                continue;
            }

            binding.OfficialProperty = propertyName;
            binding.OfficialTextureName = official.TextureName;

            var hasManual = !string.IsNullOrWhiteSpace(binding.ManualTexturePath);
            if (hasManual && profile.PreferManualMatCap && !overwriteManual)
            {
                binding.Source = ZzzValueSource.Manual;
                continue;
            }

            binding.ManualTexturePath = null;
            binding.ResolvedTexturePath = official.ResolvedPath;
            binding.Scale = official.ScaleX;
            binding.ScaleY = official.ScaleY;
            binding.OffsetX = official.OffsetX;
            binding.OffsetY = official.OffsetY;
            binding.MaskChannel = "B";
            binding.BlendMode = "Official";
            var colorProperty = slot == 1 ? "_MatCapColorTint" : $"_MatCapColorTint{slot}";
            if (document.Colors.TryGetValue(colorProperty, out var tint)) binding.Tint = tint.Clone();
            binding.Enabled = !official.IsNull && !string.IsNullOrWhiteSpace(official.TextureName);
            binding.Source = official.TextureName is null ? ZzzValueSource.Default : ZzzValueSource.OfficialJson;
            if (official.TextureName is not null && official.ResolvedPath is null)
            {
                messages.Add(new ValidationMessage
                {
                    Code = "OFFICIAL_MATCAP_NOT_FOUND",
                    Message = $"材质 #{material.MaterialIndex} 的 {propertyName} 指向 {official.TextureName}，但在指定贴图目录中没有找到同名文件。"
                });
            }
        }

        return new OfficialMaterialApplyResult { Document = document, Messages = messages };
    }

    public static string MatCapPropertyName(int slot) => slot switch
    {
        1 => "_MatCapTex",
        2 => "_MatCapTex2",
        3 => "_MatCapTex3",
        4 => "_MatCapTex4",
        5 => "_MatCapTex5",
        _ => throw new ArgumentOutOfRangeException(nameof(slot))
    };
}
