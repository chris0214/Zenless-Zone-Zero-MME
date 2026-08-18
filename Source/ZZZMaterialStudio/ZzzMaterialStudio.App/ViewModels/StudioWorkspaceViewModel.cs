using System.Collections.ObjectModel;
using System.ComponentModel;
using System.IO;
using System.Windows.Data;
using EndfieldMaterialStudio.Core;
using ZzzMaterialStudio.App.Infrastructure;

namespace ZzzMaterialStudio.App.ViewModels;

public sealed class StudioWorkspaceViewModel : ObservableObject
{
    private StudioProject? _project;
    private MaterialViewModel? _selectedMaterial;
    private string _selectedControllerGroup = "全部";
    private string _statusText = "请选择 PMX 或打开 ZZZ Studio 工程。";
    private string _logText = string.Empty;
    private string? _currentProjectPath;

    public StudioWorkspaceViewModel()
    {
        ControllerView = CollectionViewSource.GetDefaultView(ControllerBindings);
        ControllerView.Filter = FilterController;
        ControllerGroups.Add("全部");
    }

    public ObservableCollection<MaterialViewModel> Materials { get; } = [];
    public ObservableCollection<ControllerBindingViewModel> ControllerBindings { get; } = [];
    public ObservableCollection<string> ControllerFiles { get; } = [];
    public ObservableCollection<string> ControllerGroups { get; } = [];
    public ICollectionView ControllerView { get; }

    public StudioProject? Project => _project;
    public bool IsProjectLoaded => _project is not null;
    public bool IsProjectEmpty => _project is null;
    public string CurrentProjectPath => _currentProjectPath ?? "尚未保存";
    public string RuntimeDisplay => _project is null ? "未载入" : RuntimeContract.DisplayName(_project.RuntimeKind);
    public bool SupportsDerivedPmx => _project is not null && _project.RuntimeKind != ShaderRuntimeKind.ZzzMme;
    public string MaterialSummary => _project is null
        ? "没有载入模型"
        : $"{Materials.Count} 个材质 · {Materials.Count(item => item.Model.Enabled)} 个启用";

    public string ProjectName
    {
        get => _project?.ProjectName ?? "ZZZCharacter";
        set { if (_project is null || _project.ProjectName == value) return; _project.ProjectName = value; OnPropertiesChanged(nameof(ProjectName), nameof(WindowTitle)); }
    }

    public string WindowTitle => IsProjectLoaded ? $"{ProjectName} · ZZZ Material Studio" : "ZZZ Material Studio";

    public string PmxPath
    {
        get => _project?.PmxPath ?? string.Empty;
        set { if (_project is null || _project.PmxPath == value) return; _project.PmxPath = value; OnPropertyChanged(); }
    }

    public string RuntimeRoot
    {
        get => _project?.RuntimeRoot ?? string.Empty;
        set { if (_project is null || _project.RuntimeRoot == value) return; _project.RuntimeRoot = value; OnPropertyChanged(); }
    }

    public string OutputDirectory
    {
        get => _project?.OutputDirectory ?? string.Empty;
        set { if (_project is null || _project.OutputDirectory == value) return; _project.OutputDirectory = value; OnPropertyChanged(); }
    }

    public string OfficialJsonRoot
    {
        get => _project?.OfficialJsonRoot ?? string.Empty;
        set { if (_project is null || _project.OfficialJsonRoot == value) return; _project.OfficialJsonRoot = value; OnPropertyChanged(); }
    }

    public string ControllerRoot
    {
        get => _project?.ControllerRoot ?? string.Empty;
        set { if (_project is null || _project.ControllerRoot == value) return; _project.ControllerRoot = value; OnPropertyChanged(); }
    }

    public string HeadBone
    {
        get => _project?.HeadBone ?? "頭";
        set { if (_project is null || _project.HeadBone == value) return; _project.HeadBone = value; OnPropertyChanged(); }
    }

    public bool EnableEyeThrough
    {
        get => _project?.EnableEyeThrough == true;
        set { if (_project is null || _project.EnableEyeThrough == value) return; _project.EnableEyeThrough = value; OnPropertyChanged(); }
    }

