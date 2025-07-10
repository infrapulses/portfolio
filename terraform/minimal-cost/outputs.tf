# Outputs for Minimal Cost AWS Infrastructure

output "website_url" {
  description = "URL of the website"
  value       = "https://${var.domain_name}"
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.website.id
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.website.domain_name
}

output "s3_bucket_name" {
  description = "S3 bucket name for website hosting"
  value       = aws_s3_bucket.website.id
}

output "route53_zone_id" {
  description = "Route 53 hosted zone ID"
  value       = aws_route53_zone.main.zone_id
}

output "route53_name_servers" {
  description = "Route 53 name servers (update these in GoDaddy)"
  value       = aws_route53_zone.main.name_servers
}

output "ssl_certificate_arn" {
  description = "SSL certificate ARN"
  value       = local.certificate_arn
}

output "ssl_certificate_source" {
  description = "Source of SSL certificate (existing or created)"
  value       = var.ssl_certificate_arn != "" ? "existing" : "created"
}

# Cost information
output "estimated_monthly_cost" {
  description = "Estimated monthly cost breakdown"
  value = {
    s3_hosting      = "$1-2"
    cloudfront_cdn  = "$1-3"
    route53_dns     = "$0.50"
    ssl_certificate = "Free"
    total_estimated = "$2-5"
    savings_vs_full = "$30-40 saved per month"
  }
}

# Deployment information
output "deployment_info" {
  description = "Deployment information for minimal cost setup"
  value = {
    github_secrets_needed = [
      "AWS_ACCESS_KEY_ID",
      "AWS_SECRET_ACCESS_KEY",
      "S3_BUCKET_NAME",
      "CLOUDFRONT_DISTRIBUTION_ID"
    ]
    features_included = [
      "✅ Professional portfolio website",
      "✅ SSL certificate (free)",
      "✅ Global CDN",
      "✅ Custom domain",
      "✅ Responsive design",
      "❌ AI Assistant (removed for cost savings)"
    ]
    next_steps = [
      "1. Update GoDaddy nameservers with Route 53 nameservers",
      "2. Wait 24-48 hours for DNS propagation",
      "3. Configure GitHub secrets for CI/CD",
      "4. Deploy application using GitHub Actions",
      "5. Test website functionality"
    ]
  }
}

output "cost_optimization_features" {
  description = "Cost optimization features enabled"
  value = {
    s3_lifecycle_rules     = "Enabled - removes old versions after 30 days"
    cloudfront_price_class = "PriceClass_100 - US, Canada, Europe only"
    billing_alerts        = "Enabled - alerts when cost exceeds $10/month"
    intelligent_tiering    = var.enable_s3_intelligent_tiering ? "Enabled" : "Disabled"
    no_ec2_instances      = "No compute costs"
    no_load_balancer      = "No load balancer costs"
  }
}