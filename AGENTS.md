# AGENTS.md — GameDev-Skeleton 运行协议

> 本文件是 gamedev-harness 的**运行时入口**。任何 agent（WorkBuddy / Codex / Claude Code / DSH 等）进入本项目，必须先读本文件，并按本文件定义的协议行动。
> 全局骨架挂载点：`C:/Users/32337/.gamedev-harness/`（以下记作 `$HARNESS`）。骨架本体跨项目唯一，判据/原子的评分与演化只发生在全局层。
> 注：WorkBuddy 中 `~/.workbuddy/gamedev-harness/` 是指向 `~/.gamedev-harness/` 的符号链接，两者等价。
> 本工作目录定位：**框架核心项目的开发目录**——框架本身即核心项目（开发/规范/生长发生在这里），**不关联任何具体游戏项目**；书籍等成长资料放 `books/<slug>/`（gitignore），读书所得沉淀进全局骨架。
> runs/ 为**框架历史档案**（历史可追溯，保留本目录；未来真实游戏项目的 run 放各自项目目录）；框架**可迁移**——模式（协议/格式/流水线/状态机）可分发，内容（判据/原子/书/项目记录）为个人定制层（待办 H 组）。
> **项目定位权威文档：[`POSITIONING.md`](./POSITIONING.md)**（本项目是什么/为谁/怎么生长/边界在哪——其他文档以其为纲）。

## 0. 最高原则（不可妥协）

harness 不替你思考。它只改变你出发时的**起点**（记忆/上下文）与**方向**（判据/方法/原子编排）。
本协议存在的唯一理由：**让"按流程走"不依赖执行者的自觉**。以下每一步都是义务，不是建议。

## 1. Task 检测（每次接到任务时执行）

| 触发信号（用户意图） | Task 类型 | 进入流水线 |
|---|---|---|
| 设计卡牌/单位/遗物/事件等**具体设计单元** | `unit-design` | `$HARNESS/pipelines/card-batch-design.md` |
| 探讨玩法/立项/概念孵化/未定方向的发散 | `incubation` | `$HARNESS/pipelines/incubation.md`（首版已建，未实测，见 §4） |
| **分享书/文章/讲座/视频，要求提取方法体系或观点并沉淀** | `knowledge-sinking` | `$HARNESS/pipelines/knowledge-sinking.md`（待建，见 §4 与进度文档 E 组） |
| **读书（继续读某本书的一节，交流取舍、沉淀）** | `reading` | `books/<slug>/` 书级状态机 + 阅读轮（见 §2 与进度文档 §5.4/G 组；单节沉淀复用 knowledge-sinking） |
| 审查/修改/迭代已有设计产出 | `design-review` | 定位原 run 的检查点，从对应阶段续走 |
| **框架/插件/契约/骨架结构/协议文件**的改动（本仓库角色：toolkit） | `harness-dev` | 设计流水线不适用；走 §2 开发注入 + §3.6 开发义务 |
| 以上皆非（闲聊/问答/资料查询） | `free` | 不走流水线，但仍适用 §3 义务 |

若无法判断：**问用户，不要猜**。Task 判定错误会污染整条流水线的上下文。

> 本文件所在仓库 = **toolkit 角色**（harness 框架+插件的开发仓库）：默认任务类型是 `harness-dev`；只有显式设计内容才走设计流水线。

## 2. 上下文注入规则（按 task）

**`unit-design` / `design-review` 必读**（按序）：
1. 本文件（运行协议）
2. `$HARNESS/HARNESS.md`（总纲与白盒五原理）
3. 叙事链最近 3 条（**按当前作用域**：项目 run = 项目链 `<项目目录>/narrative-chain.md` + 全局链 `$HARNESS/memory/narrative-chain/_MAIN.md`；框架/读书/跨项目 = 全局链；归档区默认不注入）
4. `$HARNESS/packs/<品类>/PACK.md`（原子编排与品类判据）
5. `$HARNESS/skeleton/_INDEX.md` + 相关块条目（知识层挂载：机制→效果/玩家→体验/我们信什么）
6. 流水线文件（阶段与原子清单）
7. 流水线当前阶段指定的原子文件 `$HARNESS/atoms/*.md`、判据文件 `$HARNESS/verdicts/*.md`

**明确不读**（上下文腐烂治理）：
- `runs/` 下其他任务的存档（除非当前 task 明确引用）
- 与当前设计对象无关的品类包
- 环境原况、磁盘状态等与"当下设计判断"无关的噪音

**`incubation` 必读**：本文件、HARNESS.md、当前作用域叙事链最近 3 条（项目 run 读项目链+全局链；框架/读书读全局链）。原子池按需发散，不定清单。

