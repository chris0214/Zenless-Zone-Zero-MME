namespace EndfieldMaterialStudio.Core;

public static class ZzzControllerCatalog
{
    public static List<string> CreateDefaultControllerFiles(
        ShaderRuntimeKind runtimeKind = ShaderRuntimeKind.LegacyEndfield) =>
        runtimeKind == ShaderRuntimeKind.ZzzMme
            ? new List<string>
            {
                "ZzzShadow_controller.pmx",
                "ZzzHair_controller.pmx",
                "ZzzFaceSkin_controller.pmx",
                "ZzzClothMatCap_controller.pmx",
                "ZzzEye_controller.pmx",
                "ZzzPost_controller.pmx"
            }
            : new List<string>
            {
                "EndfieldHair_controller_Range5.pmx",
                "EndfieldFace_controller.pmx",
                "EndfieldSkin_controller.pmx",
                "EndfieldCloth_controller.pmx",
                "Endfield_controller.pmx",
                "EndfieldPost_controller.pmx"
            };

    public static List<ZzzControllerBinding> CreateDefault() => new();

    public static List<ZzzControllerBinding> CreateFromDirectory(
        string controllerRoot,
        IEnumerable<string>? controllerFiles = null)
    {
        var result = new List<ZzzControllerBinding>();
        if (string.IsNullOrWhiteSpace(controllerRoot) || !Directory.Exists(controllerRoot)) return result;

        foreach (var requestedFile in controllerFiles ?? CreateDefaultControllerFiles())
        {
            var fileName = Path.GetFileName(requestedFile);
            if (string.IsNullOrWhiteSpace(fileName)) continue;
            var path = Path.Combine(controllerRoot, fileName);
            if (!File.Exists(path)) continue;
            AddControllerBindings(result, path, fileName);
        }
        return result;
    }

    public static List<ZzzControllerBinding> CreateForProject(StudioProject project)
    {
        var result = new List<ZzzControllerBinding>();
        foreach (var requestedFile in project.ControllerFiles)
        {
            var fileName = Path.GetFileName(requestedFile);
            if (string.IsNullOrWhiteSpace(fileName)) continue;
            var path = ResolveControllerPath(project, fileName);
            if (path is null) continue;
            AddControllerBindings(result, path, fileName);
        }
        return result;
    }

    public static void MergeFromDirectory(StudioProject project)
    {
        project.ControllerBindings ??= new List<ZzzControllerBinding>();
        var discovered = CreateForProject(project);
        if (discovered.Count == 0) return;

        foreach (var existing in project.ControllerBindings)
        {
            if (!string.IsNullOrWhiteSpace(existing.ControllerFile)) continue;
            var matches = discovered.Where(candidate =>
                    candidate.MorphName.Equals(existing.MorphName, StringComparison.Ordinal))
                .ToArray();
            if (matches.Length != 1) continue;
            existing.ControllerFile = matches[0].ControllerFile;
            if (string.IsNullOrWhiteSpace(existing.Group)) existing.Group = matches[0].Group;
        }

        var existingKeys = project.ControllerBindings
            .Select(BindingKey)
            .ToHashSet(StringComparer.OrdinalIgnoreCase);
        foreach (var binding in discovered)
        {
            if (existingKeys.Add(BindingKey(binding))) project.ControllerBindings.Add(binding);
        }
    }

    public static string ResolveControllerRoot(StudioProject project)
    {
        var custom = project.ControllerRoot;
        if (!string.IsNullOrWhiteSpace(custom) && Directory.Exists(custom)) return Path.GetFullPath(custom);
        return Path.GetFullPath(Path.Combine(project.RuntimeRoot, "controller"));
    }

    public static string? ResolveControllerPath(StudioProject project, string fileName)
    {
        var safeName = Path.GetFileName(fileName);
        if (string.IsNullOrWhiteSpace(safeName)) return null;
        if (!string.IsNullOrWhiteSpace(project.ControllerRoot))
        {
            var custom = Path.Combine(project.ControllerRoot, safeName);
            if (File.Exists(custom)) return Path.GetFullPath(custom);
        }
        var runtime = Path.Combine(project.RuntimeRoot, "controller", safeName);
        return File.Exists(runtime) ? Path.GetFullPath(runtime) : null;
    }

    private static void AddControllerBindings(
        ICollection<ZzzControllerBinding> target,
        string path,
        string fileName)
    {
        var model = PmxReader.Read(path);
        foreach (var morph in model.Morphs)
        {
            target.Add(new ZzzControllerBinding
            {
                ControllerFile = fileName,
                Group = ResolveGroup(fileName, morph.Name),
                MorphName = morph.Name,
                TargetProperty = ResolveTargetProperty(fileName, morph.Name),
                Min = 0.0,
                Max = 1.0,
                Default = 0.0,
                Enabled = true,
                Note = BindingNote(fileName, morph.Name)
            });
        }
    }

    private static string BindingKey(ZzzControllerBinding binding) =>
        $"{Path.GetFileName(binding.ControllerFile)}\u001f{binding.MorphName}";

