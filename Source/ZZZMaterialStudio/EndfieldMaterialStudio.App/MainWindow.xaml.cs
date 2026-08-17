using System.Collections.ObjectModel;
using System.IO;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using EndfieldMaterialStudio.Core;
using Microsoft.Win32;

namespace EndfieldMaterialStudio.App;

public partial class MainWindow : Window
{
    private StudioProject? _project;
    private MaterialAssignment? _selectedMaterial;
    private bool _updatingEditor;
    private bool _updatingProjectHeader;
    private readonly ObservableCollection<MaterialAssignment> _materials = new();
    private readonly ObservableCollection<ZzzControllerBinding> _controllerBindings = new();
    private readonly ObservableCollection<string> _controllerFiles = new();
    public IReadOnlyList<ZzzValueSource> MatCapSources { get; } = Enum.GetValues<ZzzValueSource>();
    public IReadOnlyList<string> MatCapBlendModes { get; } = new[] { "Official", "AlphaBlend", "Add", "Overlay", "Multiply", "Replace" };
    public IReadOnlyList<string> MatCapMaskChannels { get; } = new[] { "R", "G", "B", "A", "RGB", "RGBA" };
    public IReadOnlyList<int> HairHighlightSlots { get; } = Enumerable.Range(1, 5).ToArray();

    public MainWindow()
    {
        InitializeComponent();
        RoleCombo.ItemsSource = Enum.GetValues<MaterialRole>();
        MaterialsGrid.ItemsSource = _materials;
        ControllerBindingsGrid.ItemsSource = _controllerBindings;
        ControllerFilesList.ItemsSource = _controllerFiles;
        HairHighlightSlotCombo.ItemsSource = HairHighlightSlots;
        RefreshControllerGroups();
        RuntimePathBox.Text = FindRuntimeRoot() ?? string.Empty;
        RefreshRuntimeUi();
        MaterialEditor.IsEnabled = false;
        MatCapsGrid.IsEnabled = false;
        Log("ZZZ Material Studio 已启动。运行时只读，GUI 生成材质 FX、MatCap Profile、控制器映射与 EMM。");
    }

    private void ImportPmx_Click(object sender, RoutedEventArgs e)
        => SelectPmx();

    private void BrowsePmx_Click(object sender, RoutedEventArgs e)
        => SelectPmx();

    private void SelectPmx()
    {
        var dialog = new Microsoft.Win32.OpenFileDialog
        {
            Filter = "PMX 模型 (*.pmx)|*.pmx",
            Title = "选择普通 PMX 模型",
            InitialDirectory = ExistingDirectory(_project?.PmxPath)
        };
        if (dialog.ShowDialog() != true) return;
        var runtime = RuntimePathBox.Text;
        if (!Directory.Exists(runtime))
        {
            runtime = PickFolder("选择已验证的 Shader 运行时文件夹") ?? string.Empty;
            if (!Directory.Exists(runtime)) return;
        }
        var output = Directory.Exists(OutputPathBox.Text)
            ? OutputPathBox.Text
            : Path.Combine(Path.GetDirectoryName(dialog.FileName)!, "ZZZ_Output");
        try
        {
            SetProject(ProjectFactory.Create(dialog.FileName, runtime, output));
            Log($"已导入 PMX：{dialog.FileName}");
            Log("已按材质名称完成初始分类，请逐项确认右侧类型和贴图槽。");
        }
        catch (Exception ex)
        {
            ShowError(ex);
        }
    }

    private void BrowseRuntime_Click(object sender, RoutedEventArgs e)
    {
        var selected = PickFolder("选择 ZZZ_MME 或旧 EndfieldMME 运行时", RuntimePathBox.Text);
        if (selected is null) return;
        var kind = RuntimeContract.Detect(selected);
        var validation = RuntimeContract.Validate(selected, kind);
        var errors = validation.Where(message => message.IsError).ToArray();
        if (errors.Length > 0)
        {
            ShowError(new InvalidDataException(string.Join(Environment.NewLine, errors.Select(message => message.ToString()))));
            return;
        }
        var previousRuntime = _project?.RuntimeRoot;
        RuntimePathBox.Text = selected;
        if (_project is not null)
        {
            var previousKind = _project.RuntimeKind;
            var controllerFilesWereDefault = _controllerFiles.ToHashSet(StringComparer.OrdinalIgnoreCase)
                .SetEquals(ZzzControllerCatalog.CreateDefaultControllerFiles(previousKind));
            _project.RuntimeRoot = selected;
            _project.RuntimeKind = kind;
            if (controllerFilesWereDefault)
            {
                _controllerFiles.Clear();
                foreach (var file in ZzzControllerCatalog.CreateDefaultControllerFiles(kind))
                    _controllerFiles.Add(file);
                _project.ControllerFiles = _controllerFiles.ToList();
            }
            var previousDefaultController = string.IsNullOrWhiteSpace(previousRuntime)
                ? null
                : Path.Combine(previousRuntime, "controller");
            if (string.IsNullOrWhiteSpace(_project.ControllerRoot) ||
                _project.ControllerRoot.Equals(previousDefaultController, StringComparison.OrdinalIgnoreCase))
            {
                _project.ControllerRoot = Path.Combine(selected, "controller");
                ControllerRootBox.Text = _project.ControllerRoot;
                ReloadControllerBindings(preserveOverrides: true);
            }
        }
        Log($"运行时目录：{selected}");
        Log($"运行时类型：{RuntimeContract.DisplayName(kind)}");
        foreach (var message in validation.Where(message => !message.IsError)) Log(message.ToString());
        RefreshRuntimeUi();
    }

