# OSS 存储

## 桶规划

| 桶 | 用途 |
|------|------|
| `qtconsult-provider` | 业务系统主桶，应用读写 |
| `qtconsult-archive` | 归档桶，多来源数据长期保存，兼顾灾备 |

## 首次部署

```hcl
resource "alicloud_oss_bucket" "provider" {
  bucket = "qtconsult-provider"
  acl    = "private"

  versioning { status = "Enabled" }
}
```

## 查看对象历史版本

```bash
ossutil list oss://<桶名>/<路径> --all-versions
```

## 误删恢复

```bash
# 用对象路径恢复最近一个被删的版本
ossutil restore oss://<桶名>/<路径>

# 或用版本 ID 恢复
ossutil set-acl oss://<桶名>/<路径> private --version-id <VersionId>
```

## 误改恢复

```bash
# 把指定历史版本下载到本地，再重新上传
ossutil cp oss://<桶名>/<路径> /tmp/restored --version-id <VersionId>
ossutil cp /tmp/restored oss://<桶名>/<路径>
```

## 归档策略

`qtconsult-provider` 通过同区域复制（SRR）同步到 `qtconsult-archive`，同时 `qtconsult-archive` 也接收来自其他业务系统之外的归档数据。

archive 内的数据按来源前缀组织：

| 前缀 | 来源 |
|------|------|
| `platform/` | 自建平台 |
| ... | 其他系统 |

```hcl
resource "alicloud_oss_bucket" "archive" {
  bucket = "qtconsult-archive"
  acl    = "private"

  versioning { status = "Enabled" }

  lifecycle_rules {
    id      = "archive-to-cold"
    enabled = true
    prefix  = ""
    transitions {
      storage_class = "Archive"
      days          = 90
    }
  }
}

# provider → archive（不同步删除标记，provider 删数据不影响归档）
resource "alicloud_oss_bucket_replication" "archive" {
  bucket = alicloud_oss_bucket.provider.id
  rules {
    status               = "Enabled"
    delete_marker_status = "Disabled"
    destination {
      bucket = alicloud_oss_bucket.archive.id
    }
  }
}
```

`qtconsult-archive` 不授予日常 DeleteObject 权限，防止误删蔓延到归档。
```
