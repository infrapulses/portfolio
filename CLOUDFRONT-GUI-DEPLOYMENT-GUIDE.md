# 🌐 CloudFront GUI Deployment Guide

**Deploy your portfolio website using AWS Console (No Terraform Required)**

**Estimated Time: 45-60 minutes** | **Monthly Cost: $2-5** | **Difficulty: Beginner**

This guide walks you through deploying your portfolio website using the AWS Console GUI, perfect for those who prefer visual interfaces over command-line tools.

## 📋 Prerequisites

Before starting, ensure you have:
- [ ] AWS account with billing configured
- [ ] Domain name registered (GoDaddy, Route 53, etc.)
- [ ] Built portfolio website files (run `npm run build`)
- [ ] Basic understanding of AWS services

## 🎯 Architecture Overview

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   CloudFront    │────│   S3 Bucket      │    │   Route 53      │
│   (Global CDN)  │    │   (Static Files) │    │   (DNS)         │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                        │                       │
         │                        │                       │
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   SSL Cert      │    │   Your Domain    │    │   GoDaddy DNS   │
│   (Free HTTPS)  │    │   (yourdomain.com)│    │   (Nameservers) │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## 🚀 Step-by-Step Deployment

### Step 1: Build Your Website

1. **Open Terminal/Command Prompt**
   ```bash
   cd portfolio-website
   npm install
   npm run build
   ```

2. **Verify Build**
   - Check that `dist/` folder is created
   - Contains `index.html` and other assets

### Step 2: Create S3 Bucket

