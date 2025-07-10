# 🔐 SSL Certificate Setup Guide

This guide explains how to use an existing AWS ACM certificate with your portfolio deployment, including wildcard certificates and certificates from other projects.

## 📋 Overview

You can use an existing SSL certificate in two ways:
1. **Create New Certificate** (default) - Terraform creates and validates a new certificate
2. **Use Existing Certificate** - Use a certificate you already have in AWS ACM

## 🎯 When to Use Existing Certificates

### **Wildcard Certificates**
If you have a wildcard certificate like `*.yourdomain.com`, you can reuse it across multiple projects:
```
Certificate: *.example.com
Can be used for:
- portfolio.example.com
- blog.example.com  
- api.example.com
- Any subdomain of example.com
```

### **Multi-Project Certificates**
If you have a certificate that covers multiple domains:
```
Certificate covers:
- example.com
- www.example.com
- api.example.com
- *.example.com
```

### **Cost Savings**
- Avoid creating duplicate certificates
- Reduce ACM certificate limits
- Centralized certificate management

## 🔍 Finding Your Certificate ARN

### **Method 1: AWS Console**
1. Go to **AWS Certificate Manager** in the AWS Console
2. Select your region (certificates for CloudFront must be in `us-east-1`)
3. Find your certificate in the list
4. Click on the certificate
5. Copy the **ARN** from the details page

### **Method 2: AWS CLI**
```bash
# List all certificates in us-east-1 (required for CloudFront)
aws acm list-certificates --region us-east-1

# Get detailed information about a specific certificate
aws acm describe-certificate --certificate-arn "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012" --region us-east-1

# Find certificates by domain name
aws acm list-certificates --region us-east-1 --query 'CertificateSummaryList[?DomainName==`example.com`]'
```

### **Method 3: Terraform Data Source**
```hcl
# Find certificate by domain name
data "aws_acm_certificate" "existing" {
  domain   = "example.com"
  statuses = ["ISSUED"]
  most_recent = true
}

output "certificate_arn" {
  value = data.aws_acm_certificate.existing.arn
}
```

## 🚀 Using Existing Certificate

### **Full Deployment with AI**

```bash
# Set environment variables
export DOMAIN_NAME="portfolio.example.com"
export AWS_REGION="us-east-1"
export INSTANCE_TYPE="t3.small"
export SSL_CERTIFICATE_ARN="arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"

# Run deployment
./scripts/deploy-aws.sh
```

### **Minimal Cost Deployment**

```bash
# Set environment variables
export DOMAIN_NAME="portfolio.example.com"
export ALERT_EMAIL="admin@example.com"
export SSL_CERTIFICATE_ARN="arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"

# Run minimal deployment
./scripts/deploy-minimal-cost.sh
```

### **Manual Terraform**

```bash
# Create terraform.tfvars
cat > terraform.tfvars << EOF
domain_name = "portfolio.example.com"
aws_region = "us-east-1"
ssl_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
environment = "production"
EOF

# Deploy
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

## ⚠️ Important Requirements

### **Region Requirements**
- **CloudFront**: Certificate MUST be in `us-east-1` region
- **ALB**: Certificate must be in the same region as your ALB
- **Cross-region**: You may need certificates in multiple regions

### **Domain Validation**
The certificate must cover your domain:
```bash
# Check certificate domains
aws acm describe-certificate \
  --certificate-arn "your-certificate-arn" \
  --region us-east-1 \
  --query 'Certificate.DomainValidationOptions[].DomainName'
```

### **Certificate Status**
Certificate must be in `ISSUED` status:
```bash
# Check certificate status
aws acm describe-certificate \
  --certificate-arn "your-certificate-arn" \
  --region us-east-1 \
  --query 'Certificate.Status'
```

## 🔧 Troubleshooting

### **Certificate Not Found**
```bash
# Verify certificate exists and is accessible
aws acm describe-certificate \
  --certificate-arn "your-certificate-arn" \
  --region us-east-1
```

**Common Issues:**
- Wrong region (CloudFront requires us-east-1)
- Incorrect ARN format
- Certificate in different AWS account
- Certificate expired or revoked

### **Domain Mismatch**
```bash
# Check if certificate covers your domain
aws acm describe-certificate \
  --certificate-arn "your-certificate-arn" \
  --region us-east-1 \
  --query 'Certificate.{DomainName:DomainName,SubjectAlternativeNames:SubjectAlternativeNames}'
