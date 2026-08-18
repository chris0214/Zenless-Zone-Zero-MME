namespace ZzzMaterialStudio.App.ViewModels;

public sealed record ChoiceItem<T>(string Label, T Value);

public sealed record DepthWriteChoice(string Label, bool? Value);
