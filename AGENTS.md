# AGENTS.md — GameDev-Skeleton 运行协议

> 本文件是 gamedev-harness 的**运行时入口**。任何 agent（WorkBuddy / Codex / Claude Code / DSH 等）进入本项目，必须先读本文件，并按本文件定义的协议行动。
> 全局骨架挂载点：`C:/Users/32337/.workbuddy/gamedev-harness/`（以下记作 `$HARNESS`）。骨架本体跨项目唯一，判据/原子的评分与演化只发生在全局层。

## 0. 最高原则（不可妥协）

harness 不替你思考。它只改变你出发时的**起点**（记忆/上下文）与**方向**（判据/方法/原子编排）。
本协议存在的唯一理由：**让"按流程走"不依赖执行者的自觉**。以下每一步都是义务，不是建议。

## 1. Task 检测（每次接到任务时执行）

| 触发信号（用户意图） | Task 类型 | 进入流水线 |
|---|---|---|
| 设计卡牌/单位/遗物/事件等**具体设计单元** | `unit-design` | `$HARNESS/pipelines/card-batch-design.md` |
| 探讨玩法/立项/概念孵化/未定方向的发散 | `incubation` | `$HARNESS/pipelines/incubation.md`（待建，见 §4） |
| 审查/修改/迭代已有设计产出 | `design-review` | 定位原 run 的检查点，从对应阶段续走 |
| 以上皆非（闲聊/问答/资料查询） | `free` | 不走流水线，但仍适用 §3 义务 |

若无法判断：**问用户，不要猜**。Task 判定错误会污染整条流水线的上下文。

## 2. 上下文注入规则（按 task）

**`unit-design` / `design-review` 必读**（按序）：
1. 本文件（运行协议）
2. `$HARNESS/HARNESS.md`（总纲与白盒五原理）
3. `$HARNESS/memory/narrative-chain.md` 最近 3 条（记忆流：上次从哪出发）
4. `$HARNESS/packs/<品类>/PACK.md`（原子编排与品类判据）
5. 流水线文件（阶段与原子清单）
6. 流水线当前阶段指定的原子文件 `$HARNESS/atoms/*.md`、判据文件 `$HARNESS/verdicts/*.md`

**明确不读**（上下文腐烂治理）：
- `runs/` 下其他任务的存档（除非当前 task 明确引用）
- 与当前设计对象无关的品类包
- 环境原况、磁盘状态等与"当下设计判断"无关的噪音

**`incubation` 必读**：本文件、HARNESS.md、narrative-chain.md 最近 3 条。原子池按需发散，不定清单。

## 3. 义务条款（所有非 free task 适用）

1. **检查点义务**：流水线每完成一个阶段，产出文件写入 `runs/<YYYY-MM-DD>-<任务名>/`，文件名对齐阶段编号（`00-fact-sheet` … `05-review`）。禁止跳阶段、禁止合并产出。
2. **判据挂载义务**：设计初稿中每个关键决策必须挂至少一条 `$HARNESS/verdicts/` 判据作为依据；无判据可挂时，在回顾阶段提出新判据候选。
3. **回写义务**（阶段 5 回顾自检时执行）：
   - 原子使用记录追加到 `$HARNESS/atoms/<对应原子>.md` 的使用记录表
   - 判据有效性记录追加到 `$HARNESS/verdicts/<对应判据>.md`
   - 叙事摘要追加到 `$HARNESS/memory/narrative-chain.md`（格式见该文件头部）
4. **事实义务**：设计对象的事实信息（现有机制/卡池/社区共识）必须先检索核实，禁止臆测。检索结论入 `00-fact-sheet.md` 并注明来源。
5. **减法义务**：终稿前必须逐效果自问"删掉它快乐会不会塌"，减法记录入终稿。

## 4. 骨架缺口登记（执行中遇到即记录）

- `pipelines/incubation.md` 未建——`incubation` task 暂由执行者参照 `card-batch-design.md` 精神即兴，完成后须将过程沉淀为该流水线
- `skeleton/` 三块为空——从真实设计复盘中生长，禁止批量编造
- 双轨检索（BM25+向量）未建——记忆流当前仅时间倒序追加

## 5. 版本纪律

- 本仓库（GameDev-Skeleton）：框架文档 + runs/ 存档，每次 run 完成后提交
- 全局骨架（`$HARNESS`）：每次回写后提交
- Commit message 遵循 conventional commits（feat/fix/docs/refactor/chore）
