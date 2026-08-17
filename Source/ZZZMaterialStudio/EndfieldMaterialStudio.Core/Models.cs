using System.Text.Json.Serialization;

namespace EndfieldMaterialStudio.Core;

[JsonConverter(typeof(JsonStringEnumConverter))]
public enum ShaderRuntimeKind
{
    Auto,
    ZzzMme,
    LegacyEndfield
}

[JsonConverter(typeof(JsonStringEnumConverter))]
public enum MaterialRole
{
    None,
    Face,
    Iris,
    EyeHighlight,
    EyeWhite,
    BrowLash,
    Mouth,
    Hair,
    Skin,
    Cloth,
    EyeOverlay,
    BrowOverlay,
    FaceProxy,
    Hidden
}

[JsonConverter(typeof(JsonStringEnumConverter))]
public enum ZzzValueSource
{
    Manual,
    OfficialJson,
    Default
}

public sealed class ZzzColorValue
{
    public double R { get; set; } = 1.0;
    public double G { get; set; } = 1.0;
    public double B { get; set; } = 1.0;
    public double A { get; set; } = 1.0;

    public ZzzColorValue Clone() => new() { R = R, G = G, B = B, A = A };
}

public sealed class OfficialTextureBinding
{
    public string PropertyName { get; set; } = string.Empty;
    public string? TextureName { get; set; }
    public string? ResolvedPath { get; set; }
    public bool IsNull { get; set; }
    public double ScaleX { get; set; } = 1.0;
    public double ScaleY { get; set; } = 1.0;
    public double OffsetX { get; set; }
    public double OffsetY { get; set; }

    public OfficialTextureBinding Clone() => new()
    {
        PropertyName = PropertyName,
        TextureName = TextureName,
        ResolvedPath = ResolvedPath,
        IsNull = IsNull,
        ScaleX = ScaleX,
        ScaleY = ScaleY,
        OffsetX = OffsetX,
        OffsetY = OffsetY
    };
}

public sealed class MatCapSlotBinding
{
    public int Slot { get; set; }
    public bool Enabled { get; set; } = true;
    public ZzzValueSource Source { get; set; } = ZzzValueSource.Manual;
    public string? ManualTexturePath { get; set; }
    public string? ResolvedTexturePath { get; set; }
    public string? OfficialProperty { get; set; }
    public string? OfficialTextureName { get; set; }
    public string MaskChannel { get; set; } = "B";
    public double Intensity { get; set; } = 1.0;
    public double Rotation { get; set; }
    public double Scale { get; set; } = 1.0;
    public double ScaleY { get; set; } = 1.0;
    public double OffsetX { get; set; }
    public double OffsetY { get; set; }
    public string BlendMode { get; set; } = "Official";
    public ZzzColorValue Tint { get; set; } = new();

    public string? EffectiveTexturePath => Source switch
    {
        ZzzValueSource.Manual => ManualTexturePath ?? ResolvedTexturePath,
        ZzzValueSource.OfficialJson => ResolvedTexturePath ?? ManualTexturePath,
        _ => null
    };

    public MatCapSlotBinding Clone() => new()
    {
        Slot = Slot,
        Enabled = Enabled,
        Source = Source,
        ManualTexturePath = ManualTexturePath,
        ResolvedTexturePath = ResolvedTexturePath,
        OfficialProperty = OfficialProperty,
        OfficialTextureName = OfficialTextureName,
        MaskChannel = MaskChannel,
        Intensity = Intensity,
        Rotation = Rotation,
        Scale = Scale,
        ScaleY = ScaleY,
        OffsetX = OffsetX,
        OffsetY = OffsetY,
        BlendMode = BlendMode,
        Tint = Tint.Clone()
    };
}

public sealed class ZzzMaterialProfile
{
    public string? OfficialJsonPath { get; set; }
    public string? OfficialMaterialName { get; set; }
    public string? OfficialShaderName { get; set; }
    public bool PreferManualMatCap { get; set; } = true;
    public bool AllowOfficialJsonSuggestions { get; set; } = true;
    public int HairHighlightSlot { get; set; } = 2;
    public double HairHighlightGain { get; set; } = 10.0;
    public double HairCenterPower { get; set; } = 7.0;
    public bool HairUseCenterMask { get; set; } = true;
    public bool HairUseScreenRim { get; set; } = true;
    public bool HairUseFaceShadow { get; set; } = true;
    public List<MatCapSlotBinding> MatCaps { get; set; } = CreateDefaultMatCaps();
    public Dictionary<string, string> OfficialTextures { get; set; } = new(StringComparer.Ordinal);
    public Dictionary<string, OfficialTextureBinding> OfficialTextureBindings { get; set; } = new(StringComparer.Ordinal);
    public Dictionary<string, double> OfficialFloats { get; set; } = new(StringComparer.Ordinal);
    public Dictionary<string, int> OfficialInts { get; set; } = new(StringComparer.Ordinal);
    public Dictionary<string, ZzzColorValue> OfficialColors { get; set; } = new(StringComparer.Ordinal);
    public Dictionary<string, string> OfficialRawProperties { get; set; } = new(StringComparer.Ordinal);

