output "bucket_name" {
  value       = alicloud_oss_bucket.website.bucket
  description = "The name of the OSS bucket"
}

output "bucket_endpoint" {
  value       = alicloud_oss_bucket.website.extranet_internet_endpoint
  description = "The public internet endpoint of the OSS bucket"
}

output "website_url" {
  value       = "https://${var.domain_name}"
  description = "The URL of the static website"
}

output "cname_record_id" {
  value       = alicloud_alidns_record.consult_cname.record_id
  description = "The DNS record ID for CNAME"
}
