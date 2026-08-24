# GameDev Harness 空框架包（empty package）

> 由 `scripts/export-empty-package.ps1` 生成（H-02 最小版）——**模式层全文 + 内容层清空骨架**。
> 定位（FRAMEWORK-LAYERING）：别人拿去的是模式，不是你的答案——包里没有任何"我的判断"，全部空白等你长出。

## 包里有什么

**模式层（照抄即用）**
- `HARNESS.md` 总纲与目录职责表｜`FRAMEWORK-MIND.md` 心智基线（架构精神/实体矩阵/红线）
- `atoms/GOVERNANCE.md` 原子治理（铁律/四维/格式/度量格式）｜`atoms/_INDEX.md` 原语表+空技能原子表
- `atoms/` 10 个认知原语（固定不变；原语使用记录已清空）
- `verdicts/_FORMAT.md` 判据格式+空索引表｜`packs/_TEMPLATE.md` 品类包模板｜`pipelines/_FORMAT.md` 流水线模板
- `skeleton/_INDEX.md` 三块空清单｜`decisions/_INDEX.md` / `sources/_INDEX.md` / `memory/narrative-chain/_MAIN.md` 格式与规范（空条目）

**空目录骨架（内容层生长位）**

`atoms/skills/`｜`verdicts/`｜`skeleton/{game-mechanics,fictional-player,design-philosophy}/`｜`packs/`｜`pipelines/`｜`memory/narrative-chain/archive/`｜`decisions/`｜`projects/`｜`reviews/`

## 包里不含什么

- **内容层**：判据内容 / 技能原子 / 骨架条目 / 品类包编排 / 叙事链条目 / ADR / 项目注册 / 来源台账
- **项目层**：任何具体项目接入件（协议挂载/run/项目文档）
- **框架仓文档**（AGENTS.md 运行协议 / POSITIONING / LAYERING / PROGRESS 结构 / READING-PROTOCOL / scripts 生成器 / 插件）——随框架公开仓分发，不在本包内

## 怎么用（新设计师）

1. **拿到模式**：clone 框架公开仓（协议+生成器+插件）+ 本包内容合并为你的 `~/.gamedev-harness`；
2. **读 FRAMEWORK-LAYERING.md** 三层判定（模式怎么动/内容怎么长/项目怎么接）；
3. **接入第一个项目**：`harness_init_project` 或 writer 生成接入件（协议/目录/注册），品类包用 `_TEMPLATE.md` 自建；
4. **开始生长**：第一条真实 run → 判据/原子/骨架跟着长——每条带来源 + 用户圈选，禁止无来源编造。

> 注意：本包由个人骨架导出，索引表/目录已清空；若目录里残留任何个人条目，属导出故障——重跑脚本并对照 FRAMEWORK-LAYERING §4.2 清单核查。
> **已知残留点（v1 谨慎处理）**：`HARNESS.md`「当前品类包」节保留的是导出来源的实际品类清单（含示例项目名）——新用户使用前将本节改为自己的品类包或用 `packs/_TEMPLATE.md` 自建；其余个人引用已净化。
