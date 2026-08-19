# ZZZ Material Studio 通用架构与交付契约

## 1. 目标与边界

`ZZZ Material Studio` 的职责是把已经逐项验收的 ZZZ MME Shader 组织成可复用、可检查、可打包的角色工程，而不是重新实现一套视觉算法。

参数优先级固定为：

1. 用户手动指定。
2. 官方 Unity Material JSON 提供候选值与原始参数。
3. Shader 中性默认值。

GUI 不会用模糊匹配静默替换手动 MatCap，也不会因为某个角色的材质编号可用，就把该编号写死进通用 Shader。正式角色包中的材质索引、贴图和眼透 Subset 都从当前 PMX 工程动态生成。

## 2. 已验收运行时

正式运行时目录为：

```text
M:\MMD相关的\zzz\ZZZ_MME
```

当前交付链复用以下已验收模块：

- `ZZZshadow`：角色投影、自阴影和屏幕空间边缘光。
- Hair：基础色、二分光照、HgShadow、解析式高光、中央遮罩、屏幕边缘光、刘海偏移阴影。
- Face：FaceLight/SDF、鼻影、面部高光、与皮肤共享的红润 Ramp。
- Skin：N/M/A、HgShadow、共享 Ramp、通用 MatCap 数据预留。
- Eye01：虹膜与眼白基础层。
- Eye02：睫毛、眉毛、瞳内光、瞳外高光、眼影覆盖层。
- EyeThrough：原 PMX + 动态 Capture + 动态 HairMask，不生成 ZZZ 派生角色 PMX。
- Cloth：N/M/A、二分阴影、直射高光、五槽 MatCap Profile。
- `ZZZPost`：GT Tonemap 与 Bloom，Tonemap 默认关闭。
- Controller：头发、面部、皮肤、衣服、眼睛、阴影和后处理 PMX 控制器。

SAO 已按视觉验收结论从正式流程移除，避免角色渲染变脏。

## 3. 正式材质角色契约

| 角色 | 正式输入 | 当前行为 |
| --- | --- | --- |
| `Face` | Base + FaceLight/SDF | SDF 面部光照、鼻影、共享肤色 Ramp |
| `Skin` | Base + N + M + A | HgShadow、皮肤明暗、共享肤色 Ramp；保留 MatCap Profile 空间 |
| `Hair` | Base + N + M + A | 已验收头发高光、边缘光、阴影与刘海偏移阴影 |
| `Cloth` | Base + N + M + A + MatCap 1..5 | 衣服/金属通用入口，每材质独立 Profile |
| `Iris` | Base | 虹膜基础层，进入 EyeThrough Eye 集合 |
| `EyeWhite` | Base | 正常绘制，强制排除在眼透内容之外 |
| `BrowLash` | Base | `睫` 进入覆盖层，`眉/二重` 进入眉毛层 |
| `EyeOverlay` | Base | 瞳内光，默认自发光亮度保持验收值 9 |
| `EyeHighlight` | Base | 瞳外高光，包含远距离深度保护 |
| `BrowOverlay` | Base | 眼影覆盖层 |
| `None` | 无 | 不生成材质 FX |
| `Mouth` | 尚未开放 | 正式 Mouth 模板未验收，当前应保持 `None` |
| `FaceProxy` | 旧运行时专用 | 正式 ZZZ 不生成代理材质或派生 PMX |

头发高光的“材质槽 1..5”来自 M 贴图 B 通道的材质分区，不是衣服 MatCap 的五个贴图槽。GUI 会分别提示这两种含义。

## 4. 工程数据模型

当前工程 schema 为 `v4`。每个 `MaterialAssignment` 包含：

- PMX 材质索引、中文名、英文名和角色分类。
- PMX 原始 Base 贴图解析结果。
- Base、Normal、Property、RD、RS、LUT、SDF、ST、ColorMask、LipSpecular、HairLine 槽。
- 独立的 `ZzzMaterialProfile`。
- 五个固定 `MatCapSlotBinding`，槽号严格为 1..5。
- 官方 JSON 的纹理、浮点、整数、颜色和原始属性。
- 头发高光材质槽、增益、中央收窄、边缘光和刘海偏移阴影开关。

MatCap 每槽独立保存：

- 启用状态。
- 来源：`Manual`、`OfficialJson`、`Default`。
- 手动贴图路径。
- 官方 property 名与官方贴图名。
- 精确解析后的本地贴图路径。
- 遮罩通道。
- 强度、颜色、旋转、缩放、UV 偏移和混合模式。

同一角色的不同衣服材质可以选择不同 MatCap；Jane、Miyabi、Burnice 的材质编号和贴图名不会进入正式模板核心。

## 5. 官方 JSON 使用方式