    private void BrowseOutput_Click(object sender, RoutedEventArgs e)
    {
        var selected = PickFolder("选择角色包输出目录", OutputPathBox.Text);
        if (selected is null) return;
        OutputPathBox.Text = selected;
        if (_project is not null) _project.OutputDirectory = selected;
        Log($"输出目录：{selected}");
    }

    private void BrowseOfficialJson_Click(object sender, RoutedEventArgs e)
    {
        var selected = PickFolder("选择官方材质 JSON 根目录", OfficialJsonRootBox.Text);
        if (selected is null) return;
        OfficialJsonRootBox.Text = selected;
        if (_project is not null) _project.OfficialJsonRoot = selected;
        Log($"官方 JSON 目录：{selected}");
    }

    private void BrowseControllerRoot_Click(object sender, RoutedEventArgs e)
    {
        var selected = PickFolder("选择控制器 PMX 目录", ControllerRootBox.Text);
        if (selected is null) return;
        ControllerRootBox.Text = selected;
        if (_project is not null) _project.ControllerRoot = selected;
        Log($"控制器目录：{selected}");
        ReloadControllerBindings(preserveOverrides: true);
    }

    private void ApplyOfficialJson_Click(object sender, RoutedEventArgs e)
    {
        if (_project is null || _selectedMaterial is null)
        {
            Log("请先载入工程并选择一个材质。");
            return;
        }
        var root = OfficialJsonRootBox.Text.Trim();
        if (!Directory.Exists(root))
        {
            Log("官方 JSON 目录不存在，请先选择目录。");
            return;
        }
        try
        {
            var candidates = OfficialMaterialJsonReader.FindCandidatePaths(root, _selectedMaterial);
            string jsonPath;
            if (candidates.Count == 0)
            {
                var dialog = new Microsoft.Win32.OpenFileDialog
                {
                    Filter = "官方材质 JSON (*.json)|*.json",
                    Title = $"为 #{_selectedMaterial.MaterialIndex} {_selectedMaterial.MaterialName} 手动选择官方 JSON",
                    InitialDirectory = root
                };
                if (dialog.ShowDialog() != true)
                {
                    Log($"没有找到与 #{_selectedMaterial.MaterialIndex} {_selectedMaterial.MaterialName} 精确匹配的 UI.json，已取消手动选择。");
                    return;
                }
                jsonPath = dialog.FileName;
                Log("材质名没有精确匹配，改用用户手动选择的 JSON。");
            }
            else
            {
                jsonPath = candidates[0];
            }
            var modelDirectory = Path.GetDirectoryName(_project.PmxPath)!;
            var jsonDirectory = Path.GetDirectoryName(jsonPath)!;
            var jsonParent = Directory.GetParent(jsonDirectory)?.FullName ?? jsonDirectory;
            var textureRoots = new[]
            {
                Path.Combine(root, "Textures"),
                Path.Combine(jsonParent, "Textures"),
                root,
                jsonDirectory,
                Path.Combine(modelDirectory, "Textures"),
                modelDirectory,
                Path.Combine(_project.RuntimeRoot, "textures")
            };
            _selectedMaterial.Zzz.PreferManualMatCap = _project.PreferManualMatCap;
            var result = MatCapProfileResolver.Apply(_selectedMaterial, jsonPath, textureRoots);
            RefreshEditor();
            MaterialsGrid.Items.Refresh();
            Log($"已读取官方 JSON：{jsonPath}");
            foreach (var message in result.Messages) Log(message.ToString());
            WriteValidation();
        }
        catch (Exception ex)
        {
            ShowError(ex);
        }
    }

    private void OpenProject_Click(object sender, RoutedEventArgs e)
    {
        var dialog = new Microsoft.Win32.OpenFileDialog { Filter = "ZZZ Studio 工程 (*.zzzstudio.json)|*.zzzstudio.json|旧版工程 (*.endfieldstudio.json)|*.endfieldstudio.json|JSON (*.json)|*.json" };
        if (dialog.ShowDialog() != true) return;
        try
        {
            SetProject(ProjectFactory.Load(dialog.FileName));
            Log($"已打开工程：{dialog.FileName}");
        }
        catch (Exception ex)
        {
            ShowError(ex);
        }
    }

    private void SaveProject_Click(object sender, RoutedEventArgs e)
    {
        if (!CommitHeader()) return;
        var dialog = new Microsoft.Win32.SaveFileDialog
        {
            Filter = "ZZZ Studio 工程 (*.zzzstudio.json)|*.zzzstudio.json",
            FileName = ProjectFactory.SanitizeProjectName(_project!.ProjectName) + ".zzzstudio.json"
        };
        if (dialog.ShowDialog() != true) return;
        try
        {
            ProjectFactory.Save(_project!, dialog.FileName);
            Log($"工程已保存：{dialog.FileName}");
        }
        catch (Exception ex)
        {
            ShowError(ex);
        }
    }

