# 🔧 Fix S3 Access Denied Error

**Quick Fix for "Access Denied" Error on Your Portfolio Website**

## 🎯 Problem
Your website shows:
```xml
<Error>
<Code>AccessDenied</Code>
<Message>Access Denied</Message>
</Error>
```

## 🚀 Solution Steps

### Step 1: Update S3 Bucket Public Access Settings

1. **Go to S3 Console**
   - Open [AWS S3 Console](https://s3.console.aws.amazon.com/)
   - Click on your bucket name

2. **Update Public Access Block**
   - Go to **Permissions** tab
   - Click **Edit** under "Block public access (bucket settings)"
   - **Uncheck ALL boxes**:
     - ❌ Block all public access
     - ❌ Block public access to buckets and objects granted through new access control lists (ACLs)
     - ❌ Block public access to buckets and objects granted through any access control lists (ACLs)
     - ❌ Block public access to buckets and objects granted through new public bucket or access point policies
     - ❌ Block public access to buckets and objects granted through any public bucket or access point policies
   - Type `confirm` in the confirmation box
   - Click **Save changes**

### Step 2: Add Correct Bucket Policy

1. **Go to Bucket Policy**
   - Still in **Permissions** tab
   - Scroll to **Bucket policy**
   - Click **Edit**

2. **Replace with This Policy**
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
   
   **⚠️ Important**: Replace `YOUR-BUCKET-NAME` with your actual bucket name (e.g., `yourdomain.com`)

3. **Save Policy**
   - Click **Save changes**

### Step 3: Verify Static Website Hosting

1. **Check Website Configuration**
   - Go to **Properties** tab
   - Scroll to **Static website hosting**
   - Ensure it shows:
     ```
     Static website hosting: Enabled
     Index document: index.html
     Error document: index.html
     ```

2. **If Not Enabled**
   - Click **Edit**
   - Select **Enable**
   - Set Index document: `index.html`
   - Set Error document: `index.html`
   - Click **Save changes**

### Step 4: Test Direct S3 Access

1. **Get S3 Website Endpoint**
   - In **Properties** > **Static website hosting**
   - Copy the **Bucket website endpoint**
   - Should look like: `http://yourdomain.com.s3-website-us-east-1.amazonaws.com`

2. **Test in Browser**
   - Open the S3 website endpoint URL
   - Your website should load correctly

### Step 5: Fix CloudFront (If Using)

If you're using CloudFront and still getting errors:

1. **Update CloudFront Origin**
   - Go to [CloudFront Console](https://console.aws.amazon.com/cloudfront/)
   - Click on your distribution
   - Go to **Origins** tab
   - Click **Edit** on your origin

2. **Change Origin Domain**
   - Instead of: `yourdomain.com.s3.amazonaws.com`
   - Use: `yourdomain.com.s3-website-us-east-1.amazonaws.com`
   - This uses the S3 website endpoint, not the REST API endpoint

3. **Update Origin Settings**
   ```
   Origin domain: yourdomain.com.s3-website-us-east-1.amazonaws.com
   Protocol: HTTP only
   Origin path: [leave empty]
   ```

4. **Create Invalidation**
   - Go to **Invalidations** tab
   - Click **Create invalidation**
   - Enter `/*`
   - Click **Create invalidation**

## ✅ Quick Verification

### Test These URLs:

1. **Direct S3 Website**
   ```
   http://yourdomain.com.s3-website-us-east-1.amazonaws.com
   ```

2. **CloudFront Distribution**
   ```
   https://d1234567890123.cloudfront.net
   ```

3. **Your Custom Domain** (after DNS propagation)
   ```
   https://yourdomain.com
   ```

## 🔧 Alternative: Complete Bucket Policy

If you're still having issues, use this comprehensive bucket policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion"
      ],
      "Resource": "arn:aws:s3:::YOUR-BUCKET-NAME/*"
    },
    {
      "Sid": "PublicReadGetBucketLocation",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetBucketLocation",
      "Resource": "arn:aws:s3:::YOUR-BUCKET-NAME"
    },
    {
      "Sid": "PublicListBucket",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::YOUR-BUCKET-NAME"
    }
  ]
}
```

## 🚨 Common Mistakes to Avoid

1. **Wrong Resource ARN**
   - ❌ `arn:aws:s3:::yourdomain.com`
   - ✅ `arn:aws:s3:::yourdomain.com/*`
   - The `/*` at the end is crucial!

2. **Public Access Still Blocked**
   - Make sure ALL public access blocks are unchecked
   - This is the most common cause of access denied errors

3. **Wrong CloudFront Origin**
   - Use S3 website endpoint, not REST API endpoint
   - Website endpoint: `bucket.s3-website-region.amazonaws.com`
   - REST endpoint: `bucket.s3.region.amazonaws.com`

## 🔍 Troubleshooting Commands

```bash
# Test S3 website endpoint
curl -I http://yourdomain.com.s3-website-us-east-1.amazonaws.com

# Test CloudFront
curl -I https://d1234567890123.cloudfront.net

# Check DNS (after propagation)
nslookup yourdomain.com
```

## 📞 Still Having Issues?

If you're still getting access denied errors:

1. **Check AWS Region**
   - Ensure your S3 bucket is in the correct region
   - Update the website endpoint URL accordingly

2. **Verify File Upload**
   - Make sure `index.html` exists in your bucket
   - Check file permissions are not explicitly denied

3. **Wait for Propagation**
   - S3 policy changes can take a few minutes
   - CloudFront changes can take 15-20 minutes

4. **Try Incognito Mode**
   - Clear browser cache or use incognito mode
   - Sometimes browsers cache error responses

---

**🎯 After following these steps, your website should be accessible without the Access Denied error!**