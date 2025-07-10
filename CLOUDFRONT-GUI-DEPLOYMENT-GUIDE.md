# 🌐 CloudFront GUI Deployment Guide

**Deploy Your Portfolio Using AWS Console** | **No Command Line Required** | **Visual Step-by-Step**

This guide shows you how to deploy your professional portfolio website using the AWS Console GUI, perfect for those who prefer visual interfaces over command-line tools.

## 📋 Overview

We'll deploy your portfolio using:
- **S3** for static website hosting
- **CloudFront** for global CDN
- **Route 53** for DNS management
- **Certificate Manager** for SSL certificates
- **All through the AWS Console GUI**

**Estimated Monthly Cost: $2-5**

## 🎯 Prerequisites

Before starting, ensure you have:
- [ ] AWS account with billing configured
- [ ] Domain name registered (GoDaddy, Namecheap, etc.)
- [ ] Built portfolio website files (we'll help you build these)
- [ ] Basic understanding of AWS Console navigation

## 🚀 Step 1: Prepare Your Website Files

### **Option A: Download Pre-built Files**
If you don't want to build locally:

1. Go to [GitHub Actions](https://github.com/infrapulses/portfolio-website/actions)
2. Click on the latest successful build
3. Download the `build-artifacts` zip file
4. Extract the files - you'll see a `dist` folder

### **Option B: Build Locally**
If you have Node.js installed:

```bash
# Clone the repository
git clone https://github.com/infrapulses/portfolio-website.git
cd portfolio-website

# Install dependencies
npm install

# Build the website
npm run build
```

You'll get a `dist` folder with all website files.

### **What You Should Have**
After building, your `dist` folder should contain:
- `index.html` (main page)
- `assets/` folder (CSS, JS, images)
- Other HTML files and resources

## 🪣 Step 2: Create S3 Bucket for Website Hosting

### **2.1 Navigate to S3**
1. Login to [AWS Console](https://console.aws.amazon.com/)
2. Search for "S3" in the services search bar
3. Click on **S3** to open the S3 console

### **2.2 Create Bucket**
1. Click **"Create bucket"**
2. **Bucket name**: Enter your domain name (e.g., `yourdomain.com`)
   - Must be globally unique
   - Use lowercase letters, numbers, and hyphens only
3. **AWS Region**: Select `US East (N. Virginia) us-east-1`
   - Required for CloudFront integration
4. **Object Ownership**: Select `ACLs enabled`
5. **Block Public Access settings**: 
   - ❌ **Uncheck** "Block all public access"
   - ✅ **Check** the acknowledgment box
6. **Bucket Versioning**: Enable (recommended)
7. **Default encryption**: Keep default (SSE-S3)
8. Click **"Create bucket"**

### **2.3 Configure Bucket for Website Hosting**
1. Click on your newly created bucket name
2. Go to **"Properties"** tab
3. Scroll down to **"Static website hosting"**
4. Click **"Edit"**
5. Select **"Enable"**
6. **Index document**: `index.html`
7. **Error document**: `index.html` (for single-page apps)
8. Click **"Save changes"**

### **2.4 Set Bucket Policy for Public Access**
1. Go to **"Permissions"** tab
2. Scroll to **"Bucket policy"**
3. Click **"Edit"**
4. Paste this policy (replace `YOUR-BUCKET-NAME` with your actual bucket name):

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::YOUR-BUCKET-NAME/*"
        }
    ]
}
```

5. Click **"Save changes"**

## 📁 Step 3: Upload Website Files

### **3.1 Upload Files**
1. Go to **"Objects"** tab in your S3 bucket
2. Click **"Upload"**
3. Click **"Add files"** and **"Add folder"**
4. Select all files and folders from your `dist` directory
   - Select `index.html`
   - Select the entire `assets` folder
   - Select any other files in the `dist` folder
5. Click **"Upload"**

### **3.2 Set Proper Permissions**
1. After upload completes, select all uploaded objects
2. Click **"Actions"** → **"Make public using ACL"**
3. Confirm by typing "make public"
4. Click **"Make public"**

### **3.3 Test S3 Website**
1. Go back to **"Properties"** tab
2. Scroll to **"Static website hosting"**
3. Copy the **"Bucket website endpoint"** URL
4. Open it in a new browser tab
5. Verify your website loads correctly

## 🔐 Step 4: Request SSL Certificate

### **4.1 Navigate to Certificate Manager**
1. In AWS Console, search for "Certificate Manager"
2. Click on **AWS Certificate Manager**
3. **Important**: Ensure you're in **US East (N. Virginia)** region
   - CloudFront requires certificates in this region

### **4.2 Request Certificate**
1. Click **"Request a certificate"**
2. Select **"Request a public certificate"**
3. Click **"Next"**

### **4.3 Add Domain Names**
1. **Domain name**: Enter your domain (e.g., `yourdomain.com`)
2. Click **"Add another name to this certificate"**
3. Add `www.yourdomain.com`
4. Click **"Next"**

### **4.4 Select Validation Method**
1. Choose **"DNS validation"** (recommended)
2. Click **"Next"**
3. Add tags if desired (optional)
4. Click **"Review"**
5. Click **"Confirm and request"**

### **4.5 Complete DNS Validation**
1. Click **"View certificate"**
2. For each domain, you'll see DNS validation records
3. Click **"Create record in Route 53"** (if using Route 53)
   - OR manually add CNAME records to your DNS provider
4. Wait for validation (usually 5-30 minutes)
5. Certificate status should change to **"Issued"**

## 🌐 Step 5: Set Up Route 53 (DNS)

### **5.1 Create Hosted Zone**
1. Search for "Route 53" in AWS Console
2. Click on **Route 53**
3. Click **"Hosted zones"** in the left sidebar
4. Click **"Create hosted zone"**
5. **Domain name**: Enter your domain (e.g., `yourdomain.com`)
6. **Type**: Public hosted zone
7. Click **"Create hosted zone"**

### **5.2 Note Nameservers**
1. Click on your newly created hosted zone
2. Note the 4 **NS (Name Server)** records
3. Copy these nameservers - you'll need them for your domain registrar

### **5.3 Update Domain Registrar**
Go to your domain registrar (GoDaddy, Namecheap, etc.) and update nameservers:

#### **For GoDaddy:**
1. Login to [GoDaddy Account](https://account.godaddy.com/)
2. Go to **"My Products"** → **"All Products and Services"**
3. Find your domain and click **"DNS"**
4. Click **"Change Nameservers"**
5. Select **"Custom"**
6. Enter the 4 Route 53 nameservers
7. Click **"Save"**

#### **For Namecheap:**
1. Login to Namecheap account
2. Go to **"Domain List"**
3. Click **"Manage"** next to your domain
4. Go to **"Nameservers"** section
5. Select **"Custom DNS"**
6. Enter the 4 Route 53 nameservers
7. Click **"Save"**

**⏰ DNS propagation takes 24-48 hours**

## ☁️ Step 6: Create CloudFront Distribution

### **6.1 Navigate to CloudFront**
1. Search for "CloudFront" in AWS Console
2. Click on **Amazon CloudFront**

### **6.2 Create Distribution**
1. Click **"Create distribution"**
2. **Origin domain**: Select your S3 bucket from dropdown
   - Choose the bucket website endpoint (not the bucket itself)
   - Should look like: `yourdomain.com.s3-website-us-east-1.amazonaws.com`

### **6.3 Configure Origin Settings**
1. **Protocol**: HTTP only (S3 website endpoints don't support HTTPS)
2. **Origin path**: Leave empty
3. **Name**: Keep default or customize

### **6.4 Configure Default Cache Behavior**
1. **Viewer protocol policy**: Redirect HTTP to HTTPS
2. **Allowed HTTP methods**: GET, HEAD, OPTIONS, PUT, POST, PATCH, DELETE
3. **Cache policy**: Managed-CachingOptimized
4. **Origin request policy**: None
5. **Response headers policy**: None

### **6.5 Configure Distribution Settings**
1. **Price class**: Use all edge locations (best performance)
   - Or select "Use only North America and Europe" for cost savings
2. **Alternate domain names (CNAMEs)**: 
   - Add `yourdomain.com`
   - Add `www.yourdomain.com`
3. **Custom SSL certificate**: Select your certificate from dropdown
4. **Security policy**: TLSv1.2_2021 (recommended)
5. **Default root object**: `index.html`

### **6.6 Configure Error Pages (Important for SPAs)**
1. Scroll to **"Custom error responses"**
2. Click **"Create custom error response"**
3. **HTTP error code**: 403 Forbidden
4. **Response page path**: `/index.html`
5. **HTTP response code**: 200 OK
6. Click **"Create custom error response"**
7. Repeat for **404 Not Found** error

### **6.7 Create Distribution**
1. Review all settings
2. Click **"Create distribution"**
3. Wait for deployment (usually 15-20 minutes)
4. Status will change from "Deploying" to "Enabled"

## 🔗 Step 7: Configure DNS Records

### **7.1 Create A Records in Route 53**
1. Go back to **Route 53** → **Hosted zones**
2. Click on your domain's hosted zone
3. Click **"Create record"**

#### **For Root Domain (yourdomain.com):**
1. **Record name**: Leave empty (root domain)
2. **Record type**: A
3. **Alias**: Yes
4. **Route traffic to**: 
   - Select "Alias to CloudFront distribution"
   - Select your CloudFront distribution from dropdown
5. Click **"Create records"**

#### **For WWW Subdomain:**
1. Click **"Create record"** again
2. **Record name**: `www`
3. **Record type**: A
4. **Alias**: Yes
5. **Route traffic to**: 
   - Select "Alias to CloudFront distribution"
   - Select your CloudFront distribution from dropdown
6. Click **"Create records"**

## ✅ Step 8: Test Your Deployment

### **8.1 Wait for Propagation**
- CloudFront deployment: 15-20 minutes
- DNS propagation: 24-48 hours (can be faster)

### **8.2 Test Website Access**
1. Try accessing `https://yourdomain.com`
2. Try accessing `https://www.yourdomain.com`
3. Verify SSL certificate (green lock icon)
4. Test all pages and functionality

### **8.3 Performance Testing**
1. Use [Google PageSpeed Insights](https://pagespeed.web.dev/)
2. Test mobile and desktop performance
3. Check Core Web Vitals scores

## 🔄 Step 9: Set Up Automated Deployments (Optional)

### **9.1 Create IAM User for GitHub Actions**
1. Go to **IAM** in AWS Console
2. Click **"Users"** → **"Create user"**
3. **User name**: `github-actions-portfolio`
4. **Access type**: Programmatic access
5. Click **"Next"**

### **9.2 Attach Policies**
1. Click **"Attach policies directly"**
2. Search and select these policies:
   - `AmazonS3FullAccess`
   - `CloudFrontFullAccess`
3. Click **"Next"** → **"Create user"**
4. **Important**: Save the Access Key ID and Secret Access Key

### **9.3 Configure GitHub Secrets**
1. Go to your GitHub repository
2. Click **"Settings"** → **"Secrets and variables"** → **"Actions"**
3. Add these secrets:
   - `AWS_ACCESS_KEY_ID`: Your IAM user's access key
   - `AWS_SECRET_ACCESS_KEY`: Your IAM user's secret key
   - `S3_BUCKET_NAME`: Your S3 bucket name
   - `CLOUDFRONT_DISTRIBUTION_ID`: From CloudFront console

### **9.4 GitHub Actions Workflow**
The repository already includes automated deployment workflows. Every push to `main` branch will:
1. Build the website
2. Upload to S3
3. Invalidate CloudFront cache
4. Deploy changes live

## 💰 Step 10: Monitor Costs and Performance

### **10.1 Set Up Billing Alerts**
1. Go to **AWS Billing Console**
2. Click **"Billing preferences"**
3. Enable **"Receive Billing Alerts"**
4. Go to **CloudWatch** → **"Alarms"** → **"Billing"**
5. Create alarm for monthly charges > $10

### **10.2 Monitor Usage**
1. **S3**: Check storage usage and requests
2. **CloudFront**: Monitor data transfer and requests
3. **Route 53**: DNS query charges

### **Expected Monthly Costs:**
- S3 Storage: $1-2
- CloudFront: $1-3
- Route 53: $0.50
- **Total: $2-5/month**

## 🔧 Troubleshooting Common Issues

### **Website Not Loading**
1. **Check CloudFront status**: Must be "Enabled"
2. **Verify DNS**: Use [DNS Checker](https://dnschecker.org/)
3. **Check S3 bucket policy**: Ensure public read access
4. **Verify certificate**: Must be in us-east-1 region

### **SSL Certificate Issues**
1. **Wrong region**: Certificate must be in us-east-1
2. **DNS validation**: Check CNAME records in DNS
3. **Domain mismatch**: Certificate must cover your domain

### **404 Errors on Refresh**
1. **Add custom error responses** in CloudFront
2. **Map 403/404 errors** to `/index.html` with 200 status

### **Slow Loading**
1. **Check CloudFront cache settings**
2. **Optimize images** before uploading
3. **Enable compression** in CloudFront

## 🔄 Updating Your Website

### **Manual Updates**
1. Build your updated website locally
2. Go to S3 bucket in AWS Console
3. Delete old files (optional)
4. Upload new files from `dist` folder
5. Go to CloudFront → Your distribution
6. Click **"Invalidations"** tab
7. Click **"Create invalidation"**
8. Enter `/*` to invalidate all files
9. Click **"Create invalidation"**

### **Automated Updates (Recommended)**
Once GitHub Actions is set up:
1. Make changes to your code
2. Commit and push to GitHub
3. GitHub Actions automatically deploys changes

## 📈 Scaling and Enhancements

### **Add More Features**
1. **Contact Form Backend**: Use AWS Lambda + API Gateway
2. **Database**: Add DynamoDB for dynamic content
3. **Analytics**: Integrate Google Analytics or AWS Analytics
4. **Monitoring**: Set up CloudWatch dashboards

### **Performance Optimizations**
1. **Image Optimization**: Use WebP format
2. **Caching**: Fine-tune CloudFront cache policies
3. **Compression**: Enable Gzip/Brotli compression
4. **CDN**: Use additional edge locations

## ✅ Success Checklist

- [ ] ✅ S3 bucket created and configured for static hosting
- [ ] ✅ Website files uploaded to S3
- [ ] ✅ SSL certificate requested and validated
- [ ] ✅ Route 53 hosted zone created
- [ ] ✅ Domain nameservers updated at registrar
- [ ] ✅ CloudFront distribution created and deployed
- [ ] ✅ DNS A records pointing to CloudFront
- [ ] ✅ Website accessible at https://yourdomain.com
- [ ] ✅ SSL certificate working (green lock icon)
- [ ] ✅ All pages load correctly
- [ ] ✅ Mobile responsive design works
- [ ] ✅ Contact form functional
- [ ] ✅ Billing alerts configured
- [ ] ✅ GitHub Actions deployment (optional)

## 🎉 Congratulations!

You've successfully deployed your professional portfolio website using AWS GUI! Your site is now:

- ✅ **Globally distributed** via CloudFront CDN
- ✅ **Secure** with SSL/TLS encryption
- ✅ **Fast loading** with optimized caching
- ✅ **Scalable** and ready for growth
- ✅ **Cost-effective** at $2-5/month
- ✅ **Professional grade** infrastructure

Your portfolio is live at `https://yourdomain.com` with enterprise-level performance and security!

## 📞 Support and Resources

### **AWS Documentation**
- [S3 Static Website Hosting](https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteHosting.html)
- [CloudFront User Guide](https://docs.aws.amazon.com/cloudfront/)
- [Route 53 Developer Guide](https://docs.aws.amazon.com/route53/)
- [Certificate Manager User Guide](https://docs.aws.amazon.com/acm/)

### **Useful Tools**
- [DNS Checker](https://dnschecker.org/) - Check DNS propagation
- [SSL Labs](https://www.ssllabs.com/ssltest/) - Test SSL configuration
- [Google PageSpeed Insights](https://pagespeed.web.dev/) - Performance testing
- [AWS Calculator](https://calculator.aws/) - Cost estimation

### **Getting Help**
- **AWS Support**: For AWS-specific issues
- **GitHub Issues**: Report problems in the repository
- **Community Forums**: AWS re:Post, Stack Overflow

---

**🎯 You now have a professional, scalable, and cost-effective portfolio website deployed entirely through the AWS Console GUI!**