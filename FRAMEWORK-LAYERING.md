# FRAMEWORK-LAYERING — 模式/内容/项目三层（可迁移性审计）

> **定位**：H-01「模式/内容分层审计」的产出——回答"这套框架里，**哪些可以分发、哪些是个人定制、哪些跟随项目走**"。
> **非启动必读**（不占 FRAMEWORK-MIND 基线）；只在模板分发 / 空包导出 / 新用户接入时读。
> **权威关系**：POSITIONING §5（可迁移性定位）为纲 → 本文件为分层细则与现状清单；FRAMEWORK-MIND 的「模式层权威源在 $HARNESS」镜像注记以本文件为分层判定依据。
> **镜像注记（2026-08-24）**：本文件唯一源 = 框架仓 `FRAMEWORK-LAYERING.md`；$HARNESS 不镜像（项目会话不需要它）。

---

## 1. 为什么分层

一句话：**别人拿去的是模式，不是你的答案**（视频⑧/结尾）。要让框架"可迁移"，先分清三样东西：

- **模式 = 机器**：怎么用、什么格式、什么结构、什么协议——换个人**照抄即用**；
- **内容 = 血肉**：我在使用中长出来的判断、知识、记忆、编排——换个人**必须替换成他的**；
- **项目 = 应用实例**：一个具体游戏接入后的一切——**跟随项目走，不进模板**。

不分层的后果：把个人判据当模板分发 = 信号污染 + 隐私泄露；把模板当个人内容推 = 新人长不出自己的东西。

## 2. 三层定义

| 层 | 是什么 | 回答的问题 | 存放位置 |
|---|---|---|---|
| **模式层** | 框架的"机器"：协议 / 格式 / 原语 / 结构 / 机制 | 这套框架怎么运转、怎么长、怎么用 | 框架仓文档 + $HARNESS 格式契约与 10 认知原语 + 接入件生成器（scripts/） |
| **内容层** | 框架的"血肉"：判断 / 知识 / 记忆 / 编排 / 台账 | 我积累了哪些设计判断与来路 | $HARNESS 内容目录（verdicts / atoms·skills / skeleton / packs 编排 / memory / decisions / projects 注册 / sources）+ books/ + 框架仓进度历史 |
| **项目层** | 框架的"应用实例" | 某个具体游戏怎么接入、走到了哪 | 项目目录（协议挂载 / runs / docs / agent-notes）+ $HARNESS/projects/<name>/ 注册 |

## 3. 归属判定三问

| 问 | 问句 | 答案 → 落位 |
|---|---|---|
| **Q1 主体** | 它服务"框架**怎么运转**"，还是"设计**怎么判断** / 我在**积累什么**"？ | 运转 → 模式；判断/积累 → 内容 |
| **Q2 换人** | 另一个设计师拿到它，应当**照抄使用**还是**必须替换成自己的**？ | 照抄 → 模式；必须替换 → 内容（**争议时以 Q2 为最终裁决**） |
| **Q3 归属** | 它跟随**框架**迁移，还是跟随**某个具体项目**？ | 项目目录内（接入件/run/项目文档/项目 chain）→ 项目层；框架仓 / $HARNESS → 框架级（再经前两问细分） |

**判定次序**：先 Q3 剔项目层 → 再 Q1/Q2 分模式/内容。

**双层合一文件**：一个文件常同时含模式结构与个人内容（如 `FRAMEWORK-PROGRESS.md` = 进度结构 + 个人历史；`README` 状态快照 = 快照结构 + 个人数字；`POSITIONING.md` = 定位结构 + 个人定位声明；`atoms/_INDEX.md` = 原语表 + 技能原子表）。
**处理规则**：按文件**主体**落位；空包导出时**保留结构、清空/替换个人值**（H-02 执行）。

## 4. 现状清单（2026-08-24 盘点）

### 4.1 模式层（可分发）

