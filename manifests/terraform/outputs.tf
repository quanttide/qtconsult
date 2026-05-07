output "bucket_name" {
  value       = alicloud_oss_bucket.website.bucket
  description = "The name of the OSS bucket"
}

output "bucket_endpoint" {
  value       = alicloud_oss_bucket.website.extranet_endpoint
  description = "The public endpoint of the OSS bucket (use this as CNAME target)"
}

output "website_url" {
  value       = "https://${var.domain_name}"
  description = "The URL of the static website (available after CNAME is bound)"
}

output "dns_record_id" {
  value       = alicloud_alidns_record.consult_cname.id
  description = "The DNS record ID"
}
