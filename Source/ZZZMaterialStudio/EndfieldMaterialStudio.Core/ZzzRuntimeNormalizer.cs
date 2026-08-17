using System.Text;
using System.Text.RegularExpressions;

namespace EndfieldMaterialStudio.Core;

public static class ZzzRuntimeNormalizer
{
    static ZzzRuntimeNormalizer() => Encoding.RegisterProvider(CodePagesEncodingProvider.Instance);

    public static void NormalizeGeneratedCopy(string runtimeRoot)
    {
        var hairRuntime = Path.Combine(runtimeRoot, "internal", "zzz_hair_runtime.hlsl");
        if (File.Exists(hairRuntime)) NormalizeHairRuntime(hairRuntime);

        var eyeCaptureCore = Path.Combine(
            runtimeRoot,
            "internal",
            "zzz_eye_through_capture_core.fxsub");
        if (File.Exists(eyeCaptureCore)) NormalizeEyeCaptureCore(eyeCaptureCore);
    }

    private static void NormalizeHairRuntime(string path)
    {
        var bytes = File.ReadAllBytes(path);
        var (text, encoding) = Decode(bytes);
        text = text.Replace(
            "#include \"internal/zzz_hair_controls.inc\"",
            "#include \"zzz_hair_controls.inc\"",
            StringComparison.Ordinal);
        text = text.Replace(
            "#include \"internal/zzz_hair_zzzshadow_rim.hlsl\"",
            "#include \"zzz_hair_zzzshadow_rim.hlsl\"",
            StringComparison.Ordinal);
        if (!text.Contains("#ifndef ZZZ_NORMAL_RESOURCE", StringComparison.Ordinal))
        {
            foreach (var name in new[]
                     {
                         "ZZZ_NORMAL_RESOURCE",
                         "ZZZ_MATERIAL_RESOURCE",
                         "ZZZ_ATTRIBUTE_RESOURCE",
                         "ZZZ_HEAD_BONE",
                         "ZZZ_ALPHA_CUTOFF"
                     })
            {
                text = WrapDefine(text, name);
            }

            const string anchor = "float4x4 ZzzWorldViewProjection : WORLDVIEWPROJECTION;";
            if (!text.Contains(anchor, StringComparison.Ordinal))
                throw new InvalidDataException("ZZZ Hair Runtime 缺少可参数化锚点。 ");
            text = text.Replace(
                anchor,
                "#ifndef ZZZ_HAIR_SUBSET\r\n" +
                "#define ZZZ_HAIR_SUBSET \"13\"\r\n" +
                "#endif\r\n\r\n" + anchor,
                StringComparison.Ordinal);
        }

        const string fixedSubset = "string Subset = \"13\";";
        var subsetCount = Regex.Matches(text, Regex.Escape(fixedSubset), RegexOptions.CultureInvariant).Count;
        if (subsetCount == 0 && !text.Contains("string Subset = ZZZ_HAIR_SUBSET;", StringComparison.Ordinal))
            throw new InvalidDataException("ZZZ Hair Runtime 没有找到固定材质索引。 ");
        text = text.Replace(fixedSubset, "string Subset = ZZZ_HAIR_SUBSET;", StringComparison.Ordinal);
        File.WriteAllText(path, text, encoding);
    }

    private static void NormalizeEyeCaptureCore(string path)
    {
        var bytes = File.ReadAllBytes(path);
        var (text, encoding) = Decode(bytes);
        const string macro = "ZZZ_EYE_THROUGH_FACE_RESOURCE";
        if (text.Contains($"#ifndef {macro}", StringComparison.Ordinal)) return;

        const string resource =
            "string ResourceName = \"../textures/Unagi_Face_D.png\";";
        var count = Regex.Matches(
            text,
            Regex.Escape(resource),
            RegexOptions.CultureInvariant).Count;
        if (count != 1)
            throw new InvalidDataException(
                $"ZZZ EyeThrough Capture Core 中面部资源锚点数量异常：{count}。");

        const string textureAnchor = "texture2D ZZZ_EyeEyeCaptureFaceTexture <";
        if (!text.Contains(textureAnchor, StringComparison.Ordinal))
            throw new InvalidDataException("ZZZ EyeThrough Capture Core 缺少面部贴图入口。");

        text = text.Replace(
            textureAnchor,
            $"#ifndef {macro}\r\n" +
            $"#define {macro} \"../textures/common/neutral_base.png\"\r\n" +
            "#endif\r\n\r\n" + textureAnchor,
            StringComparison.Ordinal);
        text = text.Replace(
            resource,
            $"string ResourceName = {macro};",
            StringComparison.Ordinal);
        File.WriteAllText(path, text, encoding);
    }

    private static string WrapDefine(string text, string name)
    {
        var pattern = $"(?m)^#define[ \\t]+{Regex.Escape(name)}[ \\t]+.*$";
        var matches = Regex.Matches(text, pattern, RegexOptions.CultureInvariant);
        if (matches.Count != 1)
            throw new InvalidDataException($"ZZZ Hair Runtime 中 {name} 定义数量异常：{matches.Count}");
        return Regex.Replace(
            text,
            pattern,
            match => $"#ifndef {name}\r\n{match.Value}\r\n#endif",
            RegexOptions.CultureInvariant);
    }

    private static (string Text, Encoding Encoding) Decode(byte[] bytes)
    {
        var candidates = new Encoding[]
        {
            new UTF8Encoding(false, true),
            Encoding.GetEncoding(
                932,
                EncoderFallback.ExceptionFallback,
                DecoderFallback.ExceptionFallback),
            Encoding.GetEncoding(
                936,
                EncoderFallback.ExceptionFallback,
                DecoderFallback.ExceptionFallback)
        };
        foreach (var encoding in candidates)
        {
            try
            {
                return (encoding.GetString(bytes), encoding);
            }
            catch (DecoderFallbackException)
            {
                // Try the next legacy MME encoding.
            }
        }
        throw new InvalidDataException("ZZZ Runtime 文件既不是 UTF-8、CP932，也不是 CP936。");
    }
}
