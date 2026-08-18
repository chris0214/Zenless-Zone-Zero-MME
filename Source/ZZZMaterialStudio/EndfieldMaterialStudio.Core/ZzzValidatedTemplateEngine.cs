using System.Text;
using System.Text.RegularExpressions;

namespace EndfieldMaterialStudio.Core;

internal static class ZzzValidatedTemplateEngine
{
    private const string EmptySubset = "2147483647";
    private static readonly Encoding Cp936;
    private static readonly Encoding Utf8 = new UTF8Encoding(false, true);

    static ZzzValidatedTemplateEngine()
    {
        Encoding.RegisterProvider(CodePagesEncodingProvider.Instance);
        Cp936 = Encoding.GetEncoding(
            936,
            EncoderFallback.ExceptionFallback,
            DecoderFallback.ExceptionFallback);
    }

    public static string BuildFace(
        MaterialAssignment material,
        TextureSlots textures,
        string headBone)
    {
        var text = ReadTemplate("ZzzFace_Template.fx", Cp936);
        text = ReplaceDefineString(text, "ZZZ_FACE_DIFFUSE_RESOURCE", Required(textures.Base, "Face Base"));
        text = ReplaceDefineString(text, "ZZZ_FACE_LIGHT_RESOURCE", Required(textures.Sdf, "Face Light/SDF"));
        text = ReplaceDefineString(text, "ZZZ_FACE_HEAD_BONE", EscapeQuoted(headBone));
        text = ReplaceExact(text, "string Subset = \"0\";", $"string Subset = \"{material.MaterialIndex}\";", 1);
        return text;
    }

    public static string BuildSkin(MaterialAssignment material, TextureSlots textures)
    {
        var normal = Required(textures.Normal, "Skin Normal / N");
        var property = Required(textures.Property, "Skin Property / M");
        var auxiliary = Required(textures.Rs, "Skin Attribute / A");
        var text = ReadTemplate("ZzzSkin_Template.fx", Cp936);

        text = ReplaceResource(text, "textures/Unagi_Body_Map1_N.png", normal);
        text = ReplaceResource(text, "textures/Unagi_Body_Map2_N.png", normal);
        text = ReplaceResource(text, "textures/Unagi_Body_Map1_M.png", property);
        text = ReplaceResource(text, "textures/Unagi_Body_Map2_M.png", property);
        text = ReplaceResource(text, "textures/Unagi_Body_Map1_A.png", auxiliary);
        text = ReplaceResource(text, "textures/Unagi_Body_Map2_A.png", auxiliary);
        text = ReplaceExact(text, "\"15\"", $"\"{material.MaterialIndex}\"", 4);
        text = ReplaceExact(text, "Jane face/skin", "ZZZ face/skin", 1);
        text = ReplaceExact(text, "Jane Body Map2", "ZZZ skin", 1);
        return text;
    }

    public static string BuildEyeBase(MaterialAssignment material, TextureSlots textures)
    {
        var text = ReadTemplate("ZzzEye01_Base_Template.fx", Cp936);
        text = ReplaceDefineString(text, "ZZZ_EYE_DIFFUSE_RESOURCE", Required(textures.Base, "Eye Base"));
        text = ReplaceExact(text, "string Subset = \"1,2,3\";", $"string Subset = \"{material.MaterialIndex}\";", 1);
        return text;
    }

    public static string BuildEyeOverlay(MaterialAssignment material, TextureSlots textures)
    {
        var variant = EyeVariant.ForRole(material.Role);
        var text = ReadTemplate("ZzzEye02_Overlays_Template.fx", Cp936);
        text = ReplaceDefineString(text, "ZZZ_EYE_OVERLAY_RESOURCE", Required(textures.Base, "Eye Overlay Base"));
        text = ReplaceExact(text, "Jane's authored eye overlay geometry", "generic authored eye overlay geometry", 1);
        text = ReplaceExact(text, "PMX 9 = inner light, 10 = outer highlight, 11 = eye shadow.",
            "The generator emits exactly one overlay path for the current PMX material.", 1);

        const string invocationPattern =
            @"(?s)ZZZ_EYE_OVERLAY_TECHNIQUE\(\r?\n[ \t]+ZzzEyeLashObject,.*?(?=\r?\ntechnique[ \t]+ZzzEyeOverlayEdge)";
        var subset = material.MaterialIndex.ToString(System.Globalization.CultureInfo.InvariantCulture);
        var prefix = $"ZzzEye{variant.Name}_{material.MaterialIndex:000}";
        var zWrite = (material.ZWriteOverride ?? roleWritesOcclusionDepth(material.Role)) ? "true" : "false";
        var invocations =
            $"ZZZ_EYE_OVERLAY_TECHNIQUE(\r\n" +
            $"    {prefix}Object, \"object\", \"{subset}\", true,\r\n" +
            $"    {variant.VertexShader}, {variant.PixelShader}, {zWrite}, {variant.DestinationBlend})\r\n" +
            $"ZZZ_EYE_OVERLAY_TECHNIQUE(\r\n" +
            $"    {prefix}ObjectSs, \"object_ss\", \"{subset}\", true,\r\n" +
            $"    {variant.VertexShader}, {variant.PixelShader}, {zWrite}, {variant.DestinationBlend})\r\n";
        return ReplaceRegex(text, invocationPattern, invocations, 1, "Eye02 technique block");

        static bool roleWritesOcclusionDepth(MaterialRole role) => role is
            MaterialRole.BrowLash or
            MaterialRole.EyeHighlight or
            MaterialRole.BrowOverlay;
    }

