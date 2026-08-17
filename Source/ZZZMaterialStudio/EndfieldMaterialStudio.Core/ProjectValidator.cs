namespace EndfieldMaterialStudio.Core;

public static class ProjectValidator
{
    public static IReadOnlyList<ValidationMessage> Validate(StudioProject project)
    {
        var messages = new List<ValidationMessage>();
        messages.AddRange(RuntimeContract.Validate(project.RuntimeRoot, project.RuntimeKind));
        if (string.IsNullOrWhiteSpace(project.PmxPath) || !File.Exists(project.PmxPath))
            messages.Add(Error("PMX", "PMX 文件不存在。"));
        else
            messages.AddRange(ValidatePmxDependencies(project));
        if (string.IsNullOrWhiteSpace(project.OutputDirectory))
            messages.Add(Error("OUTPUT", "没有选择输出目录。"));
        ValidateControllers(project, messages);
        ValidateRuntimeRoles(project, messages);

        var duplicateIndices = project.Materials.GroupBy(material => material.MaterialIndex)
            .Where(group => group.Count() > 1)
            .Select(group => group.Key)
            .ToArray();
        foreach (var index in duplicateIndices)
            messages.Add(Error("DUPLICATE_BINDING", $"PMX 材质 #{index} 被重复绑定。"));

        if (project.EnableEyeThrough)
        {
            if (!project.Materials.Any(material => material.Role == MaterialRole.Iris))
                messages.Add(Error("EYE_IRIS", "眼透至少需要一个 Iris/眼睛材质。"));
            if (!project.Materials.Any(material => material.Role == MaterialRole.BrowLash))
                messages.Add(Error("EYE_BROW", "眼透至少需要一个 BrowLash/眉毛睫毛材质。"));
        }

        foreach (var material in project.Materials.Where(material => material.Enabled))
            ValidateMaterial(material, project.RuntimeKind, messages);
        return messages;
    }

    public static IReadOnlyList<ValidationMessage> ValidatePmxDependencies(StudioProject project)
    {
        var messages = new List<ValidationMessage>();
        if (string.IsNullOrWhiteSpace(project.PmxPath) || !File.Exists(project.PmxPath)) return messages;

        PmxModelInfo model;
        try
        {
            model = PmxReader.Read(project.PmxPath);
        }
        catch (Exception exception) when (exception is IOException or PmxFormatException or UnauthorizedAccessException)
        {
            messages.Add(Error("PMX_READ", $"PMX 无法读取：{exception.Message}"));
            return messages;
        }

        foreach (var dependency in PmxReader.ResolveTextureDependencies(model))
        {
            var resolution = dependency.Resolution;
            var kind = TextureKindName(dependency.Kind);
            if (resolution.UsedFallback)
            {
                messages.Add(Warning(
                    "PMX_TEXTURE_FALLBACK",
                    $"PMX 材质 #{dependency.MaterialIndex} {dependency.MaterialName} 的{kind}按声明路径不存在；已从 {resolution.FallbackDirectory} 精确找到同名文件：{resolution.DeclaredPath} -> {resolution.ResolvedPath}"));
            }
            else if (!resolution.Exists)
            {
                messages.Add(Error(
                    "PMX_TEXTURE_MISSING",
                    $"PMX 材质 #{dependency.MaterialIndex} {dependency.MaterialName} 的{kind}不存在：{resolution.DeclaredPath}"));
            }
        }
        return messages;
    }

    private static void ValidateMaterial(
        MaterialAssignment material,
        ShaderRuntimeKind runtimeKind,
        ICollection<ValidationMessage> messages)
    {
        foreach (var (slot, path) in RequiredTextures(material, runtimeKind))
        {
            if (string.IsNullOrWhiteSpace(path) || !File.Exists(path))
                messages.Add(Error("TEXTURE", $"材质 #{material.MaterialIndex} {material.MaterialName}（{material.Role}）缺少 {slot} 贴图。"));
        }
        ValidateMatCaps(material, messages);
    }

