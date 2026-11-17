import Markdown from '../components/Markdown'
import { stripFrontmatter } from '../utils/frontmatter'

// 咨询师介绍静态副本（data/consultants/*.md），根锚定路径与 CI 一致
const consultantModules = import.meta.glob('/data/consultants/*.md', {
  eager: true,
  query: '?raw',
  import: 'default',
}) as Record<string, string>

// 咨询师介绍：按文件名排序渲染全部档案
function Consultants() {
  const paths = Object.keys(consultantModules).sort()
  return (
    <main>
      {paths.map((path) => (
        <article key={path}>
          <Markdown>{stripFrontmatter(consultantModules[path] ?? '')}</Markdown>
        </article>
      ))}
    </main>
  )
}

export default Consultants
