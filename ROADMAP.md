# ROADMAP

## v0.2.0（规划中）

### 目标

0.1 → 0.2 的核心目标是引入 **Workspace** 机制，实现不同客户之间的数据隔离。

### 关键任务

- [ ] Provider 增加 Workspace 模型与 CRUD API
- [ ] 所有数据模型关联 Workspace，按 workspace_id 隔离读写
- [ ] Studio 增加 workspace 选择/切换界面
- [ ] 认证机制关联当前 workspace，限制跨 workspace 访问
- [ ] 数据迁移脚本：存量数据归入默认 workspace
