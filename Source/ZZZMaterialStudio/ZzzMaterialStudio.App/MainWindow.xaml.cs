using System.Diagnostics;
using System.IO;
using System.Windows;
using System.Windows.Controls;
using EndfieldMaterialStudio.Core;
using Microsoft.Win32;
using ZzzMaterialStudio.App.Infrastructure;
using ZzzMaterialStudio.App.ViewModels;

namespace ZzzMaterialStudio.App;

public partial class MainWindow : Window
{
    private readonly StudioWorkspaceViewModel _workspace = new();
    private readonly string? _defaultRuntimeRoot;

    public MainWindow()
    {
        InitializeComponent();
        DataContext = _workspace;
        _defaultRuntimeRoot = FindRuntimeRoot();
        AppendLog("ZZZ Material Studio 4 已启动。新界面不再使用旧版 DataGrid MatCap 编辑器。");
        if (_defaultRuntimeRoot is not null) AppendLog($"已发现运行时：{_defaultRuntimeRoot}");
    }

    private void ImportPmx_Click(object sender, RoutedEventArgs e)
    {
        var dialog = new OpenFileDialog
        {
            Filter = "PMX 模型 (*.pmx)|*.pmx",
            Title = "选择普通 PMX 模型",
            InitialDirectory = ExistingDirectory(_workspace.PmxPath)
        };
        if (dialog.ShowDialog(this) != true) return;

        try
        {
            var runtime = Directory.Exists(_workspace.RuntimeRoot)
                ? _workspace.RuntimeRoot
                : _defaultRuntimeRoot;
            if (!Directory.Exists(runtime)) runtime = PickFolder("选择 ZZZ_MME 运行时文件夹");
            if (!Directory.Exists(runtime)) return;

            var validation = RuntimeContract.Validate(runtime, RuntimeContract.Detect(runtime));
            var errors = validation.Where(message => message.IsError).ToArray();
            if (errors.Length > 0)
                throw new InvalidDataException(string.Join(Environment.NewLine, errors.Select(message => message.ToString())));

            var output = Directory.Exists(_workspace.OutputDirectory)
                ? _workspace.OutputDirectory
                : Path.Combine(Path.GetDirectoryName(dialog.FileName)!, "ZZZ_Output");
            var project = ProjectFactory.Create(dialog.FileName, runtime, output);
            _workspace.LoadProject(project);
            AppendLog($"已导入 PMX：{dialog.FileName}");
            AppendLog("已完成材质初始分类，请在材质工作区逐项确认角色、贴图与 MatCap。");
            foreach (var message in validation.Where(message => !message.IsError)) AppendLog(message.ToString());
            WorkspaceTabs.SelectedIndex = 1;
        }
        catch (Exception exception)
        {
            ShowError("导入 PMX", exception);
        }
    }

    private void OpenProject_Click(object sender, RoutedEventArgs e)
    {
        var dialog = new OpenFileDialog
        {
            Filter = "ZZZ Studio 工程 (*.zzzstudio.json)|*.zzzstudio.json|旧版工程 (*.endfieldstudio.json)|*.endfieldstudio.json|JSON (*.json)|*.json",
            Title = "打开 ZZZ Studio 工程"
        };
        if (dialog.ShowDialog(this) != true) return;

        try
        {
            _workspace.LoadProject(ProjectFactory.Load(dialog.FileName), dialog.FileName);
            AppendLog($"已打开工程：{dialog.FileName}");
            LogTextureFallbacks();
        }
        catch (Exception exception)
        {
            ShowError("打开工程", exception);
        }
    }

