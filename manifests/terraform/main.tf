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
