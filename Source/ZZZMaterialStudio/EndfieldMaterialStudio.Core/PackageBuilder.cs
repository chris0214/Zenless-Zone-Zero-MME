using System.Security.Cryptography;
using System.Text;

namespace EndfieldMaterialStudio.Core;

public sealed class PackageBuilder
{
    public PackageResult Build(StudioProject sourceProject, bool overwrite = true)
    {
        var project = Clone(sourceProject);
        var modelPath = PrepareEyeThrough(project);
        var validation = ProjectValidator.Validate(project);
        var errors = validation.Where(message => message.IsError).ToArray();
        if (errors.Length > 0)
            throw new InvalidDataException(string.Join(Environment.NewLine, errors.Select(message => message.ToString())));

        var packageName = ProjectFactory.SanitizeProjectName(project.ProjectName) + "_ZZZ";
        var outputRoot = Path.Combine(Path.GetFullPath(project.OutputDirectory), packageName);
        var staging = outputRoot + ".stage_" + Guid.NewGuid().ToString("N");
        if (Directory.Exists(outputRoot) && !overwrite) throw new IOException($"输出目录已存在：{outputRoot}");

        var generated = new List<string>();
        try
        {
            Directory.CreateDirectory(staging);
            generated.AddRange(RuntimeContract.CopyRuntime(project.RuntimeRoot, staging, project.RuntimeKind));
            generated.AddRange(CopyControllerOverrides(project, staging));
            var packagedModelPath = CopyModelAndDependencies(modelPath, staging, outputRoot, generated);
            var packagedTextures = CopyTextures(project, staging, generated);
            var generatedProfiles = WriteZzzProfiles(project, packagedTextures, staging, generated);
            const string bindingFileName = "endfield_generated_face_binding.cp932";
            if (project.RuntimeKind == ShaderRuntimeKind.LegacyEndfield)
            {
                var bindingPath = Path.Combine(staging, "internal", bindingFileName);
                File.WriteAllBytes(bindingPath, FxTemplateEngine.BuildFaceBinding(project.HeadBone));
                generated.Add(bindingPath);
            }

            var materialFx = new Dictionary<int, string>();
            foreach (var material in project.Materials.Where(material => material.Enabled).OrderBy(material => material.MaterialIndex))
            {
                var fxName = $"Material_{material.MaterialIndex:000}_{material.Role}.fx";
                var fxPath = Path.Combine(staging, fxName);
                File.WriteAllBytes(fxPath, FxTemplateEngine.BuildMaterialFx(
                    material,
                    packagedTextures[material.MaterialIndex],
                    project.HeadBone,
                    bindingFileName,
                    Path.GetRelativePath(staging, generatedProfiles[material.MaterialIndex]).Replace('\\', '/'),
                    project.RuntimeKind));
                generated.Add(fxPath);
                materialFx[material.MaterialIndex] = fxPath;
            }

            string? capturePath = null;
            if (project.EnableEyeThrough)
            {
                var captureMaterial = project.RuntimeKind == ShaderRuntimeKind.ZzzMme
                    ? project.Materials.FirstOrDefault(material => material.Role == MaterialRole.Face) ??
                      project.Materials.First(material => material.Role == MaterialRole.Iris)
                    : project.Materials.First(material => material.Role == MaterialRole.Iris);
                capturePath = project.RuntimeKind == ShaderRuntimeKind.ZzzMme
                    ? Path.Combine(staging, "ZZZEyeThrough", "ZZZEyeThrough_Capture.fxsub")
                    : Path.Combine(staging, "EndfieldEyeThrough_Capture.fxsub");
                Directory.CreateDirectory(Path.GetDirectoryName(capturePath)!);
                File.WriteAllText(
                    capturePath,
                    FxTemplateEngine.BuildEyeCapture(
                        project,
                        packagedTextures[captureMaterial.MaterialIndex],
                        project.HeadBone,
                        project.RuntimeKind),
                    project.RuntimeKind == ShaderRuntimeKind.ZzzMme
                        ? Encoding.GetEncoding(936)
                        : new UTF8Encoding(false));
                AddGenerated(generated, capturePath);

                if (project.RuntimeKind == ShaderRuntimeKind.ZzzMme)
                {
                    var hairMaskPath = Path.Combine(
                        staging,
                        "ZZZEyeThrough",
                        "ZZZEyeThrough_HairMask.fxsub");
                    File.WriteAllText(
                        hairMaskPath,
                        FxTemplateEngine.BuildZzzEyeHairMask(project),
                        new UTF8Encoding(false));
                    AddGenerated(generated, hairMaskPath);
                }
            }

            if (project.RuntimeKind == ShaderRuntimeKind.LegacyEndfield)
            {
                var hairVisibilityCapturePath = Path.Combine(
                    staging, "EndfieldHairVisibility_Capture.fxsub");
                File.WriteAllText(
                    hairVisibilityCapturePath,
                    FxTemplateEngine.BuildHairVisibilityCapture(project),
                    new UTF8Encoding(false));
                generated.Add(hairVisibilityCapturePath);
            }

            var finalMaterialFx = materialFx.ToDictionary(
                pair => pair.Key,
                pair => Path.Combine(outputRoot, Path.GetRelativePath(staging, pair.Value)));
            var finalProfiles = generatedProfiles.ToDictionary(
                pair => pair.Key,
                pair => Path.Combine(outputRoot, Path.GetRelativePath(staging, pair.Value)));
            var finalCapture = capturePath is null ? null : Path.Combine(outputRoot, Path.GetRelativePath(staging, capturePath));
            var emmName = ProjectFactory.SanitizeProjectName(project.ProjectName) + "_自动映射.emm";
            var emmPath = Path.Combine(staging, emmName);
            File.WriteAllBytes(emmPath, EmmWriter.Build(project, outputRoot, staging, packagedModelPath, finalMaterialFx, finalCapture));
            generated.Add(emmPath);

            const string controllerMapName = "controller-map.json";
            var controllerMapPath = Path.Combine(staging, controllerMapName);
            File.WriteAllBytes(controllerMapPath, ZzzControllerManifestWriter.Build(project));
            generated.Add(controllerMapPath);

            const string materialMapName = "material-map.json";
            var materialMapPath = Path.Combine(staging, materialMapName);
            File.WriteAllBytes(materialMapPath, MaterialMapWriter.Build(
                project,
                outputRoot,
                packagedModelPath,
                Path.Combine(staging, "Model", Path.GetFileName(modelPath)),
                finalMaterialFx,
                packagedTextures,
                finalProfiles,
                Path.Combine(outputRoot, controllerMapName),
                Path.Combine(outputRoot, emmName),
                finalCapture));
            generated.Add(materialMapPath);

            PreparePackagedProject(project, outputRoot, packagedModelPath, modelPath, packagedTextures);
            var projectPath = Path.Combine(staging, ProjectFactory.SanitizeProjectName(project.ProjectName) + ".zzzstudio.json");
            ProjectFactory.Save(project, projectPath);
            generated.Add(projectPath);

            var reportPath = Path.Combine(staging, "材质映射说明.txt");
            File.WriteAllText(reportPath, BuildReport(project, packagedModelPath, finalMaterialFx), new UTF8Encoding(false));
            generated.Add(reportPath);

            Commit(staging, outputRoot);
            return new PackageResult
            {
                OutputDirectory = outputRoot,
                EmmPath = Path.Combine(outputRoot, emmName),
                MaterialMapPath = Path.Combine(outputRoot, materialMapName),
                ControllerMapPath = Path.Combine(outputRoot, controllerMapName),
                ModelPath = packagedModelPath,
                GeneratedFiles = generated.Select(path => Path.Combine(outputRoot, Path.GetRelativePath(staging, path))).ToArray()
            };
        }
        finally
        {
            if (Directory.Exists(staging)) Directory.Delete(staging, true);
        }
    }

