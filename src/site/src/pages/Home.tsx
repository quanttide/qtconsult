import Markdown from '../components/Markdown'
import { stripFrontmatter } from '../utils/frontmatter'

// 服务介绍静态副本（源自宣传册 brochure/qtconsult/，data/home/*.md），根锚定路径与 CI 一致
const homeModules = import.meta.glob('/data/home/*.md', {
  eager: true,
  query: '?raw',
  import: 'default',
}) as Record<string, string>

const HOME_ORDER = ['/data/home/index.md', '/data/home/how.md']

// 服务介绍：业务定义、定价与服务模式。正文剥 frontmatter 后渲染
function Home() {
  return (
    <main>
      {HOME_ORDER.map((path) => (
        <article key={path}>
          <Markdown>{stripFrontmatter(homeModules[path] ?? '')}</Markdown>
        </article>
      ))}
    </main>
  )
}

export default Home
