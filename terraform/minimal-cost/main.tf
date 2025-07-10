# Minimal Cost AWS Infrastructure - Static Website Only
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# S3 Bucket for static website hosting
resource "aws_s3_bucket" "website" {
  bucket = var.domain_name

  tags = {
    Name        = "Portfolio Website"
    Environment = var.environment
    CostCenter  = "minimal"
  }
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_versioning" "website" {
  bucket = aws_s3_bucket.website.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "website" {
  bucket = aws_s3_bucket.website.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.website.arn}/*"
      },
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.website]
}

# S3 Bucket Lifecycle Configuration for cost optimization
resource "aws_s3_bucket_lifecycle_configuration" "website" {
  bucket = aws_s3_bucket.website.id

  rule {
    id     = "lifecycle_rule"
    status = "Enabled"

    filter {
      prefix = ""
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }
  }
}

# CloudFront Origin Access Identity
resource "aws_cloudfront_origin_access_identity" "website" {
  comment = "OAI for ${var.domain_name}"
}

# Route 53 Hosted Zone
resource "aws_route53_zone" "main" {
  name = var.domain_name

  tags = {
    Name        = "Portfolio DNS Zone"
    Environment = var.environment
    CostCenter  = "minimal"
  }
}

# SSL Certificate (only create if not using existing)
resource "aws_acm_certificate" "website" {
  count = var.ssl_certificate_arn == "" && !var.use_existing_certificate ? 1 : 0
  
  domain_name               = var.domain_name
  subject_alternative_names = ["www.${var.domain_name}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = "Portfolio SSL Certificate"
    Environment = var.environment
    CostCenter  = "minimal"
  }
}

# Certificate validation (only if creating new certificate)
resource "aws_route53_record" "cert_validation" {
  for_each = var.ssl_certificate_arn == "" && !var.use_existing_certificate ? {
    for dvo in aws_acm_certificate.website[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.main.zone_id
}

resource "aws_acm_certificate_validation" "website" {
  count = var.ssl_certificate_arn == "" && !var.use_existing_certificate ? 1 : 0
  
  certificate_arn         = aws_acm_certificate.website[0].arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
  
  depends_on = [aws_route53_record.cert_validation]
}

# Note: We don't need a data source for existing certificates
# when we have the ARN directly. The ARN is sufficient for
# referencing the certificate in CloudFront and other services.
# This avoids the "empty result" error when the certificate
# domain doesn't exactly match the search criteria.


# Local value to determine which certificate to use
locals {
  certificate_arn = var.ssl_certificate_arn != "" ? var.ssl_certificate_arn : (
    length(aws_acm_certificate_validation.website) > 0 ? aws_acm_certificate_validation.website[0].certificate_arn : ""
  )
}

# CloudFront Distribution (Cost-optimized)
resource "aws_cloudfront_distribution" "website" {
  origin {
    domain_name = aws_s3_bucket.website.bucket_regional_domain_name
    origin_id   = "S3-${var.domain_name}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.website.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  price_class         = var.cloudfront_price_class

  aliases = [var.domain_name, "www.${var.domain_name}"]

  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-${var.domain_name}"
    compress               = true
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 86400    # 1 day
    max_ttl     = 31536000 # 1 year
  }

  # Aggressive caching for static assets
  ordered_cache_behavior {
    path_pattern     = "/assets/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${var.domain_name}"
    compress         = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl                = 86400     # 1 day
    default_ttl            = 2592000   # 30 days
    max_ttl                = 31536000  # 1 year
    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = local.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }

  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }

  tags = {
    Name        = "Portfolio CloudFront Distribution"
    Environment = var.environment
    CostCenter  = "minimal"
  }

  depends_on = [
    aws_acm_certificate_validation.website,
    data.aws_acm_certificate.existing
  ]
}

# Route 53 Records
resource "aws_route53_record" "website" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.website.domain_name
    zone_id                = aws_cloudfront_distribution.website.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "www.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.website.domain_name
    zone_id                = aws_cloudfront_distribution.website.hosted_zone_id
    evaluate_target_health = false
  }
}

# Cost monitoring alarm
resource "aws_cloudwatch_metric_alarm" "billing_alarm" {
  alarm_name          = "portfolio-billing-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period              = "86400"
  statistic           = "Maximum"
  threshold           = var.billing_alert_threshold
  alarm_description   = "This metric monitors estimated charges"
  alarm_actions       = [aws_sns_topic.billing_alerts.arn]

  dimensions = {
    Currency = "USD"
  }

  tags = {
    Name        = "Portfolio Billing Alarm"
    Environment = var.environment
  }
}

# SNS topic for billing alerts
resource "aws_sns_topic" "billing_alerts" {
  name = "portfolio-billing-alerts"

  tags = {
    Name        = "Portfolio Billing Alerts"
    Environment = var.environment
  }
}

# SNS topic subscription
resource "aws_sns_topic_subscription" "billing_alerts_email" {
  topic_arn = aws_sns_topic.billing_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}