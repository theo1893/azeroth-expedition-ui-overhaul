# 任务详情内页沟结构部件修订提示词 QL-A2 V2.1

## 元数据

- 类型：`production-edit`
- 状态：固定版本修订、Alpha 清理与离线重组检查已完成，达到 `P3` 候选；
  等待用户视觉复审，尚未成为 source 或 runtime
- 固定执行器：`imagegen-0-143-0`／`@openai/codex@0.143.0`
- 固定执行会话：`019fac8e-bae8-73f2-af89-674e925b0068`
- 首次编辑结果：`ig_0e15261f6bc2a618016a699d6f4f5481919c35afcaa581e3fc`；
  因缺少右内折、缝线仍像竖向构件、两个收口上下堆叠而退回
- 最终候选结果：`ig_0bda33a80800f83f016a699ddd6dbc8191a674cb8b33717482`
- 输入 Image 1：首轮 V2 raw，仅作为待修订画布
- 输入 Image 2：已确认的 `QL-A1` 结构与材质权威
- 母提示词：
  [任务详情内页沟结构部件_生产提示词_QL-A2_v2.md](任务详情内页沟结构部件_生产提示词_QL-A2_v2.md)
- 修订范围：保留上排双页的内部视角与近等宽结构，只重绘下排六组对象
- 本地 raw：`generated/quests/QL-A2/v2/QL-A2_v2_1_raw.png`
- 本地透明候选：`generated/quests/QL-A2/v2/QL-A2_v2.png`
- 本地重组预演：
  `generated/quests/QL-A2/v2/QL-A2_v2_reassembly_preview.png`
- raw：`1536 × 1024` RGB，SHA-256
  `e0f04181a297f37f48dbfd568c374e0578e9cace24106a3adcdee613d5cf57ff`
- 透明候选：`1536 × 1024` RGBA，SHA-256
  `c4f3b41c8108776ddeb69cd092627e605fe2bfa41c28822f491a151cd327a461`
- Alpha：透明／半透明／不透明像素为
  `745186／57546／770132`；可见绿色残留 `0`
- 色键：边缘自动采样为 `#04EE1B`；使用仓库固定 helper 软遮罩、
  `transparent-threshold 32`、`opaque-threshold 110`、
  `edge-contract 2`、`edge-feather 0.5` 与 despill；随后只对下排
  色键污染执行确定性暖色去溢，不改变造型或 Alpha
- 离线对象外接尺寸：左页 `654 × 620`、右页 `657 × 617`、页沟
  `104 × 299`、左内折 `91 × 291`、右内折 `84 × 289`、缝线周期
  `76 × 251`、顶部收口 `150 × 53`、底部收口 `123 × 47`
- 结构检查：双页物理尺寸近等；六个下排对象横向分离；页沟与装订在下，
  双页在上，左右内折最后覆盖；没有外置封脊、皮革底板、跨页横梁或大型端帽
- `42%／58%`：只用于 runtime 左／右文字阅读安全区，不改变物理页面宽度
- 禁止用途：未经用户确认不得进入 `assets/source/` 或 addon runtime

下面“已确认修订提示词正文”是提交给固定执行器的完整创作提示词。绝对路径、
Image 1／Image 2 映射和保存位置只作为独立 `Execution instruction` 传入。

## 已确认修订提示词正文

修订 Image 1 的 Turtle WoW 1.18.1 香草时代手绘位图 UI 组件源画布。Image 1
是首轮 `QL-A2 V2` 画布；Image 2 是已经确认的 `QL-A1` 打开任务簿结构与
材质权威。

上排两张近似等宽纸页已经正确表达打开书本的内部视角、相反方向的内缘弯曲
与左暗右亮的纸张关系，必须完整保留其形状、位置、比例、材质、光照、磨损和
纯绿色背景，不新增书脊、页叠、文字或控件。

只重绘下排。清除 Image 1 下排现有的所有六组结构件以及它们的阴影和残留，
恢复完全均匀的纯 `#00FF00` 背景，再沿同一水平中线从左到右放置精确六组
互不接触的对象。六个单元的中心间距近似相等，每组四周都有连续绿色裁切间隔，
不得把最后两组上下堆叠：

1. 窄而纵向延展的内部页沟底层。它是向下凹陷的深胡桃装订衬布和柔和接触
   阴影，左右边缘渐隐，中央略暗；无明亮完整描边、无凸起边框、无横向绑带，
   中段可纵向平铺。
2. 左页内折过渡层。窄长、以透明／绿色留空为主，左侧旧纸高光向右侧页沟
   阴影渐变；不是独立纸板或完整纸条，不含皮革、毛边和缝线。
3. 右页内折过渡层。对象 2 的结构镜像，右侧旧纸高光向左侧页沟阴影渐变；
   不能简单复制成同向光照，不含皮革、毛边和缝线。
4. 内部装订缝线周期。只保留一至两个粗麻线圈与一小段纵向麻线，线材之外
   必须直接是纯绿色。绝对不允许任何皮革底板、棕色竖条、衬布底板、矩形框、
   木条、金属杆或投向背景的大阴影。线圈的视觉关系应像从纸页下方的窄页沟
   中短暂露出，而不是绑在一根皮带正面。
