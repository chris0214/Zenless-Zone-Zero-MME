using System.Text;
using EndfieldMaterialStudio.Core;

Encoding.RegisterProvider(CodePagesEncodingProvider.Instance);

var repositoryRoot = FindRepositoryRoot();
var runtime = Environment.GetEnvironmentVariable("ENDFIELD_MME_RUNTIME") ?? Path.Combine(repositoryRoot, "EndfieldMME");
var hasLegacyRuntime = Directory.Exists(runtime) &&
                       RuntimeContract.Detect(runtime) == ShaderRuntimeKind.LegacyEndfield;

if (hasLegacyRuntime)
{
    foreach (var message in RuntimeContract.Validate(runtime)) Console.WriteLine(message);
    Assert(RuntimeContract.Validate(runtime).All(message => !message.IsError), "EndfieldMME 运行时不完整");
}
else
{
    Console.WriteLine("LEGACY_RUNTIME_TESTS_SKIPPED: 独立开源包未包含 EndfieldMME。");
}
RunTemplateSmokeTests();
RunZzzAcceptedMaterialTemplateSmokeTests();
RunZzzCharacterClassificationSmokeTests();
if (hasLegacyRuntime) RunRuntimeCopySmokeTest();
RunZzzRuntimeContractSmokeTest();
RunZzzCharacterPackageSmokeTests();
RunOfficialJsonSmokeTests();
if (hasLegacyRuntime) RunControllerEmmSmokeTest();
RunZzzControllerEmmSmokeTest();
RunZzzControllerMigrationSmokeTest();
Console.WriteLine("PORTABLE_TESTS_PASSED");

var pmx = Environment.GetEnvironmentVariable("ENDFIELD_TEST_PMX");
if (string.IsNullOrWhiteSpace(pmx))
{
    Console.WriteLine("INTEGRATION_TEST_SKIPPED: set ENDFIELD_TEST_PMX to a locally licensed PMX for the optional package test.");
    return;
}

pmx = Path.GetFullPath(pmx);
if (!hasLegacyRuntime)
{
    Console.WriteLine("LEGACY_INTEGRATION_TEST_SKIPPED: 当前可选 PMX 集成测试仍属于旧 Endfield Runtime。");
    return;
}
var output = args.Length > 0
    ? Path.GetFullPath(args[0])
    : Path.Combine(Path.GetTempPath(), "EndfieldMaterialStudio_GenericPackageTest");
var project = ProjectFactory.Create(pmx, runtime, output);
project.ProjectName = args.Length > 1 ? ProjectFactory.SanitizeProjectName(args[1]) : "Generic_Endfield_Test";
project.EnableEyeThrough = false;
project.GenerateDerivedPmx = false;
foreach (var material in project.Materials) material.Role = MaterialRole.None;

var validation = ProjectValidator.Validate(project);
foreach (var message in validation) Console.WriteLine(message);
Assert(validation.All(message => !message.IsError), "通用 PMX 工程预检查失败");

var result = new PackageBuilder().Build(project);
Assert(File.Exists(result.ModelPath), "通用角色包缺少 PMX");
Assert(File.Exists(result.EmmPath), "通用角色包缺少 EMM");
Assert(File.Exists(Path.Combine(result.OutputDirectory, "internal", "endfield_shader.hlsl")),
    "通用角色包缺少 Shader 运行时");
Assert(File.Exists(Path.Combine(result.OutputDirectory, "EndfieldHairVisibility_Capture.fxsub")),
    "通用角色包缺少头发可见性 Capture");
Assert(File.ReadAllBytes(Path.Combine(result.OutputDirectory, "ZMDshadow.fx"))
    .SequenceEqual(File.ReadAllBytes(Path.Combine(runtime, "ZMDshadow.fx"))),
    "输出包改写了权威 ZMDshadow.fx");
Console.WriteLine("GENERIC_PACKAGE_TEST_PASSED");

void RunTemplateSmokeTests()
{
    var slots = new TextureSlots
    {
        Base = "textures/character/base.png",
        Normal = "textures/character/normal.png",
        Property = "textures/character/property.png",
        Rd = "textures/common/rd.png",
        Rs = "textures/common/rs.png",
        Lut = "textures/common/lut.png",
        Sdf = "textures/character/sdf.png",
        St = "textures/common/st.png",
        ColorMask = "textures/character/color_mask.png",
        LipSpecular = "textures/character/lip_specular.png",
        HairLine = "textures/common/hair_line.png"
    };
    var roles = new[]
    {
        MaterialRole.Face,
        MaterialRole.Iris,
        MaterialRole.EyeHighlight,
        MaterialRole.EyeWhite,
        MaterialRole.BrowLash,
        MaterialRole.Mouth,
        MaterialRole.Hair,
        MaterialRole.Skin,
        MaterialRole.Cloth,
        MaterialRole.EyeOverlay,
        MaterialRole.BrowOverlay,
        MaterialRole.Hidden
    };

    foreach (var role in roles)
    {
        var bytes = FxTemplateEngine.BuildMaterialFx(
            new MaterialAssignment { MaterialIndex = (int)role, MaterialName = role.ToString(), Role = role },
            slots,
            "頭",
            "endfield_generated_face_binding.cp932",
            $"generated_json_profiles/Material_{(int)role:000}_ZZZ.inc");
        var text = Decode(bytes);
        AssertGeneratedText(text, $"{role} FX");
        Assert(text.StartsWith("#include \"generated_json_profiles/", StringComparison.Ordinal),
            $"{role} FX 没有包含对应 ZZZ Profile");
    }

    var zzzCloth = Decode(FxTemplateEngine.BuildMaterialFx(
        new MaterialAssignment { MaterialIndex = 37, MaterialName = "Body_1", Role = MaterialRole.Cloth },
        slots,
        "頭",
        "unused.cp932",
        "generated_json_profiles/Material_037_ZZZ.inc",
        ShaderRuntimeKind.ZzzMme));
    Assert(zzzCloth.StartsWith("#include \"generated_json_profiles/Material_037_ZZZ.inc\"", StringComparison.Ordinal),
        "正式 ZZZ Cloth 没有包含当前材质 Profile");
    Assert(zzzCloth.Contains("#define ZZZ_CLOTH_MATERIAL_RESOURCE \"textures/character/property.png\"", StringComparison.Ordinal),
        "正式 ZZZ Cloth 没有把 Property 槽映射到官方 M 贴图");
    Assert(zzzCloth.Contains("#define ZZZ_CLOTH_AUX_RESOURCE \"textures/common/rs.png\"", StringComparison.Ordinal),
        "正式 ZZZ Cloth 没有把 RS 槽映射到官方 A 贴图");
    Assert(zzzCloth.Contains("\"37\", true, true", StringComparison.Ordinal),
        "正式 ZZZ Cloth 没有生成当前 PMX 材质索引的 object_ss 入口");
    Assert(zzzCloth.Contains("internal/zzz_cloth_runtime.hlsl", StringComparison.Ordinal),
        "正式 ZZZ Cloth 没有复用已验收五槽 Runtime");

    var zzzHairMaterial = new MaterialAssignment
    {
        MaterialIndex = 13,
        MaterialName = "Hair",
        Role = MaterialRole.Hair,
        Zzz = new ZzzMaterialProfile
        {
            HairHighlightSlot = 2,
            HairHighlightGain = 10.0,
            HairCenterPower = 7.0
        }
    };
    var zzzHair = Decode(FxTemplateEngine.BuildMaterialFx(
        zzzHairMaterial,
        slots,
        "頭",
        "unused.cp932",
        "generated_json_profiles/Material_013_ZZZ.inc",
        ShaderRuntimeKind.ZzzMme));
    Assert(zzzHair.Contains("#define ZZZ_HAIR_HIGHLIGHT_SHAPE_2 1.0", StringComparison.Ordinal),
        "正式 ZZZ Hair 没有保留每角色高光材质槽");
    Assert(zzzHair.Contains("#define ZZZ_HAIR_COMPOSITE_GAIN_OVERRIDE 10.0", StringComparison.Ordinal),
        "正式 ZZZ Hair 高光增益默认值不是已验收的 10");
    Assert(zzzHair.Contains("#define ZZZ_HAIR_SUBSET \"13\"", StringComparison.Ordinal),
        "正式 ZZZ Hair 没有生成当前 PMX 材质索引");
    Assert(zzzHair.Contains("internal/zzz_hair_runtime.hlsl", StringComparison.Ordinal),
        "正式 ZZZ Hair 没有复用已验收 Hair Runtime");

    var captureProject = new StudioProject
    {
        HeadBone = "頭",
        Materials = new List<MaterialAssignment>
        {
            Material(0, MaterialRole.Face),
            Material(1, MaterialRole.Iris),
            Material(2, MaterialRole.EyeHighlight),
            Material(3, MaterialRole.EyeWhite),
            Material(4, MaterialRole.BrowLash),
            Material(5, MaterialRole.Hair),
            Material(6, MaterialRole.FaceProxy),
            Material(7, MaterialRole.EyeOverlay),
            Material(8, MaterialRole.BrowOverlay)
        }
    };
    AssertGeneratedText(FxTemplateEngine.BuildEyeCapture(captureProject, slots, captureProject.HeadBone), "EyeThrough Capture");
    var hairVisibility = FxTemplateEngine.BuildHairVisibilityCapture(captureProject);
    AssertGeneratedText(hairVisibility, "Hair Visibility Capture");
    Assert(hairVisibility.Contains("#define EF_HAIR_VISIBILITY_SUBSETS \"5\"", StringComparison.Ordinal),
        "Hair Visibility Capture 没有使用 Hair 材质索引");
    Assert(hairVisibility.Contains(
            "#define EF_HAIR_VISIBILITY_FACE_OCCLUDER_SUBSETS \"0,1,3\"",
            StringComparison.Ordinal),
        "Hair Visibility Capture 没有使用 Face/Iris/EyeWhite 遮挡索引");
}

