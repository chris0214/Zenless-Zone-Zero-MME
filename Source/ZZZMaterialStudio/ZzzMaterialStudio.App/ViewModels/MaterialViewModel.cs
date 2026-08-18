using System.Collections.ObjectModel;
using System.IO;
using EndfieldMaterialStudio.Core;
using ZzzMaterialStudio.App.Infrastructure;

namespace ZzzMaterialStudio.App.ViewModels;

public sealed class MaterialViewModel : ObservableObject
{
    private ShaderRuntimeKind _runtimeKind;

    public MaterialViewModel(MaterialAssignment model, ShaderRuntimeKind runtimeKind)
    {
        Model = model;
        _runtimeKind = runtimeKind;
        RoleChoices = CreateRoleChoices();
        ZWriteChoices =
        [
            new("自动（推荐）", null),
            new("开启（true）", true),
            new("关闭（false）", false)
        ];
        HairHighlightSlots = Enumerable.Range(1, 5).ToArray();
        TextureSlots = CreateTextureSlots();
        MatCaps = new ObservableCollection<MatCapSlotViewModel>(
            Enumerable.Range(1, 5).Select(slot => new MatCapSlotViewModel(Model.Zzz.GetMatCap(slot))));
    }

    public MaterialAssignment Model { get; }
    public IReadOnlyList<ChoiceItem<MaterialRole>> RoleChoices { get; }
    public IReadOnlyList<DepthWriteChoice> ZWriteChoices { get; }
    public IReadOnlyList<int> HairHighlightSlots { get; }
    public ObservableCollection<TextureSlotViewModel> TextureSlots { get; }
    public ObservableCollection<MatCapSlotViewModel> MatCaps { get; }

    public int MaterialIndex => Model.MaterialIndex;
    public string MaterialName => Model.MaterialName;
    public string EnglishName => Model.EnglishName;
    public string DisplayIndex => $"{MaterialIndex:00}";

    public MaterialRole Role
    {
        get => Model.Role;
        set
        {
            if (Model.Role == value) return;
            Model.Role = value;
            RefreshComputed();
        }
    }

    public string RoleLabel => RoleDisplayName(Role);
    public string RoleDescription => DescribeRole(Role, _runtimeKind == ShaderRuntimeKind.ZzzMme);
    public string TextureContract => DescribeTextureContract(Role, _runtimeKind == ShaderRuntimeKind.ZzzMme);
    public string OfficialJsonName => string.IsNullOrWhiteSpace(Model.Zzz.OfficialJsonPath)
        ? "未读取官方 JSON"
        : Path.GetFileName(Model.Zzz.OfficialJsonPath);
    public string OfficialShaderName => string.IsNullOrWhiteSpace(Model.Zzz.OfficialShaderName)
        ? "-"
        : Model.Zzz.OfficialShaderName;
    public bool HasOfficialJson => !string.IsNullOrWhiteSpace(Model.Zzz.OfficialJsonPath);
    public bool IsActive => Role is not MaterialRole.None and not MaterialRole.FaceProxy and not MaterialRole.Hidden;
    public bool SupportsHairSettings => _runtimeKind == ShaderRuntimeKind.ZzzMme && Role == MaterialRole.Hair;
    public bool SupportsMatCaps => _runtimeKind == ShaderRuntimeKind.ZzzMme && Role is MaterialRole.Hair or MaterialRole.Skin or MaterialRole.Cloth;
    public bool SupportsZWrite => _runtimeKind == ShaderRuntimeKind.ZzzMme && Role is
        MaterialRole.BrowLash or MaterialRole.EyeOverlay or MaterialRole.EyeHighlight or MaterialRole.BrowOverlay;

    public bool UsePmxBaseTexture
    {
        get => Model.UsePmxBaseTexture;
        set
        {
            if (Model.UsePmxBaseTexture == value) return;
            Model.UsePmxBaseTexture = value;
            if (value && !string.IsNullOrWhiteSpace(Model.PmxBaseTexture)) Model.Textures.Base = Model.PmxBaseTexture;
            OnPropertyChanged();
            RefreshTextureSlots();
        }
    }

    public string PmxBaseTexture => Model.PmxBaseTexture ?? "PMX 未绑定基础贴图";

    public DepthWriteChoice SelectedZWriteChoice
    {
        get => ZWriteChoices.First(choice => choice.Value == Model.ZWriteOverride);
        set
        {
            if (value is null || Model.ZWriteOverride == value.Value) return;
            Model.ZWriteOverride = value.Value;
            OnPropertyChanged();
        }
    }

