/**
 * 方案注册表：加一个方案 = 加一条记录再发版（lite/v0.x.y）。
 * 首页只列打包单元，详情走 /solutions/<slug>。
 */

export interface SolutionMeta {
  slug: string
  name: string
  summary: string
}

export const solutions: SolutionMeta[] = [
  {
    slug: 'vibe-working',
    name: 'AI 办公平台选择',
    summary: 'WorkBuddy 计算单元 + 腾讯文档存储单元，服务一个企业的 AI 办公升级改造。',
  },
]

export function findSolution(slug: string): SolutionMeta | undefined {
  return solutions.find((s) => s.slug === slug)
}

/** vibe-working 打包单元的详情载荷 */
export const vibeWorking = {
  name: 'AI 办公平台选择',
  problem: '企业 AI 办公升级改造的平台选型：用什么平台组合把 AI 装进日常办公。',
  conclusion: 'WorkBuddy + 腾讯文档组合，用于一个企业的 AI 办公升级改造。',
  compute: { name: 'WorkBuddy', role: '计算单元' },
  storage: { name: '腾讯文档', role: '存储单元' },
  decidedAt: '2026-11-24',
  steps: ['待分解——方案已形成，评估过程与平台分工边界随实施补充。'],
  source:
    'https://github.com/quanttide/quanttide-profile-of-consulting-management/blob/main/vibe-working/platform-decision/index.md',
}
