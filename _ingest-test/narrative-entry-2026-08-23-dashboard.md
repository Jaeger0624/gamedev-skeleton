
## 2026-08-23 总控台生长视图双轨化（meta / harness-dev）
- 做了什么：插件「生长」tab 从单轨缺口看板重构为「来路（sources/ 血缘 + 叙事链全量时间线）+ 去路（缺口按生长轨标注）」；新增「读书」tab（书架：跨工作区自动发现 book.json，书卡进度/游标/产出合计 + 章节热力条 + 日志轮次）；概览加生长趋势累计折线（birthtime + 条目日期）；新工具 harness_sources_list / harness_books_list（工具 18→20）
- 关键决策与理由：
  1. 书架定位用 workspaceRegistry 自动发现而非配置项——books/ 是工作目录级簿记，工作区注册表天然持有候选目录，零配置且多工作区藏书天然聚合
  2. 生长趋势用文件创建时间（birthtime）而非 git log——与「目录扫描 + 格式解析、无外部进程」的契约哲学一致
  3. 去路缺口加轨道标注（双轨 / 仅真实 run 慢通道 / harness-dev）——E-03 后「只从复盘生长」的文案已过时，UI 语义须跟上框架语义
- 搁置/遗留：来源→产物的反向跳转（点产物 chip 跳到原子/判据卡）未做；三通道成熟度漏斗视图（E 组决策 1 的完整可视化）待做
- 长出的东西：ADR 2026-08-23-dashboard-growth-dual-track；ADAPTER.md 版本联动（面板双轨化）；ROADMAP ⑩⑬⑱⑲⑳ 完成；FRAMEWORK-PROGRESS G-05 完成、D-02/D-03 部分完成
