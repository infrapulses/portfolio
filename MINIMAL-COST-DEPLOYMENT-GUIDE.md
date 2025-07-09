# 💰 Minimal Cost Portfolio Deployment Guide

**Estimated Monthly Cost: $2-5** (vs $35-45 with full AI setup)

This guide will help you deploy a professional portfolio website to AWS with minimal costs by removing the AI assistant and using only static hosting.

## 📊 Cost Breakdown

| Service | Monthly Cost | Purpose |
|---------|-------------|---------|
| S3 Static Hosting | $1-2 | Website files storage |
| CloudFront CDN | $1-3 | Global content delivery |
| Route 53 DNS | $0.50 | Domain management |
| SSL Certificate | Free | HTTPS encryption |
| **Total** | **$2-5** | **Professional website** |

**Savings: $30-40/month** compared to full AI setup

## 🚀 Step-by-Step Deployment

### Prerequisites

Before starting, ensure you have:
- [ ] AWS account with billing set up
- [ ] Domain name (from GoDaddy or any registrar)
- [ ] GitHub account
- [ ] Basic command line knowledge

### Step 1: Prepare Your Local Environment

1. **Install Required Tools**
   ```bash
   # Install AWS CLI
   curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
   unzip awscliv2.zip
   sudo ./aws/install
   
   # Install Terraform
   wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
   unzip terraform_1.6.0_linux_amd64.zip
   sudo mv terraform /usr/local/bin/
   
   # Verify installations
   aws --version
   terraform --version
   node --version
   npm --version
   ```

2. **Configure AWS Credentials**
   ```bash
   aws configure
   # Enter your AWS Access Key ID
   # Enter your AWS Secret Access Key
   # Enter your default region (e.g., us-east-1)
   # Enter output format (json)
   ```

3. **Clone and Prepare Project**
   ```bash
   git clone https://github.com/Kamal-Raj123/portfolio-website.git
   cd portfolio-website
   npm install
   ```

### Step 2: Update Configuration for Static-Only

1. **Disable AI Features**
   
   The chatbot will automatically use rule-based responses instead of AI when deployed in minimal cost mode.

2. **Build the Application**
   ```bash
   npm run build
   ```

3. **Test Locally**
   ```bash
   npm run preview
   ```
   Visit `http://localhost:4173` to verify everything works.

### Step 3: Deploy Infrastructure with Terraform

1. **Navigate to Minimal Cost Configuration**
   ```bash
   cd terraform/minimal-cost
   ```

2. **Initialize Terraform**
   ```bash
   terraform init
   ```

3. **Create Variables File**
   ```bash
   # Create terraform.tfvars
   cat > terraform.tfvars << EOF
   domain_name = "yourdomain.com"
   aws_region = "us-east-1"
   alert_email = "your-email@example.com"
   environment = "production"
   EOF
   ```

4. **Plan Deployment**
   ```bash
   terraform plan -var-file="terraform.tfvars"
   ```
   Review the planned resources and estimated costs.

5. **Deploy Infrastructure**
   ```bash
   terraform apply -var-file="terraform.tfvars"
   ```
   Type `yes` when prompted.

6. **Save Important Outputs**
   ```bash
   # Save outputs for later use
   terraform output > ../deployment-outputs.txt
   
   # Get nameservers for DNS configuration
   terraform output route53_name_servers
   ```

### Step 4: Configure Domain DNS

1. **Get Route 53 Nameservers**
   ```bash
   terraform output route53_name_servers
   ```

2. **Update GoDaddy DNS Settings**
   - Login to your GoDaddy account
   - Go to DNS Management for your domain
   - Replace the default nameservers with the Route 53 nameservers
   - Save changes

   **⏰ DNS propagation takes 24-48 hours**

### Step 5: Deploy Website Files

1. **Get S3 Bucket Name**
   ```bash
   S3_BUCKET=$(terraform output -raw s3_bucket_name)
   echo "S3 Bucket: $S3_BUCKET"
   ```

2. **Upload Website Files**
   ```bash
   cd ../../  # Back to project root
   
   # Upload with optimized caching
   aws s3 sync dist/ "s3://$S3_BUCKET" \
       --delete \
       --cache-control "public, max-age=31536000" \
       --exclude "*.html" \
       --exclude "service-worker.js"
   
   # Upload HTML files with shorter cache
   aws s3 sync dist/ "s3://$S3_BUCKET" \
       --cache-control "public, max-age=0, must-revalidate" \
       --include "*.html" \
       --include "service-worker.js"
   ```

3. **Invalidate CloudFront Cache**
   ```bash
   CLOUDFRONT_DIST_ID=$(cd terraform/minimal-cost && terraform output -raw cloudfront_distribution_id)
   
   aws cloudfront create-invalidation \
       --distribution-id "$CLOUDFRONT_DIST_ID" \
       --paths "/*"
   ```

### Step 6: Set Up Automated Deployment

1. **Configure GitHub Secrets**
   
   Go to your GitHub repository → Settings → Secrets and variables → Actions
   
   Add these secrets:
   - `AWS_ACCESS_KEY_ID`: Your AWS access key
   - `AWS_SECRET_ACCESS_KEY`: Your AWS secret key
   - `S3_BUCKET_NAME`: From terraform output
   - `CLOUDFRONT_DISTRIBUTION_ID`: From terraform output
   - `DOMAIN_NAME`: Your domain name

2. **Update GitHub Actions Workflow**
   
   The repository already includes `.github/workflows/deploy-minimal-cost.yml` for automated deployments.

