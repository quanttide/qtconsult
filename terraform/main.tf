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

# Create OSS Bucket
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

# Create DNS record for custom domain
resource "alicloud_alidns_record" "consult_cname" {
  domain_name = "quanttide.com"
  record_type = "CNAME"
  record_name = "consult"
  value       = alicloud_oss_bucket.website.extranet_internet_endpoint
  ttl         = 600
  status      = "ENABLE"

  depends_on = [alicloud_oss_bucket.website]
}

# Bind custom domain to OSS bucket
resource "alicloud_oss_bucket_cname" "consult" {
  bucket        = alicloud_oss_bucket.website.id
  domain_name   = var.domain_name
  certificate_id = alicloud_oss_bucket_website_certificate.cert.id
}

# Auto SSL certificate for the domain
resource "alicloud_oss_bucket_website_certificate" "cert" {
  bucket        = alicloud_oss_bucket.website.id
  domain_name   = var.domain_name
  force_destroy = false
}