    private static void ValidateRuntimeRoles(StudioProject project, ICollection<ValidationMessage> messages)
    {
        if (project.RuntimeKind != ShaderRuntimeKind.ZzzMme) return;
        if (project.Materials.Any(material => material.Enabled) &&
            !RuntimeContract.HasZzzShadowRuntime(project.RuntimeRoot))
        {
            messages.Add(Error(
                "RUNTIME_ZZZ_SHADOW_REQUIRED",
                "正式 ZZZ 角色包需要完整 ZZZshadow 目录；当前运行时只有材质核心，不能生成会引用缺失附件的 EMM。"));
        }
        if (project.EnableEyeThrough && !RuntimeContract.HasZzzEyeThroughRuntime(project.RuntimeRoot))
        {
            messages.Add(Error(
                "RUNTIME_ZZZ_EYE_REQUIRED",
                "工程启用了眼透，但运行时缺少 ZZZEyeThrough.x / ZZZEyeThrough.fx。"));
        }
        var pending = project.Materials.Where(material => material.Enabled &&
                                                          !IsSupportedZzzRole(material.Role, project.RuntimeRoot))
            .Select(material => material.Role)
            .Distinct()
            .OrderBy(role => role)
            .ToArray();
        if (pending.Length > 0)
        {
            messages.Add(Error(
                "RUNTIME_ZZZ_ROLE_PENDING",
                $"正式 ZZZ 生成器已开放 Hair、Face、Skin、Eye01、Eye02 与 Cloth；以下类型仍未提取为通用模板：{string.Join("、", pending)}。"));
        }
    }

    private static bool IsSupportedZzzRole(MaterialRole role, string runtimeRoot) => role switch
    {
        MaterialRole.Cloth => RuntimeContract.HasZzzClothRuntime(runtimeRoot),
        MaterialRole.Hair => RuntimeContract.HasZzzHairRuntime(runtimeRoot),
        MaterialRole.Face => RuntimeContract.HasZzzFaceRuntime(runtimeRoot),
        MaterialRole.Skin => RuntimeContract.HasZzzSkinRuntime(runtimeRoot),
        MaterialRole.Iris or MaterialRole.EyeWhite or MaterialRole.EyeHighlight or
            MaterialRole.BrowLash or MaterialRole.EyeOverlay or MaterialRole.BrowOverlay => true,
        _ => false
    };

    private static void ValidateMatCaps(MaterialAssignment material, ICollection<ValidationMessage> messages)
    {
        var duplicateSlots = material.Zzz.MatCaps.GroupBy(binding => binding.Slot)
            .Where(group => group.Count() > 1)
            .Select(group => group.Key);
        foreach (var slot in duplicateSlots)
            messages.Add(Error("MATCAP_DUPLICATE_SLOT", $"材质 #{material.MaterialIndex} 的 MatCap 槽 {slot} 重复。"));

        foreach (var binding in material.Zzz.MatCaps.Where(binding => binding.Enabled))
        {
            if (binding.Slot is < 1 or > 5)
            {
                messages.Add(Error("MATCAP_SLOT", $"材质 #{material.MaterialIndex} 的 MatCap 槽号必须是 1..5：{binding.Slot}"));
                continue;
            }
            if (!new[] { "R", "G", "B", "A", "RGB", "RGBA" }.Contains(binding.MaskChannel, StringComparer.OrdinalIgnoreCase))
                messages.Add(Error("MATCAP_MASK", $"材质 #{material.MaterialIndex} 的 MatCap 槽 {binding.Slot} 遮罩通道无效：{binding.MaskChannel}"));
            if (double.IsNaN(binding.Intensity) || double.IsInfinity(binding.Intensity) || binding.Intensity < 0.0)
                messages.Add(Error("MATCAP_INTENSITY", $"材质 #{material.MaterialIndex} 的 MatCap 槽 {binding.Slot} 强度无效：{binding.Intensity}"));

            if (binding.Source == ZzzValueSource.Manual &&
                !string.IsNullOrWhiteSpace(binding.ManualTexturePath) &&
                !File.Exists(binding.ManualTexturePath))
            {
                messages.Add(Error("MATCAP_MANUAL_MISSING", $"材质 #{material.MaterialIndex} 的 MatCap 槽 {binding.Slot} 已设为手动，但贴图不存在。"));
            }
            else if (binding.Source == ZzzValueSource.OfficialJson &&
                     !string.IsNullOrWhiteSpace(binding.OfficialTextureName) &&
                     (string.IsNullOrWhiteSpace(binding.ResolvedTexturePath) || !File.Exists(binding.ResolvedTexturePath)))
            {
                messages.Add(Warning("MATCAP_JSON_UNRESOLVED", $"材质 #{material.MaterialIndex} 的 MatCap 槽 {binding.Slot} 保留了官方名称 {binding.OfficialTextureName}，但尚未解析到本地贴图。"));
            }
        }

        if (!string.IsNullOrWhiteSpace(material.Zzz.OfficialJsonPath) && !File.Exists(material.Zzz.OfficialJsonPath))
            messages.Add(Warning("OFFICIAL_JSON_MISSING", $"材质 #{material.MaterialIndex} 记录的官方 JSON 已不存在：{material.Zzz.OfficialJsonPath}"));

        if (material.Role == MaterialRole.Hair)
        {
            if (material.Zzz.HairHighlightSlot is < 1 or > 5)
                messages.Add(Error("HAIR_HIGHLIGHT_SLOT", $"材质 #{material.MaterialIndex} 的头发高光槽必须是 1..5。"));
            if (!double.IsFinite(material.Zzz.HairHighlightGain) || material.Zzz.HairHighlightGain < 0.0)
                messages.Add(Error("HAIR_HIGHLIGHT_GAIN", $"材质 #{material.MaterialIndex} 的头发高光强度无效。"));
            if (!double.IsFinite(material.Zzz.HairCenterPower) || material.Zzz.HairCenterPower <= 0.0)
                messages.Add(Error("HAIR_CENTER_POWER", $"材质 #{material.MaterialIndex} 的头发中央收窄参数无效。"));
        }
    }