**`reading` 必读**（每节阅读轮）：①`books/<slug>/book.json` 摘要（元信息/状态/游标/未读清单）②最近 N 轮 `读书日志.md` 摘要（上次读到哪、怎么看的）③当前节正文（只带这一节）④相关现有判据/原子对照（查重）。执行手册见 [`READING-PROTOCOL.md`](./READING-PROTOCOL.md)。
**`reading` 明确不读**：全书全文、其他书、与本书无关的框架内容与环境噪音。
**`reading` 沉淀**：每节全量入账（提取+我的看法+你的判断）；你圈选认同的**当场**走四维审计入库（`harness_atom_propose`/`harness_verdict_propose`/skeleton 写入），来源字段 = 书 + 节 + 页码；每轮叙事链回写一条。

## 3. 义务条款（所有非 free task 适用）

1. **检查点义务**：流水线每完成一个阶段，产出文件写入 `runs/<YYYY-MM-DD>-<任务名>/`，文件名对齐阶段编号（`00-fact-sheet` … `05-review`）。禁止跳阶段、禁止合并产出。
2. **判据挂载义务**：设计初稿中每个关键决策必须挂至少一条 `$HARNESS/verdicts/` 判据作为依据；无判据可挂时，在回顾阶段提出新判据候选。
3. **回写义务**（阶段 5 回顾自检时执行）：
   - 原子使用记录追加到对应叙事链条目（当前作用域：`$HARNESS/memory/narrative-chain/_MAIN.md` 或项目链）的"原子使用明细"段
   - 判据有效性记录追加到 `$HARNESS/verdicts/<对应判据>.md`
   - 叙事摘要追加到当前作用域叙事链（`$HARNESS/memory/narrative-chain/_MAIN.md` 或项目链；格式见该文件头部）——**每条须带「出发自」字段**（可空=全新主题起点；推翻旧决策→指向被推翻条目，对方标注 ⏳已取代）；检查主题段是否终了，终了则提议「归档候选」（主题终了+无活跃引用）→ 用户确认后移入 `archive/`
4. **事实义务**：设计对象的事实信息（现有机制/卡池/社区共识）必须先检索核实，禁止臆测。检索结论入 `00-fact-sheet.md` 并注明来源。
5. **减法义务**：终稿前必须逐效果自问"删掉它快乐会不会塌"，减法记录入终稿。
6. **开发义务**（`harness-dev` 适用；设计流水线/判据挂载/减法义务不适用）：
   - 版本纪律：每次变更提交（conventional commits）；全局骨架每次回写后提交
   - ADR 记录：关键决策/翻案/架构取舍 → `$HARNESS/decisions/<日期>-<主题>.md`（格式见 _INDEX.md 头部）
   - 契约维护：骨架格式/流程文件的变化 → 同步更新适配契约（插件 `ADAPTER.md` 的版本联动节）
   - 叙事链回写：决策摘要/长出的东西 → 当前作用域叙事链（`$HARNESS/memory/narrative-chain/_MAIN.md` 或项目链；append-only）

## 4. 骨架缺口登记（执行中遇到即记录）

- `pipelines/incubation.md` **已建**（2026-08-22 首版沉淀，无实测）——执行首个真实 `incubation` run 后须修订；`pipelines/level-design.md`（单关卡设计）**未建**——puzzle PACK 已引用「待建」
- `skeleton/` 已有 4 条（game-mechanics ×1 / fictional-player ×3；design-philosophy 待生长）——生长来源 = **真实项目复盘 或 外部输入**（书/文章/讲座，须带来源 + 用户圈选确认）；继续禁止无来源编造；条目清单见 `skeleton/_INDEX.md`
- `pipelines/knowledge-sinking.md` **未建**——外部输入沉淀模式（来源提取→拆解→审计→用户圈选→写入）已立规范（见进度文档 §5 与 E 组），首篇输入试跑后沉淀为流水线
- 双轨检索：字面轨**已建**（`harness_recall` BM25 段落检索）；向量轨**未建**——接 DSH mnemon 记忆空间（不自建 embedding）
- 度量闭环**无真实数据**：评分趋势 0 条 / 原子验证 0/3 / 判据有效性无真实 run 行——机制全就位，只欠真实 run 点亮（待办 A-01）
- `L2.3` 核心/设计 agent 分工**未建**；task 机制半成品（工具分级/用户画像/共识 top3 自动注入/原子池按 task 装配未做）
- **视频符合度审查**（2026-08-23，63 条对照）：结构层符合、内容层与数据层未达标（6 项）——完整审查与项目待办见 [`FRAMEWORK-PROGRESS.md`](./FRAMEWORK-PROGRESS.md)

## 5. 版本纪律

- 本仓库（GameDev-Skeleton）：框架文档 + runs/ 存档，每次 run 完成后提交
- 全局骨架（`$HARNESS`）：每次回写后提交
- Commit message 遵循 conventional commits（feat/fix/docs/refactor/chore）
