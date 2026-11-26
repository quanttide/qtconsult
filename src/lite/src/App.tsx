import { BrowserRouter, Navigate, Routes, Route } from 'react-router-dom'
import Home from './pages/Home'
import SolutionDetail from './pages/SolutionDetail'
import { ROUTE_PATHS } from './routes'
import './App.css'

// 路由表单独导出，便于测试
export function AppRoutes() {
  return (
    <Routes>
      <Route path={ROUTE_PATHS.home} element={<Home />} />
      <Route path={ROUTE_PATHS.solutionItem} element={<SolutionDetail />} />
      <Route path="*" element={<Navigate to={ROUTE_PATHS.home} replace />} />
    </Routes>
  )
}

// 外壳：品牌顶栏 + 页面
function App() {
  return (
    <BrowserRouter>
      <div className="liteApp">
        <header className="liteHeader">
          <span className="liteBrand">量潮咨询 Lite</span>
        </header>
        <main className="liteMain">
          <AppRoutes />
        </main>
      </div>
    </BrowserRouter>
  )
}

export default App
