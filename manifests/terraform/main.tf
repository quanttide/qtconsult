terraform {
  required_version = ">= 1.0"

  required_providers {
    alicloud = {
      source  = "aliyun/alicloud"
      version = "~> 1.212"
    }
  }
}

provider "alicloud" {
  region = var.region
}

# Site bucket：咨询服务介绍站，接管 consult 主域名
resource "alicloud_oss_bucket" "site" {
  bucket = var.site_bucket_name

  versioning {
    status = "Enabled"
  }

  website {
    index_document = var.index_document
    error_document = var.error_document
  }

  lifecycle {
    prevent_destroy = false
  }
}

# Studio bucket：咨询师工作台（Flutter Web）。资源名沿用原 website，避免 state 重建
resource "alicloud_oss_bucket" "website" {
  bucket = var.studio_bucket_name

  versioning {
    status = "Enabled"
  }

  website {
    index_document = var.index_document
    error_document = var.error_document
  }

  lifecycle {
    prevent_destroy = false
  }
}

# 2023 后新桶默认开启"阻止公共访问"，会使 public-read 失效（AccessDenied），
# 需显式关闭（qtclass / qtcloud / qtadmin 同款踩坑，见各自 manifests README）
resource "alicloud_oss_bucket_public_access_block" "site" {
  bucket              = alicloud_oss_bucket.site.bucket
  block_public_access = false
}

resource "alicloud_oss_bucket_public_access_block" "studio" {
  bucket              = alicloud_oss_bucket.website.bucket
  block_public_access = false
}

# 公共读：静态站分发；如后续接入 CDN 回源鉴权可改回 private
resource "alicloud_oss_bucket_acl" "site" {
  bucket = alicloud_oss_bucket.site.bucket
  acl    = "public-read"

  depends_on = [alicloud_oss_bucket_public_access_block.site]
}

resource "alicloud_oss_bucket_acl" "studio" {
  bucket = alicloud_oss_bucket.website.bucket
  acl    = "public-read"

  depends_on = [alicloud_oss_bucket_public_access_block.studio]
}

# consult.quanttide.com → site bucket（原指向 studio bucket，改值原地更新）
resource "alicloud_alidns_record" "consult_cname" {
  domain_name = "quanttide.com"
  type        = "CNAME"
  rr          = "consult"
  value       = "${alicloud_oss_bucket.site.bucket}.${alicloud_oss_bucket.site.extranet_endpoint}"
  ttl         = 600
  status      = "ENABLE"

  depends_on = [alicloud_oss_bucket.site]
}

# studio.consult.quanttide.com → studio bucket
resource "alicloud_alidns_record" "studio_cname" {
  domain_name = "quanttide.com"
  type        = "CNAME"
  rr          = "studio.consult"
  value       = "${alicloud_oss_bucket.website.bucket}.${alicloud_oss_bucket.website.extranet_endpoint}"
  ttl         = 600
  status      = "ENABLE"

  depends_on = [alicloud_oss_bucket.website]
}

# Note: Custom domain CNAME binding must be done manually in OSS console
# After a bucket is created, go to:
# Bucket Settings → Domain Management → Add Custom Domain → bind the matching domain
# Aliyun will auto-provision SSL certificate