void RunRuntimeCopySmokeTest()
{
    var output = Path.Combine(Path.GetTempPath(), "EndfieldRuntimeContract_" + Guid.NewGuid().ToString("N"));
    try
    {
        var copied = RuntimeContract.CopyRuntime(runtime, output);
        Assert(copied.Count > 0, "运行时复制没有产生文件");
        Assert(File.Exists(Path.Combine(output, "EndfieldEyeThrough.fx")), "运行时复制缺少眼透入口");
        Assert(File.Exists(Path.Combine(output, "EndfieldHairVisibility_Capture.fxsub")),
            "运行时复制缺少头发可见性 Capture");
        Assert(File.Exists(Path.Combine(output, "ZMDshadow.fx")), "运行时复制缺少阴影入口");
        Assert(File.Exists(Path.Combine(output, "EndfieldPost.fx")), "运行时复制缺少后处理入口");
        Assert(File.ReadAllBytes(Path.Combine(output, "ZMDshadow.fx"))
            .SequenceEqual(File.ReadAllBytes(Path.Combine(runtime, "ZMDshadow.fx"))), "运行时复制阶段不应改写 ZMDshadow.fx");
        var shaderCore = File.ReadAllText(Path.Combine(output, "internal", "endfield_shader.hlsl"));
        Assert(shaderCore.Contains("EF_HAIR_FACE_SHADOW_SINGLE_BLEND_MASK", StringComparison.Ordinal),
            "运行时 Shader 缺少发影单次混合锁");
        Assert(shaderCore.Contains("StencilPass = INVERT", StringComparison.Ordinal),
            "运行时 Shader 没有阻止重叠发片重复叠色");
        Assert(!Directory.Exists(Path.Combine(output, "tools")), "运行时复制不应包含开发工具");
    }
    finally
    {
        if (Directory.Exists(output)) Directory.Delete(output, true);
    }
}