    private static string PrepareEyeThrough(StudioProject project)
    {
        if (!project.EnableEyeThrough || !project.GenerateDerivedPmx) return Path.GetFullPath(project.PmxPath);
        if (project.RuntimeKind == ShaderRuntimeKind.ZzzMme)
            return Path.GetFullPath(project.PmxPath);
        var result = EyeThroughProjectService.Ensure(project);
        return result.DerivedPmxPath;
    }

    private static void AddGenerated(ICollection<string> generated, string path)
    {
        if (!generated.Contains(path, StringComparer.OrdinalIgnoreCase)) generated.Add(path);
    }

    private static IReadOnlyList<string> CopyControllerOverrides(StudioProject project, string staging)
    {
        var sourceRoot = !string.IsNullOrWhiteSpace(project.ControllerRoot) && Directory.Exists(project.ControllerRoot)
            ? Path.GetFullPath(project.ControllerRoot)
            : Path.Combine(Path.GetFullPath(project.RuntimeRoot), "controller");
        if (!Directory.Exists(sourceRoot))
            return Array.Empty<string>();

        var copied = new List<string>();
        var output = Path.Combine(staging, "controller");
        Directory.CreateDirectory(output);
        foreach (var fileName in project.ControllerFiles.Select(Path.GetFileName)
                     .Where(fileName => !string.IsNullOrWhiteSpace(fileName))
                     .Select(fileName => fileName!)
                     .Distinct(StringComparer.OrdinalIgnoreCase))
        {
            var source = Path.Combine(sourceRoot, fileName);
            if (!File.Exists(source)) continue;
            var destination = Path.Combine(output, fileName);
            File.Copy(source, destination, true);
            copied.Add(destination);
        }
        return copied;
    }

