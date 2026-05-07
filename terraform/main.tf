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

# Create OSS Bucket with static website hosting
resource "alicloud_oss_bucket" "website" {
  bucket = var.bucket_name

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

# Create DNS CNAME record pointing to OSS
resource "alicloud_alidns_record" "consult_cname" {
  domain_name = "quanttide.com"
  type        = "CNAME"
  rr          = "consult"
  value       = "${alicloud_oss_bucket.website.bucket}.${alicloud_oss_bucket.website.extranet_endpoint}"
  ttl         = 600
  status      = "ENABLE"

  depends_on = [alicloud_oss_bucket.website]
}

# Note: Custom domain CNAME binding must be done manually in OSS console
# After bucket is created, go to:
# Bucket Settings → Domain Management → Add Custom Domain → consult.quanttide.com
# Aliyun will auto-provision SSL certificate
