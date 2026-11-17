# 部署指南

## 架构

```
GitHub Action → Flutter Build → 阿里云 OSS → studio.consult.quanttide.com
GitHub Action → Vite Build    → 阿里云 OSS → consult.quanttide.com（主域名给 site）
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
cd manifests/terraform

# 初始化
terraform init

# 预览计划
terraform plan

# 应用配置（创建 OSS Bucket + 域名绑定 + SSL）
terraform apply
```

自动完成：
- 创建 OSS Bucket (`qtconsult-site` 与 `qtconsult-studio`)
- 开启静态网站托管
- 绑定自定义域名 `consult.quanttide.com`（site）与 `studio.consult.quanttide.com`（studio）
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
ossutil cp --recursive src/studio/build/web/ oss://qtconsult-studio/
```

## 关键操作记录（部署踩坑）

1. **公共读两步走**：2023 后新桶默认开启「阻止公共访问」，直接 `set-acl public-read` 或设公共 bucket-policy 均报 403（`Put public bucket acl/policy is not allowed`）。正确顺序：先 `PutBucketPublicAccessBlock`（`block_public_access=false`）再设 `public-read`——已在 `main.tf` 固化（qtclass / qtcloud / qtadmin 同款）。
2. **自定义域名绑定需 token 验证**：`ossutil bucket-cname --method put --item token oss://<桶> <域名>` 取 token，在 DNS 加 TXT 记录 `_dnsauth.<域名>` → token，生效后再 `ossutil bucket-cname --method put oss://<桶> <域名>`。未绑定域名时 CNAME 已指过来也会 403（`Anonymous access is forbidden`，HostId 为自定义域名）。
3. **自动证书签发有延迟**：域名绑定后 Aliyun 自动签发 HTTPS 证书需几分钟，期间严格 HTTPS 握手失败（`no alternative certificate subject name`），HTTP 已 200；重验通过即完成。

## 文件结构

```
qtconsult/
├── manifests/terraform/
│   ├── main.tf      # OSS Bucket + 域名 + SSL
│   ├── variables.tf # 配置参数
│   └── outputs.tf   # 输出信息
└── .github/
    └── workflows/
        └── deploy.yml # CI/CD 流程
```