    private static IReadOnlyDictionary<int, string> WriteZzzProfiles(
        StudioProject project,
        IReadOnlyDictionary<int, TextureSlots> packagedTextures,
        string staging,
        ICollection<string> generated)
    {
        var result = new Dictionary<int, string>();
        var root = Path.Combine(staging, "generated_json_profiles");
        Directory.CreateDirectory(root);
        var neutral = Path.Combine(root, Path.GetFileName(ZzzProfileIncludeWriter.NeutralResource));
        File.WriteAllBytes(neutral, ZzzProfileIncludeWriter.NeutralTextureBytes());
        generated.Add(neutral);

        foreach (var material in project.Materials.Where(material => material.Enabled)
                     .OrderBy(material => material.MaterialIndex))
        {
            if (!packagedTextures.TryGetValue(material.MaterialIndex, out var textures)) continue;
            var name = $"Material_{material.MaterialIndex:000}_ZZZ";
            var path = Path.Combine(root, name + ".inc");
            File.WriteAllText(path, ZzzProfileIncludeWriter.Build(material, textures, name), new UTF8Encoding(false));
            generated.Add(path);
            result[material.MaterialIndex] = path;
        }
        return result;
    }

    private static string CopyModelAndDependencies(
        string sourceModelPath,
        string staging,
        string outputRoot,
        ICollection<string> generated)
    {
        var sourceModel = Path.GetFullPath(sourceModelPath);
        var stagingModelRoot = Path.Combine(staging, "Model");
        var stagingModelPath = Path.Combine(stagingModelRoot, Path.GetFileName(sourceModel));
        Directory.CreateDirectory(stagingModelRoot);
        File.Copy(sourceModel, stagingModelPath, true);
        generated.Add(stagingModelPath);

        var model = PmxReader.Read(sourceModel);
        var copied = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        foreach (var material in model.Materials)
        {
            CopyDependency(material.TexturePath, $"#{material.Index} {material.Name} 基础贴图");
            if (material.SphereMode != 0)
                CopyDependency(material.SphereTexturePath, $"#{material.Index} {material.Name} 球面贴图");
            CopyDependency(material.ToonTexturePath, $"#{material.Index} {material.Name} Toon 贴图");
        }

        return Path.Combine(outputRoot, "Model", Path.GetFileName(sourceModel));

        void CopyDependency(string? relativePath, string label)
        {
            if (string.IsNullOrWhiteSpace(relativePath)) return;
            var safeRelativePath = NormalizeModelTexturePath(relativePath, label);
            var resolution = PmxReader.ResolveTexture(sourceModel, relativePath)!;
            var source = resolution.ResolvedPath;
            if (!resolution.Exists) throw new FileNotFoundException($"{label}不存在，无法生成自包含角色包。", resolution.DirectPath);

            var destination = Path.GetFullPath(Path.Combine(stagingModelRoot, safeRelativePath));
            var modelRootPrefix = Path.GetFullPath(stagingModelRoot) + Path.DirectorySeparatorChar;
            if (!destination.StartsWith(modelRootPrefix, StringComparison.OrdinalIgnoreCase))
                throw new InvalidDataException($"{label}路径越出了 Model 文件夹：{relativePath}");
            if (!copied.Add(destination)) return;
            Directory.CreateDirectory(Path.GetDirectoryName(destination)!);
            File.Copy(source, destination, true);
            generated.Add(destination);
        }
    }