    private void AutoMatch_Click(object sender, RoutedEventArgs e)
    {
        if (_project is null) return;
        var modelDirectory = Path.GetDirectoryName(_project.PmxPath)!;
        var roots = new List<string> { modelDirectory };
        var otherTex = Directory.GetDirectories(modelDirectory, "*", SearchOption.TopDirectoryOnly)
            .FirstOrDefault(path => Path.GetFileName(path).Contains("other tex", StringComparison.OrdinalIgnoreCase));
        if (otherTex is not null) roots.Add(otherTex);
        var runtimeTextures = Path.Combine(_project.RuntimeRoot, "textures");
        if (Directory.Exists(runtimeTextures)) roots.Add(runtimeTextures);
        try
        {
            var matchMessages = TextureAutoMatcher.Assign(_project, overwriteExisting: true, roots.ToArray());
            RefreshEditor();
            MaterialsGrid.Items.Refresh();
            Log($"自动匹配完成。扫描目录：{string.Join("；", roots)}");
            if (matchMessages.Count > 0)
                Log(string.Join(Environment.NewLine, matchMessages));
            WriteValidation();
        }
        catch (Exception ex)
        {
            ShowError(ex);
        }
    }

    private void GenerateEyeThrough_Click(object sender, RoutedEventArgs e)
    {
        if (!CommitHeader()) return;
        if (_project!.RuntimeKind == ShaderRuntimeKind.ZzzMme)
        {
            _project.GenerateDerivedPmx = false;
            DerivedPmxCheck.IsChecked = false;
            Log("正式 ZZZ 眼透直接使用原 PMX；角色包会动态生成 Capture 与 HairMask，不生成派生 PMX。");
            return;
        }
        try
        {
            var result = EyeThroughProjectService.Ensure(_project!);
            RefreshMaterialCollection();
            PmxPathBox.Text = _project!.PmxPath;
            Log($"眼透派生 PMX：{(result.Created ? "新建" : "复用")} {result.DerivedPmxPath}");
            foreach (var overlay in result.Overlays)
                Log($"  #{overlay.OverlayMaterialIndex} {overlay.OverlayMaterialName} <- #{overlay.SourceMaterialIndex} {overlay.SourceMaterialName}");
        }
        catch (Exception ex)
        {
            ShowError(ex);
        }
    }

    private void Validate_Click(object sender, RoutedEventArgs e)
    {
        if (!CommitHeader()) return;
        WriteValidation();
    }

    private void GeneratePackage_Click(object sender, RoutedEventArgs e)
    {
        if (!CommitHeader()) return;
        try
        {
            WriteValidation();
            var result = new PackageBuilder().Build(_project!);
            Log($"生成完成：{result.OutputDirectory}");
            Log($"EMM：{result.EmmPath}");
            Log($"模型：{result.ModelPath}");
            StatusText.Text = "角色包生成完成。";
        }
        catch (Exception ex)
        {
            ShowError(ex);
        }
    }

    private void MaterialsGrid_SelectionChanged(object sender, SelectionChangedEventArgs e)
    {
        _selectedMaterial = MaterialsGrid.SelectedItem as MaterialAssignment;
        RefreshEditor();
    }

    private void RoleCombo_SelectionChanged(object sender, SelectionChangedEventArgs e)
    {
        if (_updatingEditor || _selectedMaterial is null || RoleCombo.SelectedItem is not MaterialRole role) return;
        _selectedMaterial.Role = role;
        MaterialsGrid.Items.Refresh();
        RefreshMaterialRoleUi(_selectedMaterial);
    }

    private void HairSettings_Changed(object sender, RoutedEventArgs e) => CommitHairSettings();

    private void HairSettings_TextChanged(object sender, TextChangedEventArgs e) => CommitHairSettings();

    private void CommitHairSettings()
    {
        if (_updatingEditor || _selectedMaterial is null) return;
        var profile = _selectedMaterial.Zzz;
        if (HairHighlightSlotCombo.SelectedItem is int slot) profile.HairHighlightSlot = slot;
        if (TryParseDouble(HairHighlightGainBox.Text, out var gain)) profile.HairHighlightGain = gain;
        if (TryParseDouble(HairCenterPowerBox.Text, out var centerPower)) profile.HairCenterPower = centerPower;
        profile.HairUseCenterMask = HairCenterMaskCheck.IsChecked == true;
        profile.HairUseScreenRim = HairScreenRimCheck.IsChecked == true;
        profile.HairUseFaceShadow = HairFaceShadowCheck.IsChecked == true;
    }

    private void UsePmxBase_Changed(object sender, RoutedEventArgs e)
    {
        if (_updatingEditor || _selectedMaterial is null) return;
        _selectedMaterial.UsePmxBaseTexture = UsePmxBaseCheck.IsChecked == true;
        RefreshTextureSlotAvailability(_selectedMaterial);
    }

    private void TextureBox_Changed(object sender, TextChangedEventArgs e)
    {
        if (_updatingEditor || _selectedMaterial is null || sender is not TextBox box || box.Tag is not string slot) return;
        SetTexture(_selectedMaterial.Textures, slot, NullIfWhiteSpace(box.Text));
    }