解析入口为 `OfficialMaterialJsonReader`，使用 `System.Text.Json` 读取：

- `m_Shader`
- `m_SavedProperties.m_TexEnvs`
- `m_SavedProperties.m_Floats`
- `m_SavedProperties.m_Ints`
- `m_SavedProperties.m_Colors`

MatCap property 映射固定为：

```text
_MatCapTex  -> 槽 1
_MatCapTex2 -> 槽 2
_MatCapTex3 -> 槽 3
_MatCapTex4 -> 槽 4
_MatCapTex5 -> 槽 5
```

`_MatCapBlendModeN`、`_MatCapAlphaBurstN`、`_SpecIntensity`、`_Metallic` 等参数会完整保留，即使当前 GUI 尚未把每个原始属性都做成控件。

贴图解析只接受文件名或 stem 的精确匹配。同名资源冲突时不猜测；JSON 中的官方名称会保留，并产生可见诊断。

### 5.1 手动优先合并

1. 手动路径非空且 `PreferManualMatCap=true` 时，JSON 只记录候选，不改变实际来源。
2. 手动槽为空时，JSON 可以填入对应的 `_MatCapTex1..5`。
3. JSON 有贴图名但本地没有精确同名资源时，保留官方名称并报告 `OFFICIAL_MATCAP_NOT_FOUND`。
4. 常规 GUI 不提供静默覆盖手动槽的操作。
5. Shader 没有消费的 MatCap 槽仍可保存到工程，供其他角色和后续皮肤/头发模板使用。

每槽 `Intensity` 是角色 Profile 的手动增益，会乘到官方 `_MatCapColorBurstN`，重新读取官方 JSON 时不得重置。Miyabi Body1 的槽 5（`Eff_Matcap_Socks`）在材质 14 与 16 中固定保留验收值 `0.30`；该值属于角色工程，不得写成所有衣服共用的 Runtime 常量。

## 6. 自动分类

分类器先处理眼睛和覆盖层，再处理头发、精确短名称、皮肤、面部和衣服。歧义短名称只按完整名称判断，避免宽泛的单字包含规则误伤其他材质。

当前已锁定的中文短名称包括：

- Hair：`发`、`刘海`、`额发`、`辫发`。
- Skin：`肌`、`肌1`、`肌2`、`耳`。
- Cloth：`饰`、`黑丝`、`体`、`体1`、`体2`、`甲`、`外套`、`套`、`镜`。
- Mouth：`齿`、`舌`、`口` 暂时保持 `None`，等待正式模板。

真实 PMX 回归已经覆盖：

- Jane：23 个材质。
- Miyabi：18 个材质。
- Burnice：19 个材质。

三角色共 60 个材质会逐项比较预期角色，不只测试几个样例字符串。

## 7. 眼透生成

正式 ZZZ 流程固定使用原 PMX：

1. Face/Iris/Eye02/Hair 等材质仍按普通独立 FX 绘制。
2. 打包器动态生成 `ZZZEyeThrough_Capture.fxsub`。
3. 打包器动态生成 `ZZZEyeThrough_HairMask.fxsub`。
4. Capture 使用打包后的面部 Base 图集。
5. 眼白使用空 Subset 哨兵，绝不进入眼透。
6. 眉毛、睫毛、瞳内光、瞳外高光和眼影按材质名及角色分组。
7. 远距离深度偏移保护由已验收 EyeThrough Core 负责。

当前回归锁定的关键 Subset：

| 角色 | Eye | Overlay | Highlight | Brow | HairDepth |
| --- | --- | --- | --- | --- | --- |
| Jane | 8 | 2,9,11 | 10 | 3,4 | 12,13,14 |
| Miyabi | 2,3 | 4,7,9 | 8 | 5,6 | 13 |
| Burnice | 2 | 3,6,8 | 7 | 4,5 | 12,13 |

GUI 中旧版“派生 PMX”按钮只对 Legacy Endfield 运行时开放。选择 `ZZZ_MME` 后，该按钮和选项会自动禁用并清零。

## 8. GUI 行为

### 8.1 材质页

- PMX 导入后执行保守初始分类。
- 右侧显示角色中文说明、JSON 状态和实际槽位契约。
- ZZZ 模式只开放当前角色真正消费的贴图框。
- Legacy 模式保留 RD、LUT、ST 等旧槽位。
- Face 只开放 Base 与 FaceLight/SDF。
- Hair/Skin/Cloth 开放 Base 与 N/M/A。
- Eye01/Eye02 只开放 Base。
- Hair 设置只在 ZZZ Hair 上启用。
- MatCap 编辑只在 ZZZ Hair/Skin/Cloth Profile 上启用；当前正式消费方是 Cloth。

