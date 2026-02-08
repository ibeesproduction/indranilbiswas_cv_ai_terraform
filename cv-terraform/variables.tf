variable "aws_region" {
  description = "Primary AWS region for resources"
  type        = string
  default     = "ap-southeast-2"
}

variable "domain_name" {
  description = "Subdomain for the CV website"
  type        = string
  default     = "indranilbiswas.ibeesproduction.com"
}

variable "hosted_zone_name" {
  description = "Parent hosted zone domain name (must exist)"
  type        = string
  default     = "ibeesproduction.com"
}

variable "enable_logging" {
  description = "Enable CloudFront access logging"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "CV-Website"
    ManagedBy   = "Terraform"
    Environment = "Production"
  }
}

variable "price_class" {
  description = "CloudFront distribution price class"
  type        = string
  default     = "PriceClass_All"
}