    public int HairHighlightSlot
    {
        get => Model.Zzz.HairHighlightSlot;
        set { if (Model.Zzz.HairHighlightSlot == value) return; Model.Zzz.HairHighlightSlot = value; OnPropertyChanged(); }
    }

    public double HairHighlightGain
    {
        get => Model.Zzz.HairHighlightGain;
        set { if (Math.Abs(Model.Zzz.HairHighlightGain - value) < 0.000001) return; Model.Zzz.HairHighlightGain = value; OnPropertyChanged(); }
    }

    public double HairCenterPower
    {
        get => Model.Zzz.HairCenterPower;
        set { if (Math.Abs(Model.Zzz.HairCenterPower - value) < 0.000001) return; Model.Zzz.HairCenterPower = value; OnPropertyChanged(); }
    }

    public bool HairUseCenterMask
    {
        get => Model.Zzz.HairUseCenterMask;
        set { if (Model.Zzz.HairUseCenterMask == value) return; Model.Zzz.HairUseCenterMask = value; OnPropertyChanged(); }
    }

    public bool HairUseScreenRim
    {
        get => Model.Zzz.HairUseScreenRim;
        set { if (Model.Zzz.HairUseScreenRim == value) return; Model.Zzz.HairUseScreenRim = value; OnPropertyChanged(); }
    }

    public bool HairUseFaceShadow
    {
        get => Model.Zzz.HairUseFaceShadow;
        set { if (Model.Zzz.HairUseFaceShadow == value) return; Model.Zzz.HairUseFaceShadow = value; OnPropertyChanged(); }
    }

    public void SetRuntimeKind(ShaderRuntimeKind runtimeKind)
    {
        if (_runtimeKind == runtimeKind) return;
        _runtimeKind = runtimeKind;
        RefreshComputed();
    }

    public string? GetTexture(string key) => key switch
    {
        "Base" => Model.Textures.Base,
        "Normal" => Model.Textures.Normal,
        "Property" => Model.Textures.Property,
        "Rd" => Model.Textures.Rd,
        "Rs" => Model.Textures.Rs,
        "Lut" => Model.Textures.Lut,
        "Sdf" => Model.Textures.Sdf,
        "St" => Model.Textures.St,
        "ColorMask" => Model.Textures.ColorMask,
        "LipSpecular" => Model.Textures.LipSpecular,
        "HairLine" => Model.Textures.HairLine,
        _ => null
    };

    public void SetTexture(string key, string? value)
    {
        switch (key)
        {
            case "Base": Model.Textures.Base = value; break;
            case "Normal": Model.Textures.Normal = value; break;
            case "Property": Model.Textures.Property = value; break;
            case "Rd": Model.Textures.Rd = value; break;
            case "Rs": Model.Textures.Rs = value; break;
            case "Lut": Model.Textures.Lut = value; break;
            case "Sdf": Model.Textures.Sdf = value; break;
            case "St": Model.Textures.St = value; break;
            case "ColorMask": Model.Textures.ColorMask = value; break;
            case "LipSpecular": Model.Textures.LipSpecular = value; break;
            case "HairLine": Model.Textures.HairLine = value; break;
        }
    }

    public bool IsTextureEnabled(string key)
    {
        if (!IsActive) return false;
        if (key == "Base") return !UsePmxBaseTexture;
        var isZzz = _runtimeKind == ShaderRuntimeKind.ZzzMme;
        if (!isZzz) return true;
        if (key is "Normal" or "Property" or "Rs") return Role is MaterialRole.Hair or MaterialRole.Skin or MaterialRole.Cloth;
        if (key == "Sdf") return Role == MaterialRole.Face;
        return false;
    }

    public void ClearTextures()
    {
        var basePath = Model.Textures.Base;
        Model.Textures = new TextureSlots { Base = basePath };
        RefreshTextureSlots();
    }

    public void RefreshFromModel()
    {
        OnPropertiesChanged(
            nameof(OfficialJsonName), nameof(OfficialShaderName), nameof(HasOfficialJson),
            nameof(HairHighlightSlot), nameof(HairHighlightGain), nameof(HairCenterPower),
            nameof(HairUseCenterMask), nameof(HairUseScreenRim), nameof(HairUseFaceShadow));
        RefreshTextureSlots();
        foreach (var matCap in MatCaps) matCap.RefreshFromModel();
    }

