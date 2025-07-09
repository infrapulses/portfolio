# Variables for Minimal Cost AWS Infrastructure

variable "domain_name" {
  description = "The domain name for the website"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]\\.[a-z]{2,}$", var.domain_name))
    error_message = "Domain name must be a valid domain format."
  }
}

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
  validation {
    condition = contains([
      "us-east-1", "us-east-2", "us-west-1", "us-west-2",
      "eu-west-1", "eu-west-2", "eu-central-1"
    ], var.aws_region)
    error_message = "AWS region must be a valid region."
  }
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
  validation {
    condition     = contains(["development", "staging", "production"], var.environment)
    error_message = "Environment must be development, staging, or production."
  }
}

variable "alert_email" {
  description = "Email address for billing alerts"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.alert_email))
    error_message = "Must be a valid email address."
  }
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default = {
    Project    = "Portfolio"
    Owner      = "infrapulses"
    CostCenter = "minimal"
  }
}

# Cost optimization settings
variable "enable_s3_intelligent_tiering" {
  description = "Enable S3 Intelligent Tiering for cost optimization"
  type        = bool
  default     = true
}

variable "cloudfront_price_class" {
  description = "CloudFront price class for cost optimization"
  type        = string
  default     = "PriceClass_100" # US, Canada, Europe only
  validation {
    condition     = contains(["PriceClass_All", "PriceClass_200", "PriceClass_100"], var.cloudfront_price_class)
    error_message = "CloudFront price class must be PriceClass_All, PriceClass_200, or PriceClass_100."
  }
}

variable "billing_alert_threshold" {
  description = "Billing alert threshold in USD"
  type        = number
  default     = 10
  validation {
    condition     = var.billing_alert_threshold > 0 && var.billing_alert_threshold <= 100
    error_message = "Billing alert threshold must be between 1 and 100 USD."
  }
}