3. **Test Automated Deployment**
   ```bash
   # Make a small change and push
   echo "<!-- Updated $(date) -->" >> src/components/Footer.tsx
   git add .
   git commit -m "Test automated deployment"
   git push origin main
   ```

### Step 7: Verify Deployment

1. **Check Website Status**
   ```bash
   # Test direct S3 access
   curl -I "http://$S3_BUCKET.s3-website-us-east-1.amazonaws.com"
   
   # Test CloudFront (may take time for DNS)
   curl -I "https://yourdomain.com"
   ```

2. **Monitor Costs**
   - Go to AWS Billing Dashboard
   - Set up billing alerts (already configured via Terraform)
   - Monitor daily costs

3. **Test Website Features**
   - [ ] Website loads correctly
   - [ ] All pages are accessible
   - [ ] Contact form works
   - [ ] Chatbot provides rule-based responses
   - [ ] Mobile responsiveness
   - [ ] SSL certificate is active

### Step 8: Ongoing Management

1. **Update Content**
   ```bash
   # Make changes to your code
   npm run build
   
   # Deploy manually
   aws s3 sync dist/ "s3://$S3_BUCKET" --delete
   aws cloudfront create-invalidation --distribution-id "$CLOUDFRONT_DIST_ID" --paths "/*"
   
   # Or push to GitHub for automated deployment
   git add .
   git commit -m "Update content"
   git push origin main
   ```

2. **Monitor Performance**
   - Use AWS CloudWatch for basic metrics
   - Monitor website speed with Google PageSpeed Insights
   - Check uptime with external monitoring tools

3. **Cost Optimization**
   ```bash
   # Check current month costs
   aws ce get-cost-and-usage \
       --time-period Start=$(date -d "$(date +%Y-%m-01)" +%Y-%m-%d),End=$(date +%Y-%m-%d) \
       --granularity MONTHLY \
       --metrics BlendedCost
   ```

## 🔧 Troubleshooting

### Common Issues

1. **Website Not Loading**
   ```bash
   # Check S3 bucket policy
   aws s3api get-bucket-policy --bucket "$S3_BUCKET"
   
   # Check CloudFront distribution status
   aws cloudfront get-distribution --id "$CLOUDFRONT_DIST_ID"
   ```

2. **SSL Certificate Issues**
   ```bash
   # Check certificate status
   aws acm list-certificates --region us-east-1
   ```

3. **DNS Not Resolving**
   ```bash
   # Check DNS propagation
   dig yourdomain.com
   nslookup yourdomain.com
   ```

4. **High Costs**
   ```bash
   # Check detailed billing
   aws ce get-cost-and-usage \
       --time-period Start=2024-01-01,End=2024-01-31 \
       --granularity DAILY \
       --metrics BlendedCost \
       --group-by Type=DIMENSION,Key=SERVICE
   ```

### Useful Commands

```bash
# Check all AWS resources
aws resourcegroupstaggingapi get-resources --tag-filters Key=Environment,Values=production

# Monitor CloudFront requests
aws logs describe-log-groups --log-group-name-prefix "/aws/cloudfront"

# Check S3 bucket size
aws s3 ls s3://$S3_BUCKET --recursive --human-readable --summarize

# Test website speed
curl -w "@curl-format.txt" -o /dev/null -s "https://yourdomain.com"
```

## 📈 Scaling Options

### When You Need More Features

1. **Add AI Assistant Later**
   - Use the full terraform configuration
   - Deploy EC2 instance with AI model
   - Update chatbot configuration
   - **Cost increase: +$30-35/month**

2. **Add Backend API**
   - Use AWS Lambda for serverless functions
   - Add API Gateway
   - **Cost increase: +$5-15/month**

3. **Add Database**
   - Use DynamoDB for NoSQL
   - Or RDS for relational database
   - **Cost increase: +$10-25/month**

## 💡 Cost Optimization Tips

1. **S3 Optimization**
   ```bash
   # Enable intelligent tiering
   aws s3api put-bucket-intelligent-tiering-configuration \
       --bucket "$S3_BUCKET" \
       --id "EntireBucket" \
       --intelligent-tiering-configuration Id="EntireBucket",Status="Enabled",Filter={}
   ```

2. **CloudFront Optimization**
   - Use PriceClass_100 (US, Canada, Europe only)
   - Set appropriate cache headers
   - Compress content

3. **Monitoring**
   - Set billing alerts for $5, $10, $15
   - Use AWS Cost Explorer
   - Review monthly bills

## 🎉 Success Checklist

- [ ] Website accessible at https://yourdomain.com
- [ ] SSL certificate working (green lock icon)
- [ ] All pages load correctly
- [ ] Mobile responsive design works
- [ ] Contact form functional
- [ ] Chatbot provides responses
- [ ] GitHub Actions deployment working
- [ ] Billing alerts configured
- [ ] DNS propagated (may take 24-48 hours)
- [ ] Monthly cost under $5

## 📞 Support

If you encounter issues:

1. **Check AWS CloudWatch logs**
2. **Review Terraform state**: `terraform show`
3. **Verify DNS propagation**: Use online DNS checkers
4. **Monitor costs**: AWS Billing Dashboard
5. **GitHub Actions logs**: Check deployment status

## 🔄 Cleanup (If Needed)

To remove all resources and stop billing:

```bash
cd terraform/minimal-cost
terraform destroy -var-file="terraform.tfvars"
```

**⚠️ This will permanently delete your website and all data!**

---

**🎯 Result: Professional portfolio website for $2-5/month with room to scale when needed!**