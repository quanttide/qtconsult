variable "region" {
  description = "Aliyun OSS region"
  type        = string
  default     = "cn-hangzhou"
}

variable "site_bucket_name" {
  description = "OSS bucket for the consult site (consult.quanttide.com)"
  type        = string
  default     = "qtconsult-site"
}

variable "studio_bucket_name" {
  description = "OSS bucket for the studio (studio.consult.quanttide.com)"
  type        = string
  default     = "qtconsult-studio"
}

variable "index_document" {
  description = "Index document for static website hosting"
  type        = string
  default     = "index.html"
}

variable "error_document" {
  description = "Error document for static website hosting"
  type        = string
  default     = "index.html"
}
