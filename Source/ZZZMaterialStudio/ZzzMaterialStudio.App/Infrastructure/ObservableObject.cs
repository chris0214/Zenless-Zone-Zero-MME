using System.ComponentModel;
using System.Runtime.CompilerServices;

namespace ZzzMaterialStudio.App.Infrastructure;

public abstract class ObservableObject : INotifyPropertyChanged
{
    public event PropertyChangedEventHandler? PropertyChanged;

    protected bool SetProperty<T>(ref T field, T value, [CallerMemberName] string? propertyName = null)
    {
        if (EqualityComparer<T>.Default.Equals(field, value)) return false;
        field = value;
        OnPropertyChanged(propertyName);
        return true;
    }

    protected void OnPropertyChanged([CallerMemberName] string? propertyName = null) =>
        PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));

    protected void OnPropertiesChanged(params string[] propertyNames)
    {
        foreach (var propertyName in propertyNames) OnPropertyChanged(propertyName);
    }
}
