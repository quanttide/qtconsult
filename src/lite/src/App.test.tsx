import '@testing-library/jest-dom/vitest'
import { render, screen } from '@testing-library/react'
import { MemoryRouter } from 'react-router-dom'
import { describe, expect, it } from 'vitest'
import { AppRoutes } from './App'
import { solutions } from './data/solutions'

function renderAt(path: string) {
  return render(
    <MemoryRouter initialEntries={[path]}>
      <AppRoutes />
    </MemoryRouter>,
  )
}

describe('解决方案 lite', () => {
  it('首页是方案列表，AI 办公是其中一个打包单元', () => {
    renderAt('/')

    expect(screen.getByRole('heading', { level: 1, name: '解决方案' })).toBeInTheDocument()
    expect(solutions.map((s) => s.slug)).toEqual(['vibe-working'])
    const link = screen.getByRole('link', { name: /AI 办公平台选择/ })
    expect(link).toHaveAttribute('href', '/solutions/vibe-working')
  })

  it('solutions/vibe-working 详情展示计算与存储单元分工', () => {
    renderAt('/solutions/vibe-working')

    expect(screen.getByText('WorkBuddy · 计算单元')).toBeInTheDocument()
    expect(screen.getByText('腾讯文档 · 存储单元')).toBeInTheDocument()
    expect(screen.getByText('待分解')).toBeInTheDocument()
    expect(screen.getByRole('link', { name: /← 解决方案/ })).toHaveAttribute('href', '/')
  })

  it('未知方案回首页', () => {
    renderAt('/solutions/nope')

    expect(screen.getByRole('heading', { level: 1, name: '解决方案' })).toBeInTheDocument()
  })
})