    public bool GenerateDerivedPmx
    {
        get => _project?.GenerateDerivedPmx == true;
        set
        {
            if (_project is null) return;
            var normalized = SupportsDerivedPmx && value;
            if (_project.GenerateDerivedPmx == normalized) return;
            _project.GenerateDerivedPmx = normalized;
            OnPropertyChanged();
        }
    }

    public bool PreferManualMatCap
    {
        get => _project?.PreferManualMatCap != false;
        set
        {
            if (_project is null || _project.PreferManualMatCap == value) return;
            _project.PreferManualMatCap = value;
            foreach (var material in _project.Materials) material.Zzz.PreferManualMatCap = value;
            OnPropertyChanged();
        }
    }

    public MaterialViewModel? SelectedMaterial
    {
        get => _selectedMaterial;
        set => SetProperty(ref _selectedMaterial, value);
    }

    public string SelectedControllerGroup
    {
        get => _selectedControllerGroup;
        set
        {
            if (!SetProperty(ref _selectedControllerGroup, value)) return;
            ControllerView.Refresh();
            OnPropertyChanged(nameof(ControllerSummary));
        }
    }

    public string ControllerSummary
    {
        get
        {
            var visible = ControllerView.Cast<object>().Count();
            var enabled = ControllerBindings.Count(binding => binding.Enabled);
            return $"共 {ControllerBindings.Count} 项 · 当前 {visible} 项 · 启用 {enabled} 项";
        }
    }

    public string StatusText
    {
        get => _statusText;
        set => SetProperty(ref _statusText, value);
    }

    public string LogText
    {
        get => _logText;
        private set => SetProperty(ref _logText, value);
    }

    public void LoadProject(StudioProject project, string? projectPath = null)
    {
        ProjectFactory.Normalize(project);
        _project = project;
        _currentProjectPath = projectPath;

        Materials.Clear();
        foreach (var material in project.Materials.OrderBy(material => material.MaterialIndex))
            Materials.Add(new MaterialViewModel(material, project.RuntimeKind));
        SelectedMaterial = Materials.FirstOrDefault();

        ReplaceControllerFiles(project.ControllerFiles);
        ReplaceControllerBindings(project.ControllerBindings);
        RaiseProjectProperties();
        StatusText = $"已载入 {Materials.Count} 个 PMX 材质 · {RuntimeContract.DisplayName(project.RuntimeKind)}。";
    }

    public StudioProject Commit()
    {
        if (_project is null) throw new InvalidOperationException("尚未载入工程。");
        _project.ProjectName = string.IsNullOrWhiteSpace(_project.ProjectName) ? "ZZZCharacter" : _project.ProjectName.Trim();
        _project.HeadBone = string.IsNullOrWhiteSpace(_project.HeadBone) ? "頭" : _project.HeadBone.Trim();
        _project.ControllerFiles = ControllerFiles.ToList();
        _project.ControllerBindings = ControllerBindings.Select(binding => binding.Model).ToList();
        foreach (var material in _project.Materials) material.Zzz.PreferManualMatCap = _project.PreferManualMatCap;
        if (!string.IsNullOrWhiteSpace(_project.RuntimeRoot))
            _project.RuntimeKind = RuntimeContract.Detect(Path.GetFullPath(_project.RuntimeRoot));
        if (_project.RuntimeKind == ShaderRuntimeKind.ZzzMme) _project.GenerateDerivedPmx = false;
        return _project;
    }

    public void MarkSaved(string path)
    {
        _currentProjectPath = Path.GetFullPath(path);
        OnPropertyChanged(nameof(CurrentProjectPath));
    }

    public void SetRuntime(string root, ShaderRuntimeKind kind)
    {
        if (_project is null) return;
        _project.RuntimeRoot = Path.GetFullPath(root);
        _project.RuntimeKind = kind;
        if (kind == ShaderRuntimeKind.ZzzMme) _project.GenerateDerivedPmx = false;
        foreach (var material in Materials) material.SetRuntimeKind(kind);
        OnPropertiesChanged(nameof(RuntimeRoot), nameof(RuntimeDisplay), nameof(SupportsDerivedPmx), nameof(GenerateDerivedPmx));
    }

