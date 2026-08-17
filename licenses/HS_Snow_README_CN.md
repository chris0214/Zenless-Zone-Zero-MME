教程：
1. 在 MMD 9.31 x64 + MME 中加载角色 PMX。
2. 加载本目录的 `Snow_controller.pmx`。
3. 以附件加载本目录的 `HgShadow.x`，并开启角色自阴影。
4. 使用 `Tools/SnowBreakShaderTool.exe` 选择本 `HS_Snow` 目录和角色 PMX，生成角色专属 FX。
5. 在 Main 页给角色材质分配生成的 SnowBreak FX；不要使用 `full_HgShadow.fx`。
6. 检查 `HgS_SMap` 和 `HgS_VMap` 两个映射页，排除发影、眼睛、眉毛、口腔与控制器。

MME写：針金P/给你柠檬椰果养乐多你会跟我玩吗/克里斯提亚娜
使用了给你柠檬椰果养乐多你会跟我玩吗老师的控制器，針金P老师的HGshadow作为阴影后端。
特别鸣谢 [**暮雪Official**](https://space.bilibili.com/413219044) 暮雪老师的Unity工程参考