void RunZzzAcceptedMaterialTemplateSmokeTests()
{
    var slots = new TextureSlots
    {
        Base = "textures/character/base.png",
        Normal = "textures/character/body_n.png",
        Property = "textures/character/body_m.png",
        Rs = "textures/character/body_a.png",
        Sdf = "textures/character/face_lightmap.png"
    };

    var face = DecodeCp936(FxTemplateEngine.BuildMaterialFx(
        new MaterialAssignment { MaterialIndex = 21, MaterialName = "Face", Role = MaterialRole.Face },
        slots,
        "头",
        "unused.cp932",
        "generated_json_profiles/Material_021_ZZZ.inc",
        ShaderRuntimeKind.ZzzMme));
    Assert(face.Contains("#define ZZZ_FACE_DIFFUSE_RESOURCE \"textures/character/base.png\"", StringComparison.Ordinal),
        "ZZZ Face 没有参数化基础贴图");
    Assert(face.Contains("#define ZZZ_FACE_LIGHT_RESOURCE \"textures/character/face_lightmap.png\"", StringComparison.Ordinal),
        "ZZZ Face 没有参数化 FaceLight/SDF");
    Assert(face.Contains("#define ZZZ_FACE_HEAD_BONE \"头\"", StringComparison.Ordinal) &&
           face.Contains("string Subset = \"21\";", StringComparison.Ordinal),
        "ZZZ Face 没有参数化头骨或 Subset");
    Assert(face.Contains("#include \"zzz_face_skin_ramp_shared.hlsl\"", StringComparison.Ordinal),
        "ZZZ Face 脱离了验收的 Face/Skin 共享 Ramp");

    var skin = DecodeCp936(FxTemplateEngine.BuildMaterialFx(
        new MaterialAssignment { MaterialIndex = 22, MaterialName = "Skin", Role = MaterialRole.Skin },
        slots,
        "头",
        "unused.cp932",
        "generated_json_profiles/Material_022_ZZZ.inc",
        ShaderRuntimeKind.ZzzMme));
    Assert(CountOccurrences(skin, "string ResourceName = \"textures/character/body_n.png\";") == 2 &&
           CountOccurrences(skin, "string ResourceName = \"textures/character/body_m.png\";") == 2 &&
           CountOccurrences(skin, "string ResourceName = \"textures/character/body_a.png\";") == 2,
        "ZZZ Skin 没有将 Map1/Map2 收束为当前材质的 N/M/A");
    Assert(CountOccurrences(skin, "\"22\"") == 4,
        "ZZZ Skin 没有生成单材质 Subset 入口");
    Assert(!skin.Contains("Unagi_Body_", StringComparison.Ordinal),
        "ZZZ Skin 仍引用 Miyabi 专用贴图");

    var eyeBase = DecodeCp936(FxTemplateEngine.BuildMaterialFx(
        new MaterialAssignment { MaterialIndex = 3, MaterialName = "Iris", Role = MaterialRole.Iris },
        slots,
        "头",
        "unused.cp932",
        "generated_json_profiles/Material_003_ZZZ.inc",
        ShaderRuntimeKind.ZzzMme));
    Assert(eyeBase.Contains("#define ZZZ_EYE_DIFFUSE_RESOURCE \"textures/character/base.png\"", StringComparison.Ordinal) &&
           eyeBase.Contains("string Subset = \"3\";", StringComparison.Ordinal),
        "ZZZ Eye01 没有参数化贴图或 Subset");

    foreach (var (role, index, variant) in new[]
             {
                 (MaterialRole.BrowLash, 4, "Lash"),
                 (MaterialRole.EyeOverlay, 7, "Inner"),
                 (MaterialRole.EyeHighlight, 8, "Highlight"),
                 (MaterialRole.BrowOverlay, 9, "Shadow")
             })
    {
        var overlay = DecodeCp936(FxTemplateEngine.BuildMaterialFx(
            new MaterialAssignment { MaterialIndex = index, MaterialName = variant, Role = role },
            slots,
            "头",
            "unused.cp932",
            $"generated_json_profiles/Material_{index:000}_ZZZ.inc",
            ShaderRuntimeKind.ZzzMme));
        Assert(overlay.Contains($"ZzzEye{variant}_{index:000}Object", StringComparison.Ordinal) &&
               overlay.Contains($"\"{index}\", true", StringComparison.Ordinal),
            $"ZZZ Eye02 {variant} 没有生成独立 Subset 分支");
        Assert(CountOccurrences(overlay, "ZZZ_EYE_OVERLAY_TECHNIQUE(") == 3,
            $"ZZZ Eye02 {variant} 混入了其他材质分支");
        var expectedZWrite = role == MaterialRole.EyeOverlay ? "false" : "true";
        Assert(CountOccurrences(
                   overlay,
                   $"{variant}VS, ZzzEye{variant}PS, {expectedZWrite},") == 2,
            $"ZZZ Eye02 {variant} 深度写入状态回退");
        if (role == MaterialRole.EyeOverlay)
            Assert(overlay.Contains("> = 9.0;", StringComparison.Ordinal), "瞳内光默认亮度不是验收的 9");
    }

    var forcedHighlightNoWrite = DecodeCp936(FxTemplateEngine.BuildMaterialFx(
        new MaterialAssignment
        {
            MaterialIndex = 18,
            MaterialName = "Highlight no write",
            Role = MaterialRole.EyeHighlight,
            ZWriteOverride = false
        },
        slots,
        "头",
        "unused.cp932",
        "generated_json_profiles/Material_018_ZZZ.inc",
        ShaderRuntimeKind.ZzzMme));
    Assert(CountOccurrences(forcedHighlightNoWrite, "ZzzEyeHighlightPS, false,") == 2,
        "ZZZ Eye02 GUI ZWrite=false 覆盖没有生效");

    var forcedInnerWrite = DecodeCp936(FxTemplateEngine.BuildMaterialFx(
        new MaterialAssignment
        {
            MaterialIndex = 19,
            MaterialName = "Inner write",
            Role = MaterialRole.EyeOverlay,
            ZWriteOverride = true
        },
        slots,
        "头",
        "unused.cp932",
        "generated_json_profiles/Material_019_ZZZ.inc",
        ShaderRuntimeKind.ZzzMme));
    Assert(CountOccurrences(forcedInnerWrite, "ZzzEyeInnerPS, true,") == 2,
        "ZZZ Eye02 GUI ZWrite=true 覆盖没有生效");

    var zWriteProjectPath = Path.Combine(Path.GetTempPath(), $"ZZZ_ZWrite_{Guid.NewGuid():N}.zzzstudio.json");
    try
    {
        ProjectFactory.Save(new StudioProject
        {
            Materials =
            [
                new MaterialAssignment
                {
                    MaterialIndex = 8,
                    MaterialName = "Highlight override",
                    Role = MaterialRole.EyeHighlight,
                    ZWriteOverride = false
                }
            ]
        }, zWriteProjectPath);
        var loadedZWriteProject = ProjectFactory.Load(zWriteProjectPath);
        Assert(loadedZWriteProject.Materials.Single().ZWriteOverride == false,
            "工程 JSON 没有保存或恢复 ZWrite 覆盖");
    }
    finally
    {
        if (File.Exists(zWriteProjectPath)) File.Delete(zWriteProjectPath);
    }

    var captureProject = new StudioProject
    {
        RuntimeKind = ShaderRuntimeKind.ZzzMme,
        HeadBone = "头",
        Materials = new List<MaterialAssignment>
        {
            NamedMaterial(0, "面", MaterialRole.Face),
            NamedMaterial(1, "白目", MaterialRole.EyeWhite),
            NamedMaterial(2, "瞳", MaterialRole.Iris),
            NamedMaterial(3, "瞳心", MaterialRole.Iris),
            NamedMaterial(4, "睫", MaterialRole.BrowLash),
            NamedMaterial(5, "眉", MaterialRole.BrowLash),
            NamedMaterial(6, "二重", MaterialRole.BrowLash),
            NamedMaterial(7, "瞳内光", MaterialRole.EyeOverlay),
            NamedMaterial(8, "瞳外光", MaterialRole.EyeHighlight),
            NamedMaterial(9, "目影", MaterialRole.BrowOverlay),
            NamedMaterial(10, "齿", MaterialRole.Mouth),
            NamedMaterial(11, "舌", MaterialRole.Mouth),
            NamedMaterial(12, "口", MaterialRole.Mouth),
            NamedMaterial(13, "发", MaterialRole.Hair),
            NamedMaterial(14, "饰", MaterialRole.Cloth),
            NamedMaterial(15, "肌", MaterialRole.Skin),
            NamedMaterial(16, "黑丝", MaterialRole.Cloth),
            NamedMaterial(17, "服", MaterialRole.Cloth)
        }
    };
    var capture = FxTemplateEngine.BuildEyeCapture(
        captureProject,
        new TextureSlots { Base = "textures/character/m000_base.png" },
        captureProject.HeadBone,
        ShaderRuntimeKind.ZzzMme);
    foreach (var expected in new[]
             {
                 "#define ZZZ_EYE_THROUGH_EYE_SUBSETS \"2,3\"",
                 "#define ZZZ_EYE_THROUGH_OVERLAY_SUBSETS \"4,7,9\"",
                 "#define ZZZ_EYE_THROUGH_HIGHLIGHT_SUBSETS \"8\"",
                 "#define ZZZ_EYE_THROUGH_SCLERA_SUBSETS \"2147483647\"",
                 "#define ZZZ_EYE_THROUGH_BROW_SUBSETS \"5,6\"",
                 "#define ZZZ_EYE_THROUGH_IGNORED_SUBSETS \"10,11,12,14,15,16,17\"",
                 "#define ZZZ_EYE_THROUGH_HAIR_DEPTH_SUBSETS \"13\"",
                 "#define ZZZ_EYE_THROUGH_SHIFTED_SUBSETS \"2147483647\"",
                 "#define ZZZ_EYE_THROUGH_FACE_RESOURCE \"../textures/character/m000_base.png\""
             })
        Assert(capture.Contains(expected, StringComparison.Ordinal), $"ZZZ EyeThrough Capture 缺少验收定义：{expected}");

    var hairMask = FxTemplateEngine.BuildZzzEyeHairMask(captureProject);
    Assert(hairMask.Contains("string Subset = \"13\";", StringComparison.Ordinal) &&
           hairMask.Contains("string Subset = \"0\";", StringComparison.Ordinal),
        "ZZZ EyeThrough HairMask 没有生成头发/面部 Subset");

    Assert(MaterialClassifier.Suggest(new PmxMaterialInfo { Name = "白目" }) == MaterialRole.EyeWhite,
        "ZZZ 白目材质分类错误");
    Assert(MaterialClassifier.Suggest(new PmxMaterialInfo { Name = "瞳内光" }) == MaterialRole.EyeOverlay,
        "ZZZ 瞳内光材质分类错误");
    Assert(MaterialClassifier.Suggest(new PmxMaterialInfo { Name = "瞳外光" }) == MaterialRole.EyeHighlight,
        "ZZZ 瞳外光材质分类错误");
    Assert(MaterialClassifier.Suggest(new PmxMaterialInfo { Name = "目影" }) == MaterialRole.BrowOverlay,
        "ZZZ 目影材质分类错误");
    Console.WriteLine("ZZZ_ACCEPTED_MATERIAL_TEMPLATES_PASSED");
}

