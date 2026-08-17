namespace EndfieldMaterialStudio.Core;

public static class RuntimeContract
{
    private static readonly string[] LegacyFixedTextureNames =
    {
        "Eff_MatCap_019.png",
        "Eff_MatCap_019_manual_lod.png",
        "PreIntegratedFGD_GGXDisneyDiffuse.png",
        "T_actor_common_face_01_hl_M.png",
        "T_actor_common_matcap_05_D.png",
        "T_actor_common_matcap_07_D.png",
        "T_actor_common_cloth_lut_01_D.png",
        "cloth_environment_current.dds",
        Path.Combine("rain", "T_actor_common_rain_02_M.png"),
        Path.Combine("rain", "rain_drops.png"),
        Path.Combine("rain", "rain_drops_phase.png")
    };

    private static readonly string[] LegacyRequiredTopLevelFiles =
    {
        "EndfieldHairVisibility_Capture.fxsub",
        "EndfieldEyeThrough_Capture.fxsub",
        "EndfieldEyeThrough_Mask.fxsub",
        "EndfieldEyeThrough.fx",
        "EndfieldEyeThrough.x",
        "EndfieldPost.fx",
        "EndfieldPost.x",
        "ZMDshadow.x",
        "ZMDshadow.fx",
        "ZMDshadow_ShadowMap.fxsub",
        "ZMDshadow_ViewportMap.fxsub",
        "HgShadow_CFSUSM.fxh",
        "HgShadow_CLSPSM.fxh",
        "HgShadow_Header.fxh",
        "JitteredSamp.png"
    };

    private static readonly string[] ZzzRequiredCoreFiles =
    {
        Path.Combine("internal", "zzz_cloth_runtime.hlsl"),
        Path.Combine("internal", "zzz_cloth_matcap_controls.inc"),
        Path.Combine("internal", "zzz_common.hlsl"),
        Path.Combine("internal", "zzz_decode.hlsl"),
        Path.Combine("internal", "zzz_eye_controls.inc"),
        Path.Combine("internal", "zzz_eye_through_capture_core.fxsub"),
        Path.Combine("internal", "zzz_eye_through_contract.hlsl"),
        Path.Combine("internal", "zzz_face_skin_controls.inc"),
        Path.Combine("internal", "zzz_hair_controls.inc"),
        Path.Combine("internal", "zzz_hair_highlight.hlsl"),
        Path.Combine("internal", "zzz_hair_offset_shadow.hlsl"),
        Path.Combine("internal", "zzz_hair_runtime.hlsl"),
        Path.Combine("internal", "zzz_hair_zzzshadow_rim.hlsl"),
        Path.Combine("internal", "zzz_hgsao_contract.hlsl"),
        Path.Combine("internal", "zzz_hgshadow_bridge.hlsl"),
        Path.Combine("internal", "zzz_hoyotoon_hair_specular.hlsl"),
        Path.Combine("internal", "zzz_matcap.hlsl"),
        "zzz_hgshadow_bridge.hlsl",
        "zzz_face_skin_ramp_shared.hlsl"
    };

    private static readonly string[] ZzzRequiredControllerFiles =
    {
        "ZzzShadow_controller.pmx",
        "ZzzHair_controller.pmx",
        "ZzzFaceSkin_controller.pmx",
        "ZzzClothMatCap_controller.pmx",
        "ZzzEye_controller.pmx",
        "ZzzPost_controller.pmx"
    };

    private static readonly string[] ZzzCopiedDirectories =
    {
        "internal",
        "textures",
        "ZZZshadow",
        "ZZZEyeThrough",
        "ZZZPost"
    };

    private static readonly HashSet<string> ZzzDevelopmentEntryFiles = new(
        new[]
        {
            "ZZZ_Body.fx",
            "ZZZ_Debug.fx",
            "ZZZ_EyeThrough_Capture.fxsub",
            "ZZZ_EyeThrough_Mask.fxsub",
            "ZZZ_EyeThrough.fx",
            "ZZZ_Face.fx",
            "ZZZ_Hair.fx",
            "ZZZ_HairOffsetShadow.fx",
            "ZZZ_HairVisibility_Capture.fxsub"
        },
        StringComparer.OrdinalIgnoreCase);

    public static ShaderRuntimeKind Detect(string runtimeRoot)
    {
        if (string.IsNullOrWhiteSpace(runtimeRoot) || !Directory.Exists(runtimeRoot))
            return ShaderRuntimeKind.Auto;

        if (IsZzzRoot(runtimeRoot)) return ShaderRuntimeKind.ZzzMme;
        if (IsLegacyRoot(runtimeRoot)) return ShaderRuntimeKind.LegacyEndfield;
        return ShaderRuntimeKind.Auto;
    }

