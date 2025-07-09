# AWS Deployment Guide for Portfolio with AI Assistant

## 🚀 Overview

This guide covers deploying your portfolio website with AI assistant to AWS, connecting your GoDaddy domain, and setting up the AI model infrastructure.

## 📋 Architecture Overview

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   CloudFront    │────│   S3 Bucket      │    │   EC2 Instance  │
│   (CDN)         │    │   (Static Site)  │    │   (AI Model)    │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                        │                       │
         │                        │                       │
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Route 53      │    │   GitHub Actions │    │   Application   │
│   (DNS)         │    │   (CI/CD)        │    │   Load Balancer │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## 💰 Cost Estimation (Monthly)

### **Minimal Setup (Recommended for Start)**
- **S3 Static Hosting**: $1-3/month
- **CloudFront CDN**: $1-5/month
- **Route 53 DNS**: $0.50/month
- **EC2 t3.small (AI Model)**: $15-20/month
- **Application Load Balancer**: $16/month
- **Total**: **~$35-45/month**

### **Production Setup**
- **S3 + CloudFront**: $5-10/month
- **Route 53**: $0.50/month
- **EC2 t3.medium (AI Model)**: $30-35/month
- **RDS (Database)**: $15-25/month
- **Application Load Balancer**: $16/month
- **Total**: **~$65-85/month**

## 🛠️ Required AWS Resources

### **Core Infrastructure**
1. **S3 Bucket** - Static website hosting
2. **CloudFront Distribution** - CDN for global performance
3. **Route 53 Hosted Zone** - DNS management
4. **EC2 Instance** - AI model hosting
5. **Application Load Balancer** - Traffic distribution
6. **Security Groups** - Network security
7. **IAM Roles** - Access management

### **Optional Enhancements**
1. **RDS Instance** - Database for chat logs
2. **ElastiCache** - Caching layer
3. **Lambda Functions** - Serverless functions
4. **CloudWatch** - Monitoring and logging
5. **WAF** - Web Application Firewall

## 📁 Project Structure for AWS

```
aws-infrastructure/
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── modules/
├── scripts/
│   ├── deploy.sh
│   ├── setup-domain.sh
│   └── configure-ssl.sh
├── cloudformation/
│   └── infrastructure.yaml
└── docker/
    ├── Dockerfile
    └── docker-compose.yml
```

## 🚀 Deployment Steps

### **Step 1: Prepare AWS Account**

```bash
# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Configure AWS credentials
aws configure
# Enter your AWS Access Key ID
# Enter your AWS Secret Access Key
# Enter your default region (e.g., us-east-1)
# Enter output format (json)
```

### **Step 2: Domain Configuration (GoDaddy)**

1. **Get AWS Name Servers**:
   ```bash
   # Create hosted zone in Route 53
   aws route53 create-hosted-zone \
     --name yourdomain.com \
     --caller-reference $(date +%s)
   ```

2. **Update GoDaddy DNS**:
   - Login to GoDaddy
   - Go to DNS Management
   - Replace default nameservers with AWS Route 53 nameservers
   - Wait 24-48 hours for propagation

### **Step 3: Infrastructure Setup with Terraform**

Create Terraform configuration:

```hcl
# terraform/main.tf
terraform {
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

# S3 Bucket for static website
resource "aws_s3_bucket" "website" {
  bucket = var.domain_name
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

resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# CloudFront Distribution
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
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.website.arn
    ssl_support_method  = "sni-only"
  }
}

# EC2 Instance for AI Model
resource "aws_instance" "ai_model" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2
  instance_type = var.instance_type
  key_name      = var.key_pair_name

  vpc_security_group_ids = [aws_security_group.ai_model.id]

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    domain_name = var.domain_name
  }))

  tags = {
    Name = "AI-Model-Server"
  }
}

# Security Group for AI Model
resource "aws_security_group" "ai_model" {
  name_prefix = "ai-model-"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8001
    to_port     = 8001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
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

# SSL Certificate
resource "aws_acm_certificate" "website" {
  domain_name               = var.domain_name
  subject_alternative_names = ["www.${var.domain_name}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}
```

### **Step 4: Deploy Infrastructure**

```bash
# Initialize Terraform
cd terraform
terraform init

# Plan deployment
terraform plan -var="domain_name=yourdomain.com" \
               -var="aws_region=us-east-1" \
               -var="instance_type=t3.small"

# Apply infrastructure
terraform apply -var="domain_name=yourdomain.com" \
                -var="aws_region=us-east-1" \
                -var="instance_type=t3.small"
```

### **Step 5: Setup CI/CD with GitHub Actions**

```yaml
# .github/workflows/deploy-aws.yml
name: Deploy to AWS

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '18'
        cache: 'npm'
        
    - name: Install dependencies
      run: npm ci
      
    - name: Build project
      run: npm run build
      
    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v4
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-east-1
        
    - name: Deploy to S3
      run: |
        aws s3 sync dist/ s3://${{ secrets.S3_BUCKET_NAME }} --delete
        
    - name: Invalidate CloudFront
      run: |
        aws cloudfront create-invalidation \
          --distribution-id ${{ secrets.CLOUDFRONT_DISTRIBUTION_ID }} \
          --paths "/*"
          
    - name: Deploy AI Model
      run: |
        # Copy AI model files to EC2
        scp -i ${{ secrets.EC2_KEY }} -r ai-infrastructure/ ec2-user@${{ secrets.EC2_IP }}:/home/ec2-user/
        
        # Restart AI services
        ssh -i ${{ secrets.EC2_KEY }} ec2-user@${{ secrets.EC2_IP }} << 'EOF'
          cd /home/ec2-user/ai-infrastructure
          sudo systemctl restart ai-model
          sudo systemctl restart nginx
        EOF
```