void RunZzzRuntimeContractSmokeTest()
{
    var zzzRuntime = FindZzzRuntime(repositoryRoot);
    if (zzzRuntime is null)
    {
        Console.WriteLine("ZZZ_RUNTIME_TEST_SKIPPED: 未找到 ZZZ_MME。 ");
        return;
    }

    Assert(RuntimeContract.Detect(zzzRuntime) == ShaderRuntimeKind.ZzzMme,
        "ZZZ_MME 运行时类型识别错误");
    var validation = RuntimeContract.Validate(zzzRuntime, ShaderRuntimeKind.ZzzMme);
    foreach (var message in validation) Console.WriteLine(message);
    Assert(validation.All(message => !message.IsError), "ZZZ_MME 核心运行时不完整");

    var output = Path.Combine(Path.GetTempPath(), "ZzzRuntimeContract_" + Guid.NewGuid().ToString("N"));
    try
    {
        var copied = RuntimeContract.CopyRuntime(zzzRuntime, output, ShaderRuntimeKind.ZzzMme);
        Assert(copied.Count > 0, "ZZZ 运行时复制没有产生文件");
        Assert(File.Exists(Path.Combine(output, "internal", "zzz_cloth_runtime.hlsl")),
            "ZZZ 运行时复制缺少五槽 Cloth Runtime");
        Assert(File.Exists(Path.Combine(output, "internal", "zzz_hair_zzzshadow_rim.hlsl")),
            "ZZZ 运行时复制缺少头发边缘光 include");
        Assert(File.Exists(Path.Combine(output, "internal", "zzz_cloth_matcap_controls.inc")) &&
               File.Exists(Path.Combine(output, "internal", "zzz_face_skin_controls.inc")) &&
               File.Exists(Path.Combine(output, "internal", "zzz_eye_controls.inc")),
            "ZZZ 运行时复制缺少正式控制器接线 include");
        foreach (var name in new[]
        {
            "zzz_cloth_matcap_controls.inc",
            "zzz_decode.hlsl",
            "zzz_hair_controls.inc",
            "zzz_hair_zzzshadow_rim.hlsl",
            "zzz_hgsao_contract.hlsl",
            "zzz_hgshadow_bridge.hlsl"
        })
        {
            Assert(File.Exists(Path.Combine(output, name)),
                $"MME 根目录 include 兼容副本缺失：{name}");
        }
        Assert(File.Exists(Path.Combine(output, "zzz_face_skin_ramp_shared.hlsl")),
            "ZZZ 运行时复制缺少 Face/Skin 共享 Ramp");
        Assert(!File.Exists(Path.Combine(output, "ZZZ_Hair.fx")) &&
               !File.Exists(Path.Combine(output, "ZZZ_EyeThrough.fx")),
            "ZZZ 运行时复制仍夹带废弃的顶层角色原型");
        var normalizedHair = Decode(File.ReadAllBytes(Path.Combine(output, "internal", "zzz_hair_runtime.hlsl")));
        Assert(normalizedHair.Contains("#ifndef ZZZ_NORMAL_RESOURCE", StringComparison.Ordinal) &&
                normalizedHair.Contains("string Subset = ZZZ_HAIR_SUBSET;", StringComparison.Ordinal) &&
               normalizedHair.Contains(
                   "#include \"zzz_hair_controls.inc\"",
                   StringComparison.Ordinal) &&
               normalizedHair.Contains(
                   "#include \"zzz_hair_zzzshadow_rim.hlsl\"",
                   StringComparison.Ordinal),
            "ZZZ 运行时复制没有把已验收 Hair Runtime 参数化");
        var normalizedCaptureCore = File.ReadAllText(Path.Combine(
            output,
            "internal",
            "zzz_eye_through_capture_core.fxsub"));
        Assert(normalizedCaptureCore.Contains("#ifndef ZZZ_EYE_THROUGH_FACE_RESOURCE", StringComparison.Ordinal) &&
               normalizedCaptureCore.Contains("string ResourceName = ZZZ_EYE_THROUGH_FACE_RESOURCE;", StringComparison.Ordinal),
            "ZZZ 运行时复制没有参数化 EyeThrough 面部图集");
        Assert(!Directory.Exists(Path.Combine(output, "tools")) &&
               !Directory.Exists(Path.Combine(output, "build")) &&
               !Directory.Exists(Path.Combine(output, "docs")) &&
               !Directory.Exists(Path.Combine(output, "templates")),
            "ZZZ 运行时复制混入了开发目录");

        var postFx = Decode(File.ReadAllBytes(Path.Combine(output, "ZZZPost", "ZZZPost.fx")));
        Assert(System.Text.RegularExpressions.Regex.IsMatch(
                postFx,
                @"float\s+ZzzPostExposure\s*<.*?>\s*=\s*1\.0\s*;",
                System.Text.RegularExpressions.RegexOptions.Singleline),
            "ZZZPost 默认曝光不是中性值 1.0");
        Assert(System.Text.RegularExpressions.Regex.IsMatch(
                postFx,
                @"float\s+ZzzPostBloomIntensity\s*<.*?>\s*=\s*0\.0\s*;",
                System.Text.RegularExpressions.RegexOptions.Singleline),
            "ZZZPost 默认 Bloom 必须关闭，避免拖入附件后整张画面被抬白");
        Assert(postFx.Contains("return saturate(ZzzPostControlTonemap);", StringComparison.Ordinal),
            "ZZZPost GT Tonemap 必须由默认归零的控制器显式开启");

        var zzzProject = new StudioProject
        {
            RuntimeRoot = zzzRuntime,
            RuntimeKind = ShaderRuntimeKind.ZzzMme,
            ControllerRoot = Path.Combine(zzzRuntime, "controller"),
            ControllerFiles = ZzzControllerCatalog.CreateDefaultControllerFiles(ShaderRuntimeKind.ZzzMme),
            EnableEyeThrough = true
        };
        var futurePackageRoot = Path.Combine(output, "future-package");
        var zzzEmm = Encoding.GetEncoding(936).GetString(EmmWriter.Build(
            zzzProject,
            futurePackageRoot,
            zzzRuntime,
            "M:/package/model.pmx",
            new Dictionary<int, string>(),
            Path.Combine(zzzRuntime, "ZZZEyeThrough", "ZZZEyeThrough_Capture.fxsub")));
        Assert(zzzEmm.Contains("ZZZshadow\\ZZZshadow.x", StringComparison.Ordinal),
            "正式 ZZZ EMM 没有加载单一 ZZZshadow 附件");
        Assert(zzzEmm.Contains("ZZZPost\\ZZZPost.x", StringComparison.Ordinal),
            "正式 ZZZ EMM 没有加载 ZZZPost");
        Assert(zzzEmm.Contains("ZZZPost\\ZZZPost.fx", StringComparison.Ordinal),
            "正式 ZZZ EMM 没有绑定 ZZZPost 效果");
        Assert(zzzEmm.Contains("[Effect@ZZZ_EyeHairMask_RT]", StringComparison.Ordinal),
            "正式 ZZZ EMM 缺少远距离眼透 HairMask RT");
        Assert(zzzEmm.Contains("ZzzHair_controller.pmx", StringComparison.Ordinal) &&
               zzzEmm.Contains("ZzzPost_controller.pmx", StringComparison.Ordinal),
            "正式 ZZZ EMM 没有加载验收版头发/后处理控制器");
        Console.WriteLine("ZZZ_RUNTIME_TEST_PASSED");
    }
    finally
    {
        if (Directory.Exists(output)) Directory.Delete(output, true);
    }
}

void RunZzzCharacterClassificationSmokeTests()
{
    var workspaceRoot = Directory.GetParent(repositoryRoot)?.FullName;
    if (workspaceRoot is null)
    {
        Console.WriteLine("ZZZ_CHARACTER_CLASSIFICATION_TEST_SKIPPED: 找不到工作区根目录。");
        return;
    }

    var cases = new[]
    {
        new
        {
            Label = "Jane",
            PmxPath = Path.Combine(
                workspaceRoot,
                "JaneDoe_by_给你柠檬椰果养乐多你会跟我玩吗_7d08ac56e5bf84867eb11bac62e3ebea",
                "簡.pmx"),
            Roles = new[]
            {
                MaterialRole.Face,
                MaterialRole.EyeWhite,
                MaterialRole.BrowLash,
                MaterialRole.BrowLash,
                MaterialRole.BrowLash,
                MaterialRole.None,
                MaterialRole.None,
                MaterialRole.None,
                MaterialRole.Iris,
                MaterialRole.EyeOverlay,
                MaterialRole.EyeHighlight,
                MaterialRole.BrowOverlay,
                MaterialRole.Hair,
                MaterialRole.Hair,
                MaterialRole.Hair,
                MaterialRole.Skin,
                MaterialRole.Cloth,
                MaterialRole.Skin,
                MaterialRole.Cloth,
                MaterialRole.Cloth,
                MaterialRole.Cloth,
                MaterialRole.Skin,
                MaterialRole.Cloth
            }
        },
        new
        {
            Label = "Miyabi",
            PmxPath = Path.Combine(
                workspaceRoot,
                "Miyabi_by_给你柠檬椰果养乐多你会跟我玩吗_3ff9ba7accca4880848bfe72e6737105",
                "星見雅_配布用.pmx"),
            Roles = new[]
            {
                MaterialRole.Face,
                MaterialRole.EyeWhite,
                MaterialRole.Iris,
                MaterialRole.Iris,
                MaterialRole.BrowLash,
                MaterialRole.BrowLash,
                MaterialRole.BrowLash,
                MaterialRole.EyeOverlay,
                MaterialRole.EyeHighlight,
                MaterialRole.BrowOverlay,
                MaterialRole.None,
                MaterialRole.None,
                MaterialRole.None,
                MaterialRole.Hair,
                MaterialRole.Cloth,
                MaterialRole.Skin,
                MaterialRole.Cloth,
                MaterialRole.Cloth
            }
        },
        new
        {
            Label = "Burnice",
            PmxPath = Path.Combine(
                workspaceRoot,
                "Burnice_by_给你柠檬椰果养乐多你会跟我玩吗_739343681be35207c0d5801e7424787c",
                "柏尼思.pmx"),
            Roles = new[]
            {
                MaterialRole.Face,
                MaterialRole.EyeWhite,
                MaterialRole.Iris,
                MaterialRole.BrowLash,
                MaterialRole.BrowLash,
                MaterialRole.BrowLash,
                MaterialRole.EyeOverlay,
                MaterialRole.EyeHighlight,
                MaterialRole.BrowOverlay,
                MaterialRole.None,
                MaterialRole.None,
                MaterialRole.None,
                MaterialRole.Hair,
                MaterialRole.Hair,
                MaterialRole.Cloth,
                MaterialRole.Cloth,
                MaterialRole.Cloth,
                MaterialRole.Cloth,
                MaterialRole.Skin
            }
        }
    };

    var tested = 0;
    foreach (var testCase in cases)
    {
        if (!File.Exists(testCase.PmxPath))
        {
            Console.WriteLine($"ZZZ_CHARACTER_CLASSIFICATION_CASE_SKIPPED: {testCase.Label} PMX 不存在。");
            continue;
        }

        var model = PmxReader.Read(testCase.PmxPath);
        Assert(model.Materials.Count == testCase.Roles.Length,
            $"{testCase.Label} 材质数量变化：预期 {testCase.Roles.Length}，实际 {model.Materials.Count}");
        foreach (var material in model.Materials)
        {
            var actual = MaterialClassifier.Suggest(material);
            var expected = testCase.Roles[material.Index];
            Assert(actual == expected,
                $"{testCase.Label} #{material.Index} {material.Name} 分类错误：预期 {expected}，实际 {actual}");
        }
        tested++;
    }

    if (tested == 0)
    {
        Console.WriteLine("ZZZ_CHARACTER_CLASSIFICATION_TEST_SKIPPED: 未找到 Jane/Miyabi/Burnice 本地 PMX。");
        return;
    }

    Console.WriteLine($"ZZZ_CHARACTER_CLASSIFICATION_TEST_PASSED: {tested}/3");
}