    public static string BuildEyeCapture(
        StudioProject project,
        string faceTextureResource,
        string headBone)
    {
        var lashes = project.Materials.Where(material =>
            material.Role == MaterialRole.BrowLash && IsLash(material));
        var brows = project.Materials.Where(material =>
            material.Role == MaterialRole.BrowLash && !IsLash(material));
        var overlays = lashes.Concat(project.Materials.Where(material =>
            material.Role is MaterialRole.EyeOverlay or MaterialRole.BrowOverlay));
        var ignored = project.Materials.Where(material => material.Role is
            MaterialRole.None or MaterialRole.Mouth or MaterialRole.Skin or
            MaterialRole.Cloth or MaterialRole.FaceProxy or MaterialRole.Hidden);

        var text = ReadTemplate("ZzzEyeThrough_Capture_Template.fxsub", Cp936);
        text = ReplaceExact(text, "Jane Doe material layout", "Generated ZZZ material layout", 1);
        text = ReplaceDefineString(text, "ZZZ_EYE_THROUGH_HEAD_BONE", EscapeQuoted(headBone));
        text = ReplaceDefineString(text, "ZZZ_EYE_THROUGH_EYE_SUBSETS",
            Subsets(project.Materials.Where(material => material.Role == MaterialRole.Iris)));
        text = ReplaceDefineString(text, "ZZZ_EYE_THROUGH_OVERLAY_SUBSETS", Subsets(overlays));
        text = ReplaceDefineString(text, "ZZZ_EYE_THROUGH_HIGHLIGHT_SUBSETS",
            Subsets(project.Materials.Where(material => material.Role == MaterialRole.EyeHighlight)));
        // The accepted EyeThrough deliberately excludes sclera. Letting eye
        // white enter the feature RT recreates the visibly floating eye shell.
        text = ReplaceDefineString(
            text,
            "ZZZ_EYE_THROUGH_SCLERA_SUBSETS",
            EmptySubset);
        text = ReplaceDefineString(text, "ZZZ_EYE_THROUGH_BROW_SUBSETS", Subsets(brows));
        text = ReplaceDefineString(text, "ZZZ_EYE_THROUGH_IGNORED_SUBSETS", Subsets(ignored));
        text = ReplaceDefineString(text, "ZZZ_EYE_THROUGH_HAIR_DEPTH_SUBSETS",
            Subsets(project.Materials.Where(material => material.Role == MaterialRole.Hair)));
        text = ReplaceDefineString(text, "ZZZ_EYE_THROUGH_SHIFTED_SUBSETS", EmptySubset);

        const string include = "#include \"../internal/zzz_eye_through_capture_core.fxsub\"";
        var resource = RelativeFromEyeDirectory(faceTextureResource);
        return InsertBefore(text, include,
            $"#define ZZZ_EYE_THROUGH_FACE_RESOURCE \"{resource}\"\r\n\r\n");
    }

    public static string BuildEyeHairMask(StudioProject project)
    {
        var text = ReadTemplate("ZzzEyeThrough_HairMask_Template.fxsub", Utf8);
        text = ReplaceExact(text, "Jane Doe EyeThrough", "ZZZ EyeThrough", 1);
        text = ReplaceExact(text, "string Subset = \"13\";",
            $"string Subset = \"{Subsets(project.Materials.Where(material => material.Role == MaterialRole.Hair))}\";", 1);
        text = ReplaceExact(text, "string Subset = \"0\";",
            $"string Subset = \"{Subsets(project.Materials.Where(material => material.Role == MaterialRole.Face))}\";", 1);
        return text;
    }

    private static bool IsLash(MaterialAssignment material)
    {
        var name = $"{material.MaterialName} {material.EnglishName}";
        return name.Contains("睫", StringComparison.OrdinalIgnoreCase) ||
               name.Contains("lash", StringComparison.OrdinalIgnoreCase);
    }

