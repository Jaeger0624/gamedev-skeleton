# PACK 结构化契约 v1（2026-08-25 框架回审 P1″/P2′ 落地规格）

> **原则（红线 8 对齐）**：机器只读**围栏数据块**（```` ```verdicts ```` / ```` ```atoms ````），散文永不解析——O1 的根因（文本解析脆弱性：注记行误收、主清单行漏收）从机制上消灭。数据块=固定格式（白盒原理 3）；人类可读性靠块外 prose 保留。

## verdicts 数据块（放在 `## 适用判据清单` 小节内）

````
```verdicts
# 行格式：slug@level（level=formal|candidate）；# 开头为注释行，解析忽略
mechanic-serves-experience@formal
human-value-change@formal
emotion-al-composite-check@candidate
```
````

- **level 语义**：`formal`=判据库存在且已转正（=正式）；`candidate`=〔候选〕。注入包对 candidate 显式标注「〔候选〕」。
- **存在性校验**（运行期，机制保险）：slug 必须存在于 `$HARNESS/verdicts/<slug>.md`——缺失的剔除并在注入包标注「判据库校验：剔除 N 条（slug 列表）」。校验失败不中断 run_start（剔除+标注）。

## atoms 数据块（放在 `## 原子编排偏好` 小节内）

````
```atoms
# 行格式：阶段名|core:slug,slug|divergent:slug,slug（逗号分隔；空列表=留空）
概念（情感钩子）|core:manufacture-love|divergent:layering
结构（起承转合）|core:kishotenketsu|divergent:causal-reasoning
```
````

- **core**=装备必带：注入包出现为「品类原子（[pack] core）」行（扁平 slug 集，[pack] 标注来源）。
- **divergent**=只列名：注入包出现为「品类发散池（按需抽）」行（一行 slug 列表，不注正文）。
- **阶段名仅供人读**：机器**不按名字映射**到流水线阶段（映射=agent 读 PACK 原文时按牌理执行——PACK 是 unit-design 必读注入）。冲突防膨胀：语义映射是"用哪颗"的判断，属于 agent，不属于装配器。

## 放置与保留

- `## 适用判据清单` / `## 原子编排偏好` 小节：保留一句 prose 概述 + 数据块替换原散文清单/表格；原内容**逐条保留**（数据化不是删内容——内容迁移必须核对，禁止遗漏/改写含义）。
- 其余小节（品类核心张力/流水线清单/演化记录）**保持 prose 不动**。
- `packs/_TEMPLATE.md` 在格式契约处写入本规格说明（新品类包按块填写）。

## 口径

- story / puzzle / strategy-roguelike 三包全部迁移（读原文→逐条搬运→标注 level→核对无遗漏）。
- 迁移后自检：`verdicts 块条目数 == 原文散文清单条目数`；`atoms 块 core/divergent == 原表格内容`。
- 品类适配节（P3″ 内容，story 专用）→ prose 段（agent 读取，不机器解析），见各路任务书。