    public void RefreshMaterials(bool preserveSelection = true)
    {
        if (_project is null) return;
        var selectedIndex = preserveSelection ? SelectedMaterial?.MaterialIndex : null;
        Materials.Clear();
        foreach (var material in _project.Materials.OrderBy(material => material.MaterialIndex))
            Materials.Add(new MaterialViewModel(material, _project.RuntimeKind));
        SelectedMaterial = selectedIndex.HasValue
            ? Materials.FirstOrDefault(material => material.MaterialIndex == selectedIndex.Value) ?? Materials.FirstOrDefault()
            : Materials.FirstOrDefault();
        OnPropertyChanged(nameof(MaterialSummary));
    }

    public void ReplaceControllerBindings(IEnumerable<ZzzControllerBinding> bindings)
    {
        foreach (var binding in ControllerBindings) binding.PropertyChanged -= OnControllerBindingChanged;
        ControllerBindings.Clear();
        foreach (var binding in bindings)
        {
            var viewModel = new ControllerBindingViewModel(binding);
            viewModel.PropertyChanged += OnControllerBindingChanged;
            ControllerBindings.Add(viewModel);
        }
        RefreshControllerGroups();
    }

    public void ReplaceControllerFiles(IEnumerable<string> files)
    {
        ControllerFiles.Clear();
        foreach (var file in files.Select(Path.GetFileName).Where(file => !string.IsNullOrWhiteSpace(file)))
            ControllerFiles.Add(file!);
    }

    public void SetVisibleControllers(bool enabled)
    {
        foreach (var binding in ControllerView.Cast<ControllerBindingViewModel>()) binding.Enabled = enabled;
        OnPropertyChanged(nameof(ControllerSummary));
    }

    public void AppendLog(string message, bool clear = false)
    {
        var entry = $"[{DateTime.Now:HH:mm:ss}] {message}{Environment.NewLine}";
        LogText = clear ? entry : LogText + entry;
        if (LogText.Length > 250_000) LogText = LogText[^200_000..];
    }

    public void ClearLog() => LogText = string.Empty;

    private bool FilterController(object item) => item is ControllerBindingViewModel binding &&
        (SelectedControllerGroup == "全部" || binding.Group.Equals(SelectedControllerGroup, StringComparison.Ordinal));

    private void RefreshControllerGroups()
    {
        var selected = SelectedControllerGroup;
        ControllerGroups.Clear();
        ControllerGroups.Add("全部");
        foreach (var group in ControllerBindings.Select(binding => binding.Group)
                     .Where(group => !string.IsNullOrWhiteSpace(group))
                     .Distinct(StringComparer.Ordinal)
                     .OrderBy(group => group, StringComparer.Ordinal))
            ControllerGroups.Add(group);
        SelectedControllerGroup = ControllerGroups.Contains(selected) ? selected : "全部";
        ControllerView.Refresh();
        OnPropertyChanged(nameof(ControllerSummary));
    }

    private void OnControllerBindingChanged(object? sender, PropertyChangedEventArgs e)
    {
        if (e.PropertyName == nameof(ControllerBindingViewModel.Enabled)) OnPropertyChanged(nameof(ControllerSummary));
    }

    private void RaiseProjectProperties() => OnPropertiesChanged(
        nameof(Project), nameof(IsProjectLoaded), nameof(IsProjectEmpty), nameof(CurrentProjectPath),
        nameof(ProjectName), nameof(WindowTitle), nameof(PmxPath), nameof(RuntimeRoot), nameof(OutputDirectory),
        nameof(OfficialJsonRoot), nameof(ControllerRoot), nameof(HeadBone), nameof(EnableEyeThrough),
        nameof(GenerateDerivedPmx), nameof(PreferManualMatCap), nameof(RuntimeDisplay),
        nameof(SupportsDerivedPmx), nameof(MaterialSummary), nameof(ControllerSummary));
}
