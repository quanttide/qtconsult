import { Link, Navigate, useParams } from 'react-router-dom'
import { findSolution, vibeWorking } from '../data/solutions'

export default function SolutionDetail() {
  const { slug } = useParams()
  const meta = slug ? findSolution(slug) : undefined
  if (!meta || meta.slug !== 'vibe-working') return <Navigate to="/" replace />

  return (
    <section className="liteCard">
      <Link to="/" className="liteBack">
        ← 解决方案
      </Link>
      <p className="liteTag">solutions/vibe-working</p>
      <h1>{vibeWorking.name}</h1>
      <p>{vibeWorking.problem}</p>
      <div className="liteBadge">待分解</div>
      <p className="liteConclusion">{vibeWorking.conclusion}</p>
      <div className="liteModules">
        <span>
          {vibeWorking.compute.name} · {vibeWorking.compute.role}
        </span>
        <span>
          {vibeWorking.storage.name} · {vibeWorking.storage.role}
        </span>
      </div>
      <ol className="liteSteps">
        {vibeWorking.steps.map((step) => (
          <li key={step}>{step}</li>
        ))}
      </ol>
      <a className="liteSource" href={vibeWorking.source} target="_blank" rel="noopener">
        咨询档案 →
      </a>
    </section>
  )
}