    public static string DisplayName(ShaderRuntimeKind kind) => kind switch
    {
        ShaderRuntimeKind.ZzzMme => "ZZZ MME",
        ShaderRuntimeKind.LegacyEndfield => "旧 Endfield 兼容运行时",
        _ => "未识别运行时"
    };

    public static IReadOnlyList<ValidationMessage> Validate(
        string runtimeRoot,
        ShaderRuntimeKind requestedKind = ShaderRuntimeKind.Auto)
    {
        var messages = new List<ValidationMessage>();
        if (string.IsNullOrWhiteSpace(runtimeRoot) || !Directory.Exists(runtimeRoot))
        {
            messages.Add(Error("RUNTIME_ROOT", "没有找到可用的 Shader 运行时目录。"));
            return messages;
        }

        var detected = Detect(runtimeRoot);
        var kind = requestedKind == ShaderRuntimeKind.Auto ? detected : requestedKind;
        if (detected == ShaderRuntimeKind.Auto)
        {
            messages.Add(Error(
                "RUNTIME_UNKNOWN",
                "该目录既不是 ZZZ_MME，也不是旧 EndfieldMME 运行时。"));
            return messages;
        }
        if (requestedKind != ShaderRuntimeKind.Auto && detected != requestedKind)
        {
            messages.Add(Error(
                "RUNTIME_KIND_MISMATCH",
                $"工程记录的运行时类型是 {DisplayName(requestedKind)}，但目录实际识别为 {DisplayName(detected)}。"));
            return messages;
        }

        if (kind == ShaderRuntimeKind.ZzzMme)
            ValidateZzz(runtimeRoot, messages);
        else
            ValidateLegacy(runtimeRoot, messages);
        return messages;
    }

    public static IReadOnlyList<string> CopyRuntime(
        string runtimeRoot,
        string outputRoot,
        ShaderRuntimeKind requestedKind = ShaderRuntimeKind.Auto)
    {
        var validation = Validate(runtimeRoot, requestedKind);
        var errors = validation.Where(message => message.IsError).ToArray();
        if (errors.Length > 0)
            throw new InvalidDataException(string.Join(Environment.NewLine, errors.Select(message => message.Message)));

        var kind = requestedKind == ShaderRuntimeKind.Auto ? Detect(runtimeRoot) : requestedKind;
        return kind == ShaderRuntimeKind.ZzzMme
            ? CopyZzzRuntime(runtimeRoot, outputRoot)
            : CopyLegacyRuntime(runtimeRoot, outputRoot);
    }

    public static bool HasZzzClothRuntime(string runtimeRoot) =>
        File.Exists(Path.Combine(runtimeRoot, "internal", "zzz_cloth_runtime.hlsl"));

    public static bool HasZzzHairRuntime(string runtimeRoot) =>
        File.Exists(Path.Combine(runtimeRoot, "internal", "zzz_hair_runtime.hlsl")) ||
        File.Exists(Path.Combine(runtimeRoot, "ZZZ_Hair.fx"));

    public static bool HasZzzFaceRuntime(string runtimeRoot) =>
        File.Exists(Path.Combine(runtimeRoot, "zzz_face_skin_ramp_shared.hlsl"));

    public static bool HasZzzSkinRuntime(string runtimeRoot) =>
        HasZzzFaceRuntime(runtimeRoot) &&
        File.Exists(Path.Combine(runtimeRoot, "zzz_hgshadow_bridge.hlsl"));

    public static bool HasZzzShadowRuntime(string runtimeRoot) =>
        File.Exists(Path.Combine(runtimeRoot, "ZZZshadow", "ZZZshadow.x")) &&
        File.Exists(Path.Combine(runtimeRoot, "ZZZshadow", "ZZZshadow.fx")) &&
        File.Exists(Path.Combine(runtimeRoot, "ZZZshadow", "ZZZshadow_ShadowMap.fxsub")) &&
        File.Exists(Path.Combine(runtimeRoot, "ZZZshadow", "ZZZshadow_ViewportMap.fxsub"));

