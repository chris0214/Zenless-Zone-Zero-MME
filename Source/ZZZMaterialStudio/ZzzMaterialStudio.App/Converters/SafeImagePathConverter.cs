using System.Globalization;
using System.IO;
using System.Windows.Data;
using System.Windows.Media.Imaging;

namespace ZzzMaterialStudio.App.Converters;

public sealed class SafeImagePathConverter : IValueConverter
{
    public object? Convert(object value, Type targetType, object parameter, CultureInfo culture)
    {
        if (value is not string path || string.IsNullOrWhiteSpace(path) || !File.Exists(path)) return null;
        var extension = Path.GetExtension(path).ToLowerInvariant();
        if (extension is not ".png" and not ".jpg" and not ".jpeg" and not ".bmp") return null;

        try
        {
            var image = new BitmapImage();
            image.BeginInit();
            image.CacheOption = BitmapCacheOption.OnLoad;
            image.CreateOptions = BitmapCreateOptions.IgnoreColorProfile;
            image.UriSource = new Uri(Path.GetFullPath(path), UriKind.Absolute);
            image.DecodePixelWidth = 160;
            image.EndInit();
            image.Freeze();
            return image;
        }
        catch
        {
            return null;
        }
    }

    public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture) =>
        Binding.DoNothing;
}
