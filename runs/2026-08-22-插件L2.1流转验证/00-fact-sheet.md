# 00-fact-sheet：插件 L2.1 流转验证

## 事实档案（每条可溯源）

- gamedev-harness-dashboard 插件已完成 L2.0（总控台：面板 + 8 工具），本次扩展 L2.1（run 流转状态机）——来源：本会话实现记录
- 本 run 目的：验证 run_start → run_checkpoint → run_review → run_writeback 全链路（半自动状态机）——来源：与 Jaeger 的设计确认（2026-08-22）
- 骨架现状快照：叙事链 3 条、判据 9 条、技能原子 7 颗、品类包 2 个（puzzle/strategy-roguelike）、流水线 2 个——来源：harness_status 实测
- 已接入项目：GameDev-Skeleton（本 run 宿主）、newton、sts2-regent（历史注册）——来源：harness_projects_list 实测
- 环境约束：宿主受限令牌导致 dev_install_package 不可用，装配走独立令牌（计划任务）方案——来源：本会话排障记录