**框架仓（GameDev-Skeleton）**：

| 文件 | 说明 |
|---|---|
| `AGENTS.md` | 运行协议 + 启动铁律（模板化时剥离个人示例） |
| `FRAMEWORK-MIND.md` | 心智基线：架构精神/实体矩阵/红线（权威源 = $HARNESS 镜像，H-02 取全局版本） |
| `FRAMEWORK-AUDIT.md` | 框架审计手册 |
| `FRAMEWORK-PROGRESS.md` | 进度/待办**结构**（历史与待办=内容；空包导出清表） |
| `POSITIONING.md` | 定位**结构**（定位声明=内容） |
| `READING-PROTOCOL.md` | 读书执行手册 |
| `README.md` | 对外门面 |
| `FRAMEWORK-LAYERING.md` | 本文件 |
| `scripts/` + `scripts/templates/` | 接入件生成器（advance-book / check-book-consistency / gen-agent-notes / gen-project-docs / gen-library-list + 模板 ×11） |
| `gamedev-harness-dashboard/` | 接驳层插件（独立产品、独立分发） |
| `runs/` | 框架历史档案**目录**（档案内容=个人历史；空包清空） |

**$HARNESS 格式契约与固定件**：

| 文件 | 说明 |
|---|---|
| `HARNESS.md` | 总纲 + 目录职责表（协议层行 = 仓库指针） |
| `atoms/GOVERNANCE.md` | 原子治理：铁律/四维审计/状态流转/文件格式/度量格式 |
| `atoms/_INDEX.md` | 10 认知原语清单（原语=模式；skills 表=内容导航） |
| `atoms/<10 原语>.md` | 认知原语（固定不变，10 个） |
| `verdicts/_FORMAT.md` | 判据格式 + 索引表**结构**（条目=内容） |
| `packs/_TEMPLATE.md` | 品类包模板 |
| `pipelines/_FORMAT.md` | 流水线模板 |
| `skeleton/_INDEX.md` | 三条目块清单**结构**（条目=内容） |
| `decisions/_INDEX.md` | ADR 索引**结构**（条目=内容） |
| `memory/narrative-chain/_MAIN.md` 头部 | 分层/出发自/归档**规范**（条目=内容） |
| `projects/<name>/project-profile.json` | 项目画像**格式**（值=项目层） |
| `sources/_INDEX.md` | 来源注册**结构**（台账=内容） |

### 4.2 内容层（个人定制，不进分发）

| 目录/文件 | 计数（2026-08-24） | 说明 |
|---|---|---|
| `verdicts/*.md`（除 `_FORMAT`） | 39 | 判据内容（全部候选，真实 run 验证从 0 计） |
| `skeleton/*/` | 63（18+14+31） | 三块知识条目（机制→效果 / 玩家→体验 / 哲学） |
| `atoms/skills/*.md` | 7 | 技能原子执行手册（候选 0/3） |
| `atoms/metrics/_INDEX.json` | 方向信号（值） | 机制=模式，方向值=内容 |
| `atoms/metrics/_genre-affinity.json` | 亲和矩阵（值） | 同上 |
| `packs/<genre>/PACK.md` | 3（puzzle / story / strategy-roguelike） | 品类编排实例（模板=模式，编排=内容） |
| `memory/narrative-chain/_MAIN.md` | 37 条 | 全局链（框架/读书/跨项目） |
| `memory/narrative-chain/archive/` | 2 条 | 首例归档（sts2 / peanut） |
| `decisions/*.md` | 9 ADR + `_INDEX` | 框架演化决策史（对新用户 = 参考书，非模板必需品） |
| `projects/*/` | 2 注册（stardust-narrator + GameDev-Skeleton 空残留） | 注册台账（值=项目层引用） |
| `sources/` | 台账 | 外部输入来源注册 |
| `books/<slug>/` | gitignore | 我的电子书 + 读书记录 |
| `reviews/` | 空 | 审查记录（机制就位，数据未长） |
| 框架仓 `runs/` | 历史档案 | 框架自身演化记录 |