    private void SaveProject_Click(object sender, RoutedEventArgs e)
    {
        if (_workspace.Project is null) return;
        var dialog = new SaveFileDialog
        {
            Filter = "ZZZ Studio 工程 (*.zzzstudio.json)|*.zzzstudio.json",
            DefaultExt = ".zzzstudio.json",
            AddExtension = true,
            FileName = ProjectFactory.SanitizeProjectName(_workspace.ProjectName) + ".zzzstudio.json",
            InitialDirectory = ExistingDirectory(_workspace.CurrentProjectPath)
        };
        if (dialog.ShowDialog(this) != true) return;

        try
        {
            var project = CommitProjectPaths();
            ProjectFactory.Save(project, dialog.FileName);
            _workspace.MarkSaved(dialog.FileName);
            _workspace.StatusText = "工程已保存。";
            AppendLog($"工程已保存：{dialog.FileName}");
        }
        catch (Exception exception)
        {
            ShowError("保存工程", exception);
        }
    }

    private void BrowseRuntime_Click(object sender, RoutedEventArgs e)
    {
        if (_workspace.Project is null) return;
        var selected = PickFolder("选择 ZZZ_MME 运行时", _workspace.RuntimeRoot);
        if (selected is null) return;

        try
        {
            var kind = RuntimeContract.Detect(selected);
            var validation = RuntimeContract.Validate(selected, kind);
            var errors = validation.Where(message => message.IsError).ToArray();
            if (errors.Length > 0)
                throw new InvalidDataException(string.Join(Environment.NewLine, errors.Select(message => message.ToString())));

            var project = _workspace.Project;
            var previousRuntime = project.RuntimeRoot;
            var previousKind = project.RuntimeKind;
            var filesWereDefault = _workspace.ControllerFiles.ToHashSet(StringComparer.OrdinalIgnoreCase)
                .SetEquals(ZzzControllerCatalog.CreateDefaultControllerFiles(previousKind));
            _workspace.SetRuntime(selected, kind);

            if (filesWereDefault)
                _workspace.ReplaceControllerFiles(ZzzControllerCatalog.CreateDefaultControllerFiles(kind));

            var previousDefaultController = string.IsNullOrWhiteSpace(previousRuntime)
                ? null
                : Path.Combine(previousRuntime, "controller");
            if (string.IsNullOrWhiteSpace(project.ControllerRoot) ||
                project.ControllerRoot.Equals(previousDefaultController, StringComparison.OrdinalIgnoreCase))
            {
                _workspace.ControllerRoot = Path.Combine(selected, "controller");
                ReloadControllerBindings(preserveOverrides: true);
            }

            AppendLog($"运行时目录：{selected}");
            AppendLog($"运行时类型：{RuntimeContract.DisplayName(kind)}");
            foreach (var message in validation.Where(message => !message.IsError)) AppendLog(message.ToString());
        }
        catch (Exception exception)
        {
            ShowError("切换运行时", exception);
        }
    }

    private void BrowseOutput_Click(object sender, RoutedEventArgs e)
    {
        var selected = PickFolder("选择角色包输出目录", _workspace.OutputDirectory);
        if (selected is null) return;
        _workspace.OutputDirectory = selected;
        AppendLog($"输出目录：{selected}");
    }

    private void BrowseOfficialJson_Click(object sender, RoutedEventArgs e)
    {
        var selected = PickFolder("选择官方材质 JSON 根目录", _workspace.OfficialJsonRoot);
        if (selected is null) return;
        _workspace.OfficialJsonRoot = selected;
        AppendLog($"官方 JSON 目录：{selected}");
    }

    private void BrowseControllerRoot_Click(object sender, RoutedEventArgs e)
    {
        var selected = PickFolder("选择控制器 PMX 目录", _workspace.ControllerRoot);
        if (selected is null) return;
        _workspace.ControllerRoot = selected;
        AppendLog($"控制器目录：{selected}");
        ReloadControllerBindings(preserveOverrides: true);
    }

