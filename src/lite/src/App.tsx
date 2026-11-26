import { officeSolution } from './vibe'
import './App.css'

export default function App() {
  return (
    <main className="page">
      <header className="hero">
        <h1>量潮咨询 · AI 办公方案</h1>
        <p>{officeSolution.problem}</p>
      </header>

      <section aria-labelledby="solution">
        <div className="trackHead">
          <h2 id="solution">{officeSolution.name}</h2>
          <p>平台选择问题 · 形成于 {officeSolution.decidedAt}</p>
        </div>
        <div className="grid">
          <article className="card">
            <div className="cardTop">
              <h3>已定结论</h3>
              <span className="badge wip">待分解</span>
            </div>
            <p className="summary">{officeSolution.conclusion}</p>
            <div className="modules">
              <span className="module">
                {officeSolution.compute.name} · {officeSolution.compute.role}
              </span>
              <span className="module">
                {officeSolution.storage.name} · {officeSolution.storage.role}
              </span>
            </div>
            <ol className="steps">
              {officeSolution.steps.map((step) => (
                <li key={step}>{step}</li>
              ))}
            </ol>
            <a className="preview" href={officeSolution.source} target="_blank" rel="noopener">
              咨询档案 →
            </a>
          </article>
        </div>
      </section>
    </main>
  )
}
