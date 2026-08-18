using System.IO;
using EndfieldMaterialStudio.Core;
using ZzzMaterialStudio.App.Infrastructure;

namespace ZzzMaterialStudio.App.ViewModels;

public sealed class ControllerBindingViewModel : ObservableObject
{
    public ControllerBindingViewModel(ZzzControllerBinding model) => Model = model;

    public ZzzControllerBinding Model { get; }
    public string ControllerFile => Path.GetFileName(Model.ControllerFile);
    public string Group => Model.Group;
    public string MorphName => Model.MorphName;

    public bool Enabled
    {
        get => Model.Enabled;
        set { if (Model.Enabled == value) return; Model.Enabled = value; OnPropertyChanged(); }
    }

    public string TargetProperty
    {
        get => Model.TargetProperty;
        set { if (Model.TargetProperty == value) return; Model.TargetProperty = value; OnPropertyChanged(); }
    }

    public double Default
    {
        get => Model.Default;
        set { if (Math.Abs(Model.Default - value) < 0.000001) return; Model.Default = value; OnPropertyChanged(); }
    }

    public double Min
    {
        get => Model.Min;
        set { if (Math.Abs(Model.Min - value) < 0.000001) return; Model.Min = value; OnPropertyChanged(); }
    }

    public double Max
    {
        get => Model.Max;
        set { if (Math.Abs(Model.Max - value) < 0.000001) return; Model.Max = value; OnPropertyChanged(); }
    }

    public string Note
    {
        get => Model.Note;
        set { if (Model.Note == value) return; Model.Note = value; OnPropertyChanged(); }
    }
}