    private void ApplyOfficialJson_Click(object sender, RoutedEventArgs e)
    {
        var project = _workspace.Project;
        var selectedMaterial = _workspace.SelectedMaterial;
        if (project is null || selectedMaterial is null) return;
        if (!Directory.Exists(_workspace.OfficialJsonRoot))
        {
            ShowError("读取官方 JSON", new DirectoryNotFoundException("官方 JSON 根目录不存在，请先在工程设置中选择目录。"));
            return;
        }

        try
        {
            var candidates = OfficialMaterialJsonReader.FindCandidatePaths(_workspace.OfficialJsonRoot, selectedMaterial.Model);
            string jsonPath;
            if (candidates.Count == 0)
            {
                var dialog = new OpenFileDialog
                {
                    Filter = "官方材质 JSON (*.json)|*.json",
                    Title = $"为 #{selectedMaterial.MaterialIndex} {selectedMaterial.MaterialName} 选择官方 JSON",
                    InitialDirectory = _workspace.OfficialJsonRoot
                };
                if (dialog.ShowDialog(this) != true) return;
                jsonPath = dialog.FileName;
                AppendLog("未找到材质名精确匹配，已使用手动选择的 JSON。");
            }
            else
            {
                jsonPath = candidates[0];
            }

            var modelDirectory = Path.GetDirectoryName(project.PmxPath)!;
            var jsonDirectory = Path.GetDirectoryName(jsonPath)!;
            var jsonParent = Directory.GetParent(jsonDirectory)?.FullName ?? jsonDirectory;
            var textureRoots = new[]
            {
                Path.Combine(_workspace.OfficialJsonRoot, "Textures"),
                Path.Combine(jsonParent, "Textures"),
                _workspace.OfficialJsonRoot,
                jsonDirectory,
                Path.Combine(modelDirectory, "Textures"),
                modelDirectory,
                Path.Combine(project.RuntimeRoot, "textures")
            };
            selectedMaterial.Model.Zzz.PreferManualMatCap = project.PreferManualMatCap;
            var result = MatCapProfileResolver.Apply(selectedMaterial.Model, jsonPath, textureRoots);
            selectedMaterial.RefreshFromModel();
            AppendLog($"已读取官方 JSON：{jsonPath}");
            foreach (var message in result.Messages) AppendLog(message.ToString());
            WriteValidation();
        }
        catch (Exception exception)
        {
            ShowError("读取官方 JSON", exception);
        }
    }

    private void AutoMatch_Click(object sender, RoutedEventArgs e)
    {
        var project = _workspace.Project;
        if (project is null) return;
        try
        {
            var modelDirectory = Path.GetDirectoryName(project.PmxPath)!;
            var roots = new List<string> { modelDirectory };
            var otherTex = Directory.GetDirectories(modelDirectory, "*", SearchOption.TopDirectoryOnly)
                .FirstOrDefault(path => Path.GetFileName(path).Contains("other tex", StringComparison.OrdinalIgnoreCase));
            if (otherTex is not null) roots.Add(otherTex);
            var runtimeTextures = Path.Combine(project.RuntimeRoot, "textures");
            if (Directory.Exists(runtimeTextures)) roots.Add(runtimeTextures);

            var messages = TextureAutoMatcher.Assign(project, overwriteExisting: true, roots.ToArray());
            foreach (var material in _workspace.Materials) material.RefreshFromModel();
            AppendLog($"自动匹配完成。扫描目录：{string.Join("；", roots)}");
            foreach (var message in messages) AppendLog(message.ToString());
            WriteValidation();
        }
        catch (Exception exception)
        {
            ShowError("自动匹配贴图", exception);
        }
    }

