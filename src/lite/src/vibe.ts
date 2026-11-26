/**
 * AI 办公咨询方案：WorkBuddy + 腾讯文档平台选型。
 * 正本在咨询档案 quanttide-profile-of-consulting-management/vibe-working/platform-decision。
 */

export interface OfficeSolution {
  name: string
  /** 平台选择问题 */
  problem: string
  conclusion: string
  /** 计算单元 */
  compute: { name: string; role: string }
  /** 存储单元 */
  storage: { name: string; role: string }
  decidedAt: string
  /** 步骤待实施分解 */
  steps: string[]
  source: string
}

export const officeSolution: OfficeSolution = {
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
