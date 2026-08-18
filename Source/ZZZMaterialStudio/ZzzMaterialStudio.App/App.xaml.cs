using System.Windows;
using System.Windows.Threading;
using ZzzMaterialStudio.App.Infrastructure;

namespace ZzzMaterialStudio.App;

public partial class App : Application
{
    protected override void OnStartup(StartupEventArgs e)
    {
        DispatcherUnhandledException += OnDispatcherUnhandledException;
        AppDomain.CurrentDomain.UnhandledException += OnDomainUnhandledException;
        base.OnStartup(e);
    }

    private static void OnDomainUnhandledException(object sender, UnhandledExceptionEventArgs e)
    {
        if (e.ExceptionObject is Exception exception) AppDiagnostics.Write("AppDomain 未处理异常", exception);
    }

    private static void OnDispatcherUnhandledException(object sender, DispatcherUnhandledExceptionEventArgs e)
    {
        AppDiagnostics.Write("界面未处理异常", e.Exception);
        MessageBox.Show(
            $"界面操作失败，但程序已阻止直接退出。\n\n{e.Exception.Message}\n\n日志：{AppDiagnostics.CurrentLogPath}",
            "ZZZ Material Studio",
            MessageBoxButton.OK,
            MessageBoxImage.Error);
        e.Handled = true;
    }
}