    private void GenerateEyeThrough_Click(object sender, RoutedEventArgs e)
    {
        if (_workspace.Project is null) return;
        try
        {
            var project = CommitProjectPaths();
            if (project.RuntimeKind == ShaderRuntimeKind.ZzzMme)
            {
                project.GenerateDerivedPmx = false;
                _workspace.StatusText = "正式 ZZZ 眼透使用原 PMX。";
                AppendLog("正式 ZZZ 眼透直接使用原 PMX；角色包会动态生成 Capture 与 HairMask，不生成派生 PMX。");
                return;
            }

            var result = EyeThroughProjectService.Ensure(project);
            _workspace.RefreshMaterials();
            AppendLog($"眼透派生 PMX：{(result.Created ? "新建" : "复用")} {result.DerivedPmxPath}");
            foreach (var overlay in result.Overlays)
                AppendLog($"  #{overlay.OverlayMaterialIndex} {overlay.OverlayMaterialName} <- #{overlay.SourceMaterialIndex} {overlay.SourceMaterialName}");
        }
        catch (Exception exception)
        {
            ShowError("生成眼透模型", exception);
        }
    }

    private void Validate_Click(object sender, RoutedEventArgs e)
    {
        if (_workspace.Project is null) return;
        try
        {
            CommitProjectPaths();
            WriteValidation();
            WorkspaceTabs.SelectedIndex = 3;
        }
        catch (Exception exception)
        {
            ShowError("检查工程", exception);
        }
    }

    private void GeneratePackage_Click(object sender, RoutedEventArgs e)
    {
        if (_workspace.Project is null) return;
        try
        {
            var project = CommitProjectPaths();
            var result = new PackageBuilder().Build(project, overwrite: true);
            AppendLog($"生成完成：{result.OutputDirectory}", clear: true);
            AppendLog($"EMM：{result.EmmPath}");
            AppendLog($"模型：{result.ModelPath}");
            AppendLog($"生成文件：{result.GeneratedFiles.Count} 个");
            _workspace.StatusText = "角色包生成完成。";
            WorkspaceTabs.SelectedIndex = 3;
        }
        catch (Exception exception)
        {
            ShowError("生成角色包", exception);
        }
    }

    private void BrowseTexture_Click(object sender, RoutedEventArgs e)
    {
        if (sender is not Button { Tag: TextureSlotViewModel slot }) return;
        try
        {
            var dialog = new OpenFileDialog
            {
                Filter = "贴图|*.png;*.jpg;*.jpeg;*.bmp;*.tga;*.dds|所有文件|*.*",
                Title = $"选择 {slot.Label}",
                InitialDirectory = ExistingDirectory(slot.Value) ?? ExistingDirectory(_workspace.PmxPath)
            };
            if (dialog.ShowDialog(this) != true) return;
            if (!File.Exists(dialog.FileName)) throw new FileNotFoundException("选择的贴图不存在。", dialog.FileName);
            slot.Value = Path.GetFullPath(dialog.FileName);
            AppendLog($"{_workspace.SelectedMaterial?.MaterialName} · {slot.Label}：{slot.Value}");
        }
        catch (Exception exception)
        {
            ShowError("选择贴图", exception);
        }
    }

    private void ClearTexture_Click(object sender, RoutedEventArgs e)
    {
        if (sender is Button { Tag: TextureSlotViewModel slot }) slot.Value = string.Empty;
    }

    private void ClearMaterialTextures_Click(object sender, RoutedEventArgs e)
    {
        _workspace.SelectedMaterial?.ClearTextures();
        AppendLog("已清空当前材质的非基础贴图槽。");
    }

    private void BrowseMatCap_Click(object sender, RoutedEventArgs e)
    {
        if (sender is not Button { Tag: MatCapSlotViewModel slot }) return;
        try
        {
            var dialog = new OpenFileDialog
            {
                Filter = "MatCap 贴图|*.png;*.jpg;*.jpeg;*.bmp;*.tga;*.dds|所有文件|*.*",
                Title = $"选择 {slot.DisplayName} 贴图",
                InitialDirectory = ExistingDirectory(slot.ManualTexturePath) ?? ExistingDirectory(_workspace.PmxPath)
            };
            if (dialog.ShowDialog(this) != true) return;
            if (!File.Exists(dialog.FileName)) throw new FileNotFoundException("选择的 MatCap 贴图不存在。", dialog.FileName);
            slot.SetManualTexture(dialog.FileName);
            AppendLog($"{_workspace.SelectedMaterial?.MaterialName} · {slot.DisplayName} 已切换为手动贴图。");
        }
        catch (Exception exception)
        {
            ShowError("选择 MatCap", exception);
        }
    }

