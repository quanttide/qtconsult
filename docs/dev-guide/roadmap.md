# ROADMAP

## v0.2.x — 前后端全链路联调

### 目标

0.1 → 0.2 的核心目标是引入 Workspace 机制，实现不同客户之间的数据隔离。0.2.0 已完成组件级开发，0.2.x 继续补全前后端联调验证。

### 已完成

- [x] Provider Workspace 模型与 CRUD API
- [x] 所有数据模型关联 Workspace，按 workspace_id 隔离读写
- [x] Studio workspace 顶栏切换器（替代旧的选择页）
- [x] 认证机制关联当前 workspace，限制跨 workspace 访问
- [x] Provider 64 测试，79% 覆盖率
- [x] Studio 41 测试，95% 覆盖率

### 进行中

- [ ] Provider → Studio 全链路联调：启动 Provider → 启动 Studio → 验证 workspace 切换和数据隔离
- [ ] E2E 自动化验证方案落地