    private static string NormalizeModelTexturePath(string path, string label)
    {
        var normalized = path.Trim().Replace('/', Path.DirectorySeparatorChar).Replace('\\', Path.DirectorySeparatorChar);
        if (Path.IsPathRooted(normalized))
            throw new InvalidDataException($"{label}使用了绝对路径，无法安全打包：{path}");

        var parts = normalized.Split(Path.DirectorySeparatorChar, StringSplitOptions.RemoveEmptyEntries);
        if (parts.Length == 0 || parts.Any(part => part is "." or ".." || part.Contains(':')))
            throw new InvalidDataException($"{label}包含不安全的相对路径：{path}");
        return Path.Combine(parts);
    }

    private static void PreparePackagedProject(
        StudioProject project,
        string outputRoot,
        string packagedModelPath,
        string sourceModelPath,
        IReadOnlyDictionary<int, TextureSlots> packagedTextures)
    {
        var sourceModel = PmxReader.Read(sourceModelPath);
        project.PmxPath = packagedModelPath;
        project.RuntimeRoot = outputRoot;
        foreach (var material in project.Materials)
        {
            var sourceMaterial = sourceModel.Materials.FirstOrDefault(item => item.Index == material.MaterialIndex);
            material.PmxBaseTexture = sourceMaterial is null
                ? null
                : PmxReader.ResolveTextureFilePath(packagedModelPath, sourceMaterial.TexturePath);
            if (packagedTextures.TryGetValue(material.MaterialIndex, out var textures))
            {
                material.Textures = MakeAbsolute(textures, outputRoot);
                for (var slot = 1; slot <= 5; slot++)
                {
                    var packagedMatCap = material.Textures.MatCaps.TryGetValue(slot, out var path) ? path : null;
                    var binding = material.Zzz.GetMatCap(slot);
                    if (string.IsNullOrWhiteSpace(packagedMatCap)) continue;
                    if (binding.Source == ZzzValueSource.Manual) binding.ManualTexturePath = packagedMatCap;
                    binding.ResolvedTexturePath = packagedMatCap;
                }
            }
        }
    }

    private static TextureSlots MakeAbsolute(TextureSlots source, string outputRoot) => new()
    {
        Base = Absolute(outputRoot, source.Base),
        Normal = Absolute(outputRoot, source.Normal),
        Property = Absolute(outputRoot, source.Property),
        Rd = Absolute(outputRoot, source.Rd),
        Rs = Absolute(outputRoot, source.Rs),
        Lut = Absolute(outputRoot, source.Lut),
        Sdf = Absolute(outputRoot, source.Sdf),
        St = Absolute(outputRoot, source.St),
        ColorMask = Absolute(outputRoot, source.ColorMask),
        LipSpecular = Absolute(outputRoot, source.LipSpecular),
        HairLine = Absolute(outputRoot, source.HairLine),
        MatCaps = source.MatCaps.ToDictionary(pair => pair.Key, pair => Absolute(outputRoot, pair.Value))
    };

    private static string? Absolute(string outputRoot, string? relativePath)
        => string.IsNullOrWhiteSpace(relativePath)
            ? null
            : Path.Combine(outputRoot, relativePath.Replace('/', Path.DirectorySeparatorChar));