    private ObservableCollection<TextureSlotViewModel> CreateTextureSlots() =>
    [
        new(this, "Base", "基础色 / Base", "角色基础颜色贴图"),
        new(this, "Normal", "法线 / N", "头发、皮肤、衣服法线"),
        new(this, "Property", "材质属性 / M", "高光、材质分区与属性遮罩"),
        new(this, "Rs", "辅助属性 / A", "角色辅助属性贴图"),
        new(this, "Sdf", "面部光照 / SDF", "面部二分光照与鼻影")
    ];

    private void RefreshComputed()
    {
        OnPropertiesChanged(
            nameof(Role), nameof(RoleLabel), nameof(RoleDescription), nameof(TextureContract), nameof(IsActive),
            nameof(SupportsHairSettings), nameof(SupportsMatCaps), nameof(SupportsZWrite), nameof(SelectedZWriteChoice));
        RefreshTextureSlots();
    }

    private void RefreshTextureSlots()
    {
        foreach (var slot in TextureSlots) slot.Refresh();
        OnPropertiesChanged(nameof(UsePmxBaseTexture), nameof(PmxBaseTexture));
    }

    private static IReadOnlyList<ChoiceItem<MaterialRole>> CreateRoleChoices() =>
        Enum.GetValues<MaterialRole>().Select(role => new ChoiceItem<MaterialRole>(RoleDisplayName(role), role)).ToArray();

    private static string RoleDisplayName(MaterialRole role) => role switch
    {
        MaterialRole.None => "停用",
        MaterialRole.Face => "面部",
        MaterialRole.Iris => "虹膜",
        MaterialRole.EyeHighlight => "瞳外高光",
        MaterialRole.EyeWhite => "眼白",
        MaterialRole.BrowLash => "睫毛与眉毛",
        MaterialRole.Mouth => "口腔",
        MaterialRole.Hair => "头发",
        MaterialRole.Skin => "皮肤",
        MaterialRole.Cloth => "衣服与金属",
        MaterialRole.EyeOverlay => "瞳内光",
        MaterialRole.BrowOverlay => "眼影覆盖",
        MaterialRole.FaceProxy => "旧眼透代理",
        MaterialRole.Hidden => "隐藏",
        _ => role.ToString()
    };

    private static string DescribeRole(MaterialRole role, bool isZzz)
    {
        if (!isZzz) return "当前运行时处于兼容模式，请检查贴图槽与生成结果。";
        return role switch
        {
            MaterialRole.Face => "SDF 面部光照，并与皮肤共享红润 Ramp。",
            MaterialRole.Skin => "使用 N/M/A 与 HgShadow；保留可选的皮肤 MatCap。",
            MaterialRole.Hair => "使用已验收的头发高光、边缘光、阴影与偏移阴影。",
            MaterialRole.Cloth => "衣服和金属使用 N/M/A，并读取五槽 MatCap Profile。",
            MaterialRole.Iris => "虹膜参与眼透捕获，基础贴图提供瞳色。",
            MaterialRole.EyeWhite => "眼白正常绘制，排除在眼透内容之外。",
            MaterialRole.BrowLash => "睫毛和眉毛使用独立层级及远距离深度保护。",
            MaterialRole.EyeOverlay => "瞳内光使用独立自发光覆盖层。",
            MaterialRole.EyeHighlight => "瞳外高光使用独立覆盖层与深度保护。",
            MaterialRole.BrowOverlay => "眼影覆盖层参与眼透，不替代面部绘制。",
            MaterialRole.Mouth => "口腔模板尚未正式验收，建议暂时停用。",
            MaterialRole.None => "不生成材质 FX。",
            MaterialRole.FaceProxy => "仅供旧运行时兼容。",
            MaterialRole.Hidden => "不参与常规角色表面绘制。",
            _ => "请核对材质角色与贴图。"
        };
    }

    private static string DescribeTextureContract(MaterialRole role, bool isZzz)
    {
        if (!isZzz) return "兼容模式会开放旧工程贴图槽。";
        return role switch
        {
            MaterialRole.Face => "需要 Base + SDF。面部不读取 N/M/A 与 MatCap。",
            MaterialRole.Hair => "需要 Base + N + M + A。M.B 控制高光分区。",
            MaterialRole.Skin => "需要 Base + N + M + A。面部和皮肤 Ramp 颜色应一致。",
            MaterialRole.Cloth => "需要 Base + N + M + A，可叠加 MatCap 1..5。",
            MaterialRole.Iris or MaterialRole.EyeWhite or MaterialRole.BrowLash or MaterialRole.EyeHighlight or
                MaterialRole.EyeOverlay or MaterialRole.BrowOverlay => "需要 Base；眼透遮罩按 PMX 材质索引动态生成。",
            _ => "当前角色没有正式贴图契约。"
        };
    }
}