    private void BrowseTexture_Click(object sender, RoutedEventArgs e)
    {
        if (_selectedMaterial is null || sender is not Button button || button.Tag is not string slot) return;
        var dialog = new Microsoft.Win32.OpenFileDialog
        {
            Filter = "贴图|*.png;*.jpg;*.jpeg;*.bmp;*.tga;*.dds|所有文件|*.*",
            InitialDirectory = Path.GetDirectoryName(_project?.PmxPath ?? string.Empty)
        };
        if (dialog.ShowDialog() != true) return;
        SetTexture(_selectedMaterial.Textures, slot, dialog.FileName);
        RefreshEditor();
    }

    private void BrowseMatCap_Click(object sender, RoutedEventArgs e)
    {
        if (sender is not Button button || button.Tag is not MatCapSlotBinding binding) return;
        var dialog = new Microsoft.Win32.OpenFileDialog
        {
            Filter = "MatCap 贴图|*.png;*.jpg;*.jpeg;*.bmp;*.tga;*.dds|所有文件|*.*",
            InitialDirectory = ExistingDirectory(binding.ManualTexturePath) ?? ExistingDirectory(_project?.PmxPath)
        };
        if (dialog.ShowDialog() != true) return;
        binding.ManualTexturePath = dialog.FileName;
        binding.Source = ZzzValueSource.Manual;
        binding.Enabled = true;
        MatCapsGrid.Items.Refresh();
        Log($"MatCap 槽 {binding.Slot} 已改为手动贴图。");
    }

    private void MatCapsGrid_CellEditEnding(object sender, DataGridCellEditEndingEventArgs e)
    {
        if (e.EditAction != DataGridEditAction.Commit || e.Row.Item is not MatCapSlotBinding binding) return;
        Dispatcher.BeginInvoke(() =>
        {
            if (!string.IsNullOrWhiteSpace(binding.ManualTexturePath)) binding.Source = ZzzValueSource.Manual;
            MatCapsGrid.Items.Refresh();
        });
    }

    private void ClearMaterialTextures_Click(object sender, RoutedEventArgs e)
    {
        if (_selectedMaterial is null) return;
        var basePath = _selectedMaterial.Textures.Base;
        _selectedMaterial.Textures = new TextureSlots { Base = basePath };
        RefreshEditor();
    }

    private void ProjectHeader_Changed(object sender, RoutedEventArgs e)
    {
        if (!_updatingProjectHeader) CommitHeader();
    }

    private void ProjectHeader_Changed(object sender, TextChangedEventArgs e)
    {
        if (!_updatingProjectHeader) CommitHeader();
    }

    private bool CommitHeader()
    {
        if (_project is null) return false;
        if (!string.IsNullOrWhiteSpace(RuntimePathBox.Text))
        {
            _project.RuntimeRoot = Path.GetFullPath(RuntimePathBox.Text);
            _project.RuntimeKind = RuntimeContract.Detect(_project.RuntimeRoot);
        }
        if (!string.IsNullOrWhiteSpace(OutputPathBox.Text)) _project.OutputDirectory = Path.GetFullPath(OutputPathBox.Text);
        if (!string.IsNullOrWhiteSpace(OfficialJsonRootBox.Text)) _project.OfficialJsonRoot = Path.GetFullPath(OfficialJsonRootBox.Text);
        if (!string.IsNullOrWhiteSpace(ControllerRootBox.Text)) _project.ControllerRoot = Path.GetFullPath(ControllerRootBox.Text);
        _project.ProjectName = string.IsNullOrWhiteSpace(ProjectNameBox.Text) ? "ZZZCharacter" : ProjectNameBox.Text.Trim();
        _project.HeadBone = string.IsNullOrWhiteSpace(HeadBoneBox.Text) ? "頭" : HeadBoneBox.Text.Trim();
        _project.EnableEyeThrough = EyeThroughCheck.IsChecked == true;
        _project.GenerateDerivedPmx = _project.RuntimeKind != ShaderRuntimeKind.ZzzMme &&
                                      DerivedPmxCheck.IsChecked == true;
        _project.PreferManualMatCap = PreferManualMatCapCheck.IsChecked == true;
        _project.ControllerFiles = _controllerFiles.ToList();
        _project.ControllerBindings = _controllerBindings.ToList();
        foreach (var material in _project.Materials) material.Zzz.PreferManualMatCap = _project.PreferManualMatCap;
        return true;
    }

    private void SetProject(StudioProject project)
    {
        _updatingProjectHeader = true;
        try
        {
            _project = project;
            _selectedMaterial = null;
            PmxPathBox.Text = project.PmxPath;
            RuntimePathBox.Text = project.RuntimeRoot;
            OutputPathBox.Text = project.OutputDirectory;
            OfficialJsonRootBox.Text = project.OfficialJsonRoot;
            ControllerRootBox.Text = project.ControllerRoot;
            HeadBoneBox.Text = project.HeadBone;
            ProjectNameBox.Text = project.ProjectName;
            EyeThroughCheck.IsChecked = project.EnableEyeThrough;
            DerivedPmxCheck.IsChecked = project.GenerateDerivedPmx;
            PreferManualMatCapCheck.IsChecked = project.PreferManualMatCap;
            RefreshControllerEditor();
        }
        finally
        {
            _updatingProjectHeader = false;
        }
        RefreshRuntimeUi();
        RefreshMaterialCollection();
        StatusText.Text = $"已载入 {project.Materials.Count} 个 PMX 材质 · {RuntimeContract.DisplayName(project.RuntimeKind)}。";
        foreach (var message in ProjectValidator.ValidatePmxDependencies(project)
                     .Where(message => message.Code == "PMX_TEXTURE_FALLBACK"))
            Log(message.ToString());
    }