1. **Go to S3 Console**
   - Open [AWS S3 Console](https://s3.console.aws.amazon.com/)
   - Click **"Create bucket"**

2. **Configure Bucket**
   ```
   Bucket name: yourdomain.com (use your actual domain)
   AWS Region: US East (N. Virginia) us-east-1
   
   ✅ Uncheck "Block all public access"
   ✅ Check "I acknowledge that the current settings..."
   
   Click "Create bucket"
   ```

3. **Enable Static Website Hosting**
   - Click on your bucket name
   - Go to **Properties** tab
   - Scroll to **Static website hosting**
   - Click **Edit**
   ```
   Static website hosting: Enable
   Index document: index.html
   Error document: index.html
   ```
   - Click **Save changes**

4. **Set Bucket Policy**
   - Go to **Permissions** tab
   - Scroll to **Bucket policy**
   - Click **Edit**
   - Paste this policy (replace `yourdomain.com` with your bucket name):
   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Sid": "PublicReadGetObject",
         "Effect": "Allow",
         "Principal": "*",
         "Action": "s3:GetObject",
         "Resource": "arn:aws:s3:::yourdomain.com/*"
       }
     ]
   }
   ```
   - Click **Save changes**

### Step 3: Upload Website Files

1. **Upload Files**
   - Go to **Objects** tab in your S3 bucket
   - Click **Upload**
   - Click **Add files** or **Add folder**
   - Select all files from your `dist/` folder
   - Click **Upload**

2. **Verify Upload**
   - Check that all files are uploaded
   - Note the S3 website endpoint (from Properties > Static website hosting)

### Step 4: Request SSL Certificate

1. **Go to Certificate Manager**
   - Open [AWS Certificate Manager](https://console.aws.amazon.com/acm/)
   - **Important**: Make sure you're in **US East (N. Virginia)** region
   - Click **Request a certificate**

2. **Configure Certificate**
   ```
   Certificate type: Request a public certificate
   
   Domain names:
   - yourdomain.com
   - www.yourdomain.com
   
   Validation method: DNS validation
   Key algorithm: RSA 2048
   ```
   - Click **Request**

3. **Note Certificate ARN**
   - Copy the Certificate ARN (starts with `arn:aws:acm:us-east-1:...`)
   - You'll need this for CloudFront

### Step 5: Create Route 53 Hosted Zone

1. **Go to Route 53 Console**
   - Open [Route 53 Console](https://console.aws.amazon.com/route53/)
   - Click **Hosted zones**
   - Click **Create hosted zone**

2. **Configure Hosted Zone**
   ```
   Domain name: yourdomain.com
   Type: Public hosted zone
   ```
   - Click **Create hosted zone**

3. **Note Nameservers**
   - Click on your hosted zone
   - Copy the 4 nameservers (NS records)
   - You'll update these in GoDaddy later

### Step 6: Validate SSL Certificate

1. **Go Back to Certificate Manager**
   - Click on your certificate
   - You'll see domain validation records

2. **Create DNS Records**
   - For each domain (yourdomain.com and www.yourdomain.com):
   - Go to Route 53 > Your hosted zone
   - Click **Create record**
   ```
   Record type: CNAME
   Record name: [Copy from certificate validation]
   Value: [Copy from certificate validation]
   TTL: 300
   ```
   - Click **Create records**

3. **Wait for Validation**
   - Certificate status will change to "Issued" (5-30 minutes)
   - Refresh the Certificate Manager page

### Step 7: Create CloudFront Distribution

1. **Go to CloudFront Console**
   - Open [CloudFront Console](https://console.aws.amazon.com/cloudfront/)
   - Click **Create distribution**

2. **Configure Origin**
   ```
   Origin domain: [Select your S3 bucket from dropdown]
   Origin path: [Leave empty]
   Name: S3-yourdomain.com
   
   Origin access: Origin access control settings (recommended)
   Origin access control: Create control setting
   ```
   - Click **Create control setting**
   ```
   Name: yourdomain.com-OAC
   Signing behavior: Sign requests
   Origin type: S3
   ```
   - Click **Create**

3. **Configure Default Cache Behavior**
   ```
   Path pattern: Default (*)
   Compress objects automatically: Yes
   Viewer protocol policy: Redirect HTTP to HTTPS
   Allowed HTTP methods: GET, HEAD, OPTIONS, PUT, POST, PATCH, DELETE
   Cache key and origin requests: Cache policy and origin request policy
   Cache policy: Managed-CachingOptimized
   Origin request policy: None
   ```

4. **Configure Distribution Settings**
   ```
   Price class: Use only North America and Europe
   Alternate domain names (CNAMEs): 
   - yourdomain.com
   - www.yourdomain.com
   
   Custom SSL certificate: [Select your certificate]
   Security policy: TLSv1.2_2021
   
   Default root object: index.html
   ```

5. **Configure Custom Error Pages**
   - Scroll to **Custom error pages**
   - Click **Create custom error response**
   ```
   HTTP error code: 403
   Customize error response: Yes
   Response page path: /index.html
   HTTP response code: 200
   ```
   - Click **Create custom error response**
   - Repeat for error code 404

6. **Create Distribution**
   - Click **Create distribution**
   - Note the Distribution ID and Domain name

### Step 8: Update S3 Bucket Policy

1. **Copy Policy from CloudFront**
   - In CloudFront, click on your distribution
   - Go to **Origins** tab
   - Click on your origin
   - Copy the bucket policy shown

2. **Update S3 Bucket Policy**
   - Go back to S3 > Your bucket > Permissions > Bucket policy
   - Replace the existing policy with the CloudFront policy
   - Click **Save changes**

### Step 9: Create DNS Records

1. **Go to Route 53**
   - Click on your hosted zone
   - Click **Create record**

2. **Create Main Domain Record**
   ```
   Record name: [Leave empty for root domain]
   Record type: A
   Alias: Yes
   Route traffic to: Alias to CloudFront distribution
   Choose distribution: [Select your distribution]
   ```
   - Click **Create records**

3. **Create WWW Record**
   ```
   Record name: www
   Record type: A
   Alias: Yes
   Route traffic to: Alias to CloudFront distribution
   Choose distribution: [Select your distribution]
   ```
   - Click **Create records**

### Step 10: Update GoDaddy DNS

1. **Login to GoDaddy**
   - Go to [GoDaddy DNS Management](https://dcc.godaddy.com/manage/dns)
   - Select your domain

2. **Update Nameservers**
   - Go to **Nameservers** section
   - Choose **Custom nameservers**
   - Enter the 4 Route 53 nameservers
   - Save changes

3. **Wait for Propagation**
   - DNS changes take 24-48 hours to fully propagate

## ✅ Step 11: Verify Deployment

### **Test Website Access**
1. **Direct CloudFront URL**
   ```
   https://d1234567890123.cloudfront.net
   ```

2. **Custom Domain (after DNS propagation)**
   ```
   https://yourdomain.com
   https://www.yourdomain.com
   ```

### **Check SSL Certificate**
- Look for green lock icon in browser
- Certificate should show your domain name

### **Test Website Features**
- [ ] All pages load correctly
- [ ] Images and assets load
- [ ] Contact form works
- [ ] Chatbot responds
- [ ] Mobile responsive design

## 🔧 Troubleshooting

### **Common Issues**

#### **1. Website Not Loading**
```bash
# Check DNS propagation
nslookup yourdomain.com
dig yourdomain.com

# Test CloudFront directly
curl -I https://d1234567890123.cloudfront.net
```

**Solutions:**
- Wait for DNS propagation (24-48 hours)
- Check Route 53 records are correct
- Verify CloudFront distribution is deployed

#### **2. SSL Certificate Issues**
**Symptoms:** Browser shows "Not Secure" or certificate errors

**Solutions:**
- Ensure certificate is in us-east-1 region
- Check certificate covers your domain
- Verify DNS validation records in Route 53

#### **3. 403 Forbidden Errors**
**Symptoms:** Getting 403 errors when accessing website

**Solutions:**
- Check S3 bucket policy allows CloudFront access
- Verify Origin Access Control is configured
- Ensure index.html exists in S3 bucket

#### **4. Files Not Updating**
**Symptoms:** Changes not visible on website

**Solutions:**
- Clear CloudFront cache (create invalidation)
- Check files uploaded to S3 correctly
- Verify cache headers

### **Useful Commands**

```bash
# Check website status
curl -I https://yourdomain.com

