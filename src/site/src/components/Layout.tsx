import type { ReactNode } from 'react'
import { NavLink } from 'react-router-dom'
import { EXTERNAL_LINKS, ROUTE_PATHS } from '../routes'

// 站点外框：导航 + 页头 + 内容区，路由出口由调用方以 children 传入
function Layout({ children }: { children: ReactNode }) {
  return (
    <div className="app">
      <nav className="site-nav">
        <div className="nav-inner">
          <a className="site-brand" href={ROUTE_PATHS.home}>
            量潮咨询
          </a>
          <div className="site-links">
            <NavLink
              to={ROUTE_PATHS.home}
              end
              className={({ isActive }) => (isActive ? 'active' : '')}
            >
              服务
            </NavLink>
            <NavLink
              to={ROUTE_PATHS.consultants}
              className={({ isActive }) => (isActive ? 'active' : '')}
            >
              咨询师
            </NavLink>
            <a href={EXTERNAL_LINKS.studio} target="_blank" rel="noreferrer">
              Studio
            </a>
          </div>
        </div>
      </nav>

      <header className="hero">
        <h1>量潮咨询</h1>
        <p>企业经营决策顾问 · 技术方案匹配</p>
      </header>

      <div className="content">{children}</div>
    </div>
  )
}

export default Layout