    private void RefreshMaterialCollection()
    {
        _materials.Clear();
        if (_project is not null)
            foreach (var material in _project.Materials.OrderBy(material => material.MaterialIndex)) _materials.Add(material);
        MaterialsGrid.SelectedIndex = _materials.Count > 0 ? 0 : -1;
    }

    private void RefreshControllerEditor()
    {
        _controllerFiles.Clear();
        _controllerBindings.Clear();
        if (_project is not null)
        {
            foreach (var file in _project.ControllerFiles) _controllerFiles.Add(Path.GetFileName(file));
            foreach (var binding in _project.ControllerBindings) _controllerBindings.Add(binding);
        }
        RefreshControllerGroups();
    }

    private void RefreshControllerGroups()
    {
        var selected = ControllerGroupCombo.SelectedItem as string ?? "全部";
        var groups = new[] { "全部" }
            .Concat(_controllerBindings.Select(binding => binding.Group)
                .Where(group => !string.IsNullOrWhiteSpace(group))
                .Distinct(StringComparer.Ordinal)
                .OrderBy(group => group, StringComparer.Ordinal))
            .ToArray();
        ControllerGroupCombo.ItemsSource = groups;
        ControllerGroupCombo.SelectedItem = groups.Contains(selected, StringComparer.Ordinal) ? selected : "全部";
        ApplyControllerFilter();
    }

    private void ApplyControllerFilter()
    {
        var selected = ControllerGroupCombo.SelectedItem as string ?? "全部";
        var view = CollectionViewSource.GetDefaultView(_controllerBindings);
        view.Filter = item => item is ZzzControllerBinding binding &&
                              (selected == "全部" || binding.Group.Equals(selected, StringComparison.Ordinal));
        var visible = view.Cast<object>().Count();
        var enabled = _controllerBindings.Count(binding => binding.Enabled);
        ControllerSummaryText.Text = $"共 {_controllerBindings.Count} 项；当前显示 {visible} 项；启用 {enabled} 项";
    }

    private void ControllerGroupCombo_SelectionChanged(object sender, SelectionChangedEventArgs e) => ApplyControllerFilter();

    private void ReloadControllers_Click(object sender, RoutedEventArgs e)
        => ReloadControllerBindings(preserveOverrides: true);

    private void ReloadControllerBindings(bool preserveOverrides)
    {
        if (_project is null) return;
        _project.ControllerFiles = _controllerFiles.ToList();
        _project.ControllerBindings = _controllerBindings.ToList();
        var discovered = ZzzControllerCatalog.CreateForProject(_project);
        if (discovered.Count == 0)
        {
            Log("没有从当前控制器目录读取到 PMX morph，请检查目录和文件列表。");
            return;
        }

        if (preserveOverrides)
        {
            var existing = _project.ControllerBindings
                .Where(binding => !string.IsNullOrWhiteSpace(binding.ControllerFile) && !string.IsNullOrWhiteSpace(binding.MorphName))
                .GroupBy(ControllerBindingKey, StringComparer.OrdinalIgnoreCase)
                .ToDictionary(group => group.Key, group => group.First(), StringComparer.OrdinalIgnoreCase);
            foreach (var binding in discovered)
            {
                if (!existing.TryGetValue(ControllerBindingKey(binding), out var previous)) continue;
                binding.Enabled = previous.Enabled;
                binding.TargetProperty = previous.TargetProperty;
                binding.Min = previous.Min;
                binding.Max = previous.Max;
                binding.Default = previous.Default;
                binding.Note = previous.Note;
            }
        }

        _project.ControllerBindings = discovered;
        RefreshControllerEditor();
        Log($"已从实际 PMX 重新读取 {_controllerBindings.Count} 个控制器 morph。名称按 PMX 原文保留。");
    }

    private void EnableControllerGroup_Click(object sender, RoutedEventArgs e) => SetVisibleControllerBindings(true);
    private void DisableControllerGroup_Click(object sender, RoutedEventArgs e) => SetVisibleControllerBindings(false);

    private void SetVisibleControllerBindings(bool enabled)
    {
        var view = CollectionViewSource.GetDefaultView(_controllerBindings);
        foreach (var binding in view.Cast<ZzzControllerBinding>()) binding.Enabled = enabled;
        ControllerBindingsGrid.Items.Refresh();
        ApplyControllerFilter();
    }

    private void ControllerBindingsGrid_CellEditEnding(object sender, DataGridCellEditEndingEventArgs e)
        => Dispatcher.BeginInvoke(ApplyControllerFilter);