    public MatCapSlotBinding GetMatCap(int slot)
    {
        if (slot is < 1 or > 5) throw new ArgumentOutOfRangeException(nameof(slot));
        var binding = MatCaps.FirstOrDefault(item => item.Slot == slot);
        if (binding is not null) return binding;
        binding = new MatCapSlotBinding { Slot = slot };
        MatCaps.Add(binding);
        return binding;
    }

    public ZzzMaterialProfile Clone() => new()
    {
        OfficialJsonPath = OfficialJsonPath,
        OfficialMaterialName = OfficialMaterialName,
        OfficialShaderName = OfficialShaderName,
        PreferManualMatCap = PreferManualMatCap,
        AllowOfficialJsonSuggestions = AllowOfficialJsonSuggestions,
        HairHighlightSlot = HairHighlightSlot,
        HairHighlightGain = HairHighlightGain,
        HairCenterPower = HairCenterPower,
        HairUseCenterMask = HairUseCenterMask,
        HairUseScreenRim = HairUseScreenRim,
        HairUseFaceShadow = HairUseFaceShadow,
        MatCaps = MatCaps.Select(item => item.Clone()).ToList(),
        OfficialTextures = new Dictionary<string, string>(OfficialTextures, StringComparer.Ordinal),
        OfficialTextureBindings = OfficialTextureBindings.ToDictionary(item => item.Key, item => item.Value.Clone(), StringComparer.Ordinal),
        OfficialFloats = new Dictionary<string, double>(OfficialFloats, StringComparer.Ordinal),
        OfficialInts = new Dictionary<string, int>(OfficialInts, StringComparer.Ordinal),
        OfficialColors = OfficialColors.ToDictionary(item => item.Key, item => item.Value.Clone(), StringComparer.Ordinal),
        OfficialRawProperties = new Dictionary<string, string>(OfficialRawProperties, StringComparer.Ordinal)
    };

    private static List<MatCapSlotBinding> CreateDefaultMatCaps() =>
        Enumerable.Range(1, 5).Select(slot => new MatCapSlotBinding { Slot = slot }).ToList();
}

public sealed class ZzzControllerBinding
{
    public string ControllerFile { get; set; } = string.Empty;
    public string Group { get; set; } = string.Empty;
    public string MorphName { get; set; } = string.Empty;
    public string TargetProperty { get; set; } = string.Empty;
    public double Min { get; set; } = -1.0;
    public double Max { get; set; } = 1.0;
    public double Default { get; set; }
    public bool Enabled { get; set; } = true;
    public string Note { get; set; } = string.Empty;

    public ZzzControllerBinding Clone() => new()
    {
        ControllerFile = ControllerFile,
        Group = Group,
        MorphName = MorphName,
        TargetProperty = TargetProperty,
        Min = Min,
        Max = Max,
        Default = Default,
        Enabled = Enabled,
        Note = Note
    };
}

public sealed class TextureSlots
{
    public string? Base { get; set; }
    public string? Normal { get; set; }
    public string? Property { get; set; }
    public string? Rd { get; set; }
    public string? Rs { get; set; }
    public string? Lut { get; set; }
    public string? Sdf { get; set; }
    public string? St { get; set; }
    public string? ColorMask { get; set; }
    public string? LipSpecular { get; set; }
    public string? HairLine { get; set; }
    public Dictionary<int, string?> MatCaps { get; set; } = Enumerable.Range(1, 5)
        .ToDictionary(slot => slot, _ => (string?)null);
}

public sealed class MaterialAssignment
{
    public int MaterialIndex { get; set; }
    public string MaterialName { get; set; } = string.Empty;
    public string EnglishName { get; set; } = string.Empty;
    public MaterialRole Role { get; set; }
    public TextureSlots Textures { get; set; } = new();
    public bool UsePmxBaseTexture { get; set; } = true;
    public string? PmxBaseTexture { get; set; }
    public ZzzMaterialProfile Zzz { get; set; } = new();
    public bool Enabled => Role is not MaterialRole.None and not MaterialRole.FaceProxy;
}