    private void ClearMatCap_Click(object sender, RoutedEventArgs e)
    {
        if (sender is Button { Tag: MatCapSlotViewModel slot }) slot.ClearManualTexture();
    }

    private void ReloadControllers_Click(object sender, RoutedEventArgs e) => ReloadControllerBindings(preserveOverrides: true);

    private void EnableControllerGroup_Click(object sender, RoutedEventArgs e) => _workspace.SetVisibleControllers(true);
    private void DisableControllerGroup_Click(object sender, RoutedEventArgs e) => _workspace.SetVisibleControllers(false);

    private void AddControllerFile_Click(object sender, RoutedEventArgs e)
    {
        if (_workspace.Project is null) return;
        try
        {
            var dialog = new OpenFileDialog
            {
                Filter = "PMX 控制器 (*.pmx)|*.pmx",
                Title = "选择要随角色包加载的控制器 PMX",
                InitialDirectory = ExistingDirectory(_workspace.ControllerRoot) ?? ExistingDirectory(_workspace.RuntimeRoot)
            };
            if (dialog.ShowDialog(this) != true) return;
            var directory = Path.GetDirectoryName(dialog.FileName)!;
            if (!directory.Equals(_workspace.ControllerRoot, StringComparison.OrdinalIgnoreCase))
                _workspace.ControllerRoot = directory;
            var fileName = Path.GetFileName(dialog.FileName);
            if (!_workspace.ControllerFiles.Contains(fileName, StringComparer.OrdinalIgnoreCase))
                _workspace.ControllerFiles.Add(fileName);
            ReloadControllerBindings(preserveOverrides: true);
        }
        catch (Exception exception)
        {
            ShowError("添加控制器", exception);
        }
    }

    private void RemoveControllerFile_Click(object sender, RoutedEventArgs e)
    {
        if (ControllerFilesList.SelectedItem is not string fileName) return;
        _workspace.ControllerFiles.Remove(fileName);
        ReloadControllerBindings(preserveOverrides: true);
    }

    private void ResetControllerFiles_Click(object sender, RoutedEventArgs e)
    {
        _workspace.ReplaceControllerFiles(ZzzControllerCatalog.CreateDefaultControllerFiles(
            _workspace.Project?.RuntimeKind ?? ShaderRuntimeKind.ZzzMme));
        ReloadControllerBindings(preserveOverrides: true);
    }

