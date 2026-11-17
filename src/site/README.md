# 量潮咨询站点

量潮咨询服务门面站，基于 React + TypeScript + Vite 构建，参照简单心理的信息结构。

## 功能

- 服务页 `/`：服务介绍（业务定义、定价与服务模式，静态副本 `data/home/`，取材宣传册 `data/brochure/qtconsult/`）
- 咨询师页 `/consultants`：咨询师名录与档案（`data/consultants/`）
- 连接引用：导航含 studio（咨询师工作台）站外链接

三端 scope 见仓库根 [ROADMAP.md](../../ROADMAP.md)：lite（报名入口与后续服务）未建。

## 开发

```bash
# 安装依赖
npm install

# 启动开发服务器
npm run dev

# 构建生产版本
npm run build

# 运行测试
npm test

# 代码检查
npm run lint
```

## 技术栈

- React 19
- TypeScript
- Vite
- React Router
- Vitest

## 项目结构

```
data/                    # 内容数据（置于 src 之外）
├── home/                # 服务介绍（上游 brochure 的静态副本）
└── consultants/         # 咨询师档案
src/
├── App.tsx              # 路由装配（/ 与 /consultants，未知回首页）
├── routes.ts            # 路由路径与站外连接（studio）
├── main.tsx             # 入口文件
├── App.css / index.css  # 样式
├── components/
│   ├── Layout.tsx       # 站点外框（导航含 studio 引用 + 页头 + 内容区）
│   └── Markdown.tsx     # markdown 渲染（react-markdown + remark-gfm）
├── pages/
│   ├── Home.tsx         # 服务介绍页
│   └── Consultants.tsx  # 咨询师页
└── utils/
    └── frontmatter.ts   # 元数据解析与剥离
```

## 内容数据

`data/` 下的 markdown 为上游内容的静态副本，页面经 `import.meta.glob` 扫描文件（根锚定路径 `/data/...`）并剥离 frontmatter。服务介绍的源在 `data/brochure/qtconsult/`，站点与上游不得各改一份：内容改动先改上游，再回流站点。
