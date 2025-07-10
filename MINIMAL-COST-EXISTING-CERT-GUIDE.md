# 💰 Minimal Cost Portfolio Deployment with Existing SSL Certificate

**Estimated Monthly Cost: $2-5** | **Setup Time: 30-45 minutes** | **Savings: $30-40/month**

This guide shows you how to deploy a professional portfolio website using an existing SSL certificate, maximizing cost savings and simplifying certificate management.

## 🎯 Why Use Existing Certificates?

### **Cost Benefits**
- **$0** for SSL certificates (already paid for)
- **Reuse wildcard certificates** across multiple projects
- **Avoid certificate limits** in AWS ACM
- **Centralized management** of all certificates

### **Common Scenarios**
- ✅ You have a wildcard certificate (`*.yourdomain.com`)
- ✅ You have a multi-domain certificate covering your portfolio domain
- ✅ You're migrating from another AWS project
- ✅ You want to use a certificate from another region/account

## 📋 Prerequisites

Before starting, ensure you have:
- [ ] AWS account with billing configured
- [ ] Domain name registered (GoDaddy, Route 53, etc.)
- [ ] **Existing SSL certificate in AWS ACM**
- [ ] Certificate ARN (we'll help you find this)
- [ ] AWS CLI installed and configured
- [ ] Terraform installed
- [ ] Node.js and npm installed

## 🔍 Step 1: Find Your Certificate ARN

### **Method 1: AWS Console (Easiest)**
1. Go to [AWS Certificate Manager Console](https://console.aws.amazon.com/acm/)
2. **Important**: Switch to `us-east-1` region (required for CloudFront)
3. Find your certificate in the list
4. Click on the certificate name
5. Copy the **Certificate ARN** from the details page

### **Method 2: AWS CLI**
```bash
# List all certificates in us-east-1 (required for CloudFront)
aws acm list-certificates --region us-east-1

# Find certificates by domain name
aws acm list-certificates --region us-east-1 \
  --query 'CertificateSummaryList[?contains(DomainName, `yourdomain.com`)]'

# Get detailed info about a specific certificate
aws acm describe-certificate \
  --certificate-arn "arn:aws:acm:us-east-1:123456789012:certificate/your-cert-id" \
  --region us-east-1
```

### **Method 3: Find Wildcard Certificates**
```bash
# Find wildcard certificates that can cover your domain
aws acm list-certificates --region us-east-1 \
  --query 'CertificateSummaryList[?starts_with(DomainName, `*`)]'
```

**📝 Save your Certificate ARN - you'll need it for deployment!**

Example ARN format:
```
arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012
```

## 🚀 Step 2: Prepare Your Environment

### **Install Required Tools**
```bash
# Install AWS CLI (if not already installed)
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Install Terraform (if not already installed)
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# Verify installations
aws --version
terraform --version
```

### **Configure AWS Credentials**
```bash
aws configure
# Enter your AWS Access Key ID
# Enter your AWS Secret Access Key  
# Enter default region: us-east-1
# Enter output format: json
```

### **Clone and Setup Project**
```bash
git clone https://github.com/infrapulses/portfolio-website.git
cd portfolio-website
npm install
```

## 🔧 Step 3: Verify Certificate Compatibility

### **Check Certificate Status**
```bash
# Replace with your actual certificate ARN
CERT_ARN="arn:aws:acm:us-east-1:123456789012:certificate/your-cert-id"

# Check certificate status (must be ISSUED)
aws acm describe-certificate \
  --certificate-arn "$CERT_ARN" \
  --region us-east-1 \
  --query 'Certificate.Status'
```

### **Check Domain Coverage**
```bash
# Check which domains the certificate covers
aws acm describe-certificate \
  --certificate-arn "$CERT_ARN" \
  --region us-east-1 \
  --query 'Certificate.{DomainName:DomainName,SubjectAlternativeNames:SubjectAlternativeNames}'
```

**✅ Your domain must be covered by the certificate:**
- Exact match: `portfolio.example.com` covered by certificate for `portfolio.example.com`
- Wildcard match: `portfolio.example.com` covered by certificate for `*.example.com`
- SAN match: `portfolio.example.com` listed in Subject Alternative Names

## 🏗️ Step 4: Deploy Infrastructure

### **Set Environment Variables**
```bash
# Required variables
export DOMAIN_NAME="portfolio.yourdomain.com"  # Your actual domain
export ALERT_EMAIL="your-email@example.com"    # For billing alerts
export SSL_CERTIFICATE_ARN="arn:aws:acm:us-east-1:123456789012:certificate/your-cert-id"

# Optional variables
export AWS_REGION="us-east-1"  # Default region
```

### **Quick Deployment (Recommended)**
```bash
# Run the automated deployment script
./scripts/deploy-minimal-cost.sh
```

### **Manual Deployment (Advanced)**
```bash
# Navigate to minimal cost configuration
cd terraform/minimal-cost

# Initialize Terraform
terraform init

# Create configuration file
cat > terraform.tfvars << EOF
domain_name = "$DOMAIN_NAME"
aws_region = "$AWS_REGION"
alert_email = "$ALERT_EMAIL"
ssl_certificate_arn = "$SSL_CERTIFICATE_ARN"
environment = "production"
EOF

# Plan deployment (review what will be created)
terraform plan -var-file="terraform.tfvars"

# Deploy infrastructure
terraform apply -var-file="terraform.tfvars"
```

### **Save Important Outputs**
```bash
# Get deployment information
terraform output > ../deployment-outputs.txt

# Get nameservers for DNS configuration
terraform output route53_name_servers
```

## 🌐 Step 5: Configure DNS

### **Get Route 53 Nameservers**
```bash
cd terraform/minimal-cost
terraform output route53_name_servers
```

### **Update Your Domain Registrar**

#### **For GoDaddy:**
1. Login to [GoDaddy DNS Management](https://dcc.godaddy.com/manage/dns)
2. Select your domain
3. Go to **Nameservers** section
4. Choose **Custom nameservers**
5. Replace with the Route 53 nameservers from Terraform output
6. Save changes

#### **For Other Registrars:**
- **Namecheap**: Domain List → Manage → Nameservers → Custom DNS
- **Cloudflare**: DNS → Records → Update nameservers
- **Route 53**: Already configured if domain is registered with Route 53

**⏰ DNS propagation takes 24-48 hours**

## 📦 Step 6: Deploy Website Files

### **Build and Upload Website**
```bash
# Return to project root
cd ../../

# Build the application
npm run build

# Get S3 bucket name from Terraform
S3_BUCKET=$(cd terraform/minimal-cost && terraform output -raw s3_bucket_name)
echo "Deploying to S3 bucket: $S3_BUCKET"

# Upload website files with optimized caching
aws s3 sync dist/ "s3://$S3_BUCKET" \
    --delete \
    --cache-control "public, max-age=31536000, immutable" \
    --exclude "*.html" \
    --exclude "service-worker.js" \
    --exclude "manifest.json"

# Upload HTML files with short cache
aws s3 sync dist/ "s3://$S3_BUCKET" \
    --cache-control "public, max-age=0, must-revalidate" \
    --include "*.html" \
    --include "service-worker.js" \
    --include "manifest.json"
```

### **Invalidate CloudFront Cache**
```bash
# Get CloudFront distribution ID
CLOUDFRONT_DIST_ID=$(cd terraform/minimal-cost && terraform output -raw cloudfront_distribution_id)

# Invalidate cache to serve new content
aws cloudfront create-invalidation \
    --distribution-id "$CLOUDFRONT_DIST_ID" \
    --paths "/*"

echo "Cache invalidation started. Changes will be live in 5-10 minutes."
```

## 🔄 Step 7: Setup Automated Deployment

### **Configure GitHub Secrets**
Go to your GitHub repository → **Settings** → **Secrets and variables** → **Actions**

Add these secrets:
```
AWS_ACCESS_KEY_ID: Your AWS access key
AWS_SECRET_ACCESS_KEY: Your AWS secret key  
S3_BUCKET_NAME: Output from terraform (e.g., yourdomain.com)
CLOUDFRONT_DISTRIBUTION_ID: Output from terraform
DOMAIN_NAME: Your domain name
```

### **Test Automated Deployment**
```bash
# Make a small change to test deployment
echo "<!-- Updated $(date) -->" >> README.md

# Commit and push
git add .
git commit -m "Test automated deployment with existing certificate"
git push origin main
```

The GitHub Actions workflow will automatically:
1. Build the website
2. Upload to S3
3. Invalidate CloudFront cache
4. Deploy changes live

## ✅ Step 8: Verify Deployment

### **Test Website Access**
```bash
# Test direct S3 access
curl -I "http://$S3_BUCKET.s3-website-us-east-1.amazonaws.com"

# Test CloudFront (may take time for DNS propagation)
curl -I "https://$DOMAIN_NAME"

# Test SSL certificate
openssl s_client -connect "$DOMAIN_NAME:443" -servername "$DOMAIN_NAME" < /dev/null 2>/dev/null | openssl x509 -text -noout | grep -A 2 "Subject:"
```

### **Browser Verification**
1. Visit `https://yourdomain.com`
2. Check for **green lock icon** (SSL working)
3. Verify all pages load correctly
4. Test mobile responsiveness
5. Test contact form functionality
6. Verify chatbot provides responses

### **Performance Testing**
```bash
# Test page load speed
curl -w "@curl-format.txt" -o /dev/null -s "https://$DOMAIN_NAME"

# Create curl-format.txt for detailed timing
cat > curl-format.txt << 'EOF'
     time_namelookup:  %{time_namelookup}\n
        time_connect:  %{time_connect}\n
     time_appconnect:  %{time_appconnect}\n
    time_pretransfer:  %{time_pretransfer}\n
       time_redirect:  %{time_redirect}\n
  time_starttransfer:  %{time_starttransfer}\n
                     ----------\n
          time_total:  %{time_total}\n
EOF
```

## 💰 Step 9: Monitor Costs

### **Set Up Billing Alerts**
The Terraform configuration automatically creates billing alerts, but you can verify:

```bash
# Check current month costs
aws ce get-cost-and-usage \
    --time-period Start=$(date -d "$(date +%Y-%m-01)" +%Y-%m-%d),End=$(date +%Y-%m-%d) \
    --granularity MONTHLY \
    --metrics BlendedCost \
    --query 'ResultsByTime[0].Total.BlendedCost.Amount' \
    --output text
```

### **Cost Breakdown Verification**
Expected monthly costs:
- **S3 Storage**: $1-2 (website files)
- **CloudFront**: $1-3 (CDN requests)
- **Route 53**: $0.50 (hosted zone)
- **SSL Certificate**: $0 (using existing)
- **Total**: $2-5/month

## 🔧 Troubleshooting

### **Certificate Issues**

#### **"Certificate not found" Error**
```bash
# Verify certificate exists and is accessible
aws acm describe-certificate \
    --certificate-arn "$SSL_CERTIFICATE_ARN" \
    --region us-east-1
```

**Solutions:**
- Ensure certificate is in `us-east-1` region
- Verify ARN format is correct
- Check AWS permissions for ACM access

#### **"Domain not covered" Error**
```bash
# Check certificate domain coverage
aws acm describe-certificate \
    --certificate-arn "$SSL_CERTIFICATE_ARN" \
    --region us-east-1 \
    --query 'Certificate.{DomainName:DomainName,SubjectAlternativeNames:SubjectAlternativeNames}'
```

**Solutions:**
- Use exact domain match
- Use wildcard certificate (`*.yourdomain.com`)
- Add domain to existing certificate
- Use different domain covered by certificate

### **DNS Issues**

#### **Website Not Loading**
```bash
# Check DNS propagation
dig $DOMAIN_NAME
nslookup $DOMAIN_NAME

# Check Route 53 records
aws route53 list-resource-record-sets \
    --hosted-zone-id $(cd terraform/minimal-cost && terraform output -raw route53_zone_id)
```

**Solutions:**
- Wait 24-48 hours for DNS propagation
- Verify nameservers updated at registrar
- Check Route 53 hosted zone configuration

### **Deployment Issues**

#### **S3 Upload Failures**
```bash
# Check S3 bucket policy
aws s3api get-bucket-policy --bucket "$S3_BUCKET"

# Test S3 access
aws s3 ls "s3://$S3_BUCKET"
```

#### **CloudFront Issues**
```bash
# Check CloudFront distribution status
aws cloudfront get-distribution --id "$CLOUDFRONT_DIST_ID"

# Check CloudFront logs
aws logs describe-log-groups --log-group-name-prefix "/aws/cloudfront"
```

## 🔄 Ongoing Management

### **Update Website Content**
```bash
# Method 1: Automated (Recommended)
# Make changes and push to GitHub
git add .
git commit -m "Update content"
git push origin main

# Method 2: Manual
npm run build
aws s3 sync dist/ "s3://$S3_BUCKET" --delete
aws cloudfront create-invalidation --distribution-id "$CLOUDFRONT_DIST_ID" --paths "/*"
```

### **Monitor Performance**
```bash
# Check website speed
curl -w "%{time_total}" -o /dev/null -s "https://$DOMAIN_NAME"

# Monitor S3 usage
aws s3 ls "s3://$S3_BUCKET" --recursive --human-readable --summarize

# Check CloudFront metrics
aws cloudwatch get-metric-statistics \
    --namespace AWS/CloudFront \
    --metric-name Requests \
    --dimensions Name=DistributionId,Value="$CLOUDFRONT_DIST_ID" \
    --start-time $(date -d '1 day ago' -u +%Y-%m-%dT%H:%M:%S) \
    --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
    --period 3600 \
    --statistics Sum
```

### **Certificate Management**
```bash
# Check certificate expiration
aws acm describe-certificate \
    --certificate-arn "$SSL_CERTIFICATE_ARN" \
    --region us-east-1 \
    --query 'Certificate.{Status:Status,NotAfter:NotAfter,DomainName:DomainName}'

# Monitor certificate renewal (ACM auto-renews)
aws acm list-certificates --region us-east-1 \
    --query 'CertificateSummaryList[?Status==`PENDING_VALIDATION`]'
```

## 📈 Scaling Options

### **Add More Features Later**

#### **Add AI Assistant (+$30-35/month)**
```bash
# Switch to full deployment
export DOMAIN_NAME="yourdomain.com"
export SSL_CERTIFICATE_ARN="your-cert-arn"
export INSTANCE_TYPE="t3.small"

./scripts/deploy-aws.sh
```

#### **Add Backend API (+$5-15/month)**
- Use AWS Lambda for serverless functions
- Add API Gateway for REST APIs
- Use DynamoDB for data storage

#### **Add Database (+$10-25/month)**
- RDS for relational databases
- DynamoDB for NoSQL
- ElastiCache for caching

### **Multi-Project Certificate Sharing**
```bash
# Use same certificate for multiple projects
SHARED_CERT="arn:aws:acm:us-east-1:123456789012:certificate/wildcard-cert"

# Deploy multiple sites
DOMAIN_NAME="portfolio.example.com" SSL_CERTIFICATE_ARN="$SHARED_CERT" ./scripts/deploy-minimal-cost.sh
DOMAIN_NAME="blog.example.com" SSL_CERTIFICATE_ARN="$SHARED_CERT" ./scripts/deploy-minimal-cost.sh
DOMAIN_NAME="docs.example.com" SSL_CERTIFICATE_ARN="$SHARED_CERT" ./scripts/deploy-minimal-cost.sh
```

## 🎉 Success Checklist

- [ ] ✅ Certificate ARN identified and verified
- [ ] ✅ Infrastructure deployed via Terraform
- [ ] ✅ DNS configured at domain registrar
- [ ] ✅ Website files uploaded to S3
- [ ] ✅ CloudFront cache invalidated
- [ ] ✅ GitHub Actions deployment configured
- [ ] ✅ Website accessible at https://yourdomain.com
- [ ] ✅ SSL certificate working (green lock)
- [ ] ✅ All pages load correctly
- [ ] ✅ Mobile responsive design works
- [ ] ✅ Contact form functional
- [ ] ✅ Chatbot provides responses
- [ ] ✅ Billing alerts configured
- [ ] ✅ Monthly cost under $5

## 💡 Pro Tips

### **Certificate Best Practices**
- **Use wildcard certificates** for multiple subdomains
- **Monitor expiration dates** (ACM auto-renews)
- **Keep certificates in us-east-1** for CloudFront
- **Document certificate usage** across projects

### **Cost Optimization**
- **Use S3 Intelligent Tiering** for automatic cost optimization
- **Set CloudFront cache headers** appropriately
- **Monitor billing daily** for the first month
- **Use AWS Cost Explorer** for detailed analysis

### **Performance Optimization**
- **Compress images** before uploading
- **Use WebP format** for better compression
- **Set proper cache headers** for static assets
- **Monitor Core Web Vitals** with Google PageSpeed Insights

## 🆘 Getting Help

### **Common Commands Reference**
```bash
# Check deployment status
cd terraform/minimal-cost && terraform show

# View all outputs
cd terraform/minimal-cost && terraform output

# Check certificate details
aws acm describe-certificate --certificate-arn "$SSL_CERTIFICATE_ARN" --region us-east-1

# Test website
curl -I "https://$DOMAIN_NAME"

# Check costs
aws ce get-cost-and-usage --time-period Start=$(date -d "$(date +%Y-%m-01)" +%Y-%m-%d),End=$(date +%Y-%m-%d) --granularity MONTHLY --metrics BlendedCost
```

### **Support Resources**
- **AWS Documentation**: [ACM User Guide](https://docs.aws.amazon.com/acm/)
- **Terraform Documentation**: [AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- **GitHub Issues**: Report problems in the repository
- **AWS Support**: For AWS-specific issues

## 🔄 Cleanup (If Needed)

To remove all resources and stop billing:

```bash
cd terraform/minimal-cost
terraform destroy -var-file="terraform.tfvars"
```

**⚠️ Warning: This will permanently delete your website and all data!**

The SSL certificate will remain untouched and can be reused for other projects.

---

## 🎯 Final Result

**🎉 Congratulations!** You now have:

- ✅ **Professional portfolio website** running on AWS
- ✅ **SSL certificate** from your existing ACM certificate
- ✅ **Global CDN** with CloudFront for fast loading
- ✅ **Custom domain** with proper DNS configuration
- ✅ **Automated deployments** via GitHub Actions
- ✅ **Cost monitoring** with billing alerts
- ✅ **Monthly cost of $2-5** (vs $35-45 with AI)
- ✅ **Scalable architecture** ready for future enhancements

**💰 Total Savings: $30-40/month** while maintaining professional quality and performance!

Your portfolio is now live at `https://yourdomain.com` with enterprise-grade security and performance, all while maximizing cost efficiency by reusing your existing SSL certificate.