using System.IO;
using EndfieldMaterialStudio.Core;
using ZzzMaterialStudio.App.Infrastructure;

namespace ZzzMaterialStudio.App.ViewModels;

public sealed class MatCapSlotViewModel : ObservableObject
{
    private readonly MatCapSlotBinding _model;

    public MatCapSlotViewModel(MatCapSlotBinding model)
    {
        _model = model;
    }

    public static IReadOnlyList<ChoiceItem<ZzzValueSource>> SourceChoices { get; } =
    [
        new("手动贴图", ZzzValueSource.Manual),
        new("官方 JSON", ZzzValueSource.OfficialJson),
        new("默认值", ZzzValueSource.Default)
    ];

    public static IReadOnlyList<ChoiceItem<string>> BlendModeChoices { get; } =
    [
        new("官方", "Official"),
        new("透明混合", "AlphaBlend"),
        new("相加", "Add"),
        new("叠加", "Overlay"),
        new("正片叠底", "Multiply"),
        new("替换", "Replace")
    ];

    public static IReadOnlyList<string> MaskChannelChoices { get; } = ["R", "G", "B", "A", "RGB", "RGBA"];

    public int Slot => _model.Slot;
    public string DisplayName => $"MatCap {Slot}";

    public bool Enabled
    {
        get => _model.Enabled;
        set { if (_model.Enabled == value) return; _model.Enabled = value; OnPropertyChanged(); }
    }

    public ZzzValueSource Source
    {
        get => _model.Source;
        set
        {
            if (_model.Source == value) return;
            _model.Source = value;
            OnPropertiesChanged(nameof(Source), nameof(EffectiveTexturePath), nameof(SourceDescription));
        }
    }

    public string ManualTexturePath
    {
        get => _model.ManualTexturePath ?? string.Empty;
        set
        {
            var normalized = string.IsNullOrWhiteSpace(value) ? null : value.Trim();
            if (string.Equals(_model.ManualTexturePath, normalized, StringComparison.Ordinal)) return;
            _model.ManualTexturePath = normalized;
            OnPropertiesChanged(nameof(ManualTexturePath), nameof(EffectiveTexturePath));
        }
    }

    public string OfficialTextureName => _model.OfficialTextureName ?? "未指定";
    public string OfficialProperty => _model.OfficialProperty ?? "-";
    public string EffectiveTexturePath => _model.EffectiveTexturePath ?? string.Empty;
    public string SourceDescription => Source switch
    {
        ZzzValueSource.Manual => "使用手动选择的贴图",
        ZzzValueSource.OfficialJson => "使用官方 JSON 解析结果",
        _ => "不绑定外部 MatCap"
    };

    public string MaskChannel
    {
        get => _model.MaskChannel;
        set { if (_model.MaskChannel == value) return; _model.MaskChannel = value; OnPropertyChanged(); }
    }

    public string BlendMode
    {
        get => _model.BlendMode;
        set { if (_model.BlendMode == value) return; _model.BlendMode = value; OnPropertyChanged(); }
    }

    public double Intensity
    {
        get => _model.Intensity;
        set { if (Math.Abs(_model.Intensity - value) < 0.000001) return; _model.Intensity = value; OnPropertyChanged(); }
    }

    public double Rotation
    {
        get => _model.Rotation;
        set { if (Math.Abs(_model.Rotation - value) < 0.000001) return; _model.Rotation = value; OnPropertyChanged(); }
    }

    public double Scale
    {
        get => _model.Scale;
        set { if (Math.Abs(_model.Scale - value) < 0.000001) return; _model.Scale = value; OnPropertyChanged(); }
    }

    public double ScaleY
    {
        get => _model.ScaleY;
        set { if (Math.Abs(_model.ScaleY - value) < 0.000001) return; _model.ScaleY = value; OnPropertyChanged(); }
    }

    public double OffsetX
    {
        get => _model.OffsetX;
        set { if (Math.Abs(_model.OffsetX - value) < 0.000001) return; _model.OffsetX = value; OnPropertyChanged(); }
    }

    public double OffsetY
    {
        get => _model.OffsetY;
        set { if (Math.Abs(_model.OffsetY - value) < 0.000001) return; _model.OffsetY = value; OnPropertyChanged(); }
    }

    public double TintR
    {
        get => _model.Tint.R;
        set { if (Math.Abs(_model.Tint.R - value) < 0.000001) return; _model.Tint.R = value; OnPropertyChanged(); }
    }

    public double TintG
    {
        get => _model.Tint.G;
        set { if (Math.Abs(_model.Tint.G - value) < 0.000001) return; _model.Tint.G = value; OnPropertyChanged(); }
    }

    public double TintB
    {
        get => _model.Tint.B;
        set { if (Math.Abs(_model.Tint.B - value) < 0.000001) return; _model.Tint.B = value; OnPropertyChanged(); }
    }

    public void SetManualTexture(string path)
    {
        ManualTexturePath = Path.GetFullPath(path);
        Source = ZzzValueSource.Manual;
        Enabled = true;
    }

    public void ClearManualTexture()
    {
        ManualTexturePath = string.Empty;
        if (!string.IsNullOrWhiteSpace(_model.ResolvedTexturePath)) Source = ZzzValueSource.OfficialJson;
    }

    public void RefreshFromModel() => OnPropertiesChanged(
        nameof(Enabled), nameof(Source), nameof(ManualTexturePath), nameof(OfficialTextureName),
        nameof(OfficialProperty), nameof(EffectiveTexturePath), nameof(SourceDescription), nameof(MaskChannel),
        nameof(BlendMode), nameof(Intensity), nameof(Rotation), nameof(Scale), nameof(ScaleY),
        nameof(OffsetX), nameof(OffsetY), nameof(TintR), nameof(TintG), nameof(TintB));
}