    private void AddControllerFile_Click(object sender, RoutedEventArgs e)
    {
        if (_project is null) return;
        var dialog = new Microsoft.Win32.OpenFileDialog
        {
            Filter = "PMX 控制器 (*.pmx)|*.pmx",
            Title = "选择要随角色包加载的控制器 PMX",
            InitialDirectory = ExistingDirectory(ControllerRootBox.Text) ?? ExistingDirectory(_project.RuntimeRoot)
        };
        if (dialog.ShowDialog() != true) return;
        var directory = Path.GetDirectoryName(dialog.FileName)!;
        if (!directory.Equals(ControllerRootBox.Text, StringComparison.OrdinalIgnoreCase))
        {
            ControllerRootBox.Text = directory;
            _project.ControllerRoot = directory;
        }
        var fileName = Path.GetFileName(dialog.FileName);
        if (!_controllerFiles.Contains(fileName, StringComparer.OrdinalIgnoreCase)) _controllerFiles.Add(fileName);
        ReloadControllerBindings(preserveOverrides: true);
    }

    private void RemoveControllerFile_Click(object sender, RoutedEventArgs e)
    {
        if (ControllerFilesList.SelectedItem is not string fileName) return;
        _controllerFiles.Remove(fileName);
        ReloadControllerBindings(preserveOverrides: true);
    }

    private void ResetControllerFiles_Click(object sender, RoutedEventArgs e)
    {
        _controllerFiles.Clear();
        foreach (var file in ZzzControllerCatalog.CreateDefaultControllerFiles(
                     _project?.RuntimeKind ?? ShaderRuntimeKind.LegacyEndfield))
            _controllerFiles.Add(file);
        ReloadControllerBindings(preserveOverrides: true);
    }

    private static string ControllerBindingKey(ZzzControllerBinding binding) =>
        $"{Path.GetFileName(binding.ControllerFile)}\u001f{binding.MorphName}";

    private void RefreshEditor()
    {
        _updatingEditor = true;
        try
        {
            MaterialEditor.IsEnabled = _selectedMaterial is not null;
            MatCapsGrid.IsEnabled = false;
            MatCapsExpander.IsEnabled = false;
            if (_selectedMaterial is null)
            {
                SelectedMaterialTitle.Text = "选择一个材质";
                SelectedMaterialHint.Text = string.Empty;
                TextureContractText.Text = string.Empty;
                return;
            }
            var material = _selectedMaterial;
            SelectedMaterialTitle.Text = material.MaterialName;
            var jsonName = string.IsNullOrWhiteSpace(material.Zzz.OfficialJsonPath)
                ? "未读取 JSON"
                : Path.GetFileName(material.Zzz.OfficialJsonPath);
            RoleCombo.SelectedItem = material.Role;
            UsePmxBaseCheck.IsChecked = material.UsePmxBaseTexture;
            BaseBox.Text = material.Textures.Base ?? string.Empty;
            NormalBox.Text = material.Textures.Normal ?? string.Empty;
            PropertyBox.Text = material.Textures.Property ?? string.Empty;
            RdBox.Text = material.Textures.Rd ?? string.Empty;
            RsBox.Text = material.Textures.Rs ?? string.Empty;
            LutBox.Text = material.Textures.Lut ?? string.Empty;
            SdfBox.Text = material.Textures.Sdf ?? string.Empty;
            StBox.Text = material.Textures.St ?? string.Empty;
            ColorMaskBox.Text = material.Textures.ColorMask ?? string.Empty;
            LipSpecularBox.Text = material.Textures.LipSpecular ?? string.Empty;
            HairLineBox.Text = material.Textures.HairLine ?? string.Empty;
            HairHighlightSlotCombo.SelectedItem = material.Zzz.HairHighlightSlot;
            HairHighlightGainBox.Text = material.Zzz.HairHighlightGain.ToString("0.###", System.Globalization.CultureInfo.CurrentCulture);
            HairCenterPowerBox.Text = material.Zzz.HairCenterPower.ToString("0.###", System.Globalization.CultureInfo.CurrentCulture);
            HairCenterMaskCheck.IsChecked = material.Zzz.HairUseCenterMask;
            HairScreenRimCheck.IsChecked = material.Zzz.HairUseScreenRim;
            HairFaceShadowCheck.IsChecked = material.Zzz.HairUseFaceShadow;
            MatCapsGrid.ItemsSource = material.Zzz.MatCaps.OrderBy(binding => binding.Slot).ToList();
            RefreshMaterialRoleUi(material, jsonName);
        }
        finally
        {
            _updatingEditor = false;
        }
    }

    private void RefreshRuntimeUi()
    {
        var kind = _project?.RuntimeKind ?? RuntimeContract.Detect(RuntimePathBox.Text);
        var usesOriginalPmx = kind == ShaderRuntimeKind.ZzzMme;
        EyeThroughDerivedButton.IsEnabled = _project is not null && !usesOriginalPmx;
        DerivedPmxCheck.IsEnabled = !usesOriginalPmx;
        if (usesOriginalPmx)
        {
            DerivedPmxCheck.IsChecked = false;
            if (_project is not null) _project.GenerateDerivedPmx = false;
        }
        if (_selectedMaterial is not null) RefreshMaterialRoleUi(_selectedMaterial);
    }