    public static bool HasZzzEyeThroughRuntime(string runtimeRoot) =>
        File.Exists(Path.Combine(runtimeRoot, "ZZZEyeThrough", "ZZZEyeThrough.x")) &&
        File.Exists(Path.Combine(runtimeRoot, "ZZZEyeThrough", "ZZZEyeThrough.fx")) &&
        File.Exists(Path.Combine(runtimeRoot, "ZZZEyeThrough", "ZZZEyeThrough_HairMask.fxsub")) &&
        File.Exists(Path.Combine(runtimeRoot, "internal", "zzz_eye_through_capture_core.fxsub")) &&
        File.Exists(Path.Combine(runtimeRoot, "internal", "zzz_eye_through_contract.hlsl"));

    public static bool HasZzzPostRuntime(string runtimeRoot) =>
        File.Exists(Path.Combine(runtimeRoot, "ZZZPost", "ZZZPost.x")) &&
        File.Exists(Path.Combine(runtimeRoot, "ZZZPost", "ZZZPost.fx"));

    private static void ValidateLegacy(string runtimeRoot, ICollection<ValidationMessage> messages)
    {
        foreach (var directory in new[] { "internal", "controller", Path.Combine("textures", "common") })
        {
            if (!Directory.Exists(Path.Combine(runtimeRoot, directory)))
                messages.Add(Error("RUNTIME_DIRECTORY", $"旧运行时缺少目录：{directory}"));
        }

        foreach (var name in LegacyRequiredTopLevelFiles)
        {
            if (!File.Exists(Path.Combine(runtimeRoot, name)))
                messages.Add(Error("RUNTIME_FILE", $"旧运行时缺少权威文件：{name}"));
        }
        foreach (var name in LegacyFixedTextureNames)
        {
            if (FindLegacyFixedTexture(runtimeRoot, name) is null)
                messages.Add(Error("RUNTIME_TEXTURE", $"旧运行时缺少通用固定贴图：{name}"));
        }
    }

    private static void ValidateZzz(string runtimeRoot, ICollection<ValidationMessage> messages)
    {
        foreach (var name in ZzzRequiredCoreFiles)
        {
            if (!File.Exists(Path.Combine(runtimeRoot, name)))
                messages.Add(Error("RUNTIME_ZZZ_CORE", $"ZZZ 运行时缺少核心文件：{name}"));
        }

        if (!HasZzzHairRuntime(runtimeRoot))
            messages.Add(Warning("RUNTIME_ZZZ_HAIR", "ZZZ 运行时没有找到头发入口。"));
        if (!HasZzzFaceRuntime(runtimeRoot))
            messages.Add(Warning("RUNTIME_ZZZ_FACE", "ZZZ 运行时没有找到面部/皮肤共享 Ramp。"));
        if (!HasZzzSkinRuntime(runtimeRoot))
            messages.Add(Warning("RUNTIME_ZZZ_SKIN", "ZZZ 运行时缺少皮肤阴影桥接。"));
        if (!HasZzzShadowRuntime(runtimeRoot))
            messages.Add(Warning("RUNTIME_ZZZ_SHADOW", "ZZZshadow 未包含在该核心目录中，成品包需要另行补齐阴影附件。"));
        if (!HasZzzEyeThroughRuntime(runtimeRoot) &&
            !File.Exists(Path.Combine(runtimeRoot, "ZZZ_EyeThrough.fx")))
            messages.Add(Warning("RUNTIME_ZZZ_EYE", "没有找到 ZZZ 眼透入口。"));
        if (!HasZzzPostRuntime(runtimeRoot))
            messages.Add(Warning("RUNTIME_ZZZ_POST", "没有找到正式 ZZZPost；这不影响材质生成，但输出包不含后处理。"));
        var controllerRoot = Path.Combine(runtimeRoot, "controller");
        if (!Directory.Exists(controllerRoot))
        {
            messages.Add(Error("RUNTIME_ZZZ_CONTROLLER", "ZZZ 运行时缺少正式 controller 目录。"));
        }
        else
        {
            foreach (var fileName in ZzzRequiredControllerFiles)
            {
                if (!File.Exists(Path.Combine(controllerRoot, fileName)))
                    messages.Add(Error("RUNTIME_ZZZ_CONTROLLER", $"ZZZ 运行时缺少正式控制器：{fileName}"));
            }
        }
    }

