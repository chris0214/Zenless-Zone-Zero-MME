namespace EndfieldMaterialStudio.Core;

public static class MaterialClassifier
{
    public static MaterialRole Suggest(PmxMaterialInfo material)
    {
        var name = Normalize(material.Name);
        var englishName = Normalize(material.EnglishName);
        var value = name + englishName;

        if (Contains(value, "目透发", "eyeoverlay")) return MaterialRole.EyeOverlay;
        if (Contains(value, "睫眉透发", "browoverlay")) return MaterialRole.BrowOverlay;
        if (Contains(value, "表情", "emotion", "faceproxy", "faceparts", "面部代理")) return MaterialRole.FaceProxy;
        if (Contains(value, "瞳内光", "目内光", "eyeinner", "innerlight")) return MaterialRole.EyeOverlay;
        if (Contains(value, "目影", "眼影", "eyeshadow")) return MaterialRole.BrowOverlay;
        if (Contains(value, "发影", "髪影", "hairshadow")) return MaterialRole.None;
        if (Contains(value, "眼白", "目白", "白目", "sclera", "eyewhite")) return MaterialRole.EyeWhite;
        if (Contains(value, "瞳外光", "目外光", "目hl", "眼hl", "高光", "highlight", "catchlight", "eyehighlight", "eyehl", "outerlight")) return MaterialRole.EyeHighlight;
        if (Contains(value, "睫毛", "睫", "眉毛", "眉", "二重", "eyelash", "eyebrow", "eyelid", "browlash")) return MaterialRole.BrowLash;
        if (Contains(value, "虹膜", "瞳", "眼睛", "目", "iris", "eyebase") && !Contains(value, "面", "face")) return MaterialRole.Iris;
        if (Contains(value, "口内", "口腔", "嘴", "mouth", "teeth", "tongue")) return MaterialRole.Mouth;
        if (name is "发" or "髪" || Contains(value, "头发", "頭髪", "刘海", "额发", "辫发", "髪", "hair")) return MaterialRole.Hair;
        if (name is "饰" or "甲" or "镜" or "体" or "体1" or "体2" or "套" || Contains(value, "黑丝", "外套")) return MaterialRole.Cloth;
        if (name is "耳" or "耳朵" or "耳部" || Contains(value, "皮肤", "皮膚", "肌", "skin", "body") && !Contains(value, "cloth", "衣")) return MaterialRole.Skin;
        if (value is "面" or "脸" or "顔" || Contains(value, "脸", "面部", "顔", "face")) return MaterialRole.Face;
        if (Contains(value, "衣", "布", "服", "裙", "鞋", "靴", "金属", "metal", "cloth", "coat", "dress", "skirt", "shoe", "boot")) return MaterialRole.Cloth;
        return MaterialRole.None;
    }

    private static string Normalize(string value) => value.Replace(" ", string.Empty).Replace("_", string.Empty).ToLowerInvariant();

    private static bool Contains(string value, params string[] tokens) => tokens.Any(value.Contains);
}