void RunZzzCharacterPackageSmokeTests()
{
    var workspaceRoot = Directory.GetParent(repositoryRoot)?.FullName;
    var zzzRuntime = workspaceRoot is null ? string.Empty : Path.Combine(workspaceRoot, "ZZZ_MME");
    if (workspaceRoot is null || !Directory.Exists(zzzRuntime))
    {
        Console.WriteLine("ZZZ_CHARACTER_PACKAGE_TEST_SKIPPED: 找不到工作区或 ZZZ_MME。");
        return;
    }

    var cases = new[]
    {
        new
        {
            Label = "Jane",
            PmxPath = Path.Combine(
                workspaceRoot,
                "JaneDoe_by_给你柠檬椰果养乐多你会跟我玩吗_7d08ac56e5bf84867eb11bac62e3ebea",
                "簡.pmx"),
            CaptureDefinitions = new[]
            {
                "#define ZZZ_EYE_THROUGH_EYE_SUBSETS \"8\"",
                "#define ZZZ_EYE_THROUGH_OVERLAY_SUBSETS \"2,9,11\"",
                "#define ZZZ_EYE_THROUGH_HIGHLIGHT_SUBSETS \"10\"",
                "#define ZZZ_EYE_THROUGH_SCLERA_SUBSETS \"2147483647\"",
                "#define ZZZ_EYE_THROUGH_BROW_SUBSETS \"3,4\"",
                "#define ZZZ_EYE_THROUGH_IGNORED_SUBSETS \"5,6,7,15,16,17,18,19,20,21,22\"",
                "#define ZZZ_EYE_THROUGH_HAIR_DEPTH_SUBSETS \"12,13,14\"",
                "#define ZZZ_EYE_THROUGH_SHIFTED_SUBSETS \"2147483647\""
            },
            HairSubsets = "12,13,14"
        },
        new
        {
            Label = "Miyabi",
            PmxPath = Path.Combine(
                workspaceRoot,
                "Miyabi_by_给你柠檬椰果养乐多你会跟我玩吗_3ff9ba7accca4880848bfe72e6737105",
                "星見雅_配布用.pmx"),
            CaptureDefinitions = new[]
            {
                "#define ZZZ_EYE_THROUGH_EYE_SUBSETS \"2,3\"",
                "#define ZZZ_EYE_THROUGH_OVERLAY_SUBSETS \"4,7,9\"",
                "#define ZZZ_EYE_THROUGH_HIGHLIGHT_SUBSETS \"8\"",
                "#define ZZZ_EYE_THROUGH_SCLERA_SUBSETS \"2147483647\"",
                "#define ZZZ_EYE_THROUGH_BROW_SUBSETS \"5,6\"",
                "#define ZZZ_EYE_THROUGH_IGNORED_SUBSETS \"10,11,12,14,15,16,17\"",
                "#define ZZZ_EYE_THROUGH_HAIR_DEPTH_SUBSETS \"13\"",
                "#define ZZZ_EYE_THROUGH_SHIFTED_SUBSETS \"2147483647\""
            },
            HairSubsets = "13"
        },
        new
        {
            Label = "Burnice",
            PmxPath = Path.Combine(
                workspaceRoot,
                "Burnice_by_给你柠檬椰果养乐多你会跟我玩吗_739343681be35207c0d5801e7424787c",
                "柏尼思.pmx"),
            CaptureDefinitions = new[]
            {
                "#define ZZZ_EYE_THROUGH_EYE_SUBSETS \"2\"",
                "#define ZZZ_EYE_THROUGH_OVERLAY_SUBSETS \"3,6,8\"",
                "#define ZZZ_EYE_THROUGH_HIGHLIGHT_SUBSETS \"7\"",
                "#define ZZZ_EYE_THROUGH_SCLERA_SUBSETS \"2147483647\"",
                "#define ZZZ_EYE_THROUGH_BROW_SUBSETS \"4,5\"",
                "#define ZZZ_EYE_THROUGH_IGNORED_SUBSETS \"9,10,11,14,15,16,17,18\"",
                "#define ZZZ_EYE_THROUGH_HAIR_DEPTH_SUBSETS \"12,13\"",
                "#define ZZZ_EYE_THROUGH_SHIFTED_SUBSETS \"2147483647\""
            },
            HairSubsets = "12,13"
        }
    };

    var outputRoot = Path.Combine(Path.GetTempPath(), "ZzzCharacterPackage_" + Guid.NewGuid().ToString("N"));
    var tested = 0;
    try
    {
        foreach (var testCase in cases)
        {
            if (!File.Exists(testCase.PmxPath))
            {
                Console.WriteLine($"ZZZ_CHARACTER_PACKAGE_CASE_SKIPPED: {testCase.Label} PMX 不存在。");
                continue;
            }

            var project = ProjectFactory.Create(testCase.PmxPath, zzzRuntime, outputRoot);
            project.ProjectName = testCase.Label + "_PackageSmoke";
            project.EnableEyeThrough = true;
            project.GenerateDerivedPmx = true;
            var matchMessages = TextureAutoMatcher.Assign(
                project,
                overwriteExisting: true,
                Path.GetDirectoryName(testCase.PmxPath)!);
            Assert(matchMessages.Count == 0,
                $"{testCase.Label} 自动贴图匹配产生了诊断：{string.Join(" | ", matchMessages.Select(message => message.ToString()))}");

            var compatibilityMaterial = project.Materials.FirstOrDefault(material =>
                material.Enabled && File.Exists(material.PmxBaseTexture ?? material.Textures.Base));
            if (compatibilityMaterial is null)
                throw new InvalidOperationException($"{testCase.Label} 找不到兼容槽过滤探针贴图");
            var compatibilityTexture = compatibilityMaterial.PmxBaseTexture ?? compatibilityMaterial.Textures.Base!;
            compatibilityMaterial.Textures.Rd = compatibilityTexture;
            compatibilityMaterial.Textures.Lut = compatibilityTexture;
            compatibilityMaterial.Textures.St = compatibilityTexture;
            compatibilityMaterial.Textures.ColorMask = compatibilityTexture;
            compatibilityMaterial.Textures.LipSpecular = compatibilityTexture;
            compatibilityMaterial.Textures.HairLine = compatibilityTexture;

            var validation = ProjectValidator.Validate(project);
            Assert(validation.All(message => !message.IsError),
                $"{testCase.Label} 打包前验证失败：{string.Join(" | ", validation.Select(message => message.ToString()))}");

            var result = new PackageBuilder().Build(project);
            var packagedProjectPath = Directory.GetFiles(
                result.OutputDirectory, "*.zzzstudio.json", SearchOption.TopDirectoryOnly).Single();
            var packagedProject = ProjectFactory.Load(packagedProjectPath);
            var packagedCompatibilityMaterial = packagedProject.Materials.Single(material =>
                material.MaterialIndex == compatibilityMaterial.MaterialIndex);
            Assert(string.IsNullOrWhiteSpace(packagedCompatibilityMaterial.Textures.Rd) &&
                   string.IsNullOrWhiteSpace(packagedCompatibilityMaterial.Textures.Lut) &&
                   string.IsNullOrWhiteSpace(packagedCompatibilityMaterial.Textures.St) &&
                   string.IsNullOrWhiteSpace(packagedCompatibilityMaterial.Textures.ColorMask) &&
                   string.IsNullOrWhiteSpace(packagedCompatibilityMaterial.Textures.LipSpecular) &&
                   string.IsNullOrWhiteSpace(packagedCompatibilityMaterial.Textures.HairLine),
                $"{testCase.Label} ZZZ 角色包仍保留旧 Endfield 贴图槽");
            var emm = DecodeStrictCp936(File.ReadAllBytes(result.EmmPath));
            Assert(emm.Contains("Acs3 = ", StringComparison.Ordinal) &&
                   emm.Contains("ZZZPost\\ZZZPost.x", StringComparison.Ordinal) &&
                   emm.Contains("ZZZPost\\ZZZPost.fx", StringComparison.Ordinal),
                $"{testCase.Label} 正式角色包 EMM 没有加载 ZZZPost");
            Assert(Path.GetFileName(result.ModelPath) == Path.GetFileName(testCase.PmxPath),
                $"{testCase.Label} 正式 ZZZ 包改了 PMX 文件名");
            Assert(File.ReadAllBytes(result.ModelPath).SequenceEqual(File.ReadAllBytes(testCase.PmxPath)),
                $"{testCase.Label} 正式 ZZZ 包没有原字节复制 PMX");
            Assert(Directory.GetFiles(Path.Combine(result.OutputDirectory, "Model"), "*.pmx", SearchOption.TopDirectoryOnly).Length == 1,
                $"{testCase.Label} 正式 ZZZ 包仍生成了派生角色 PMX");

            var neutralMatCap = Path.Combine(
                result.OutputDirectory,
                ZzzProfileIncludeWriter.NeutralResource.Replace('/', Path.DirectorySeparatorChar));
            Assert(File.Exists(neutralMatCap),
                $"{testCase.Label} 正式 ZZZ 包缺少 BMP 中性 MatCap");
            var neutralMatCapBytes = File.ReadAllBytes(neutralMatCap);
            Assert(neutralMatCapBytes.Length >= 70 &&
                   neutralMatCapBytes[0] == (byte)'B' && neutralMatCapBytes[1] == (byte)'M',
                $"{testCase.Label} 中性 MatCap 扩展名与内容不一致");
            Assert(!File.Exists(Path.Combine(
                    result.OutputDirectory,
                    "generated_json_profiles",
                    "ZZZ_JSON_NeutralMatCap.png")),
                $"{testCase.Label} 正式 ZZZ 包仍生成旧 PNG 占位文件");

            var capturePath = Path.Combine(result.OutputDirectory, "ZZZEyeThrough", "ZZZEyeThrough_Capture.fxsub");
            var hairMaskPath = Path.Combine(result.OutputDirectory, "ZZZEyeThrough", "ZZZEyeThrough_HairMask.fxsub");
            var capture = DecodeStrictCp936(File.ReadAllBytes(capturePath));
            var hairMask = File.ReadAllText(hairMaskPath, new UTF8Encoding(false, true));
            foreach (var definition in testCase.CaptureDefinitions)
                Assert(capture.Contains(definition, StringComparison.Ordinal),
                    $"{testCase.Label} Capture 缺少：{definition}");
            Assert(capture.Contains(
                    "#define ZZZ_EYE_THROUGH_FACE_RESOURCE \"../textures/character/m000_base.png\"",
                    StringComparison.Ordinal),
                $"{testCase.Label} Capture 没有使用打包后的面部贴图");
            Assert(hairMask.Contains($"string Subset = \"{testCase.HairSubsets}\";", StringComparison.Ordinal) &&
                   hairMask.Contains("string Subset = \"0\";", StringComparison.Ordinal),
                $"{testCase.Label} HairMask 没有使用头发/面部 Subset");

            var materialFx = Directory.GetFiles(result.OutputDirectory, "Material_*.fx", SearchOption.TopDirectoryOnly);
            Assert(materialFx.Length == project.Materials.Count(material => material.Enabled),
                $"{testCase.Label} 正式材质 FX 数量与启用材质不一致");
            foreach (var fxPath in materialFx)
            {
                AssertRootRelativeIncludeClosure(result.OutputDirectory, fxPath);
                var fx = DecodeStrictCp936(File.ReadAllBytes(fxPath));
                Assert(!fx.Contains("M:\\", StringComparison.OrdinalIgnoreCase) &&
                       !fx.Contains("M:/", StringComparison.OrdinalIgnoreCase),
                    $"{testCase.Label} {Path.GetFileName(fxPath)} 泄漏了源绝对路径");
                foreach (var characterToken in new[] { "JaneDoe_", "Unagi_", "Burnice_" })
                    Assert(!fx.Contains(characterToken, StringComparison.OrdinalIgnoreCase),
                        $"{testCase.Label} {Path.GetFileName(fxPath)} 残留角色专用资源：{characterToken}");
            }

            tested++;
        }
    }
    finally
    {
        if (Directory.Exists(outputRoot)) Directory.Delete(outputRoot, true);
    }

    if (tested == 0)
    {
        Console.WriteLine("ZZZ_CHARACTER_PACKAGE_TEST_SKIPPED: 未找到 Jane/Miyabi/Burnice 本地 PMX。");
        return;
    }

    Console.WriteLine($"ZZZ_CHARACTER_PACKAGE_TEST_PASSED: {tested}/3");
}