### **Step 6: AI Model Setup on EC2**

```bash
# user_data.sh for EC2 instance
#!/bin/bash
yum update -y
yum install -y python3 python3-pip git nginx

# Install Python dependencies
pip3 install torch transformers mlflow fastapi uvicorn

# Clone your repository
cd /home/ec2-user
git clone https://github.com/infrapulses/portfolio-website.git

# Setup AI model service
cd portfolio-website/ai-infrastructure

# Install dependencies
pip3 install -r requirements-ai.txt

# Create systemd service
cat > /etc/systemd/system/ai-model.service << EOF
[Unit]
Description=AI Model API
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/home/ec2-user/portfolio-website/ai-infrastructure
ExecStart=/usr/bin/python3 models/serving/experience_api.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Start services
systemctl enable ai-model
systemctl start ai-model

# Configure Nginx
cat > /etc/nginx/conf.d/ai-model.conf << EOF
server {
    listen 80;
    server_name api.${domain_name};
    
    location / {
        proxy_pass http://localhost:8001;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

systemctl enable nginx
systemctl start nginx
```

## 🔧 Configuration Steps

### **1. Update ChatBot Configuration**

```typescript
// Update src/components/ChatBot.tsx
const checkAiModelAvailability = async () => {
  try {
    // Use your AWS domain instead of localhost
    const response = await fetch('https://api.yourdomain.com/health');
    if (response.ok) {
      setAiModelAvailable(true);
    }
  } catch (error) {
    setAiModelAvailable(false);
  }
};

const getAiPrediction = async (text: string): Promise<any> => {
  try {
    // Use your AWS domain
    const response = await fetch('https://api.yourdomain.com/predict', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer your-secret-token'
      },
      body: JSON.stringify({
        text: text,
        return_probabilities: true
      })
    });

    if (response.ok) {
      return await response.json();
    }
  } catch (error) {
    console.error('AI prediction failed:', error);
  }
  return null;
};
```

### **2. Environment Variables**

```bash
# Add to GitHub Secrets
AWS_ACCESS_KEY_ID=your_access_key
AWS_SECRET_ACCESS_KEY=your_secret_key
S3_BUCKET_NAME=yourdomain.com
CLOUDFRONT_DISTRIBUTION_ID=your_distribution_id
EC2_IP=your_ec2_ip
EC2_KEY=your_private_key
```

## 📊 Monitoring and Maintenance

### **CloudWatch Monitoring**

```bash
# Create CloudWatch alarms
aws cloudwatch put-metric-alarm \
  --alarm-name "High-CPU-Usage" \
  --alarm-description "Alarm when CPU exceeds 80%" \
  --metric-name CPUUtilization \
  --namespace AWS/EC2 \
  --statistic Average \
  --period 300 \
  --threshold 80 \
  --comparison-operator GreaterThanThreshold \
  --dimensions Name=InstanceId,Value=i-1234567890abcdef0 \
  --evaluation-periods 2
```

### **Backup Strategy**

```bash
# Automated S3 backup
aws s3 sync s3://yourdomain.com s3://yourdomain.com-backup --delete

# EC2 snapshot
aws ec2 create-snapshot \
  --volume-id vol-1234567890abcdef0 \
  --description "Daily backup"
```

## 🔒 Security Best Practices

### **1. IAM Policies**
- Use least privilege access
- Create specific roles for each service
- Enable MFA for root account

### **2. Security Groups**
- Restrict SSH access to your IP
- Use HTTPS only for web traffic
- Limit AI API access

### **3. SSL/TLS**
- Use AWS Certificate Manager
- Enable HSTS headers
- Configure secure ciphers

## 🚀 Deployment Commands

```bash
# Quick deployment script
#!/bin/bash

# Build and deploy frontend
npm run build
aws s3 sync dist/ s3://yourdomain.com --delete
aws cloudfront create-invalidation --distribution-id YOUR_DIST_ID --paths "/*"

# Deploy AI model
scp -r ai-infrastructure/ ec2-user@your-ec2-ip:/home/ec2-user/
ssh ec2-user@your-ec2-ip "sudo systemctl restart ai-model"

echo "Deployment completed!"
```

## 📈 Scaling Considerations

### **Auto Scaling (Future)**
- Application Load Balancer
- Auto Scaling Groups
- Multiple AZ deployment
- RDS Multi-AZ

### **Performance Optimization**
- CloudFront caching
- S3 Transfer Acceleration
- EC2 instance optimization
- Database query optimization

## 💡 Cost Optimization Tips

1. **Use Reserved Instances** for predictable workloads
2. **Enable S3 Intelligent Tiering** for storage optimization
3. **Set up CloudWatch billing alarms**
4. **Use Spot Instances** for development environments
5. **Implement auto-scaling** to handle traffic spikes

## 🆘 Troubleshooting

### **Common Issues**
1. **DNS Propagation**: Wait 24-48 hours after changing nameservers
2. **SSL Certificate**: Ensure DNS validation records are correct
3. **CORS Issues**: Configure proper CORS headers for API
4. **AI Model Not Loading**: Check EC2 security groups and service status

### **Useful Commands**
```bash
# Check EC2 status
aws ec2 describe-instances --instance-ids i-1234567890abcdef0

# Check CloudFront distribution
aws cloudfront get-distribution --id YOUR_DIST_ID

# Check Route 53 records
aws route53 list-resource-record-sets --hosted-zone-id YOUR_ZONE_ID
```

This deployment will give you a production-ready portfolio with AI assistant hosted on AWS, connected to your GoDaddy domain, with proper SSL, CDN, and monitoring capabilities.