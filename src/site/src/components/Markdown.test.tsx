import { describe, it, expect } from 'vitest'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/vitest'
import Markdown from './Markdown'

describe('markdown 渲染', () => {
  it('GFM 表格渲染表头与表体', () => {
    const { container } = render(
      <Markdown>{'| 职级 | 价格 |\n|---|---|\n| 首席 | 500 |'}</Markdown>,
    )
    expect(container.querySelector('table thead th')?.textContent).toBe('职级')
    expect(container.querySelector('table tbody td')?.textContent).toBe('首席')
  })

  it('无分隔行的竖线文本不成表格', () => {
    const { container } = render(<Markdown>{'| A | B |'}</Markdown>)
    expect(container.querySelector('table')).toBeNull()
  })

  it('标题、列表、引用块、代码块', () => {
    const { container } = render(
      <Markdown>{'# 标题\n\n- 甲\n- 乙\n\n> 引用\n\n```ts\nconst a = 1\n```'}</Markdown>,
    )
    expect(screen.getByRole('heading', { level: 1, name: '标题' })).toBeInTheDocument()
    expect(container.querySelectorAll('ul li')).toHaveLength(2)
    expect(container.querySelector('blockquote')).toHaveTextContent('引用')
    expect(container.querySelector('pre code')?.className).toContain('language-ts')
  })

  it('行内强调、行内代码与链接', () => {
    const { container } = render(<Markdown>{'**粗** 与 `a` 与 [文档](/x)'}</Markdown>)
    expect(container.querySelector('strong')?.textContent).toBe('粗')
    expect(container.querySelector('p code')?.textContent).toBe('a')
    expect(container.querySelector('a')?.getAttribute('href')).toBe('/x')
  })

  it('嵌套列表渲染层级', () => {
    const { container } = render(<Markdown>{'- 甲\n  - 甲一\n- 乙'}</Markdown>)
    expect(container.querySelectorAll('ul li ul li')).toHaveLength(1)
  })

  it('原始 HTML 不解析为元素', () => {
    const { container } = render(
      <Markdown>{'正文 <script>alert(1)</script> 与 <b>粗</b>'}</Markdown>,
    )
    expect(container.querySelector('script')).toBeNull()
    expect(container.querySelector('b')).toBeNull()
  })

  it('连续行合并为同一段落', () => {
    const { container } = render(<Markdown>{'第一行\n第二行'}</Markdown>)
    expect(container.querySelectorAll('p')).toHaveLength(1)
  })
})
