import { describe, it, expect } from 'vitest'
import { parseFrontmatter, stripFrontmatter } from './frontmatter'

describe('frontmatter 解析', () => {
  it('无 frontmatter 返回 null', () => {
    expect(parseFrontmatter('# 标题\n\n正文')).toBeNull()
  })

  it('平铺键值', () => {
    expect(parseFrontmatter('---\ntitle: 训练营\ndescription: 说明\n---\n# 标题')).toEqual({
      title: '训练营',
      description: '说明',
    })
  })

  it('带引号的值', () => {
    expect(
      parseFrontmatter('---\ntitle: "训练营：入门"\ndescription: \'含「引号」的说明\'\n---\n'),
    ).toEqual({ title: '训练营：入门', description: '含「引号」的说明' })
  })

  it('值含冒号须加引号', () => {
    expect(parseFrontmatter('---\ntitle: 训练营: 入门\ndescription: 说明\n---\n')).toBeNull()
    expect(
      parseFrontmatter('---\ntitle: "训练营: 入门"\ndescription: 说明\n---\n')?.title,
    ).toBe('训练营: 入门')
  })

  it('多行块标量', () => {
    const md = '---\ntitle: 训练营\ndescription: |\n  第一行\n  第二行\n---\n'
    expect(parseFrontmatter(md)?.description).toBe('第一行\n第二行')
  })

  it('只有 title 时仍返回', () => {
    expect(parseFrontmatter('---\ntitle: 训练营\n---\n')).toEqual({
      title: '训练营',
      description: '',
    })
  })

  it('键值均为空返回 null', () => {
    expect(parseFrontmatter('---\ntitle: ""\n---\n')).toBeNull()
  })

  it('非法 YAML 返回 null', () => {
    expect(parseFrontmatter('---\ntitle: : :\n\tbad\n---\n')).toBeNull()
  })
})

describe('frontmatter 剥离', () => {
  it('去掉首部元数据只留正文', () => {
    expect(stripFrontmatter('---\ntitle: 标题\ndescription: 说明\n---\n\n正文')).toBe('\n正文')
  })

  it('无元数据时原样返回', () => {
    expect(stripFrontmatter('# 标题\n\n正文')).toBe('# 标题\n\n正文')
  })

  it('首行仅为分隔线时不当作元数据', () => {
    const md = '---\n\n正文\n\n---\n\n末尾'
    expect(stripFrontmatter(md)).toBe(md)
  })
})