```

**Solutions:**
- Use exact domain match
- Use wildcard certificate (`*.example.com`)
- Add domain to existing certificate
- Create new certificate with correct domains

### **Permission Issues**
```bash
# Check IAM permissions
aws iam simulate-principal-policy \
  --policy-source-arn "arn:aws:iam::123456789012:user/your-user" \
  --action-names "acm:DescribeCertificate" \
  --resource-arns "your-certificate-arn"
```

**Required Permissions:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "acm:DescribeCertificate",
        "acm:ListCertificates"
      ],
      "Resource": "*"
    }
  ]
}
```

## 📊 Certificate Management Best Practices

### **Wildcard Certificates**
```bash
# Create a wildcard certificate for reuse
aws acm request-certificate \
  --domain-name "*.example.com" \
  --subject-alternative-names "example.com" \
  --validation-method DNS \
  --region us-east-1
```

### **Certificate Monitoring**
```bash
# Check certificate expiration
aws acm describe-certificate \
  --certificate-arn "your-certificate-arn" \
  --region us-east-1 \
  --query 'Certificate.{Status:Status,NotAfter:NotAfter}'
```

### **Automated Renewal**
ACM certificates auto-renew if:
- Domain validation records exist in Route 53
- Certificate is actively used by AWS services
- Domain ownership can be verified

## 🔄 Migration Scenarios

### **From New to Existing Certificate**

1. **Get existing certificate ARN**
2. **Update terraform.tfvars**:
   ```hcl
   ssl_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
   ```
3. **Apply changes**:
   ```bash
   terraform plan
   terraform apply
   ```

### **From Existing to New Certificate**

1. **Remove certificate ARN from terraform.tfvars**:
   ```hcl
   # ssl_certificate_arn = ""  # Comment out or remove
   ```
2. **Apply changes**:
   ```bash
   terraform plan
   terraform apply
   ```

## 📝 Examples

### **Example 1: Wildcard Certificate**
```bash
# Certificate ARN for *.example.com
SSL_CERTIFICATE_ARN="arn:aws:acm:us-east-1:123456789012:certificate/wildcard-example-com"

# Deploy portfolio at portfolio.example.com
DOMAIN_NAME="portfolio.example.com" \
SSL_CERTIFICATE_ARN="$SSL_CERTIFICATE_ARN" \
./scripts/deploy-minimal-cost.sh
```

### **Example 2: Multi-Domain Certificate**
```bash
# Certificate covers: example.com, www.example.com, api.example.com
SSL_CERTIFICATE_ARN="arn:aws:acm:us-east-1:123456789012:certificate/multi-domain-cert"

# Deploy at any covered domain
DOMAIN_NAME="api.example.com" \
SSL_CERTIFICATE_ARN="$SSL_CERTIFICATE_ARN" \
./scripts/deploy-aws.sh
```

### **Example 3: Cross-Project Sharing**
```bash
# Use same certificate for multiple projects
SHARED_CERT="arn:aws:acm:us-east-1:123456789012:certificate/shared-cert"

# Project 1: Portfolio
DOMAIN_NAME="portfolio.example.com" SSL_CERTIFICATE_ARN="$SHARED_CERT" ./scripts/deploy-minimal-cost.sh

# Project 2: Blog  
DOMAIN_NAME="blog.example.com" SSL_CERTIFICATE_ARN="$SHARED_CERT" ./scripts/deploy-minimal-cost.sh
```

## ✅ Verification

After deployment, verify the certificate is working:

```bash
# Check SSL certificate details
openssl s_client -connect yourdomain.com:443 -servername yourdomain.com < /dev/null 2>/dev/null | openssl x509 -text -noout

# Check certificate via curl
curl -vI https://yourdomain.com

# Verify certificate in browser
# Look for green lock icon and certificate details
```

## 💡 Cost Optimization

### **Certificate Costs**
- **ACM Certificates**: Free for AWS services
- **Wildcard Certificates**: Same cost as single domain
- **Multiple Certificates**: No additional cost

### **Savings with Existing Certificates**
- Avoid duplicate certificates
- Reduce management overhead
- Centralized certificate monitoring
- Simplified renewal process

---

**🎯 Result: Use existing SSL certificates to reduce complexity and centralize certificate management across multiple projects!**