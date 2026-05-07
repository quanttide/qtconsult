# 部署指南

## 架构

```
GitHub Action → Flutter Build → 阿里云 OSS → consult.quanttide.com
```

## 准备工作

### 1. 添加 GitHub Secrets

在 GitHub 仓库 Settings → Secrets and variables → Actions 中添加：

| Secret 名称 | 值 |
|------------|-----|
| `ALIYUN_ACCESS_KEY_ID` | 阿里云 AccessKey ID |
| `ALIYUN_ACCESS_KEY_SECRET` | 阿里云 AccessKey Secret |

> 推荐创建 RAM 用户并授予 OSS 权限，不要使用主账号 AccessKey。

### 2. 初始化 Terraform 基础设施（仅首次）

```bash
cd terraform

# 初始化
terraform init

# 预览计划
terraform plan

# 应用配置（创建 OSS Bucket + 域名绑定 + SSL）
terraform apply
```

自动完成：
- 创建 OSS Bucket (`qtconsult`)
- 开启静态网站托管
- 绑定自定义域名 `consult.quanttide.com`
- 申请 SSL 证书（HTTPS）
- 创建 DNS CNAME 记录

## 部署

推送代码到 `main` 分支自动触发部署：

```bash
git add .
git commit -m "feat: add terraform + github action deployment"
git push origin main
```

## 手动部署（调试用）

### 本地构建

```bash
cd src/studio
flutter build web --release
```

### 使用 ossutil 上传

```bash
ossutil cp --recursive src/studio/build/web/ oss://qtconsult/
```

## 文件结构

```
qtconsult/
├── terraform/
│   ├── main.tf      # OSS Bucket + 域名 + SSL
│   ├── variables.tf # 配置参数
│   └── outputs.tf   # 输出信息
└── .github/
    └── workflows/
        └── deploy.yml # CI/CD 流程
```
