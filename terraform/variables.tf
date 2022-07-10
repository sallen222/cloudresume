variable "domain_name" {
  type        = string
  description = "The domain name of the website"
}

variable "zone_id" {
  type        = string
  description = "ID of route53 hosted zone"
}

variable "certificate_arn" {
  type        = string
  description = "ARN of SSL cert"
}