# Outputs for AWS Infrastructure

output "website_url" {
  description = "URL of the website"
  value       = "https://${var.domain_name}"
}

output "api_url" {
  description = "URL of the AI API"
  value       = "https://api.${var.domain_name}"
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

output "s3_assets_bucket_name" {
  description = "S3 bucket name for assets (images, etc.)"
  value       = aws_s3_bucket.assets.id
}

output "profile_image_urls" {
  description = "URLs for profile images"
  value = {
    hero_profile  = "https://${aws_s3_bucket.assets.id}.s3.amazonaws.com/profile/kamal-raj-profile.jpg"
    about_profile = "https://${aws_s3_bucket.assets.id}.s3.amazonaws.com/profile/kamal-raj-about.jpg"
  }
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

output "ec2_instance_id" {
  description = "EC2 instance ID for AI model"
  value       = aws_instance.ai_model.id
}

output "ec2_public_ip" {
  description = "EC2 instance public IP"
  value       = aws_eip.ai_model.public_ip
}

output "ec2_private_ip" {
  description = "EC2 instance private IP"
  value       = aws_instance.ai_model.private_ip
}

output "load_balancer_dns" {
  description = "Application Load Balancer DNS name"
  value       = aws_lb.ai_model.dns_name
}

output "load_balancer_zone_id" {
  description = "Application Load Balancer zone ID"
  value       = aws_lb.ai_model.zone_id
}

output "vpc_id" {
  description = "VPC ID for AI infrastructure"
  value       = aws_vpc.ai_vpc.id
}

output "security_group_id" {
  description = "Security group ID for AI model"
  value       = aws_security_group.ai_model.id
}

# Cost tracking outputs
output "estimated_monthly_cost" {
  description = "Estimated monthly cost breakdown"
  value = {
    s3_hosting      = "$1-3"
    cloudfront_cdn  = "$1-5"
    route53_dns     = "$0.50"
    ec2_instance    = var.instance_type == "t3.small" ? "$15-20" : var.instance_type == "t3.medium" ? "$30-35" : "$40-50"
    load_balancer   = "$16"
    ssl_certificate = "Free"
    total_estimated = var.instance_type == "t3.small" ? "$35-45" : var.instance_type == "t3.medium" ? "$50-60" : "$60-75"
  }
}

# Deployment information
output "deployment_info" {
  description = "Important deployment information"
  value = {
    github_secrets_needed = [
      "AWS_ACCESS_KEY_ID",
      "AWS_SECRET_ACCESS_KEY",
      "S3_BUCKET_NAME",
      "CLOUDFRONT_DISTRIBUTION_ID",
      "EC2_IP",
      "EC2_PRIVATE_KEY"
    ]
    next_steps = [
      "1. Update GoDaddy nameservers with Route 53 nameservers",
      "2. Wait 24-48 hours for DNS propagation",
      "3. Configure GitHub secrets for CI/CD",
      "4. Deploy application using GitHub Actions",
      "5. Test website and AI API functionality"
    ]
  }
}

# Monitoring outputs
output "cloudwatch_log_group" {
  description = "CloudWatch log group for AI model"
  value       = aws_cloudwatch_log_group.ai_model.name
}

output "monitoring_dashboard_url" {
  description = "CloudWatch dashboard URL"
  value       = "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:"
}

# Security outputs
output "security_recommendations" {
  description = "Security recommendations"
  value = {
    ssh_access     = "Restrict SSH access to your IP only"
    api_security   = "Use strong API tokens and enable rate limiting"
    ssl_grade      = "A+ SSL rating with modern TLS"
    backup_enabled = var.enable_backup
    monitoring     = var.enable_monitoring
  }
}