    private void RefreshMaterialRoleUi(MaterialAssignment material, string? jsonName = null)
    {
        jsonName ??= string.IsNullOrWhiteSpace(material.Zzz.OfficialJsonPath)
            ? "未读取 JSON"
            : Path.GetFileName(material.Zzz.OfficialJsonPath);
        var isZzz = _project?.RuntimeKind == ShaderRuntimeKind.ZzzMme;
        SelectedMaterialHint.Text = $"#{material.MaterialIndex} · {RoleDisplayName(material.Role)} · {jsonName}\n{RoleDescription(material.Role, isZzz)}";
        TextureContractText.Text = TextureContract(material.Role, isZzz);
        HairSettingsExpander.IsEnabled = isZzz && material.Role == MaterialRole.Hair;
        var keepsMatCapProfile = isZzz && material.Role is MaterialRole.Hair or MaterialRole.Skin or MaterialRole.Cloth;
        MatCapsExpander.IsEnabled = keepsMatCapProfile;
        MatCapsGrid.IsEnabled = keepsMatCapProfile;
        RefreshTextureSlotAvailability(material);
    }

    private void RefreshTextureSlotAvailability(MaterialAssignment material)
    {
        var isZzz = _project?.RuntimeKind == ShaderRuntimeKind.ZzzMme;
        var role = material.Role;
        var active = role is not MaterialRole.None and not MaterialRole.FaceProxy and not MaterialRole.Hidden;
        var usesNma = !isZzz || role is MaterialRole.Hair or MaterialRole.Skin or MaterialRole.Cloth;
        var usesFaceLight = !isZzz || role == MaterialRole.Face;

        UsePmxBaseCheck.IsEnabled = active;
        BaseBox.IsEnabled = active && !material.UsePmxBaseTexture;
        BaseBrowseButton.IsEnabled = active && !material.UsePmxBaseTexture;
        SetTextureInputEnabled(NormalBox, NormalBrowseButton, active && usesNma);
        SetTextureInputEnabled(PropertyBox, PropertyBrowseButton, active && usesNma);
        SetTextureInputEnabled(RsBox, RsBrowseButton, active && usesNma);
        SetTextureInputEnabled(SdfBox, SdfBrowseButton, active && usesFaceLight);

        var legacyOnly = active && !isZzz;
        SetTextureInputEnabled(RdBox, RdBrowseButton, legacyOnly);
        SetTextureInputEnabled(LutBox, LutBrowseButton, legacyOnly);
        SetTextureInputEnabled(StBox, StBrowseButton, legacyOnly);
        SetTextureInputEnabled(ColorMaskBox, ColorMaskBrowseButton, legacyOnly);
        SetTextureInputEnabled(LipSpecularBox, LipSpecularBrowseButton, legacyOnly);
        SetTextureInputEnabled(HairLineBox, HairLineBrowseButton, legacyOnly);
    }

    private static void SetTextureInputEnabled(TextBox box, Button button, bool enabled)
    {
        box.IsEnabled = enabled;
        button.IsEnabled = enabled;
    }

    private static string RoleDisplayName(MaterialRole role) => role switch
    {
        MaterialRole.None => "停用",
        MaterialRole.Face => "面部 / Face",
        MaterialRole.Iris => "虹膜 / Iris",
        MaterialRole.EyeHighlight => "瞳外高光",
        MaterialRole.EyeWhite => "眼白",
        MaterialRole.BrowLash => "睫毛与眉毛",
        MaterialRole.Mouth => "口腔（待接入）",
        MaterialRole.Hair => "头发",
        MaterialRole.Skin => "皮肤",
        MaterialRole.Cloth => "衣服与金属",
        MaterialRole.EyeOverlay => "瞳内光",
        MaterialRole.BrowOverlay => "眼影覆盖",
        MaterialRole.FaceProxy => "旧眼透代理",
        MaterialRole.Hidden => "隐藏",
        _ => role.ToString()
    };

    private static string RoleDescription(MaterialRole role, bool isZzz)
    {
        if (!isZzz) return "旧 Endfield 兼容模式保留原有多贴图槽与派生 PMX 流程。";
        return role switch
        {
            MaterialRole.Face => "面部使用 SDF 光照，并与皮肤共享同一套红润 Ramp。",
            MaterialRole.Skin => "皮肤使用 N/M/A 与 HgShadow；MatCap 槽会保留，当前模板默认不启用皮肤 MatCap。",
            MaterialRole.Hair => "头发使用已验收高光、边缘光和阴影；高光材质槽来自 M.B 分区。",
            MaterialRole.Cloth => "衣服与金属使用 N/M/A，并消费每材质独立的官方或手动 MatCap Profile。",
            MaterialRole.Iris => "虹膜进入眼透 Eye 集合；基础贴图同时提供瞳色。",
            MaterialRole.EyeWhite => "眼白只正常绘制，强制排除在眼透内容之外。",
            MaterialRole.BrowLash => "睫、眉、二重共用入口；材质名决定睫毛层与眉毛层。",
            MaterialRole.EyeOverlay => "瞳内光使用独立覆盖层，默认自发光亮度为已验收值 9。",
            MaterialRole.EyeHighlight => "瞳外高光使用独立覆盖层和远距离深度保护。",
            MaterialRole.BrowOverlay => "眼影覆盖层参与眼透，但不替代正常面部绘制。",
            MaterialRole.Mouth => "正式 ZZZ Mouth 模板尚未接入，交付工程应保持停用。",
            MaterialRole.None => "不生成材质 FX；适用于当前尚未开放的口腔材质。",
            MaterialRole.FaceProxy => "仅用于旧运行时；正式 ZZZ 不生成派生代理材质。",
            MaterialRole.Hidden => "生成隐藏用途材质，不参与常规角色表面。",
            _ => "请核对材质角色与贴图。"
        };
    }