void RunOfficialJsonSmokeTests()
{
    var officialRoot = FindAncestorContaining(repositoryRoot, "hoshimi-miyabi-frostgleam-dew") ?? repositoryRoot;
    var json = Environment.GetEnvironmentVariable("ENDFIELD_TEST_OFFICIAL_JSON") ??
        Path.Combine(officialRoot, "hoshimi-miyabi-frostgleam-dew", "Materials", "MAT_Unagi_Body_1_UI.json");
    var textureRoot = Path.Combine(officialRoot, "hoshimi-miyabi-frostgleam-dew", "Textures");
    if (!File.Exists(json) || !Directory.Exists(textureRoot))
    {
        Console.WriteLine("OFFICIAL_JSON_TEST_SKIPPED: 未找到本地官方 JSON 或贴图目录。");
        return;
    }

    var document = OfficialMaterialJsonReader.Read(json);
    Assert(document.Textures.TryGetValue("_MatCapTex2", out var matcap2), "官方 JSON 缺少 _MatCapTex2");
    Assert(matcap2!.TextureName == "Eff_MatCap_019", "_MatCapTex2 解析错误");
    Assert(document.Textures.TryGetValue("_MatCapTex5", out var matcap5), "官方 JSON 缺少 _MatCapTex5");
    Assert(matcap5!.TextureName == "Eff_Matcap_Socks", "_MatCapTex5 解析错误");
    Assert(document.Floats.ContainsKey("_MatCapBlendMode2"), "官方 JSON 浮点属性没有保留");
    Assert(document.RawProperties.ContainsKey("_MatCapTex2"), "官方 JSON 原始属性没有保留");

    var material = new MaterialAssignment
    {
        MaterialIndex = 0,
        MaterialName = "Unagi_Body_1",
        EnglishName = "Unagi_Body_1"
    };
    var result = MatCapProfileResolver.Apply(material, json, new[] { textureRoot });
    Assert(material.Zzz.GetMatCap(2).Source == ZzzValueSource.OfficialJson, "JSON MatCap 槽位来源错误");
    Assert(material.Zzz.GetMatCap(2).EffectiveTexturePath?.EndsWith("Eff_MatCap_019.png", StringComparison.OrdinalIgnoreCase) == true,
        "JSON MatCap 槽位没有精确匹配贴图");
    Assert(material.Zzz.GetMatCap(5).EffectiveTexturePath?.EndsWith("Eff_Matcap_Socks.png", StringComparison.OrdinalIgnoreCase) == true,
        "JSON MatCap 槽位 5 没有精确匹配贴图");
    Assert(result.Messages.All(message => message.Code != "OFFICIAL_MATCAP_NOT_FOUND"), "官方 JSON 已存在的 MatCap 被错误标记为缺失");

    material.Zzz.GetMatCap(5).Intensity = 0.30;
    material.Zzz.GetMatCap(2).ManualTexturePath = "manual_override.png";
    material.Zzz.GetMatCap(2).Source = ZzzValueSource.Manual;
    material.Zzz.GetMatCap(2).MaskChannel = "G";
    material.Zzz.GetMatCap(2).Scale = 1.25;
    material.Zzz.GetMatCap(2).ScaleY = 0.75;
    MatCapProfileResolver.Apply(material, json, new[] { textureRoot });
    Assert(material.Zzz.GetMatCap(2).ManualTexturePath == "manual_override.png", "手动 MatCap 被 JSON 静默覆盖");
    Assert(material.Zzz.GetMatCap(2).Source == ZzzValueSource.Manual, "手动 MatCap 来源被 JSON 静默改写");
    Assert(Math.Abs(material.Zzz.GetMatCap(5).Intensity - 0.30) < 0.000001,
        "手动 MatCap 强度被重新读取官方 JSON 时覆盖");
    var packaged = new TextureSlots
    {
        Base = "textures/character/base.png",
        Normal = "textures/character/normal.png",
        Property = "textures/character/material.png",
        Rs = "textures/character/attribute.png"
    };
    packaged.MatCaps[2] = "textures/character/manual_matcap_2.png";
    packaged.MatCaps[3] = "textures/character/json_matcap_3.png";
    packaged.MatCaps[5] = "textures/character/json_matcap_5.png";
    var include = ZzzProfileIncludeWriter.Build(material, packaged, "Miyabi_Body1_Test");
    Assert(include.Contains("ZZZ_JSON_MATCAP_SLOT_2_RESOURCE \"textures/character/manual_matcap_2.png\"", StringComparison.Ordinal),
        "ZZZ Profile 没有写出手动 MatCap 资源");
    Assert(include.Contains("ZZZ_JsonMatcapColorBurst2 = 0.68", StringComparison.Ordinal),
        "ZZZ Profile 没有保留官方 MatCap ColorBurst");
    Assert(include.Contains("ZZZ_JsonMatcapColorBurst5 = 0.303", StringComparison.Ordinal),
        "ZZZ Profile 没有把手动强度应用到丝袜 MatCap 槽位");
    Assert(include.Contains("ZZZ_JsonMatcapMaskChannel2", StringComparison.Ordinal),
        "ZZZ Profile 没有写出 MatCap 遮罩通道");
    Assert(include.Contains("ZZZ_JsonMatcapRotation2", StringComparison.Ordinal) &&
           include.Contains("ZZZ_JsonMatcapOffset2", StringComparison.Ordinal),
        "ZZZ Profile 没有写出 MatCap UV 参数");
    Assert(include.Contains("ZZZ_JsonMatcapScale2 = float2(1.25, 0.75)", StringComparison.Ordinal),
        "ZZZ Profile 没有保留 MatCap 双轴缩放");
    Assert(include.Contains("ZZZ_JsonMatcapMaskChannel2 = 1.0", StringComparison.Ordinal),
        "ZZZ Profile 没有写出手动 MatCap 遮罩通道");
    Assert(include.Contains("ZZZ_JsonSpecularColor2 = float3(0.6929957, 0.7380872, 0.8207547)", StringComparison.Ordinal),
        "ZZZ Profile 没有写出官方五槽高光颜色");
    Assert(include.Contains("ZZZ_JsonModelSize2 = 5.0", StringComparison.Ordinal) &&
           include.Contains("ZZZ_JsonSpecularIntensity = 0.1", StringComparison.Ordinal),
        "ZZZ Profile 没有写出官方高光尺度或强度");
    var neutralTexture = ZzzProfileIncludeWriter.NeutralTextureBytes();
    Assert(neutralTexture.Length >= 70 &&
           neutralTexture[0] == (byte)'B' && neutralTexture[1] == (byte)'M',
        "中性 MatCap 不是有效 BMP");

    var janeJson = Path.Combine(officialRoot, "jane-doe-hidden-nightfade", "Materials", "MAT_JaneDoe_Body_2_UI.json");
    if (File.Exists(janeJson))
    {
        var jane = OfficialMaterialJsonReader.Read(janeJson);
        Assert(jane.Textures.TryGetValue("_MatCapTex", out var janeMatcap1) && janeMatcap1.TextureName == "Eff_Matcap_013",
            "Jane Body2 的 MatCap 槽 1 解析错误");
        Assert(jane.Textures.TryGetValue("_MatCapTex4", out var janeMatcap4) && janeMatcap4.TextureName == "Eff_Matcap_047",
            "Jane Body2 的 MatCap 槽 4 解析错误");
    }

    var duplicateRoot = Path.Combine(Path.GetTempPath(), "ZzzTextureIndex_" + Guid.NewGuid().ToString("N"));
    try
    {
        Directory.CreateDirectory(Path.Combine(duplicateRoot, "a"));
        Directory.CreateDirectory(Path.Combine(duplicateRoot, "b"));
        File.WriteAllBytes(Path.Combine(duplicateRoot, "a", "same.png"), Array.Empty<byte>());
        File.WriteAllBytes(Path.Combine(duplicateRoot, "b", "same.dds"), Array.Empty<byte>());
        var duplicateIndex = TextureAssetIndex.Build(new[] { duplicateRoot });
        Assert(!duplicateIndex.TryResolve("same", out _), "同名 MatCap 冲突时不应猜测贴图");
    }
    finally
    {
        if (Directory.Exists(duplicateRoot)) Directory.Delete(duplicateRoot, true);
    }
    Console.WriteLine("OFFICIAL_JSON_TEST_PASSED");
}

