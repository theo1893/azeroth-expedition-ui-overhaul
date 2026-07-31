# 实际展示区域门禁

本门禁适用于生成前模拟、正式候选真实排版、runtime 导出和实机验证。它回答
“插件真实对象最终占用哪里、位图的安静展示区在哪里、两者是否相容”，不能用
“Texture 已铺满 Frame”代替。

## 四层区域

每个可见组件都要在同一左上原点、右下排他的 UI 像素坐标系中记录：

1. source／atlas 的可见 Alpha bbox，以及 runtime 实际采样的 UV／cell；
2. 九宫格／三段式装配后的完整视觉边界、装饰端帽和安静内容安全区；
3. provider／Blizzard／pfUI 真实 Frame 在空、最小、典型、最高密度和全部
   支持模式下的动态宽高；
4. 真实 Texture、FontString、Button 可见像素与命中盒，包括第一项、最后一项、
   最长文字、工具条、滚动条和状态覆盖。

展示区检查必须区分：

- `frame coverage`：背景是否无缝覆盖目标 Frame；
- `content conformance`：动态内容是否完全位于指定安静区；
- `interaction conformance`：真实命中盒是否仍在预期位置且未被装饰层接管；
- `preview fidelity`：预演尺寸是否由真实布局公式产生。

前一项通过不能推导后一项通过。

## 尺寸来源

- 从当前仓库的真实实现、manifest、Frame 锚点和布局公式推导尺寸；不得把概念图、
  屏幕截图或人工选择的“好看高度”当作实际 Frame。
- 对用户可配置的字体、行高、缩放或条目上限，至少覆盖默认值和会改变安全区的
  边界值；未知边界必须标为阻塞。
- 空状态也必须检查。若 provider 的空 Frame 小于九宫格声明的最小尺寸，即使
  adapter 会压缩端帽，也属于合同不一致。
- “容量包络图”可以额外存在，但必须明确标记为非真实实例；同一批次仍要提供
  至少一张由真实对象数量和布局公式计算出的精确实例。

## 确定性检查

优先使用：

```bash
conda run -n py312 python \
  .codex/skills/run-aeui-asset-workflow/scripts/validate_display_regions.py \
  /absolute/path/to/display-region-contract.json \
  --report /absolute/path/to/generated/display-region-report.json
```

macOS 之外按主 Skill 的 Python 运行时规则替换解释器。合同采用
`aeui-display-region-contract-v1`，至少包含 atlas 可见区／采样切片、
九宫格端帽、真实场景 Frame、内容 zone 和真实可见 region。

检查器验证：

- atlas 采样是否越界，采样切片是否无重叠、无缺口地覆盖声明的可见区；
- 每个真实 Frame 是否满足九宫格最小尺寸，中心切片是否保持正面积；
- provider 布局公式推导的高度是否等于审查场景高度；
- 真实排版预演尺寸是否等于实际 Frame，而非固定容量画布；
- 每个动态可见区域是否完整落入指定内容／工具／图标安全区。

脚本只证明几何合同；仍需目视检查纹理、接缝、文字可读性和综合色。报告写入
`generated/`，在现有组件 work 中记录合同路径、命令、报告 SHA、通过／失败、
首个失败码和修正边界。

## 门禁结果

以下任一情况均为失败：

- 预演尺寸与真实布局公式不一致；
- 空／最小／典型／最大任一支持状态无法装配；
- atlas 透明 padding 被采样，或有效像素未被任何 slice 使用；
- 动态文字、图标、Button 可见区进入装饰端帽、撕裂边、裁切区或 Frame 外；
- 背景覆盖正确，但最后一行、最长文字或外侧工具 Button 没有安全余量；
- 为了让效果图好看而增加了 runtime 不存在的空白、padding 或固定高度。

失败会阻止候选成为 `candidate-reviewed`，也会阻止 runtime 被视为可进入 P6
实机验收。已有 P5 导出若首次补查失败，保留 P5 文件但标记
`display-region-blocked`，直到 adapter／资产合同修正并重新通过。