    private static Dictionary<int, TextureSlots> CopyTextures(StudioProject project, string staging, ICollection<string> generated)
    {
        var result = new Dictionary<int, TextureSlots>();
        var dedupe = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        foreach (var material in project.Materials.Where(material => material.Enabled))
        {
            var source = material.Textures;
            var packaged = new TextureSlots();
            packaged.Base = Copy("base", material.UsePmxBaseTexture ? material.PmxBaseTexture : source.Base);
            if (project.RuntimeKind == ShaderRuntimeKind.ZzzMme)
            {
                if (material.Role == MaterialRole.Face)
                    packaged.Sdf = Copy("sdf", source.Sdf);
                else if (material.Role is MaterialRole.Hair or MaterialRole.Skin or MaterialRole.Cloth)
                {
                    packaged.Normal = Copy("normal", source.Normal);
                    packaged.Property = Copy("property", source.Property);
                    packaged.Rs = Copy("attribute", source.Rs);
                    for (var slot = 1; slot <= 5; slot++)
                    {
                        var binding = material.Zzz.GetMatCap(slot);
                        packaged.MatCaps[slot] = Copy($"matcap_{slot}", binding.EffectiveTexturePath);
                    }
                }
            }
            else
            {
                packaged.Normal = Copy("normal", source.Normal);
                packaged.Property = Copy("property", source.Property);
                packaged.Rd = Copy("rd", source.Rd);
                packaged.Rs = Copy("rs", source.Rs);
                packaged.Lut = Copy("lut", source.Lut);
                packaged.Sdf = Copy("sdf", source.Sdf);
                packaged.St = Copy("st", source.St);
                packaged.ColorMask = Copy("color_mask", source.ColorMask);
                packaged.LipSpecular = Copy("lip_specular", source.LipSpecular);
                packaged.HairLine = Copy("hair_line", source.HairLine);
                for (var slot = 1; slot <= 5; slot++)
                {
                    var binding = material.Zzz.GetMatCap(slot);
                    packaged.MatCaps[slot] = Copy($"matcap_{slot}", binding.EffectiveTexturePath);
                }
            }
            result[material.MaterialIndex] = packaged;

            string? Copy(string slot, string? path)
            {
                if (string.IsNullOrWhiteSpace(path) || !File.Exists(path)) return null;
                var hash = Convert.ToHexString(SHA256.HashData(File.ReadAllBytes(path)));
                if (dedupe.TryGetValue(hash, out var existing)) return existing;
                var extension = Path.GetExtension(path).ToLowerInvariant();
                if (string.IsNullOrWhiteSpace(extension)) extension = ".png";
                var relative = Path.Combine("textures", "character", $"m{material.MaterialIndex:000}_{slot}{extension}").Replace('\\', '/');
                var destination = Path.Combine(staging, relative.Replace('/', Path.DirectorySeparatorChar));
                Directory.CreateDirectory(Path.GetDirectoryName(destination)!);
                File.Copy(path, destination, true);
                generated.Add(destination);
                dedupe[hash] = relative;
                return relative;
            }
        }
        return result;
    }

