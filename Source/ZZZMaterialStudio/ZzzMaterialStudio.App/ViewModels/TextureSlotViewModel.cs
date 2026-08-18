using ZzzMaterialStudio.App.Infrastructure;

namespace ZzzMaterialStudio.App.ViewModels;

public sealed class TextureSlotViewModel : ObservableObject
{
    private readonly MaterialViewModel _owner;

    public TextureSlotViewModel(MaterialViewModel owner, string key, string label, string hint)
    {
        _owner = owner;
        Key = key;
        Label = label;
        Hint = hint;
    }

    public string Key { get; }
    public string Label { get; }
    public string Hint { get; }

    public string Value
    {
        get => _owner.GetTexture(Key) ?? string.Empty;
        set
        {
            var normalized = string.IsNullOrWhiteSpace(value) ? null : value.Trim();
            if (string.Equals(_owner.GetTexture(Key), normalized, StringComparison.Ordinal)) return;
            _owner.SetTexture(Key, normalized);
            OnPropertyChanged();
        }
    }

    public bool IsEnabled => _owner.IsTextureEnabled(Key);

    public void Refresh()
    {
        OnPropertyChanged(nameof(Value));
        OnPropertyChanged(nameof(IsEnabled));
    }
}