void RunControllerEmmSmokeTest()
{
    var project = new StudioProject
    {
        ProjectName = "ControllerTest",
        RuntimeRoot = runtime,
        ControllerRoot = Path.Combine(runtime, "controller"),
        EnableEyeThrough = false,
        ControllerFiles = ZzzControllerCatalog.CreateDefaultControllerFiles(),
        ControllerBindings = ZzzControllerCatalog.CreateFromDirectory(Path.Combine(runtime, "controller"))
    };
    var bytes = EmmWriter.Build(project, "M:/package", runtime, "M:/package/model.pmx",
        new Dictionary<int, string>(), null);
    var text = Encoding.GetEncoding(936).GetString(bytes);
    Assert(text.Contains("EndfieldHair_controller_Range5.pmx", StringComparison.Ordinal), "EMM 缺少头发控制器");
    Assert(text.Contains("EndfieldPost_controller.pmx", StringComparison.Ordinal), "EMM 缺少后处理控制器");
    Assert(project.ControllerBindings.Count == 345, "没有完整读取六个控制器的 345 个 morph");
    Assert(project.ControllerBindings.Any(binding =>
            binding.ControllerFile == "EndfieldHair_controller_Range5.pmx" && binding.MorphName == "高光強+"),
        "头发控制器 morph 名读取错误");
    Assert(project.ControllerBindings.Any(binding =>
            binding.ControllerFile == "EndfieldPost_controller.pmx" && binding.MorphName == "Bloom強+"),
        "后处理控制器 morph 名读取错误");
    var manifest = Encoding.UTF8.GetString(ZzzControllerManifestWriter.Build(project));
    Assert(manifest.Contains("ZZZMaterialStudio.ControllerMap", StringComparison.Ordinal) &&
           manifest.Contains("高光強+", StringComparison.Ordinal),
        "控制器清单没有保留精确 morph 名");
    Assert(ProjectValidator.Validate(project).All(message => message.Code != "CONTROLLER_MORPH_MISSING"),
        "控制器清单与实际 PMX morph 不一致");
    Console.WriteLine("CONTROLLER_EMM_TEST_PASSED");
}