### 4.3 项目层（跟随项目）

| 位置 | 内容 |
|---|---|
| 项目根 | `AGENTS.md`（L1 协议挂载）/ `HARNESS-PROTOCOL.md`（双协议共存，registerOnly）/ `.gamedev-harness.json`（连接件）/ `narrative-chain.md`（项目链）/ `runs/` / `docs/`（职责矩阵 + AI 信息路由）/ `agent-notes/`（云端投影） |
| `$HARNESS/projects/<name>/project-profile.json` | 注册画像（品类/角色/覆盖/工作目录/协议文件） |
| 首例（2026-08-24） | **星尘叙事者**（`E:\taptapMaker\Projects\星尘叙事者`，story 品类，registerOnly 接入，game 角色） |

## 5. 空包组成预告（H-02 最小版）

空模板 = **模式层全文 + 内容层清空结构**：

| 包内（保留） | 包外（不含） | 处理 |
|---|---|---|
| 框架仓全部文档（含本文件） | — | AGENTS / PROGRESS / README 个人示例清空或替换为占位 |
| `HARNESS.md` / `GOVERNANCE.md` / `atoms/_INDEX.md` / `_FORMAT.md` / `packs/_TEMPLATE.md` / `pipelines/_FORMAT.md` | 判据内容 / 技能原子 / 骨架条目 / 编排实例 | 格式文件原样；索引表清空留列 |
| 10 认知原语文件 | 原语**使用记录**（个人使用史） | 原语定义保留，使用记录清空 |
| 生成器 `scripts/` + `templates/` | 已生成的接入件（星尘叙事者 docs/agent-notes 等） | 原样分发 |
| 空目录骨架：`verdicts/` `skeleton/{三块}/` `atoms/skills/` `memory/narrative-chain/`（含 `archive/` 空）`decisions/` `projects/` `sources/` `reviews/` | 个人条目/注册/台账/叙事链 | 目录 + 索引表保留，条目清空 |
| — | `books/`（我的书） | 不含（gitignore） |
| — | 项目层全部 | 不含（每个项目自行接入生成） |

**待 H-02 决策**：示例流水线（`card-batch-design` / `incubation`）保留为参考实例还是清空；README/PR 个人品牌信息剥离程度。

## 6. 落位规则（新增/变更往哪放）

1. **新机制 / 新格式 / 新协议** → 模式层：框架仓协议文档或 $HARNESS 格式契约（格式变更走 ADAPTER 版本联动；顶层文档过三处图同步契约）;
2. **新判据 / 原子 / 骨架 / 编排 / 记忆** → 内容层：走各自生长规范（GOVERNANCE 四维 / 判据格式 / 用户圈选制）；
3. **新项目接入** → 项目层：writer / gen-project-docs 生成接入件 + $HARNESS/projects 注册；
4. **模板化 / 剥离** → 模式层改动（H-02 / H-03）；
5. **双层合一文件** → 按主体落位；空包处理 = 结构保留 + 值清空/替换；
6. **拿不准** → 走三问，仍拿不准 → 问用户（红线 5：不确定就问，不猜）。

## 7. 审计接口

- **FRAMEWORK-AUDIT E 维**（结构图同步）：本文件加入三处图（POSITIONING §7 / README / HARNESS.md 协议层行）——首验 2026-08-24；
- **A 维（真相源）**：模式层跨仓库镜像关系——`FRAMEWORK-MIND` 权威源 = $HARNESS 镜像；`FRAMEWORK-LAYERING` 唯一源 = 框架仓；镜像内容冲突时以权威源为准；
- **C 维（索引一致性）**：H-02 导出后跑 `gen-library-list` + `check-book-consistency` 对账（空包 = 文件系统与清单一致为空）。
