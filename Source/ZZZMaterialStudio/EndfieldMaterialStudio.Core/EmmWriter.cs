using System.Text;

namespace EndfieldMaterialStudio.Core;

public static class EmmWriter
{
    static EmmWriter() => Encoding.RegisterProvider(CodePagesEncodingProvider.Instance);

    public static byte[] Build(
        StudioProject project,
        string packageRoot,
        string runtimeLookupRoot,
        string modelPath,
        IReadOnlyDictionary<int, string> materialFxPaths,
        string? eyeCapturePath)
    {
        var layout = RuntimeLayout.Create(project.RuntimeKind, packageRoot, runtimeLookupRoot);
        var controllers = ControllerPaths(project, packageRoot, runtimeLookupRoot);
        var accessoryKeys = new List<string> { "Acs1" };
        var lines = new List<string>
        {
            "[Info]",
            "Version = 3",
            string.Empty,
            "[Object]",
            $"Acs1 = {layout.ShadowObject}"
        };
        if (project.EnableEyeThrough)
        {
            lines.Add($"Acs2 = {layout.EyeObject}");
            accessoryKeys.Add("Acs2");
        }
        if (layout.PostObject is not null)
        {
            lines.Add($"Acs3 = {layout.PostObject}");
            accessoryKeys.Add("Acs3");
        }
        lines.Add($"Pmd2 = {modelPath}");
        foreach (var pair in controllers) lines.Add($"{pair.Key} = {pair.Value}");

        lines.Add(string.Empty);
        lines.Add("[Effect]");
        lines.Add("Default = none");
        lines.Add($"Acs1 = {layout.ShadowEffect}");
        if (project.EnableEyeThrough) lines.Add($"Acs2 = {layout.EyeEffect}");
        if (layout.PostEffect is not null) lines.Add($"Acs3 = {layout.PostEffect}");
        lines.Add("Pmd2 = none");
        foreach (var pair in materialFxPaths.OrderBy(pair => pair.Key))
            lines.Add($"Pmd2[{pair.Key}] = {pair.Value}");
        foreach (var key in controllers.Keys) lines.Add($"{key} = none");

        if (project.EnableEyeThrough && !string.IsNullOrWhiteSpace(eyeCapturePath))
        {
            lines.Add(string.Empty);
            lines.Add($"[Effect@{layout.EyeCaptureTarget}]");
            lines.Add("Owner = Acs2");
            foreach (var key in accessoryKeys) lines.Add($"{key}.show = false");
            lines.Add($"Pmd2 = {eyeCapturePath}");
            foreach (var key in controllers.Keys) lines.Add($"{key}.show = false");

            if (layout.EyeHairMaskTarget is not null && layout.EyeHairMaskEffect is not null)
            {
                lines.Add(string.Empty);
                lines.Add($"[Effect@{layout.EyeHairMaskTarget}]");
                lines.Add("Owner = Acs2");
                foreach (var key in accessoryKeys) lines.Add($"{key}.show = false");
                lines.Add($"Pmd2 = {layout.EyeHairMaskEffect}");
                foreach (var key in controllers.Keys) lines.Add($"{key}.show = false");
            }
        }

        AddShadowSection(lines, layout.ShadowMapTarget, controllers.Keys, accessoryKeys, layout.ShadowMapEffect);
        AddShadowSection(lines, layout.ViewportMapTarget, controllers.Keys, accessoryKeys, layout.ViewportMapEffect);
        return Encoding.GetEncoding(936).GetBytes(string.Join("\r\n", lines) + "\r\n");
    }

    private static void AddShadowSection(
        ICollection<string> lines,
        string targetName,
        IEnumerable<string> controllerKeys,
        IEnumerable<string> accessoryKeys,
        string effectPath)
    {
        lines.Add(string.Empty);
        lines.Add($"[Effect@{targetName}]");
        lines.Add("Owner = Acs1");
        foreach (var key in accessoryKeys) lines.Add($"{key}.show = false");
        lines.Add($"Pmd2 = {effectPath}");
        foreach (var key in controllerKeys) lines.Add($"{key}.show = false");
    }

    private static IReadOnlyDictionary<string, string> ControllerPaths(
        StudioProject project,
        string packageRoot,
        string runtimeLookupRoot)
    {
        return project.ControllerFiles
            .Where(file => !string.IsNullOrWhiteSpace(file))
            .Select((file, index) => (Key: $"Pmd{index + 3}", File: Path.GetFileName(file)))
            .Where(item => File.Exists(Path.Combine(runtimeLookupRoot, "controller", item.File)))
            .ToDictionary(item => item.Key, item => Path.Combine(packageRoot, "controller", item.File), StringComparer.Ordinal);
    }

    private sealed record RuntimeLayout(
        string ShadowObject,
        string ShadowEffect,
        string ShadowMapTarget,
        string ShadowMapEffect,
        string ViewportMapTarget,
        string ViewportMapEffect,
        string EyeObject,
        string EyeEffect,
        string EyeCaptureTarget,
        string? EyeHairMaskTarget,
        string? EyeHairMaskEffect,
        string? PostObject,
        string? PostEffect)
    {
        public static RuntimeLayout Create(
            ShaderRuntimeKind kind,
            string packageRoot,
            string runtimeLookupRoot)
        {
            if (kind == ShaderRuntimeKind.ZzzMme)
            {
                var shadowRoot = Path.Combine(packageRoot, "ZZZshadow");
                var eyeRoot = Path.Combine(packageRoot, "ZZZEyeThrough");
                var postRoot = Path.Combine(packageRoot, "ZZZPost");
                var postObject = Path.Combine(postRoot, "ZZZPost.x");
                var postEffect = Path.Combine(postRoot, "ZZZPost.fx");
                var postLookupRoot = Path.Combine(runtimeLookupRoot, "ZZZPost");
                var hasPost = File.Exists(Path.Combine(postLookupRoot, "ZZZPost.x")) &&
                              File.Exists(Path.Combine(postLookupRoot, "ZZZPost.fx"));
                return new RuntimeLayout(
                    Path.Combine(shadowRoot, "ZZZshadow.x"),
                    Path.Combine(shadowRoot, "ZZZshadow.fx"),
                    "ZZZshadow_SMap",
                    Path.Combine(shadowRoot, "ZZZshadow_ShadowMap.fxsub"),
                    "ZZZshadow_VMap",
                    Path.Combine(shadowRoot, "ZZZshadow_ViewportMap.fxsub"),
                    Path.Combine(eyeRoot, "ZZZEyeThrough.x"),
                    Path.Combine(eyeRoot, "ZZZEyeThrough.fx"),
                    "ZZZ_EyeEyeThrough_RT",
                    "ZZZ_EyeHairMask_RT",
                    Path.Combine(eyeRoot, "ZZZEyeThrough_HairMask.fxsub"),
                    hasPost ? postObject : null,
                    hasPost ? postEffect : null);
            }

            return new RuntimeLayout(
                Path.Combine(packageRoot, "ZMDshadow.x"),
                Path.Combine(packageRoot, "ZMDshadow.fx"),
                "ZMDshadow_SMap",
                Path.Combine(packageRoot, "ZMDshadow_ShadowMap.fxsub"),
                "ZMDshadow_VMap",
                Path.Combine(packageRoot, "ZMDshadow_ViewportMap.fxsub"),
                Path.Combine(packageRoot, "EndfieldEyeThrough.x"),
                Path.Combine(packageRoot, "EndfieldEyeThrough.fx"),
                "EndfieldEyeThrough_RT",
                null,
                null,
                null,
                null);
        }
    }
}