void RunZzzControllerEmmSmokeTest()
{
    var zzzRuntime = FindZzzRuntime(repositoryRoot);
    if (zzzRuntime is null)
    {
        Console.WriteLine("ZZZ_CONTROLLER_TEST_SKIPPED: 未找到 ZZZ_MME。");
        return;
    }

    var controllerFiles = ZzzControllerCatalog.CreateDefaultControllerFiles(ShaderRuntimeKind.ZzzMme);
    Assert(controllerFiles.SequenceEqual(new[]
    {
        "ZzzShadow_controller.pmx",
        "ZzzHair_controller.pmx",
        "ZzzFaceSkin_controller.pmx",
        "ZzzClothMatCap_controller.pmx",
        "ZzzEye_controller.pmx",
        "ZzzPost_controller.pmx"
    }), "正式 ZZZ 控制器顺序发生变化");

    var project = new StudioProject
    {
        ProjectName = "ZzzControllerTest",
        RuntimeRoot = zzzRuntime,
        RuntimeKind = ShaderRuntimeKind.ZzzMme,
        ControllerRoot = Path.Combine(zzzRuntime, "controller"),
        EnableEyeThrough = false,
        ControllerFiles = controllerFiles,
        ControllerBindings = ZzzControllerCatalog.CreateFromDirectory(
            Path.Combine(zzzRuntime, "controller"),
            controllerFiles)
    };
    Assert(project.ControllerBindings.Count == 207,
        "没有完整读取六个正式 ZZZ 控制器的 207 个 morph");
    Assert(project.ControllerBindings.Count(binding =>
            binding.ControllerFile == "ZzzClothMatCap_controller.pmx") == 65,
        "衣装/MatCap 控制器不是预期的 65 个 morph");
    foreach (var morphName in new[]
             {
                 "衣装高光赤+", "衣装高光緑+", "衣装高光青+",
                 "球面槽1強+", "球面槽3明-", "球面槽5遮蔽+", "球面槽5閉"
             })
    {
        Assert(project.ControllerBindings.Any(binding =>
                binding.ControllerFile == "ZzzClothMatCap_controller.pmx" &&
                binding.MorphName == morphName),
            $"衣装/MatCap 控制器缺少 morph：{morphName}");
    }

    var bytes = EmmWriter.Build(project, "M:/package", zzzRuntime, "M:/package/model.pmx",
        new Dictionary<int, string>(), null);
    var emm = Encoding.GetEncoding(936).GetString(bytes);
    foreach (var fileName in controllerFiles)
        Assert(emm.Contains(fileName, StringComparison.Ordinal), $"正式 ZZZ EMM 缺少控制器：{fileName}");
    var controllerValidation = ProjectValidator.Validate(project)
        .Where(message => message.Code.StartsWith("CONTROLLER", StringComparison.Ordinal))
        .ToArray();
    Assert(controllerValidation.All(message => !message.IsError),
        $"正式 ZZZ 控制器工程验证失败：{string.Join(" | ", controllerValidation.Select(message => message.ToString()))}");

    var manifest = Encoding.UTF8.GetString(ZzzControllerManifestWriter.Build(project));
    Assert(manifest.Contains("衣装高光赤+", StringComparison.Ordinal) &&
           manifest.Contains("球面槽5閉", StringComparison.Ordinal),
        "正式 ZZZ 控制器清单缺少五槽或高光颜色控制");
    Console.WriteLine("ZZZ_CONTROLLER_EMM_TEST_PASSED");
}

void RunZzzControllerMigrationSmokeTest()
{
    var zzzRuntime = FindZzzRuntime(repositoryRoot);
    if (zzzRuntime is null)
    {
        Console.WriteLine("ZZZ_CONTROLLER_MIGRATION_TEST_SKIPPED: 未找到 ZZZ_MME。");
        return;
    }

    var project = new StudioProject
    {
        SchemaVersion = 4,
        RuntimeRoot = zzzRuntime,
        RuntimeKind = ShaderRuntimeKind.ZzzMme,
        ControllerRoot = Path.Combine(zzzRuntime, "controller"),
        ControllerFiles = new List<string>
        {
            "ZzzHair_controller.pmx",
            "EndfieldFace_controller.pmx",
            "EndfieldSkin_controller.pmx",
            "EndfieldCloth_controller.pmx",
            "Endfield_controller.pmx",
            "ZzzPost_controller.pmx"
        },
        ControllerBindings = new List<ZzzControllerBinding>
        {
            new()
            {
                ControllerFile = "EndfieldCloth_controller.pmx",
                MorphName = "旧衣装制御"
            },
            new()
            {
                ControllerFile = "ZzzHair_controller.pmx",
                MorphName = "旧髪制御"
            }
        }
    };

    ProjectFactory.Normalize(project);
    var expected = ZzzControllerCatalog.CreateDefaultControllerFiles(ShaderRuntimeKind.ZzzMme);
    Assert(project.SchemaVersion == 6, "ZZZ 工程没有迁移到 Schema 6");
    Assert(project.ControllerFiles.SequenceEqual(expected),
        "旧 ZZZ 工程没有迁移到六个正式控制器");
    Assert(project.ControllerBindings.All(binding =>
            expected.Contains(Path.GetFileName(binding.ControllerFile), StringComparer.OrdinalIgnoreCase)),
        "控制器迁移后仍残留旧 Endfield 控制绑定");
    Assert(project.ControllerBindings.Count == 207,
        "控制器迁移后没有重新读取六个正式控制器的 207 个 morph");
    Console.WriteLine("ZZZ_CONTROLLER_MIGRATION_TEST_PASSED");
}

static MaterialAssignment Material(int index, MaterialRole role) => new()
{
    MaterialIndex = index,
    MaterialName = role.ToString(),
    Role = role
};

static MaterialAssignment NamedMaterial(int index, string name, MaterialRole role) => new()
{
    MaterialIndex = index,
    MaterialName = name,
    Role = role
};

static void AssertGeneratedText(string text, string label)
{
    Assert(!text.Contains("__EF_", StringComparison.Ordinal), $"{label} 仍有未替换占位符");
    foreach (var banned in new[] { "Chen" + "Qianyu", "chen_" + "qianyu", "textures/" + "chen/" })
        Assert(!text.Contains(banned, StringComparison.OrdinalIgnoreCase), $"{label} 仍有角色专用内容");
}

static string Decode(byte[] bytes)
{
    try { return new UTF8Encoding(false, true).GetString(bytes); }
    catch (DecoderFallbackException) { return Encoding.GetEncoding(932).GetString(bytes); }
}

static string DecodeCp936(byte[] bytes) => Encoding.GetEncoding(936).GetString(bytes);

static string DecodeStrictCp936(byte[] bytes) => Encoding.GetEncoding(
    936,
    EncoderFallback.ExceptionFallback,
    DecoderFallback.ExceptionFallback).GetString(bytes);

static void AssertRootRelativeIncludeClosure(string packageRoot, string entryPath)
{
    var root = Path.GetFullPath(packageRoot).TrimEnd(
        Path.DirectorySeparatorChar,
        Path.AltDirectorySeparatorChar) + Path.DirectorySeparatorChar;
    var visited = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
    Walk(entryPath);

    void Walk(string path)
    {
        var fullPath = Path.GetFullPath(path);
        Assert(fullPath.StartsWith(root, StringComparison.OrdinalIgnoreCase),
            $"生成包 include 越出根目录：{fullPath}");
        Assert(File.Exists(fullPath), $"生成包 include 不存在：{fullPath}");
        if (!visited.Add(fullPath)) return;

        var text = DecodeIncludeText(File.ReadAllBytes(fullPath));
        foreach (var rawLine in text.Replace("\r\n", "\n", StringComparison.Ordinal).Split('\n'))
        {
            var line = rawLine.Trim();
            const string prefix = "#include \"";
            if (!line.StartsWith(prefix, StringComparison.Ordinal)) continue;
            var end = line.IndexOf('"', prefix.Length);
            if (end < 0) continue;
            var include = line[prefix.Length..end]
                .Replace('/', Path.DirectorySeparatorChar)
                .Replace('\\', Path.DirectorySeparatorChar);
            var localPath = Path.Combine(Path.GetDirectoryName(fullPath)!, include);
            Walk(File.Exists(localPath) ? localPath : Path.Combine(root, include));
        }
    }
}

static string DecodeIncludeText(byte[] bytes)
{
    try { return new UTF8Encoding(false, true).GetString(bytes); }
    catch (DecoderFallbackException) { return DecodeStrictCp936(bytes); }
}

static int CountOccurrences(string text, string value) =>
    text.Split(value, StringSplitOptions.None).Length - 1;

static string FindRepositoryRoot()
{
    var current = new DirectoryInfo(AppContext.BaseDirectory);
    while (current is not null)
    {
        if (File.Exists(Path.Combine(current.FullName, "ShaderRuntime", "internal", "zzz_common.hlsl")) ||
            File.Exists(Path.Combine(current.FullName, "EndfieldMME", "internal", "endfield_shader.hlsl")))
            return current.FullName;
        current = current.Parent;
    }
    throw new DirectoryNotFoundException("找不到包含 ShaderRuntime 或 EndfieldMME 的仓库根目录。");
}

static string? FindZzzRuntime(string repositoryRoot)
{
    var configured = Environment.GetEnvironmentVariable("ZZZ_MME_RUNTIME");
    if (!string.IsNullOrWhiteSpace(configured) && Directory.Exists(configured))
        return Path.GetFullPath(configured);

    var local = Path.Combine(repositoryRoot, "ShaderRuntime");
    if (Directory.Exists(local)) return local;

    var workspaceRoot = Directory.GetParent(repositoryRoot)?.FullName;
    var sibling = workspaceRoot is null ? string.Empty : Path.Combine(workspaceRoot, "ZZZ_MME");
    return Directory.Exists(sibling) ? sibling : null;
}

static string? FindAncestorContaining(string start, string directoryName)
{
    var current = new DirectoryInfo(start);
    while (current is not null)
    {
        if (Directory.Exists(Path.Combine(current.FullName, directoryName))) return current.FullName;
        current = current.Parent;
    }
    return null;
}

static void Assert(bool condition, string message)
{
    if (!condition) throw new InvalidOperationException(message);
}