    private static string Subsets(IEnumerable<MaterialAssignment> materials)
    {
        var values = materials.Select(material => material.MaterialIndex)
            .Distinct()
            .OrderBy(index => index)
            .ToArray();
        return values.Length == 0 ? EmptySubset : string.Join(",", values);
    }

    private static string RelativeFromEyeDirectory(string value)
    {
        var normalized = Required(value, "EyeThrough Face Base").TrimStart('/');
        if (normalized.StartsWith("../", StringComparison.Ordinal)) return normalized;
        if (Path.IsPathRooted(normalized))
            throw new InvalidDataException("眼透 Capture 贴图必须是输出包内的相对路径。");
        return "../" + normalized;
    }

    private static string ReplaceDefineString(string text, string name, string value)
    {
        var pattern = $"(?m)^(#define[ \\t]+{Regex.Escape(name)}[ \\t]+)\"[^\"\\r\\n]*\"[ \\t]*\\r?$";
        return ReplaceRegex(
            text,
            pattern,
            match => match.Groups[1].Value + "\"" + value.Replace('\\', '/') + "\"",
            1,
            name);
    }

    private static string ReplaceResource(string text, string oldPath, string newPath) =>
        ReplaceExact(text, $"string ResourceName = \"{oldPath}\";",
            $"string ResourceName = \"{newPath.Replace('\\', '/')}\";", 1);

    private static string ReplaceExact(
        string text,
        string oldValue,
        string newValue,
        int expectedCount)
    {
        var count = Regex.Matches(text, Regex.Escape(oldValue), RegexOptions.CultureInvariant).Count;
        if (count != expectedCount)
            throw new InvalidDataException(
                $"ZZZ 验收模板锚点数量异常：{oldValue}，期望 {expectedCount}，实际 {count}。");
        return text.Replace(oldValue, newValue, StringComparison.Ordinal);
    }

    private static string ReplaceRegex(
        string text,
        string pattern,
        string replacement,
        int expectedCount,
        string label) => ReplaceRegex(
            text,
            pattern,
            _ => replacement,
            expectedCount,
            label);

    private static string ReplaceRegex(
        string text,
        string pattern,
        MatchEvaluator evaluator,
        int expectedCount,
        string label)
    {
        var matches = Regex.Matches(text, pattern, RegexOptions.CultureInvariant);
        if (matches.Count != expectedCount)
            throw new InvalidDataException(
                $"ZZZ 验收模板锚点数量异常：{label}，期望 {expectedCount}，实际 {matches.Count}。");
        return Regex.Replace(text, pattern, evaluator, RegexOptions.CultureInvariant);
    }

    private static string InsertBefore(string text, string anchor, string value)
    {
        var count = Regex.Matches(text, Regex.Escape(anchor), RegexOptions.CultureInvariant).Count;
        if (count != 1)
            throw new InvalidDataException($"ZZZ 验收模板缺少唯一入口：{anchor}。");
        return text.Insert(text.IndexOf(anchor, StringComparison.Ordinal), value);
    }

    private static string ReadTemplate(string name, Encoding encoding)
    {
        var resourceName = $"EndfieldMaterialStudio.Core.Templates.{name}";
        using var stream = typeof(ZzzValidatedTemplateEngine).Assembly.GetManifestResourceStream(resourceName)
            ?? throw new FileNotFoundException($"找不到内嵌 ZZZ 验收模板：{name}", resourceName);
        using var memory = new MemoryStream();
        stream.CopyTo(memory);
        return encoding.GetString(memory.ToArray());
    }

    private static string Required(string? value, string label) =>
        string.IsNullOrWhiteSpace(value)
            ? throw new InvalidDataException($"缺少 {label} 贴图。")
            : value.Replace('\\', '/');

    private static string EscapeQuoted(string value) =>
        value.Replace("\\", "\\\\", StringComparison.Ordinal)
            .Replace("\"", "\\\"", StringComparison.Ordinal);

    private sealed record EyeVariant(
        string Name,
        string VertexShader,
        string PixelShader,
        string DestinationBlend)
    {
        public static EyeVariant ForRole(MaterialRole role) => role switch
        {
            MaterialRole.BrowLash => new("Lash", "ZzzEyeLashVS", "ZzzEyeLashPS", "INVSRCALPHA"),
            MaterialRole.EyeOverlay => new("Inner", "ZzzEyeInnerVS", "ZzzEyeInnerPS", "ONE"),
            MaterialRole.EyeHighlight => new("Highlight", "ZzzEyeHighlightVS", "ZzzEyeHighlightPS", "INVSRCALPHA"),
            MaterialRole.BrowOverlay => new("Shadow", "ZzzEyeShadowVS", "ZzzEyeShadowPS", "INVSRCALPHA"),
            _ => throw new InvalidOperationException($"材质角色 {role} 不对应 Eye02 的 Lash/Inner/Highlight/Shadow 分支。")
        };
    }
}