    private static string TextureContract(MaterialRole role, bool isZzz)
    {
        if (!isZzz) return "旧运行时：按角色启用 RD、RS、LUT、ST、Color Mask、Lip Specular 与 Hair Line。";
        return role switch
        {
            MaterialRole.Face => "正式槽位：Base + FaceLight / SDF。N、M、A 与 MatCap 不参与面部模板。",
            MaterialRole.Hair => "正式槽位：Base + Normal / N + Property / M + Attribute / A。头发高光槽 1..5 是 M.B 材质分区，不是 MatCap 槽。",
            MaterialRole.Skin => "正式槽位：Base + Normal / N + Property / M + Attribute / A。面部与皮肤 Ramp 颜色必须保持一致。",
            MaterialRole.Cloth => "正式槽位：Base + Normal / N + Property / M + Attribute / A + MatCap 1..5。手动贴图优先，JSON 只提供候选。",
            MaterialRole.Iris or MaterialRole.EyeWhite or MaterialRole.BrowLash or
                MaterialRole.EyeHighlight or MaterialRole.EyeOverlay or MaterialRole.BrowOverlay =>
                "正式槽位：Base。眼透 Capture/HairMask 会按当前 PMX 材质索引动态生成。",
            MaterialRole.Mouth => "尚无正式 ZZZ 槽位契约；请保持停用，等待 Mouth 模板验收。",
            _ => "当前角色不生成正式材质 FX。"
        };
    }

    private void WriteValidation()
    {
        if (_project is null) return;
        var messages = ProjectValidator.Validate(_project);
        if (messages.Count == 0)
        {
            Log("检查通过：材质绑定、必要贴图和运行时文件完整。", clear: true);
            StatusText.Text = "检查通过。";
            return;
        }
        Log(string.Join(Environment.NewLine, messages), clear: true);
        var errors = messages.Count(message => message.IsError);
        StatusText.Text = errors == 0 ? $"检查完成：{messages.Count} 条提示。" : $"检查失败：{errors} 个错误。";
    }

    private void Log(string message, bool clear = false)
    {
        if (clear) LogBox.Clear();
        LogBox.AppendText($"[{DateTime.Now:HH:mm:ss}] {message}{Environment.NewLine}");
        LogBox.ScrollToEnd();
    }

    private void ShowError(Exception exception)
    {
        Log($"失败：{exception.Message}");
        StatusText.Text = "操作失败，请查看日志。";
        System.Windows.MessageBox.Show(this, exception.Message, "ZZZ Material Studio", MessageBoxButton.OK, MessageBoxImage.Error);
    }

    private static string? FindRuntimeRoot()
    {
        var current = new DirectoryInfo(AppContext.BaseDirectory);
        while (current is not null)
        {
            foreach (var candidate in new[]
            {
                Path.Combine(current.FullName, "ZZZ_MME"),
                Path.Combine(current.FullName, "EndfieldMME"),
                current.FullName
            })
            {
                if (RuntimeContract.Detect(candidate) != ShaderRuntimeKind.Auto) return candidate;
            }
            current = current.Parent;
        }
        return null;
    }

    private static string? PickFolder(string description, string? initialDirectory = null)
    {
        var dialog = new Microsoft.Win32.OpenFolderDialog
        {
            Title = description,
            Multiselect = false,
            InitialDirectory = Directory.Exists(initialDirectory) ? initialDirectory : null
        };
        return dialog.ShowDialog() == true ? dialog.FolderName : null;
    }

    private static string? ExistingDirectory(string? path)
    {
        if (string.IsNullOrWhiteSpace(path)) return null;
        if (Directory.Exists(path)) return path;
        var directory = Path.GetDirectoryName(path);
        return Directory.Exists(directory) ? directory : null;
    }

    private static string? NullIfWhiteSpace(string value) => string.IsNullOrWhiteSpace(value) ? null : value.Trim();

    private static bool TryParseDouble(string value, out double result) =>
        double.TryParse(value, System.Globalization.NumberStyles.Float, System.Globalization.CultureInfo.CurrentCulture, out result) ||
        double.TryParse(value, System.Globalization.NumberStyles.Float, System.Globalization.CultureInfo.InvariantCulture, out result);

    private static void SetTexture(TextureSlots textures, string slot, string? value)
    {
        switch (slot)
        {
            case "Base": textures.Base = value; break;
            case "Normal": textures.Normal = value; break;
            case "Property": textures.Property = value; break;
            case "Rd": textures.Rd = value; break;
            case "Rs": textures.Rs = value; break;
            case "Lut": textures.Lut = value; break;
            case "Sdf": textures.Sdf = value; break;
            case "St": textures.St = value; break;
            case "ColorMask": textures.ColorMask = value; break;
            case "LipSpecular": textures.LipSpecular = value; break;
            case "HairLine": textures.HairLine = value; break;
        }
    }
}