    private void ReloadControllerBindings(bool preserveOverrides)
    {
        var project = _workspace.Project;
        if (project is null) return;
        try
        {
            project.ControllerFiles = _workspace.ControllerFiles.ToList();
            project.ControllerBindings = _workspace.ControllerBindings.Select(binding => binding.Model).ToList();
            var discovered = ZzzControllerCatalog.CreateForProject(project);
            if (discovered.Count == 0)
            {
                AppendLog("没有从当前控制器目录读取到 PMX morph，请检查目录与文件列表。");
                return;
            }

            if (preserveOverrides)
            {
                var existing = project.ControllerBindings
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

            project.ControllerBindings = discovered;
            _workspace.ReplaceControllerBindings(discovered);
            AppendLog($"已从实际 PMX 重新读取 {discovered.Count} 个控制器 morph。");
        }
        catch (Exception exception)
        {
            ShowError("读取控制器", exception);
        }
    }

    private void ClearLog_Click(object sender, RoutedEventArgs e) => _workspace.ClearLog();

    private void OpenOutputDirectory_Click(object sender, RoutedEventArgs e)
    {
        try
        {
            if (!Directory.Exists(_workspace.OutputDirectory)) Directory.CreateDirectory(_workspace.OutputDirectory);
            Process.Start(new ProcessStartInfo("explorer.exe", _workspace.OutputDirectory) { UseShellExecute = true });
        }
        catch (Exception exception)
        {
            ShowError("打开输出目录", exception);
        }
    }

    private StudioProject CommitProjectPaths()
    {
        var project = _workspace.Commit();
        if (!string.IsNullOrWhiteSpace(project.PmxPath)) project.PmxPath = Path.GetFullPath(project.PmxPath);
        if (!string.IsNullOrWhiteSpace(project.RuntimeRoot)) project.RuntimeRoot = Path.GetFullPath(project.RuntimeRoot);
        if (!string.IsNullOrWhiteSpace(project.OutputDirectory)) project.OutputDirectory = Path.GetFullPath(project.OutputDirectory);
        if (!string.IsNullOrWhiteSpace(project.OfficialJsonRoot)) project.OfficialJsonRoot = Path.GetFullPath(project.OfficialJsonRoot);
        if (!string.IsNullOrWhiteSpace(project.ControllerRoot)) project.ControllerRoot = Path.GetFullPath(project.ControllerRoot);
        return project;
    }

    private void WriteValidation()
    {
        var project = _workspace.Project;
        if (project is null) return;
        var messages = ProjectValidator.Validate(project);
        if (messages.Count == 0)
        {
            AppendLog("检查通过：材质绑定、必要贴图和运行时文件完整。", clear: true);
            _workspace.StatusText = "检查通过。";
            return;
        }

        AppendLog(string.Join(Environment.NewLine, messages), clear: true);
        var errors = messages.Count(message => message.IsError);
        _workspace.StatusText = errors == 0 ? $"检查完成：{messages.Count} 条提示。" : $"检查失败：{errors} 个错误。";
    }

    private void LogTextureFallbacks()
    {
        if (_workspace.Project is null) return;
        foreach (var message in ProjectValidator.ValidatePmxDependencies(_workspace.Project)
                     .Where(message => message.Code == "PMX_TEXTURE_FALLBACK"))
            AppendLog(message.ToString());
    }

    private void AppendLog(string message, bool clear = false)
    {
        _workspace.AppendLog(message, clear);
        Dispatcher.BeginInvoke(() => LogBox.ScrollToEnd());
    }

    private void ShowError(string context, Exception exception)
    {
        AppDiagnostics.Write(context, exception);
        AppendLog($"失败：{context} · {exception.Message}");
        _workspace.StatusText = "操作失败，请查看日志。";
        MessageBox.Show(
            this,
            $"{exception.Message}\n\n详细日志：{AppDiagnostics.CurrentLogPath}",
            "ZZZ Material Studio",
            MessageBoxButton.OK,
            MessageBoxImage.Error);
    }

    private static string ControllerBindingKey(ZzzControllerBinding binding) =>
        $"{Path.GetFileName(binding.ControllerFile)}\u001f{binding.MorphName}";

    private static string? FindRuntimeRoot()
    {
        var current = new DirectoryInfo(AppContext.BaseDirectory);
        while (current is not null)
        {
            foreach (var candidate in new[]
            {
                Path.Combine(current.FullName, "ZZZ_MME"),
                current.FullName
            })
            {
                if (RuntimeContract.Detect(candidate) != ShaderRuntimeKind.Auto) return candidate;
            }
            current = current.Parent;
        }
        return null;
    }

    private string? PickFolder(string title, string? initialDirectory = null)
    {
        var dialog = new OpenFolderDialog
        {
            Title = title,
            Multiselect = false,
            InitialDirectory = Directory.Exists(initialDirectory) ? initialDirectory : null
        };
        return dialog.ShowDialog(this) == true ? dialog.FolderName : null;
    }

    private static string? ExistingDirectory(string? path)
    {
        if (string.IsNullOrWhiteSpace(path)) return null;
        if (Directory.Exists(path)) return path;
        var directory = Path.GetDirectoryName(path);
        return Directory.Exists(directory) ? directory : null;
    }
}
