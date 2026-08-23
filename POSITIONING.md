# POSITIONING — 项目定位与边界（权威文档）

> **本文件是框架开发项目的定位权威文档**：回答"这是什么项目、为谁、怎么生长、边界在哪"。
> 保持**稳定**；内容变更须经用户拍板，并按 `AGENTS.md` §5 版本纪律记录。
> 对外门面见 [`README.md`](./README.md)（陌生人入口）；关联：`AGENTS.md`（运行协议）｜ `FRAMEWORK-PROGRESS.md`（进度/待办）｜ `READING-PROTOCOL.md`（读书执行手册）｜ `~/.gamedev-harness/HARNESS.md`（方法体系总纲）｜ `gamedev-harness-dashboard/ADAPTER.md`（插件契约）。

---

## 1. 这是什么项目

- **本工作目录（GameDev-Skeleton）= 框架核心项目的开发目录**：框架本身即核心项目——开发、规范、生长、读书都发生在这里；**不关联任何具体游戏项目**（游戏项目在各自目录接入）。
- **三产品模型**（ADAPTER 定位原文）：
  - **DSH**（DeepSeek Harness）= 工程平台/宿主：记忆/会话/工具/子 agent/通知——**接驳而非自建**；
  - **gamedev-harness**（`~/.gamedev-harness`）= **方法体系产品**：判据/原子/编排/流水线/叙事链，L0 纯 Markdown 唯一来源；L1 = 各项目 AGENTS.md 挂载；
  - **gamedev-harness-dashboard** = **接驳层产品**：把框架语义映射为 DSH 的工具/API/面板——**不定义语义，只执行语义**。

## 2. 服务对象与哲学

- **服务对象 = 用户本人**（Jaeger）：框架是"我"的延伸——记忆、判断、方法都是我的（视频结尾五条：记忆是你的/知识是你的/判断是你的/方法是你的/通用 harness 装平均数）。
- **哲学**（视频 63 条核心）：harness **不替 agent 思考**，只改变起点（记忆流）与方向（判据/方法/原子编排）；**判断是你的**（用户圈选是最终裁决）；**白盒化管轨道**（黑盒出想法，白盒管轨道——每步看得见、可审计、可追溯）。
- **与主流的差异**：不堆知识库（知识库三死穴：存了≠用了/知道≠会做/平均数方向感）——走"方法体系（知识骨架三块）+ 技能原子（一原子一原语）+ 判据 + 白盒流水线 + task 机制"。

## 3. 工作区与仓库（责任划分）

| 位置 | 角色 | 内容 |
|---|---|---|
| `E:\Vibe-Projects\GameDev-Skeleton` | 框架开发目录（本工作区） | 协议（AGENTS.md）、定位（本文件）、进度（FRAMEWORK-PROGRESS）、执行手册（READING-PROTOCOL）、历史 runs/ 档案、materials/ 原始资料、books/ 成长资料（gitignore）、插件子仓库 |
| 　`gamedev-harness-dashboard` | 接驳层产品（独立迭代/发布） | src/host + client 面板、ADAPTER 契约、ROADMAP |
| `C:\Users\32337\.gamedev-harness` | 方法体系**唯一来源**（全局骨架，独立 git） | atoms/、verdicts/、packs/、pipelines/、skeleton/、memory/、decisions/、projects/、sources/ |
| `materials/` | 原始资料（来源材料归档） | 视频原文/观点提取等原始输入（不入骨架） |
| `books/<slug>/` | 成长资料（书文本/状态/日志，gitignore） | 入库切片、book.json、读书日志.md |
| `runs/` | **框架历史档案**（历史可追溯） | 框架自身演化记录与历史实验存档；**未来真实游戏项目的 run 放各自项目目录** |

## 4. 生长双轨

- **轨 1 · 项目复盘**：真实游戏项目接入 → 设计 run（card-batch-design 等）→ 05-review 回写 → 判据/原子/骨架生长（待办 A/B 组）。
- **轨 2 · 读书/外部输入**：书/文章/讲座/视频 → 阅读轮（提取→我的看法→你的判断→沉淀）→ knowledge-sinking / reading（待办 E/F/G 组）——**不依赖真实项目**。
- **验证通道分流**（2026-08-23 用户拍板）：技能原子 = 3 次真实 run 使用验证；判据 = 可质疑性审查 + ≥1 次 run 挂靠 + 用户确认；骨架条目/观点 = 用户确认制（验收 = 可推理/可质疑/可分析）。

## 5. 可迁移性（模式/内容分层）

- **内容层 = 个人定制**：判据内容、技能原子、skeleton 条目、品类包具体编排、我的书与读书记录、runs 档案——**不进分发模板**。
- **模式层 = 可分发**：10 认知原语清单、格式契约（GOVERNANCE/_FORMAT）、流水线模板、AGENTS.md 协议模板、HARNESS.md、读书状态机规范、判据/原子的**格式**（非内容）。
- **目标**：其他游戏设计师用同一套模式，积累**完全不同的**技能原子/电子书/真实项目。
- **原则**："别人拿去的是模式，不是你的答案"（视频 ⑧、结尾）。落地待办：H 组（分层审计 → 空框架包 → 新用户向导 → 个人层独立性）。

## 6. 边界清单

- **DSH 平台** = 宿主（接驳而非自建；记忆空间/通知等能力直接用）；
- **平行项目**（`醒时` / `Brainstormer` / `dsh-launcher`）与本项目**完全无关**；
- `GameDev-Sandbox` **已删除**（仅含插件创建提示词存档，无保留价值）；
- `projects/GameDev-Skeleton` 空目录残留 = 无害（框架已免疫）；
- **测试痕迹**：newton/sts2-regent 已解注册（测试 run 不进度量闭环）；runs/ 存档保留为历史。

## 7. 文档关系

```
README（对外门面：这是什么/怎么用/快速开始）
  └─ POSITIONING（定位·纲领·内部权威，本文档）
        ├─ FRAMEWORK-MIND   心智基线（架构精神/实体矩阵/红线——启动必读，AGENTS §0.0）
        ├─ FRAMEWORK-AUDIT  框架审计手册（周期性体检：五维度/触发/产出处理——触发时读）
        ├─ AGENTS.md            运行协议：task 检测 / 注入规则 / 义务条款 / 版本纪律
        ├─ FRAMEWORK-PROGRESS   进度·待办·决策记录（A-H 组）
        ├─ READING-PROTOCOL     读书学习方法执行手册
        ├─ HARNESS.md           方法体系总纲（骨架内：白盒五原理/目录职责）
        └─ ADAPTER.md           插件契约（两个产品、契约协同）
```

> **结构图同步契约（2026-08-24 立）**：新增/改名任何**顶层文档**（本仓库根或 $HARNESS 根），必须同步更新三处：①本图（POSITIONING §7）②README 结构图 ③HARNESS.md 目录职责表——违反=审计红点（白盒=结构说明覆盖实际）。
