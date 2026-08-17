using System.Text.Json;
using System.Text.Encodings.Web;

namespace EndfieldMaterialStudio.Core;

public static class ProjectFactory
{
    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        WriteIndented = true,
        PropertyNameCaseInsensitive = true,
        Encoder = JavaScriptEncoder.UnsafeRelaxedJsonEscaping
    };

    public static StudioProject Create(string pmxPath, string runtimeRoot, string outputDirectory)
    {
        var model = PmxReader.Read(pmxPath);
        var fullRuntimeRoot = Path.GetFullPath(runtimeRoot);
        var runtimeKind = RuntimeContract.Detect(fullRuntimeRoot);
        var project = new StudioProject
        {
            ProjectName = SanitizeProjectName(Path.GetFileNameWithoutExtension(pmxPath)),
            PmxPath = Path.GetFullPath(pmxPath),
            RuntimeRoot = fullRuntimeRoot,
            RuntimeKind = runtimeKind,
            OutputDirectory = Path.GetFullPath(outputDirectory),
            ControllerRoot = Path.Combine(fullRuntimeRoot, "controller"),
            ControllerFiles = ZzzControllerCatalog.CreateDefaultControllerFiles(runtimeKind),
            HeadBone = FindHeadBone(model)
        };
        project.ControllerBindings = ZzzControllerCatalog.CreateFromDirectory(
            project.ControllerRoot,
            project.ControllerFiles);

        foreach (var material in model.Materials)
        {
            var pmxBaseTexture = PmxReader.ResolveTexture(model.FilePath, material.TexturePath)?.ResolvedPath;
            project.Materials.Add(new MaterialAssignment
            {
                MaterialIndex = material.Index,
                MaterialName = material.Name,
                EnglishName = material.EnglishName,
                Role = MaterialClassifier.Suggest(material),
                PmxBaseTexture = pmxBaseTexture,
                Textures = new TextureSlots
                {
                    Base = pmxBaseTexture
                }
            });
        }

        return project;
    }

    public static void Save(StudioProject project, string path)
    {
        Directory.CreateDirectory(Path.GetDirectoryName(Path.GetFullPath(path))!);
        File.WriteAllText(path, JsonSerializer.Serialize(project, JsonOptions));
    }

    public static StudioProject Load(string path)
    {
        var project = JsonSerializer.Deserialize<StudioProject>(File.ReadAllText(path), JsonOptions)
            ?? throw new InvalidDataException("工程 JSON 无法解析。");
        Normalize(project);
        return project;
    }

    public static void Normalize(StudioProject project)
    {
        var previousSchemaVersion = project.SchemaVersion;
        project.Materials ??= new List<MaterialAssignment>();
        if (project.SchemaVersion < 6) project.SchemaVersion = 6;
        if (string.IsNullOrWhiteSpace(project.ShaderFamily)) project.ShaderFamily = "ZZZ";
        if (project.RuntimeKind == ShaderRuntimeKind.Auto && !string.IsNullOrWhiteSpace(project.RuntimeRoot))
            project.RuntimeKind = RuntimeContract.Detect(project.RuntimeRoot);
        if (string.IsNullOrWhiteSpace(project.ControllerRoot) && !string.IsNullOrWhiteSpace(project.RuntimeRoot))
            project.ControllerRoot = Path.Combine(project.RuntimeRoot, "controller");
        project.ControllerFiles ??= ZzzControllerCatalog.CreateDefaultControllerFiles(project.RuntimeKind);
        if (previousSchemaVersion < 6 && project.RuntimeKind == ShaderRuntimeKind.ZzzMme)
        {
            project.ControllerFiles = ZzzControllerCatalog.CreateDefaultControllerFiles(project.RuntimeKind);
            project.ControllerBindings = new List<ZzzControllerBinding>();
        }
        project.ControllerBindings ??= new List<ZzzControllerBinding>();
        ZzzControllerCatalog.MergeFromDirectory(project);
        foreach (var material in project.Materials)
        {
            material.Textures ??= new TextureSlots();
            material.Textures.MatCaps ??= new Dictionary<int, string?>();
            for (var slot = 1; slot <= 5; slot++) material.Textures.MatCaps.TryAdd(slot, null);
            material.Zzz ??= new ZzzMaterialProfile();
            material.Zzz.MatCaps ??= new List<MatCapSlotBinding>();
            for (var slot = 1; slot <= 5; slot++)
            {
                var binding = material.Zzz.GetMatCap(slot);
                if (previousSchemaVersion < 5)
                {
                    binding.MaskChannel = "B";
                    binding.ScaleY = binding.Scale;
                }
            }
            material.Zzz.PreferManualMatCap = project.PreferManualMatCap;
        }
        RefreshPmxBaseTextures(project);
    }

    public static void RefreshPmxBaseTextures(StudioProject project)
    {
        if (string.IsNullOrWhiteSpace(project.PmxPath) || !File.Exists(project.PmxPath)) return;

        var model = PmxReader.Read(project.PmxPath);
        var pmxMaterials = model.Materials.ToDictionary(material => material.Index);
        foreach (var material in project.Materials)
        {
            if (!pmxMaterials.TryGetValue(material.MaterialIndex, out var pmxMaterial)) continue;
            var resolved = PmxReader.ResolveTexture(model.FilePath, pmxMaterial.TexturePath)?.ResolvedPath;
            material.PmxBaseTexture = resolved;
            if (material.UsePmxBaseTexture) material.Textures.Base = resolved;
        }
    }

    private static string FindHeadBone(PmxModelInfo model)
    {
        foreach (var name in new[] { "頭", "头", "Head", "head" })
        {
            var found = model.BoneNames.FirstOrDefault(candidate => candidate.Equals(name, StringComparison.OrdinalIgnoreCase));
            if (!string.IsNullOrWhiteSpace(found)) return found;
        }
        return model.BoneNames.FirstOrDefault(candidate => candidate.Contains("頭") || candidate.Contains("头") || candidate.Contains("Head", StringComparison.OrdinalIgnoreCase)) ?? "頭";
    }

    public static string SanitizeProjectName(string name)
    {
        var invalid = Path.GetInvalidFileNameChars().ToHashSet();
        var value = new string(name.Select(character => invalid.Contains(character) ? '_' : character).ToArray()).Trim();
        return string.IsNullOrWhiteSpace(value) ? "ZZZCharacter" : value;
    }
}
