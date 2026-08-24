/**
 * smoke-phase2.mjs — 阶段 2 冒烟验证：M3′ 会话启动链（DSH 工作区指令候选注入）。
 *
 * 验证点（模拟 = 直接调用 dsh-agent-instructions 的发现+渲染原函数，与宿主一致）：
 *  1. 框架工作区（本仓库）：新候选配置下 AGENTS.md 注入、HARNESS-PROTOCOL.md 不存在→无影响（回归基线）
 *  2. 模拟 harness 项目（临时夹具：AGENTS.md+CLAUDE.md+HARNESS-PROTOCOL.md）：
 *     新候选 → 三段全注入；默认候选（修复前）→ 仅 AGENTS/CLAUDE（证明缺口与修复的 before/after）
 *  3. 预算语义：Maker 大文件 + 小预算 → 截断保末段（HARNESS-PROTOCOL 存活）
 *  4. 预设状态（A2′ 修正）：harness-standard 已移除（默认不污染）；harness-project 非 broken
 *     且含候选差异行；profile 默认预设 = standard（平台中立）
 *  5. 工作区感知自动绑定（纯逻辑）：isHarnessProject 接入标记判定 / shouldBindPreset
 *     默认会话绑定、显式选择尊重、非 harness/非 blank 不绑定
 *
 * 用法：node scripts/smoke-phase2.mjs
 * 说明：本脚本为公共仓脚本——不包含任何个人路径字面量；用户根/DSH 路径均运行时推导，
 *       真实项目（星尘叙事者）由临时夹具等价仿真，个人路径不出现在仓库中。
 */
import { mkdtempSync, writeFileSync, readFileSync } from 'node:fs'
import { tmpdir } from 'node:os'
import { join, dirname } from 'node:path'
import { fileURLToPath, pathToFileURL } from 'node:url'
import { createRequire } from 'node:module'
import os from 'node:os'

const expect = (label, cond) => {
  console.log((cond ? 'PASS' : 'FAIL') + '  ' + label)
  if (!cond) process.exitCode = 1
}

// ── DSH 包导入（锚点 = 本机 profile node_modules，运行时推导）─────────────
const profilesNm = join(os.homedir(), '.dsh', 'profiles', 'node_modules')
const anchor = join(profilesNm, '@deepseek-ai', 'dsh-agent-instructions', 'package.json')
const dshRequire = createRequire(anchor)
const { loadBaselineInstructions, discoverBaselineInstructionFiles } = dshRequire('@deepseek-ai/dsh-agent-instructions')
const dshPresetsRequire = createRequire(join(profilesNm, '@deepseek-ai', 'dsh-agent-presets', 'package.json'))
const { discoverPresets } = dshPresetsRequire('@deepseek-ai/dsh-agent-presets')

const NEW_CANDIDATES = ['AGENTS.md', 'CLAUDE.md', 'HARNESS-PROTOCOL.md']
const baseOptions = (cwd, candidates) => ({
  cwd,
  dshHome: join(os.homedir(), '.dsh'),
  projectRootMarkers: ['.git'],
  maxBytes: 98304,
  maxSourceBytes: 1048576,
  ...(candidates === undefined ? {} : { instructionFileCandidates: candidates }),
  signal: undefined
})

// ── 1. 框架工作区（本仓库）：回归基线 ──────────────────────────────────────
const repoRoot = dirname(dirname(fileURLToPath(import.meta.url)))
const repoInstructions = await loadBaselineInstructions(baseOptions(repoRoot, NEW_CANDIDATES))
const repoText = repoInstructions?.text ?? ''
expect('框架工作区：AGENTS.md 注入（修复前即有的基线）', repoText.includes('Instructions from: AGENTS.md') === true)
expect('框架工作区：HARNESS-PROTOCOL.md 无文件→不注入（候选只是文件名）', repoText.includes('HARNESS-PROTOCOL.md') !== true)
expect('框架工作区：无截断/省略标记（预算充足）', repoText.includes('truncated') !== true && repoText.includes('omitted') !== true)

// ── 2. 模拟 harness 项目：修复前后对比 ────────────────────────────────────
const proj = mkdtempSync(join(tmpdir(), 'harness-phase2-proj-'))
writeFileSync(join(proj, 'AGENTS.md'), '# Maker engine policy (fixture)\n'.repeat(1700), 'utf8') // ≈54KB，模拟 Maker 托管大文件（真实=55.4KB）
writeFileSync(join(proj, 'CLAUDE.md'), '# Maker claude stub\n', 'utf8')
writeFileSync(join(proj, 'HARNESS-PROTOCOL.md'), '# HARNESS-PROTOCOL (fixture)\n\n## 0.0 启动铁律\n\n1. 读本文件\n2. 读 $HARNESS/FRAMEWORK-MIND.md 完整段\n', 'utf8')

const opt = (candidates, maxBytes) => ({ ...baseOptions(proj, candidates), projectRoot: proj, maxBytes })

const before = await loadBaselineInstructions(opt(undefined, 65536))
const beforeText = before?.text ?? ''
expect('修复前（默认候选）：AGENTS.md 注入', beforeText.includes('Instructions from: AGENTS.md') === true)
expect('修复前（默认候选）：HARNESS-PROTOCOL.md 不注入（G-21 缺口实锤）', beforeText.includes('HARNESS-PROTOCOL.md') !== true)
expect('修复前（默认候选）：总字节 ≤ 65536（Maker 大文件已占 95%+，紧预算）', Buffer.byteLength(beforeText, 'utf8') <= 65536)

