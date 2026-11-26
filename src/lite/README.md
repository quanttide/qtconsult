# qtconsult-lite

量潮咨询的 **lite Web 端**：首页是解决方案列表，每个方案是一个打包单元，详情走 `/solutions/<slug>`（首单元 `solutions/vibe-working`：AI 办公平台选择）。

- **这里**：方案清单与打包单元详情（结论、计算与存储单元分工、步骤状态）
- **正本**：咨询档案 quanttide-profile-of-consulting-management 的 `vibe-working/platform-decision`

## 开发

```bash
npm install
npm test        # vitest
npm run lint    # eslint
npm run build   # tsc -b && vite build
```

## 许可

随仓库许可。
