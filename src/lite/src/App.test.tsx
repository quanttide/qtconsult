import '@testing-library/jest-dom/vitest'
import { render, screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'
import App from './App'
import { officeSolution } from './vibe'

describe('AI 办公方案', () => {
  it('结论写明平台组合与计算、存储单元分工', () => {
    render(<App />)

    expect(screen.getByText(/WorkBuddy \+ 腾讯文档组合/)).toBeInTheDocument()
    expect(screen.getByText('WorkBuddy · 计算单元')).toBeInTheDocument()
    expect(screen.getByText('腾讯文档 · 存储单元')).toBeInTheDocument()
  })

  it('标待分解，步骤如实占位', () => {
    render(<App />)

    expect(screen.getByText('待分解')).toBeInTheDocument()
    expect(screen.getAllByRole('listitem')).toHaveLength(1)
    expect(officeSolution.steps[0]).toMatch(/待分解/)
  })

  it('带咨询档案事实源入口', () => {
    render(<App />)

    const link = screen.getByRole('link', { name: /咨询档案/ })
    expect(link.getAttribute('href')).toMatch(
      /quanttide-profile-of-consulting-management\/blob\/main\/vibe-working\/platform-decision/,
    )
  })
})