const after = await loadBaselineInstructions(opt(NEW_CANDIDATES, 98304))
const afterText = after?.text ?? ''
expect('修复后：三段全注入', afterText.includes('Instructions from: AGENTS.md') === true && afterText.includes('Instructions from: CLAUDE.md') === true && afterText.includes('Instructions from: HARNESS-PROTOCOL.md') === true)
const afterBytes = Buffer.byteLength(afterText, 'utf8')
expect(`修复后：总字节 ≤ 98304（实际 ${afterBytes}，Maker 增长余量充足）`, afterBytes <= 98304)
expect('修复后：注入顺序 = 候选顺序（AGENTS 在前，HARNESS 在末段）', afterText.indexOf('Instructions from: AGENTS.md') < afterText.indexOf('Instructions from: HARNESS-PROTOCOL.md'))

// ── 3. 预算截断语义：保末段（HARNESS-PROTOCOL 存活）──────────────────────
const squeezed = await loadBaselineInstructions(opt(NEW_CANDIDATES, 3000))
const squeezedText = squeezed?.text ?? ''
expect('截断场景：HARNESS-PROTOCOL.md 段存活（末段优先保留）', squeezedText.includes('HARNESS-PROTOCOL.md') === true)
expect('截断场景：出现 omitted/truncated 标记（预算语义可见）', squeezedText.includes('omitted') === true || squeezedText.includes('truncated') === true)

// ── 4. 预设状态（A2′ 修正：默认中立 + 工作区判定）──────────────────────────
const userPresets = await discoverPresets([{ path: join(os.homedir(), '.dsh', '.agent-presets'), trust: 'user' }])
const byId = new Map(userPresets.map((p) => [p.id, p]))
expect('harness-standard 已移除（默认不污染非框架项目）', byId.get('harness-standard') === undefined)
const hp = byId.get('harness-project')
expect('harness-project 被发现且非 broken', hp !== undefined && hp.broken === undefined)
const hpComposition = readFileSync(join(os.homedir(), '.dsh', '.agent-presets', 'harness-project', 'agent.cordis.yml'), 'utf8')
expect('harness-project 组合含候选差异行（HARNESS-PROTOCOL.md）', hpComposition.includes('- HARNESS-PROTOCOL.md'))
expect('harness-project 组合含升级预算 maxBytes: 98304', hpComposition.includes('98304'))
const profileYml = readFileSync(join(os.homedir(), '.dsh', 'profiles', 'web', 'cordis.yml'), 'utf8')
expect('profile 默认预设 = standard（平台中立）', /default:\s*standard\s*\n/.test(profileYml))

// ── 5. 工作区感知自动绑定（纯逻辑：接入标记判定 + 绑定条件）───────────────
const { isHarnessProject, shouldBindPreset } = await import(pathToFileURL(join(repoRoot, 'gamedev-harness-dashboard', 'lib', 'session-bootstrap.js')).href)
const marked = mkdtempSync(join(tmpdir(), 'harness-phase2-marked-'))
writeFileSync(join(marked, '.gamedev-harness.json'), '{}', 'utf8')
const plain = mkdtempSync(join(tmpdir(), 'harness-phase2-plain-'))
expect('isHarnessProject：有接入标记的临时项目 → true', await isHarnessProject(marked) === true)
expect('isHarnessProject：无标记临时目录 → false', await isHarnessProject(plain) === false)
expect('shouldBindPreset：harness + blank + 默认预设 → 绑定', shouldBindPreset('standard', 'standard', true, true) === true)
expect('shouldBindPreset：用户显式选择其他预设 → 尊重不绑定', shouldBindPreset('router-standard', 'standard', true, true) === false)
expect('shouldBindPreset：非 harness 项目 → 不绑定', shouldBindPreset('standard', 'standard', false, true) === false)
expect('shouldBindPreset：已有内容（非 blank）→ 不绑定', shouldBindPreset('standard', 'standard', true, false) === false)

// ── 6. 真实 PACK 数据块规格符合（P1″ 契约回归，规格见 docs/PACK-STRUCTURE-SPEC.md）──
function extractFenceBlock(text, lang) {
  const lines = []
  const open = new RegExp('^```[\\w-]*' + lang + '\\s*$', 'm').exec(text)
  if (open === null) return lines
  const after = text.slice(open.index + open[0].length)
  const close = after.match(/^```\s*$/m)
  if (close === null) return lines
  for (const raw of after.slice(0, close.index).split(/\r?\n/)) {
    const line = raw.trim()
    if (line === '' || line.startsWith('#')) continue
    lines.push(line)
  }
  return lines
}
const packsRoot = join(os.homedir(), '.gamedev-harness', 'packs')
const expectedVerdicts = { story: 15, puzzle: 5, 'strategy-roguelike': 4 }
let packOk = true
for (const [pack, expected] of Object.entries(expectedVerdicts)) {
  const text = readFileSync(join(packsRoot, pack, 'PACK.md'), 'utf8')
  const v = extractFenceBlock(text, 'verdicts')
  const a = extractFenceBlock(text, 'atoms')
  const bad = v.filter(l => !/^[a-z0-9][a-z0-9-]*@(formal|candidate)$/.test(l))
  console.log(`  [pack] ${pack}: verdicts=${v.length}（期望 ${expected}） atomsRows=${a.length} bad=${bad.length}`)
  if (v.length !== expected || a.length === 0 || bad.length > 0) packOk = false
}
expect('真实 PACK 数据块：三包 verdicts 条目数=规格 + atoms 块非空 + 无非法行', packOk)

console.log(process.exitCode === 1 ? '\nsmoke-phase2 FAILED' : '\nsmoke-phase2 all PASS')