# Test SSL certificate
openssl s_client -connect yourdomain.com:443 -servername yourdomain.com

# Check DNS records
dig yourdomain.com
nslookup yourdomain.com 8.8.8.8
```

## 🔄 Updating Your Website

### **Method 1: AWS Console**
1. Go to S3 > Your bucket
2. Select files to update
3. Click **Upload** and replace files
4. Go to CloudFront > Your distribution
5. Click **Invalidations** tab
6. Click **Create invalidation**
7. Enter `/*` to clear all cache
8. Click **Create invalidation**

### **Method 2: AWS CLI (Optional)**
```bash
# Upload files
aws s3 sync dist/ s3://yourdomain.com --delete

# Clear CloudFront cache
aws cloudfront create-invalidation --distribution-id YOUR_DIST_ID --paths "/*"
```

## 💰 Cost Monitoring

### **Set Up Billing Alerts**
1. **Go to CloudWatch**
   - Open [CloudWatch Console](https://console.aws.amazon.com/cloudwatch/)
   - Click **Alarms** > **Billing**

2. **Create Billing Alarm**
   ```
   Metric: EstimatedCharges
   Statistic: Maximum
   Period: 1 day
   Threshold: $10 (or your preferred amount)
   ```

3. **Set Up SNS Notification**
   - Create SNS topic
   - Add your email subscription
   - Link to billing alarm

### **Expected Monthly Costs**
- **S3 Storage**: $1-2
- **CloudFront**: $1-3
- **Route 53**: $0.50
- **SSL Certificate**: Free
- **Total**: $2-5/month

## 📈 Performance Optimization

### **CloudFront Cache Settings**
1. **Go to CloudFront > Behaviors**
2. **Create behavior for static assets**
   ```
   Path pattern: /assets/*
   Cache policy: Managed-CachingOptimized
   TTL: 1 year
   ```

### **S3 Optimization**
1. **Enable Transfer Acceleration**
   - S3 > Bucket > Properties
   - Transfer acceleration: Enable

2. **Set Cache Headers**
   - Upload files with cache-control headers
   - Static assets: `max-age=31536000`
   - HTML files: `max-age=0`

## 🔒 Security Best Practices

### **S3 Security**
- Block public access except through CloudFront
- Use Origin Access Control (OAC)
- Enable versioning for backup

### **CloudFront Security**
- Use HTTPS only
- Enable security headers
- Consider AWS WAF for additional protection

### **DNS Security**
- Use DNSSEC (optional)
- Monitor DNS changes
- Use Route 53 health checks

## 🎉 Success Checklist

- [ ] ✅ S3 bucket created and configured
- [ ] ✅ Website files uploaded to S3
- [ ] ✅ SSL certificate issued and validated
- [ ] ✅ CloudFront distribution created
- [ ] ✅ Route 53 hosted zone configured
- [ ] ✅ DNS records created
- [ ] ✅ GoDaddy nameservers updated
- [ ] ✅ Website accessible at https://yourdomain.com
- [ ] ✅ SSL certificate working (green lock)
- [ ] ✅ All pages load correctly
- [ ] ✅ Mobile responsive design works
- [ ] ✅ Billing alerts configured
- [ ] ✅ Performance optimized

## 📞 Support Resources

### **AWS Documentation**
- [S3 Static Website Hosting](https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteHosting.html)
- [CloudFront User Guide](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/)
- [Route 53 Developer Guide](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/)

### **Useful Tools**
- [DNS Checker](https://dnschecker.org/) - Check DNS propagation
- [SSL Labs](https://www.ssllabs.com/ssltest/) - Test SSL configuration
- [GTmetrix](https://gtmetrix.com/) - Performance testing

### **Getting Help**
- AWS Support (if you have a support plan)
- AWS Forums and documentation
- Stack Overflow for technical questions

---

## 🎯 Final Result

**🎉 Congratulations!** You now have:

- ✅ **Professional portfolio website** hosted on AWS
- ✅ **Global CDN** with CloudFront for fast loading worldwide
- ✅ **Free SSL certificate** with automatic renewal
- ✅ **Custom domain** with proper DNS configuration
- ✅ **Cost-optimized setup** for $2-5/month
- ✅ **Production-ready infrastructure** that scales automatically

Your portfolio is now live at `https://yourdomain.com` with enterprise-grade performance, security, and reliability!

**💡 Next Steps:**
- Monitor your website performance
- Set up automated deployments (optional)
- Add more features as needed
- Scale up when traffic grows

**💰 Total Setup Cost: $2-5/month** (vs $35-45 with full AI setup)