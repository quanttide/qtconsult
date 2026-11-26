import { Link } from 'react-router-dom'
import { solutions } from '../data/solutions'

export default function Home() {
  return (
    <section className="liteList">
      <h1>解决方案</h1>
      <p className="liteNote">在研发中的咨询方案，按打包单元上架；点进去看结论与步骤。</p>
      <ul>
        {solutions.map((s) => (
          <li key={s.slug} className="liteItem">
            <Link to={`/solutions/${s.slug}`}>
              <h2>{s.name}</h2>
              <p>{s.summary}</p>
            </Link>
          </li>
        ))}
      </ul>
    </section>
  )
}