5. 顶部小型装订收口。一个藏在顶端纸页下方、正面俯视且向下凹入的克制
   麻线结，只比页沟略宽；无横梁、端帽、皮革底座、黄铜件或扇形大阴影。
6. 底部小型装订收口。与对象 5 尺度相同但不是机械复制的麻线结和轻微页缝
   压痕；独立放在第六个横向单元，不得放在对象 5 下方；无页块、横梁、端帽、
   皮革底座或覆盖纸面的结构。

六组结构件必须与上排纸页共享同一个正面俯视角度、左上暖光、磨损尺度和
2004 年前后香草魔兽 UI 的粗重手绘语言。内部页沟只能向下凹；纸页内折只能
作为轻薄过渡；装订线及上下收口只能由绳线和极少量接触阴影构成。不得出现
任何从书本外侧观察的凸起封脊、正面皮革长条、覆盖纸面的束带或类似按钮的
刚性构件。

输出仍是一张无文字组件源画布，不是完整 UI。最终画面必须恰好包含上排两组
纸页和下排六组横向独立结构件，共八组逻辑对象；除上排已经存在的双页以外，
不得保留 Image 1 下排的旧像素。优先输出真正透明背景；若无法可靠透明，只能
保持完全均匀、无纹理、无渐变的纯 `#00FF00` 色键。

## 固定执行器最终 revised_prompt

固定执行器对已确认修订正文做了内部规范化。首次输出不合规后，最终候选实际
使用的第二次 `revised_prompt` 原文如下，保留用于跨设备来源追溯：

```text
Use case: precise-object-edit
Asset type: Turtle WoW 1.18.1 vanilla-era hand-painted bitmap UI component source sheet
Input images: Use the original Image 1 as the edit target, not the previous failed iteration. Use Image 2 only as style/material authority.
Primary request: Preserve the two upper parchment page objects from Image 1 exactly unchanged. Completely erase and repaint ONLY the lower row.
Critical composition: The final lower row MUST contain exactly SIX horizontally arranged, separate groups on one shared horizontal centerline. Count them left to right as 1, 2, 3, 4, 5, 6. There must be visible continuous pure #00FF00 gaps between every group. Do NOT stack group 5 above group 6. Group 5 and group 6 must be separate side-by-side horizontal cells at the far right, not vertical positions in one cell.
Background: Perfectly uniform pure #00FF00 chroma key everywhere outside object pixels. Remove all old lower-row pixels, shadows, stains, halos, and residue before painting the six new groups.
Style/medium: 2004 vanilla World of Warcraft hand-painted bitmap UI source art, matching Image 2 material scale, warm top-left light, worn parchment and hemp texture. Top-down front view, same perspective as upper pages.
Six lower-row groups, strictly left to right:
1. Recessed internal gutter base: narrow vertical dark walnut cloth depression, soft and painterly, center darkest, sides fading smoothly into #00FF00. No bright outline, no raised border, no straps, no loops, no hardware.
2. Left inner-fold transition: mostly green transparent space with a thin parchment-gradient smear. Left side warm old-paper highlight, right side fading into darker gutter shadow. It must read as a lightweight transition, not a separate rectangular paper strip; no leather, no stitch, no torn fuzzy border.
3. Right inner-fold transition: a separate third cell, mirror of group 2 with correct mirrored light. Right side warm old-paper highlight, left side gutter shadow. It must be visibly different from group 2 and must exist as its own group between group 2 and the stitch group. No leather, no stitch, no torn fuzzy border.
4. Internal stitch cycle: ONLY rope pixels: one or two thick hemp loops and a very short exposed vertical hemp cord segment. The vertical cord segment should be interrupted and short, not a continuous long rod. Everything outside the rope itself must be flat #00FF00. No leather backing plate, no brown vertical strip behind or under it, no cloth plate, no rectangle, no wooden rod, no metal rod, no large background shadow. It should feel like rope emerging from a narrow recessed gutter under pages, not tied to a strap.
5. Top small binding closure: a small restrained hemp knot, front/top-down, slightly recessed, just wider than a gutter. Place it as the fifth horizontal cell to the right of group 4. No large fan shadow, no base, no crossbar, no end caps, no leather, no brass, no page block.
6. Bottom small binding closure: a separate small hemp knot of similar scale but not identical, with very slight pressure crease only. Place it as the sixth horizontal cell to the right of group 5 on the SAME lower-row centerline, not below it. No large fan shadow, no base, no crossbar, no end caps, no leather, no brass, no page block.
Avoid: any exterior book spine, front-facing leather strip, raised rigid structure, page-stack slabs, controls, buttons, text, watermark, backing plate behind stitch cycle, or cast shadows spreading over green background.
Final checklist the image must satisfy: two preserved upper pages; six lower groups arranged horizontally; eight logical objects total; group 4 has no backing plate behind the rope; groups 5 and 6 are side-by-side, not stacked.
```
