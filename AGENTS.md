# AGENTS.md — GameDev-Skeleton

> 本目录是 gamedev-harness 的**框架文档与运行实例存档**。全局骨架本体位于 `~/.workbuddy/gamedev-harness/`（跨项目唯一来源）。

## 挂载声明

启用 gamedev-harness，挂载点：`C:/Users/32337/.workbuddy/gamedev-harness/`

涉及游戏设计任务时：
1. 先读 `~/.workbuddy/gamedev-harness/HARNESS.md` 总纲
2. 按任务品类加载对应 `packs/<genre>/PACK.md`
3. 执行设计时遵循 `pipelines/` 中对应流水线的阶段与原子清单
4. 设计产出存于本目录 `runs/<日期>-<任务>/`，完成后执行阶段 5 回顾自检并回写全局

## 本目录结构

- `runs/` — 历次设计运行的完整检查点存档（事实档案→概念→初稿→攻击性检查→终稿→回顾）
- 骨架本体不在此目录，判据/原子的评分与演化只发生在全局层