    private static string ResolveGroup(string fileName, string morphName)
    {
        if (fileName.Equals("ZzzShadow_controller.pmx", StringComparison.OrdinalIgnoreCase)) return "陰影";
        if (fileName.Equals("EndfieldHair_controller_Range5.pmx", StringComparison.OrdinalIgnoreCase) ||
            fileName.Equals("ZzzHair_controller.pmx", StringComparison.OrdinalIgnoreCase)) return "髪";
        if (fileName.Equals("ZzzFaceSkin_controller.pmx", StringComparison.OrdinalIgnoreCase))
        {
            if (morphName.StartsWith("皮", StringComparison.Ordinal)) return "皮膚";
            if (morphName.StartsWith("肌色", StringComparison.Ordinal)) return "共通肌色";
            return "面部";
        }
        if (fileName.Equals("ZzzClothMatCap_controller.pmx", StringComparison.OrdinalIgnoreCase))
            return morphName.StartsWith("球面", StringComparison.Ordinal) ? "MatCap" : "衣装";
        if (fileName.Equals("ZzzEye_controller.pmx", StringComparison.OrdinalIgnoreCase)) return "眼";
        if (fileName.Equals("EndfieldSkin_controller.pmx", StringComparison.OrdinalIgnoreCase)) return "皮膚";
        if (fileName.Equals("EndfieldCloth_controller.pmx", StringComparison.OrdinalIgnoreCase)) return "衣装";
        if (fileName.Equals("EndfieldPost_controller.pmx", StringComparison.OrdinalIgnoreCase) ||
            fileName.Equals("ZzzPost_controller.pmx", StringComparison.OrdinalIgnoreCase)) return "後処理";
        if (fileName.Equals("EndfieldFace_controller.pmx", StringComparison.OrdinalIgnoreCase))
            return StartsWithAny(morphName, "虹膜", "瞳孔", "眼反射", "眼高光", "眼白") ? "眼" : "面部";
        if (StartsWithAny(morphName, "雨")) return "天候";
        if (ContainsAny(morphName, "灯光", "日光")) return "照明";
        if (ContainsAny(morphName, "陰影", "明暗線", "自陰影")) return "陰影";
        if (StartsWithAny(morphName, "髪")) return "髪";
        return "全局";
    }

    private static string ResolveTargetProperty(string fileName, string morphName)
    {
        var scope = fileName switch
        {
            "ZzzShadow_controller.pmx" => "Shadow",
            "EndfieldHair_controller_Range5.pmx" or "ZzzHair_controller.pmx" => "Hair",
            "ZzzFaceSkin_controller.pmx" => morphName.StartsWith("皮", StringComparison.Ordinal) ? "Skin" : "FaceSkin",
            "ZzzClothMatCap_controller.pmx" => morphName.StartsWith("球面", StringComparison.Ordinal) ? "Cloth.MatCap" : "Cloth",
            "ZzzEye_controller.pmx" => "Eye",
            "EndfieldFace_controller.pmx" => "FaceEye",
            "EndfieldSkin_controller.pmx" => "Skin",
            "EndfieldCloth_controller.pmx" => "Cloth",
            "EndfieldPost_controller.pmx" or "ZzzPost_controller.pmx" => "Post",
            "Endfield_controller.pmx" => "Global",
            _ => Path.GetFileNameWithoutExtension(fileName)
        };
        return $"{scope}.Morph.{morphName.TrimEnd('+', '-')}";
    }

    private static string BindingNote(string fileName, string morphName)
    {
        var neutral = "PMX 表情滑块范围 0..1；零值保持 Shader 已验收中性画面。";
        if (!fileName.Equals("ZzzClothMatCap_controller.pmx", StringComparison.OrdinalIgnoreCase) ||
            !morphName.StartsWith("球面槽", StringComparison.Ordinal)) return neutral;
        var slot = morphName.Length > 3 ? morphName[3].ToString() : "?";
        if (morphName.Contains("強", StringComparison.Ordinal))
            return $"JSON _MatCapColorBurst{slot} 基础值之上的运行时强度乘数；离散贴图选择仍在 GUI。";
        if (morphName.Contains("明", StringComparison.Ordinal))
            return $"JSON MatCap 槽 {slot} 采样明度乘数；不会改动基础色或二分阴影。";
        if (morphName.Contains("遮蔽", StringComparison.Ordinal))
            return $"JSON _MatCapAlphaBurst{slot} 与材质遮罩之上的运行时遮蔽乘数。";
        return $"MatCap 槽 {slot} 运行时关闭开关；官方 JSON 与手动贴图选择仍由 GUI 决定。";
    }

    private static bool StartsWithAny(string value, params string[] prefixes) =>
        prefixes.Any(prefix => value.StartsWith(prefix, StringComparison.Ordinal));

    private static bool ContainsAny(string value, params string[] fragments) =>
        fragments.Any(fragment => value.Contains(fragment, StringComparison.Ordinal));
}