    private static void ValidateControllers(StudioProject project, ICollection<ValidationMessage> messages)
    {
        var controllerMorphs = new Dictionary<string, HashSet<string>>(StringComparer.OrdinalIgnoreCase);
        var requestedFiles = project.ControllerFiles
            .Where(file => !string.IsNullOrWhiteSpace(file))
            .Select(Path.GetFileName)
            .Where(file => !string.IsNullOrWhiteSpace(file))
            .Select(file => file!)
            .Distinct(StringComparer.OrdinalIgnoreCase)
            .ToArray();

        foreach (var fileName in requestedFiles)
        {
            var path = ZzzControllerCatalog.ResolveControllerPath(project, fileName);
            if (path is null)
            {
                messages.Add(project.RuntimeKind == ShaderRuntimeKind.ZzzMme
                    ? Error("CONTROLLER_MISSING", $"正式 ZZZ 控制器文件不存在：{fileName}")
                    : Warning("CONTROLLER_MISSING", $"控制器文件不存在，将跳过：{fileName}"));
                continue;
            }
            try
            {
                controllerMorphs[fileName] = PmxReader.Read(path).Morphs
                    .Select(morph => morph.Name)
                    .ToHashSet(StringComparer.Ordinal);
            }
            catch (Exception exception) when (exception is IOException or PmxFormatException or UnauthorizedAccessException)
            {
                messages.Add(Warning("CONTROLLER_READ", $"控制器无法读取，将跳过：{fileName}（{exception.Message}）"));
            }
        }

        foreach (var duplicate in project.ControllerBindings
                     .Where(binding => !string.IsNullOrWhiteSpace(binding.ControllerFile) && !string.IsNullOrWhiteSpace(binding.MorphName))
                     .GroupBy(binding => $"{Path.GetFileName(binding.ControllerFile)}\u001f{binding.MorphName}", StringComparer.OrdinalIgnoreCase)
                     .Where(group => group.Count() > 1))
            messages.Add(Warning("CONTROLLER_BINDING_DUPLICATE", $"控制器表情映射重复：{duplicate.First().ControllerFile} / {duplicate.First().MorphName}"));

        foreach (var binding in project.ControllerBindings.Where(binding => binding.Enabled))
        {
            var fileName = Path.GetFileName(binding.ControllerFile);
            if (string.IsNullOrWhiteSpace(fileName) || string.IsNullOrWhiteSpace(binding.MorphName))
            {
                messages.Add(Warning("CONTROLLER_BINDING_INCOMPLETE", "存在未指定控制器文件或表情名的控制器映射。"));
                continue;
            }
            if (!double.IsFinite(binding.Min) || !double.IsFinite(binding.Max) || !double.IsFinite(binding.Default) ||
                binding.Min > binding.Max || binding.Default < binding.Min || binding.Default > binding.Max)
                messages.Add(Warning("CONTROLLER_RANGE", $"控制器范围无效：{fileName} / {binding.MorphName}"));
            if (controllerMorphs.TryGetValue(fileName, out var morphs) && !morphs.Contains(binding.MorphName))
                messages.Add(Warning("CONTROLLER_MORPH_MISSING", $"控制器中没有找到精确表情名：{fileName} / {binding.MorphName}"));
        }
    }