    private static IReadOnlyList<string> CopyLegacyRuntime(string runtimeRoot, string outputRoot)
    {
        var files = new List<string>();
        CopyDirectory(Path.Combine(runtimeRoot, "internal"), Path.Combine(outputRoot, "internal"), files);
        CopyDirectory(Path.Combine(runtimeRoot, "textures", "common"), Path.Combine(outputRoot, "textures", "common"), files);
        CopyDirectory(Path.Combine(runtimeRoot, "textures", "environment_presets"), Path.Combine(outputRoot, "textures", "environment_presets"), files);
        foreach (var name in LegacyFixedTextureNames)
        {
            var source = FindLegacyFixedTexture(runtimeRoot, name)!;
            var destination = Path.Combine(outputRoot, "textures", "common", name);
            Directory.CreateDirectory(Path.GetDirectoryName(destination)!);
            File.Copy(source, destination, true);
            AddUnique(files, destination);
        }
        foreach (var name in LegacyRequiredTopLevelFiles)
        {
            var source = Path.Combine(runtimeRoot, name);
            if (!File.Exists(source)) continue;
            var destination = Path.Combine(outputRoot, name);
            File.Copy(source, destination, true);
            AddUnique(files, destination);
        }
        return files;
    }

    private static IReadOnlyList<string> CopyZzzRuntime(string runtimeRoot, string outputRoot)
    {
        var files = new List<string>();
        foreach (var directory in ZzzCopiedDirectories)
            CopyDirectory(Path.Combine(runtimeRoot, directory), Path.Combine(outputRoot, directory), files);

        foreach (var source in Directory.GetFiles(runtimeRoot, "*", SearchOption.TopDirectoryOnly)
                     .Where(IsZzzRuntimeTopLevelFile))
        {
            var destination = Path.Combine(outputRoot, Path.GetFileName(source));
            Directory.CreateDirectory(outputRoot);
            File.Copy(source, destination, true);
            AddUnique(files, destination);
        }
        ZzzRuntimeNormalizer.NormalizeGeneratedCopy(outputRoot);
        return files;
    }

    private static bool IsZzzRuntimeTopLevelFile(string path)
    {
        var name = Path.GetFileName(path);
        if (ZzzDevelopmentEntryFiles.Contains(name)) return false;
        var extension = Path.GetExtension(path);
        if (extension.Equals(".pmx", StringComparison.OrdinalIgnoreCase))
            return name.Contains("controller", StringComparison.OrdinalIgnoreCase);
        if (!new[] { ".fx", ".fxsub", ".hlsl", ".fxh", ".inc", ".x", ".png", ".dds" }
                .Contains(extension, StringComparer.OrdinalIgnoreCase))
            return false;
        return name.StartsWith("ZZZ", StringComparison.OrdinalIgnoreCase) ||
               name.StartsWith("Zzz", StringComparison.OrdinalIgnoreCase) ||
               name.StartsWith("zzz_", StringComparison.OrdinalIgnoreCase);
    }

    private static bool IsZzzRoot(string runtimeRoot) =>
        File.Exists(Path.Combine(runtimeRoot, "internal", "zzz_cloth_runtime.hlsl")) &&
        (File.Exists(Path.Combine(runtimeRoot, "ZZZ_Body.fx")) ||
         File.Exists(Path.Combine(runtimeRoot, "ZzzCloth.fx")) ||
         Directory.Exists(Path.Combine(runtimeRoot, "ZZZshadow")));

    private static bool IsLegacyRoot(string runtimeRoot) =>
        File.Exists(Path.Combine(runtimeRoot, "ZMDshadow.fx")) &&
        File.Exists(Path.Combine(runtimeRoot, "EndfieldEyeThrough.fx")) &&
        File.Exists(Path.Combine(runtimeRoot, "internal", "endfield_shader.hlsl"));

    private static void CopyDirectory(string source, string destination, ICollection<string> files)
    {
        if (!Directory.Exists(source)) return;
        foreach (var file in Directory.GetFiles(source, "*", SearchOption.AllDirectories))
        {
            var target = Path.Combine(destination, Path.GetRelativePath(source, file));
            Directory.CreateDirectory(Path.GetDirectoryName(target)!);
            File.Copy(file, target, true);
            AddUnique(files, target);
        }
    }

    private static string? FindLegacyFixedTexture(string runtimeRoot, string name)
    {
        var candidate = Path.Combine(runtimeRoot, "textures", "common", name);
        return File.Exists(candidate) ? candidate : null;
    }

    private static void AddUnique(ICollection<string> files, string path)
    {
        if (!files.Contains(path, StringComparer.OrdinalIgnoreCase)) files.Add(path);
    }

    private static ValidationMessage Error(string code, string message) =>
        new() { IsError = true, Code = code, Message = message };

    private static ValidationMessage Warning(string code, string message) =>
        new() { IsError = false, Code = code, Message = message };
}
