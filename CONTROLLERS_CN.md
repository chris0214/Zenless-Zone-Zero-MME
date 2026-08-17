# 控制器说明

六个控制器均为中性 PMX。Morph 默认值为 0，零值不会改变已生成 Shader 的基础画面；MME 通过 `CONTROLOBJECT` 读取 0..1 的滑块值。

## 总览

| 控制器 | Morph | 作用 |
| --- | ---: | --- |
| `ZzzShadow_controller.pmx` | 5 | 投影强度、硬度与关闭 |
| `ZzzHair_controller.pmx` | 48 | 基础色、二分阴影、中央高光、刘海偏移投影 |
| `ZzzFaceSkin_controller.pmx` | 34 | SDF、鼻影、面部高光、共享 Ramp、皮肤高光与边缘光 |
| `ZzzClothMatCap_controller.pmx` | 65 | 衣装明暗、高光、边缘光及五槽 MatCap |
| `ZzzEye_controller.pmx` | 22 | 眼球、瞳内光、眼高光与眼透 |
| `ZzzPost_controller.pmx` | 21 | GT Tonemap、曝光与 Bloom |
| 合计 | 195 | |

## 五槽 MatCap

每个槽固定提供七个 Morph：

```text
球面槽N強+ / 球面槽N強-
球面槽N明+ / 球面槽N明-
球面槽N遮蔽+ / 球面槽N遮蔽-
球面槽N閉
```

- `強`：乘在 JSON `_MatCapColorBurstN` 和 GUI 手动强度之上。
- `明`：只改变 MatCap 采样明度，不改基础色、二分阴影或直射高光。
- `遮蔽`：乘在 `_MatCapAlphaBurstN`、贴图 Alpha 和材质遮罩之上。
- `閉`：仅关闭当前槽，不清除 GUI/JSON 中的贴图绑定。
- `球面全体強+/-`：对五个槽做统一总强度微调。

五槽由材质 M.R 解码的 Material ID 选择，不是五层同时叠加。GUI 负责把贴图与槽位绑定，PMX 控制器不承担离散贴图选择，避免 MME 运行时出现路径和资源状态错误。

## JSON 与控制器的优先级

```text
手动 GUI 贴图选择
  > 官方 JSON 建议贴图
  > 中性空槽

生成 Profile 基础值
  x PMX 控制器运行时乘数
  = 最终 Shader 参数
```

因此可以先用官方 JSON 得到角色原始参数，再在 MMD 中用控制器调亮、压暗、收窄或关闭，且不会回写或破坏 JSON。

## EMM 加载

GUI 生成 EMM 时会把六个控制器作为独立 PMX 项写入，只加载一次。正式 Runtime 不需要额外的头发、衣装或眼睛 `.x` 控制附件。

完整 Morph 名、分组和 SHA-256 位于：

```text
ShaderRuntime/controller/controller-contract.json
```