### 8.2 MatCap 表格

每个槽可编辑：

- 启用状态。
- 来源。
- 官方贴图名。
- 手动贴图路径。
- 强度。
- 混合模式。
- 遮罩通道。
- 旋转、缩放、偏移。
- RGB Tint。

手动选择贴图会立即把该槽来源切为 `Manual`。

### 8.3 控制器页

- 从实际 PMX 读取 morph 名，不依赖手写列表猜测。
- 可按全局、阴影、头发、面部、皮肤、衣服、眼睛、MatCap、后处理分组。
- 可以启用或停用单项映射。
- 可以覆盖内部参数键、默认值、最小值和最大值。
- 工程只复制控制器文件列表中实际存在的 PMX。
- EMM 从 `Pmd3` 开始加载控制器，不增加额外 `.x` 附件。

## 9. 打包输出

每个角色包包含：

```text
<Character>_ZZZ/
  Model/
    原 PMX
    PMX 原始依赖贴图
  Material_NNN_<Role>.fx
  generated_json_profiles/
    Material_NNN_ZZZ.inc
    ZZZ_JSON_NeutralMatCap.bmp
  textures/character/
    mNNN_base.*
    mNNN_normal.*
    mNNN_property.*
    mNNN_rs.*
    mNNN_matcap_1..5.*
  ZZZshadow/
  ZZZEyeThrough/
  ZZZPost/
  controller/
  <Character>_自动映射.emm
  controller-map.json
  material-map.json
  <Character>.zzzstudio.json
  材质映射说明.txt
```

规则：

- PMX 原字节复制，不为正式 ZZZ 生成眼透派生 PMX。
- PMX 原始依赖按原相对路径复制到 `Model`。
- GUI 贴图按材质和槽位重命名到 `textures/character`。
- MatCap 按内容哈希去重。
- 每个启用材质生成一个独立 FX。
- 每个正式 ZZZ FX 使用 CP936 输出。
- MME 的嵌套 `#include` 按最外层材质 FX 所在目录解析；Runtime 内引用 `internal` 文件时必须写完整的 `internal/...` 根相对路径。
- 运行时的开发目录 `tools`、`build`、`docs`、`templates` 不进入交付包。
- 原始工程对象不会被打包阶段改写。

## 10. 校验与失败处理

生成前检查：

- 运行时类型与目录契约。
- PMX 与 PMX 原始依赖贴图。
- 每种角色需要的 Base、N/M/A 或 FaceLight/SDF。
- 正式 ZZZ 是否包含完整 `ZZZshadow`。
- 启用眼透时是否包含完整 `ZZZEyeThrough`。
- 未开放角色是否被错误启用。
- MatCap 槽号、重复槽、遮罩通道和数值范围。
- 手动 MatCap 路径是否存在。
- 官方 JSON 与本地贴图是否仍可解析。
- 控制器文件、morph 名和数值范围。

JSON 候选缺图属于警告；正式材质必需贴图缺失、正式附件缺失和未支持角色启用属于错误。

## 11. 自动回归

当前回归包括：

- 已验收 Face/Skin/Eye01/Eye02 模板参数化。
- Hair/Cloth Runtime include 与每材质 Subset。
- 从每个 `Material_*.fx` 递归检查根相对 include 闭包，缺失、越界或第二层错误路径直接使测试失败。
- 瞳内光默认亮度 9。
- Miyabi 官方 JSON 与五槽 MatCap 解析。
- 手动 MatCap 不被 JSON 覆盖。
- 中性 MatCap BMP 的扩展名、文件头与最小尺寸。
- 正式运行时复制与开发目录排除。
- 六个正式控制器 207 个 Morph 的精确读取与 EMM 加载。
- Jane/Miyabi/Burnice 60 个真实材质分类。
- Jane/Miyabi/Burnice 三套真实完整包生成。
- 三角色原 PMX 哈希不变。
- 三角色 Capture/HairMask 精确 Subset。
- 每个正式材质 FX 可严格按 CP936 解码。
- 正式材质 FX 不含源绝对路径或三角色专用资源名。

## 12. 尚未完成

- 正式 Mouth/口腔模板的提取、视觉验收和 GUI 开放。
- 皮肤与头发 MatCap 的正式 Runtime 消费；数据模型和 GUI 槽位已经预留。
- 将更多官方 JSON 高级参数做成结构化 GUI 控件，而不是只保留在 Profile 中。
- 为整角色批量选择官方 JSON 的半自动映射界面；当前按所选材质读取精确候选。
- 最终发布版安装包、版本号与面向普通用户的迁移说明。

这些剩余项不会影响目前已完成的 Hair、Face、Skin、Eye、EyeThrough、Cloth、Shadow 与 Post 角色包打包链。