    public static IEnumerable<(string Slot, string? Path)> RequiredTextures(
        MaterialAssignment material,
        ShaderRuntimeKind runtimeKind = ShaderRuntimeKind.LegacyEndfield)
    {
        var textures = material.Textures;
        var basePath = material.UsePmxBaseTexture ? material.PmxBaseTexture : textures.Base;
        switch (material.Role)
        {
            case MaterialRole.Face:
                yield return ("Base", basePath);
                yield return (runtimeKind == ShaderRuntimeKind.ZzzMme ? "FaceLight/SDF" : "SDF", textures.Sdf);
                if (runtimeKind != ShaderRuntimeKind.ZzzMme)
                {
                    yield return ("ColorMask", textures.ColorMask);
                    yield return ("RD", textures.Rd);
                    yield return ("LUT", textures.Lut);
                    yield return ("ST", textures.St);
                }
                break;
            case MaterialRole.Hair:
                yield return ("Base", basePath);
                yield return ("Normal/HN", textures.Normal);
                yield return (runtimeKind == ShaderRuntimeKind.ZzzMme ? "Property/M" : "Property/P", textures.Property);
                if (runtimeKind == ShaderRuntimeKind.ZzzMme)
                {
                    yield return ("Attribute/A", textures.Rs);
                }
                else
                {
                    yield return ("RD", textures.Rd);
                    yield return ("RS", textures.Rs);
                    yield return ("ST", textures.St);
                    yield return ("HairLine", textures.HairLine);
                }
                break;
            case MaterialRole.Cloth:
                yield return ("Base", basePath);
                yield return ("Normal", textures.Normal);
                yield return (runtimeKind == ShaderRuntimeKind.ZzzMme ? "Property/M" : "Property/P", textures.Property);
                if (runtimeKind == ShaderRuntimeKind.ZzzMme)
                {
                    yield return ("Attribute/A", textures.Rs);
                }
                else
                {
                    yield return ("RD", textures.Rd);
                    yield return ("RS", textures.Rs);
                    yield return ("LUT", textures.Lut);
                }
                break;
            case MaterialRole.Skin:
                yield return ("Base", basePath);
                if (runtimeKind == ShaderRuntimeKind.ZzzMme)
                {
                    yield return ("Normal/N", textures.Normal);
                    yield return ("Property/M", textures.Property);
                    yield return ("Attribute/A", textures.Rs);
                }
                else
                {
                    yield return ("RD", textures.Rd);
                    yield return ("LUT", textures.Lut);
                }
                break;
            case MaterialRole.Iris:
            case MaterialRole.EyeHighlight:
            case MaterialRole.EyeWhite:
            case MaterialRole.BrowLash:
            case MaterialRole.Mouth:
            case MaterialRole.EyeOverlay:
            case MaterialRole.BrowOverlay:
                yield return ("Base", basePath);
                break;
        }
    }

    private static ValidationMessage Error(string code, string message) => new() { IsError = true, Code = code, Message = message };
    private static ValidationMessage Warning(string code, string message) => new() { IsError = false, Code = code, Message = message };

    private static string TextureKindName(PmxTextureKind kind) => kind switch
    {
        PmxTextureKind.Base => "基础贴图",
        PmxTextureKind.Sphere => "球面贴图",
        PmxTextureKind.Toon => "Toon 贴图",
        _ => "贴图"
    };
}