public sealed class StudioProject
{
    public int SchemaVersion { get; set; } = 6;
    public string ProjectName { get; set; } = "ZZZCharacter";
    public string ShaderFamily { get; set; } = "ZZZ";
    public string PmxPath { get; set; } = string.Empty;
    public string RuntimeRoot { get; set; } = string.Empty;
    public ShaderRuntimeKind RuntimeKind { get; set; } = ShaderRuntimeKind.Auto;
    public string OutputDirectory { get; set; } = string.Empty;
    public string OfficialJsonRoot { get; set; } = string.Empty;
    public string ControllerRoot { get; set; } = string.Empty;
    public bool PreferManualMatCap { get; set; } = true;
    public List<string> ControllerFiles { get; set; } = ZzzControllerCatalog.CreateDefaultControllerFiles();
    public List<ZzzControllerBinding> ControllerBindings { get; set; } = ZzzControllerCatalog.CreateDefault();
    public string HeadBone { get; set; } = "頭";
    public bool EnableEyeThrough { get; set; } = true;
    public bool GenerateDerivedPmx { get; set; } = true;
    public List<MaterialAssignment> Materials { get; set; } = new();
}

public sealed class PmxMaterialInfo
{
    public int Index { get; set; }
    public string Name { get; set; } = string.Empty;
    public string EnglishName { get; set; } = string.Empty;
    public string? TexturePath { get; set; }
    public string? SphereTexturePath { get; set; }
    public byte SphereMode { get; set; }
    public string? ToonTexturePath { get; set; }
    public int AdditionalUvCount { get; set; }
    public bool HasUsableUv1 { get; set; }
}

public sealed class PmxModelInfo
{
    public string FilePath { get; set; } = string.Empty;
    public float Version { get; set; }
    public string Encoding { get; set; } = string.Empty;
    public int AdditionalUvCount { get; set; }
    public List<string> BoneNames { get; set; } = new();
    public List<PmxMorphInfo> Morphs { get; set; } = new();
    public List<PmxMaterialInfo> Materials { get; set; } = new();
}

public sealed class PmxMorphInfo
{
    public int Index { get; set; }
    public string Name { get; set; } = string.Empty;
    public string EnglishName { get; set; } = string.Empty;
    public byte Panel { get; set; }
    public byte Type { get; set; }
    public int OffsetCount { get; set; }
}

public enum PmxTextureKind
{
    Base,
    Sphere,
    Toon
}

public sealed class PmxTextureResolution
{
    public string DeclaredPath { get; init; } = string.Empty;
    public string DirectPath { get; init; } = string.Empty;
    public string ResolvedPath { get; init; } = string.Empty;
    public bool Exists { get; init; }
    public bool UsedFallback { get; init; }
    public string? FallbackDirectory { get; init; }
}

public sealed class PmxTextureDependency
{
    public int MaterialIndex { get; init; }
    public string MaterialName { get; init; } = string.Empty;
    public PmxTextureKind Kind { get; init; }
    public PmxTextureResolution Resolution { get; init; } = new();
}

public sealed class ValidationMessage
{
    public bool IsError { get; init; }
    public string Code { get; init; } = string.Empty;
    public string Message { get; init; } = string.Empty;

    public override string ToString() => $"{(IsError ? "ERROR" : "WARN")} [{Code}] {Message}";
}

public sealed class PackageResult
{
    public string OutputDirectory { get; init; } = string.Empty;
    public string EmmPath { get; init; } = string.Empty;
    public string MaterialMapPath { get; init; } = string.Empty;
    public string ControllerMapPath { get; init; } = string.Empty;
    public string ModelPath { get; init; } = string.Empty;
    public IReadOnlyList<string> GeneratedFiles { get; init; } = Array.Empty<string>();
}

public sealed class EyeThroughOverlayBinding
{
    public int SourceMaterialIndex { get; init; }
    public int OverlayMaterialIndex { get; init; }
    public MaterialRole SourceRole { get; init; }
    public MaterialRole OverlayRole { get; init; }
    public string SourceMaterialName { get; init; } = string.Empty;
    public string OverlayMaterialName { get; init; } = string.Empty;
}

public sealed class EyeThroughBuildResult
{
    public string SourcePmxPath { get; init; } = string.Empty;
    public string DerivedPmxPath { get; init; } = string.Empty;
    public bool Created { get; init; }
    public IReadOnlyList<EyeThroughOverlayBinding> Overlays { get; init; } = Array.Empty<EyeThroughOverlayBinding>();
}
