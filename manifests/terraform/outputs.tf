output "site_bucket_name" {
  value       = alicloud_oss_bucket.site.bucket
  description = "The OSS bucket for consult.quanttide.com"
}

output "site_bucket_endpoint" {
  value       = alicloud_oss_bucket.site.extranet_endpoint
  description = "The public endpoint of the site bucket (use this as CNAME target)"
}

output "studio_bucket_name" {
  value       = alicloud_oss_bucket.website.bucket
  description = "The OSS bucket for studio.consult.quanttide.com"
}

output "studio_bucket_endpoint" {
  value       = alicloud_oss_bucket.website.extranet_endpoint
  description = "The public endpoint of the studio bucket (use this as CNAME target)"
}

output "site_url" {
  value       = "https://consult.quanttide.com"
  description = "The URL of the consult site (available after CNAME is bound)"
}

output "studio_url" {
  value       = "https://studio.consult.quanttide.com"
  description = "The URL of the studio (available after CNAME is bound)"
}