    private static string BuildReport(
        StudioProject project,
        string modelPath,
        IReadOnlyDictionary<int, string> materialFxPaths)
    {
        var lines = new List<string>
        {
            "ZZZ Material Studio 材质映射",
            $"PMX: Model/{Path.GetFileName(modelPath)}",
            $"运行时: {RuntimeContract.DisplayName(project.RuntimeKind)}",
            $"眼透: {(project.EnableEyeThrough ? "开启" : "关闭")}",
            "工作流: 每个 PMX 材质一个独立 FX（EMM 仅为可选快捷映射）",
            string.Empty,
            "手动上材质:",
            "1. 在 MMD 加载 Model 文件夹中的 PMX。",
            "2. 在 MME 的材质/Effect 分配窗口，按下表为对应材质选择 FX。"
        };
        if (project.RuntimeKind == ShaderRuntimeKind.ZzzMme)
        {
            lines.Add("3. 加载 ZZZshadow/ZZZshadow.x，阴影 RT 会自动覆盖角色。");
            lines.Add("4. 启用眼透时加载 ZZZEyeThrough/ZZZEyeThrough.x；正式 ZZZ Capture 直接使用原 PMX，不生成派生覆盖材质。");
            lines.Add("5. 需要后处理时加载 ZZZPost/ZZZPost.x。");
        }
        else
        {
            lines.Add("3. 加载 ZMDshadow.x 后，PMD/PMX 会自动进入阴影 RT。");
            lines.Add("4. 启用眼透时加载 EndfieldEyeThrough.x，旧运行时会生成派 PMX。");
        }
        lines.Add("6. 自动生成的 EMM 是完整快捷入口；单个 FX 仍可手动分配。");
        lines.Add(string.Empty);
        lines.AddRange(project.Materials.OrderBy(material => material.MaterialIndex)
            .Select(material =>
            {
                var fx = materialFxPaths.TryGetValue(material.MaterialIndex, out var path)
                    ? Path.GetFileName(path)
                    : "（不生成 FX）";
                var state = material.Enabled ? "启用" : "停用";
                return $"#{material.MaterialIndex} {material.MaterialName} -> {material.Role} [{state}] -> {fx}";
            }));
        lines.Add(string.Empty);
        lines.Add("说明: material-map.json 是机器可读的完整映射清单；生成的快捷 EMM 可能受 MMD 对象槽位影响，失败时请按本表手动分配。 ");
        return string.Join(Environment.NewLine, lines) + Environment.NewLine;
    }

    private static void Commit(string staging, string outputRoot)
    {
        var backup = outputRoot + ".backup_" + Guid.NewGuid().ToString("N");
        try
        {
            if (Directory.Exists(outputRoot)) Directory.Move(outputRoot, backup);
            Directory.Move(staging, outputRoot);
            if (Directory.Exists(backup)) Directory.Delete(backup, true);
        }
        catch
        {
            if (!Directory.Exists(outputRoot) && Directory.Exists(backup)) Directory.Move(backup, outputRoot);
            throw;
        }
    }

    private static StudioProject Clone(StudioProject project) => new()
    {
        SchemaVersion = project.SchemaVersion,
        ProjectName = project.ProjectName,
        PmxPath = project.PmxPath,
        RuntimeRoot = project.RuntimeRoot,
        RuntimeKind = project.RuntimeKind,
        OutputDirectory = project.OutputDirectory,
        OfficialJsonRoot = project.OfficialJsonRoot,
        ControllerRoot = project.ControllerRoot,
        ShaderFamily = project.ShaderFamily,
        PreferManualMatCap = project.PreferManualMatCap,
        ControllerFiles = project.ControllerFiles.ToList(),
        ControllerBindings = project.ControllerBindings.Select(binding => binding.Clone()).ToList(),
        HeadBone = project.HeadBone,
        EnableEyeThrough = project.EnableEyeThrough,
        GenerateDerivedPmx = project.GenerateDerivedPmx,
        Materials = project.Materials.Select(material => new MaterialAssignment
        {
            MaterialIndex = material.MaterialIndex,
            MaterialName = material.MaterialName,
            EnglishName = material.EnglishName,
            Role = material.Role,
            UsePmxBaseTexture = material.UsePmxBaseTexture,
            PmxBaseTexture = material.PmxBaseTexture,
            Textures = Clone(material.Textures),
            Zzz = material.Zzz.Clone()
        }).ToList()
    };

    private static TextureSlots Clone(TextureSlots source) => new()
    {
        Base = source.Base,
        Normal = source.Normal,
        Property = source.Property,
        Rd = source.Rd,
        Rs = source.Rs,
        Lut = source.Lut,
        Sdf = source.Sdf,
        St = source.St,
        ColorMask = source.ColorMask,
        LipSpecular = source.LipSpecular,
        HairLine = source.HairLine,
        MatCaps = source.MatCaps.ToDictionary(pair => pair.Key, pair => pair.Value)
    };
}
