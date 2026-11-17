import { describe, it, expect, afterEach } from 'vitest'
import { render, screen, cleanup } from '@testing-library/react'
import '@testing-library/jest-dom/vitest'
import App from './App'

// 冒烟：服务介绍与咨询师页必须渲染出内容，未知路由回首页。白屏会在这里失败
describe('页面渲染冒烟', () => {
  const routes = [
    { path: '/', text: /经营决策顾问/ },
    { path: '/consultants', text: /咨询师介绍/ },
  ]

  for (const { path, text } of routes) {
    it(`渲染 ${path}`, () => {
      window.history.pushState({}, '', path)
      render(<App />)
      expect(screen.getAllByText(text).length).toBeGreaterThan(0)
    })
  }

  it('未知路径重定向到首页', () => {
    window.history.pushState({}, '', '/whatever')
    render(<App />)
    expect(screen.getAllByText(/经营决策顾问/).length).toBeGreaterThan(0)
  })

  it('首页不渲染元数据', () => {
    window.history.pushState({}, '', '/')
    render(<App />)
    expect(screen.queryByText(/^title:/)).toBeNull()
    expect(screen.queryByText(/^description:/)).toBeNull()
  })

  it('导航含 studio 连接引用', () => {
    window.history.pushState({}, '', '/')
    render(<App />)
    const studio = screen.getByRole('link', { name: 'Studio' })
    expect(studio).toHaveAttribute('href', 'https://studio.consult.quanttide.com')
    expect(studio).toHaveAttribute('target', '_blank')
  })
})

afterEach(cleanup)
