# Portfolio Website Deployment on Ubuntu with GitHub Integration

## Prerequisites
- Ubuntu server (18.04+ recommended)
- GitHub repository for your portfolio
- Domain name (optional but recommended)
- SSH access to your server

## Part 1: Initial Server Setup

### Step 1: Prepare Ubuntu Server
```bash
# Update system packages
sudo apt update && sudo apt upgrade -y

# Install essential packages
sudo apt install -y curl wget git unzip software-properties-common

# Install Node.js 18.x
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify installation
node --version
npm --version

# Install Nginx
sudo apt install nginx -y

# Install PM2 for process management
sudo npm install -g pm2

# Install GitHub CLI (optional but useful)
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh -y
```

### Step 2: Create Deployment User
```bash
# Create a deployment user
sudo adduser deploy
sudo usermod -aG sudo deploy
sudo usermod -aG www-data deploy

# Switch to deploy user
sudo su - deploy

# Generate SSH key for GitHub
ssh-keygen -t ed25519 -C "techey.kamal@gmail.com"

# Display public key (add this to GitHub Deploy Keys)
cat ~/.ssh/id_ed25519.pub
```

## Part 2: GitHub Repository Setup

### Step 1: Add Deploy Key to GitHub
1. Go to your repository on GitHub
2. Navigate to **Settings** → **Deploy keys**
3. Click **Add deploy key**
4. Paste the public key from above
5. Check **Allow write access** if you need push capabilities
6. Click **Add key**

### Step 2: Create GitHub Actions Workflow
Create `.github/workflows/deploy.yml` in your repository:

```yaml
name: Deploy to Ubuntu Server

on:
  push:
    branches: [ main, master ]
  pull_request:
    branches: [ main, master ]

jobs:
  build-and-deploy:
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
      
    - name: Run tests (if available)
      run: npm test --if-present
      
    - name: Deploy to server
      if: github.ref == 'refs/heads/main' || github.ref == 'refs/heads/master'
      uses: appleboy/ssh-action@v1.0.0
      with:
        host: ${{ secrets.HOST }}
        username: ${{ secrets.USERNAME }}
        key: ${{ secrets.PRIVATE_KEY }}
        port: ${{ secrets.PORT }}
        script: |
          cd /var/www/portfolio
          git pull origin main
          npm ci --only=production
          npm run build
          sudo systemctl reload nginx
          
    - name: Notify deployment status
      if: always()
      uses: 8398a7/action-slack@v3
      with:
        status: ${{ job.status }}
        channel: '#deployments'
        webhook_url: ${{ secrets.SLACK_WEBHOOK }}
      env:
        SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK }}
```

### Step 3: Configure GitHub Secrets
Go to your repository **Settings** → **Secrets and variables** → **Actions** and add:

- `HOST`: Your server IP address
- `USERNAME`: `deploy`
- `PRIVATE_KEY`: Contents of `/home/deploy/.ssh/id_ed25519` (private key)
- `PORT`: SSH port (usually 22)
- `SLACK_WEBHOOK`: (Optional) For deployment notifications

## Part 3: Server Configuration

### Step 1: Clone Repository and Initial Setup
```bash
# Switch to deploy user
sudo su - deploy

# Create web directory
sudo mkdir -p /var/www
sudo chown deploy:www-data /var/www

# Clone your repository
cd /var/www
git clone git@github.com:infrapulses/portfolio-website.git portfolio
cd portfolio

# Install dependencies and build
npm install
npm run build

# Set proper permissions
sudo chown -R deploy:www-data /var/www/portfolio
sudo chmod -R 755 /var/www/portfolio
```

### Step 2: Configure Nginx
```bash
# Create Nginx configuration
sudo nano /etc/nginx/sites-available/portfolio
```

Add this configuration:
```nginx
server {
    listen 80;
    server_name your-domain.com www.your-domain.com;
    
    root /var/www/portfolio/dist;
    index index.html;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
    
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied expired no-cache no-store private must-revalidate auth;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;
    
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    # Cache static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        access_log off;
    }
    
    # Handle API routes if you add backend later
    location /api/ {
        proxy_pass http://localhost:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
    
    # Deny access to sensitive files
    location ~ /\. {
        deny all;
    }
    
    location ~ /\.git {
        deny all;
    }
}
```

```bash
# Enable the site
sudo ln -s /etc/nginx/sites-available/portfolio /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Test configuration
sudo nginx -t

# Start and enable Nginx
sudo systemctl start nginx
sudo systemctl enable nginx
```

### Step 3: Set Up SSL with Let's Encrypt
```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx -y

# Get SSL certificate
sudo certbot --nginx -d your-domain.com -d www.your-domain.com

# Verify auto-renewal
sudo certbot renew --dry-run
```

## Part 4: Advanced GitHub Integration

### Step 1: Webhook Setup for Instant Deployment
Create a webhook endpoint script:

```bash
# Create webhook handler
sudo nano /var/www/webhook-handler.js
```

```javascript
const http = require('http');
const crypto = require('crypto');
const { exec } = require('child_process');

const secret = 'your-webhook-secret';
const port = 9000;

const server = http.createServer((req, res) => {
  if (req.method === 'POST' && req.url === '/webhook') {
    let body = '';
    
    req.on('data', chunk => {
      body += chunk.toString();
    });
    
    req.on('end', () => {
      const signature = req.headers['x-hub-signature-256'];
      const expectedSignature = 'sha256=' + crypto
        .createHmac('sha256', secret)
        .update(body)
        .digest('hex');
      
      if (signature === expectedSignature) {
        const payload = JSON.parse(body);
        
        if (payload.ref === 'refs/heads/main') {
          console.log('Deploying...');
          
          exec('cd /var/www/portfolio && ./deploy.sh', (error, stdout, stderr) => {
            if (error) {
              console.error(`Error: ${error}`);
              return;
            }
            console.log(`Deploy output: ${stdout}`);
          });
        }
      }
      
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ status: 'ok' }));
    });
  } else {
    res.writeHead(404);
    res.end();
  }
});

server.listen(port, () => {
  console.log(`Webhook server running on port ${port}`);
});
```

### Step 2: Create Deployment Script
```bash
# Create deployment script
nano /var/www/portfolio/deploy.sh
```

```bash
#!/bin/bash

# Deployment script for portfolio
set -e

echo "Starting deployment..."

# Navigate to project directory
cd /var/www/portfolio

# Backup current version
cp -r dist dist.backup.$(date +%Y%m%d_%H%M%S) 2>/dev/null || true

# Pull latest changes
git pull origin main

# Install dependencies
npm ci --only=production

# Build project
npm run build

# Set permissions
sudo chown -R deploy:www-data /var/www/portfolio
sudo chmod -R 755 /var/www/portfolio

# Reload Nginx
sudo systemctl reload nginx

# Clean old backups (keep last 5)
ls -t dist.backup.* 2>/dev/null | tail -n +6 | xargs rm -rf 2>/dev/null || true

echo "Deployment completed successfully!"

# Send notification (optional)
curl -X POST -H 'Content-type: application/json' \
  --data '{"text":"Portfolio deployed successfully!"}' \
  YOUR_SLACK_WEBHOOK_URL 2>/dev/null || true
```

```bash
# Make script executable
chmod +x /var/www/portfolio/deploy.sh

# Start webhook handler with PM2
cd /var/www
pm2 start webhook-handler.js --name webhook
pm2 startup
pm2 save
```

### Step 3: Configure GitHub Webhook
1. Go to your repository **Settings** → **Webhooks**
2. Click **Add webhook**
3. Set Payload URL: `http://your-domain.com:9000/webhook`
4. Content type: `application/json`
5. Secret: Use the same secret from webhook-handler.js
6. Select **Just the push event**
7. Click **Add webhook**

## Part 5: Monitoring and Maintenance

### Step 1: Set Up Log Monitoring
```bash
# Create log monitoring script
sudo nano /usr/local/bin/monitor-deployment.sh
```

```bash
#!/bin/bash

# Monitor deployment logs
LOG_FILE="/var/log/deployment.log"
ERROR_LOG="/var/log/deployment-errors.log"

# Function to log with timestamp
log_with_timestamp() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $LOG_FILE
}

# Monitor Nginx access logs for errors
tail -f /var/log/nginx/access.log | while read line; do
    if echo "$line" | grep -q " 5[0-9][0-9] "; then
        log_with_timestamp "ERROR: $line"
        echo "$line" >> $ERROR_LOG
    fi
done &

# Monitor system resources
while true; do
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | awk -F'%' '{print $1}')
    MEMORY_USAGE=$(free | grep Mem | awk '{printf("%.2f", $3/$2 * 100.0)}')
    DISK_USAGE=$(df -h / | awk 'NR==2{printf "%s", $5}')
    
    log_with_timestamp "CPU: ${CPU_USAGE}%, Memory: ${MEMORY_USAGE}%, Disk: ${DISK_USAGE}"
    sleep 300  # Check every 5 minutes
done
```

```bash
# Make executable and start
sudo chmod +x /usr/local/bin/monitor-deployment.sh
pm2 start /usr/local/bin/monitor-deployment.sh --name monitor
```

### Step 2: Automated Backups
```bash
# Create backup script
sudo nano /usr/local/bin/backup-portfolio.sh
```

```bash
#!/bin/bash

BACKUP_DIR="/backup/portfolio"
DATE=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=7

# Create backup directory
mkdir -p $BACKUP_DIR

# Backup website files
tar -czf $BACKUP_DIR/portfolio_$DATE.tar.gz /var/www/portfolio

# Backup Nginx configuration
cp /etc/nginx/sites-available/portfolio $BACKUP_DIR/nginx_config_$DATE

# Remove old backups
find $BACKUP_DIR -name "portfolio_*.tar.gz" -mtime +$RETENTION_DAYS -delete
find $BACKUP_DIR -name "nginx_config_*" -mtime +$RETENTION_DAYS -delete

echo "Backup completed: portfolio_$DATE.tar.gz"
```

```bash
# Make executable
sudo chmod +x /usr/local/bin/backup-portfolio.sh

# Add to crontab for daily backups
sudo crontab -e
# Add: 0 2 * * * /usr/local/bin/backup-portfolio.sh
```

### Step 3: Health Check Script
```bash
# Create health check
nano /var/www/health-check.sh
```

```bash
#!/bin/bash

# Health check script
SITE_URL="https://your-domain.com"
WEBHOOK_URL="YOUR_SLACK_WEBHOOK_URL"

# Check if site is responding
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" $SITE_URL)

if [ $HTTP_STATUS -ne 200 ]; then
    MESSAGE="🚨 Portfolio site is down! HTTP Status: $HTTP_STATUS"
    curl -X POST -H 'Content-type: application/json' \
      --data "{\"text\":\"$MESSAGE\"}" \
      $WEBHOOK_URL
    
    # Try to restart nginx
    sudo systemctl restart nginx
    
    # Log the incident
    echo "$(date): Site down, HTTP $HTTP_STATUS" >> /var/log/health-check.log
fi
```

```bash
# Make executable and schedule
chmod +x /var/www/health-check.sh
crontab -e
# Add: */5 * * * * /var/www/health-check.sh
```

## Part 6: Security Hardening

### Step 1: Firewall Configuration
```bash
# Configure UFW
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 'Nginx Full'
sudo ufw allow 9000  # For webhook
sudo ufw enable
```

### Step 2: Fail2Ban Setup
```bash
# Install Fail2Ban
sudo apt install fail2ban -y

# Configure for Nginx
sudo nano /etc/fail2ban/jail.local
```

```ini
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 5

[nginx-http-auth]
enabled = true

[nginx-limit-req]
enabled = true
filter = nginx-limit-req
action = iptables-multiport[name=ReqLimit, port="http,https", protocol=tcp]
logpath = /var/log/nginx/*error.log
findtime = 600
bantime = 7200
maxretry = 10
```

```bash
# Start and enable Fail2Ban
sudo systemctl start fail2ban
sudo systemctl enable fail2ban
```

## Part 7: Performance Optimization

### Step 1: Enable HTTP/2 and Optimize Nginx
```bash
# Update Nginx configuration for performance
sudo nano /etc/nginx/sites-available/portfolio
```

Add to server block:
```nginx
# Enable HTTP/2
listen 443 ssl http2;
listen [::]:443 ssl http2;

# Optimize SSL
ssl_session_cache shared:le_nginx_SSL:10m;
ssl_session_timeout 1440m;
ssl_protocols TLSv1.2 TLSv1.3;
ssl_prefer_server_ciphers off;

# Enable OCSP stapling
ssl_stapling on;
ssl_stapling_verify on;

# Optimize worker processes
worker_processes auto;
worker_connections 1024;
```

### Step 2: Set Up CloudFlare (Optional)
1. Sign up for CloudFlare
2. Add your domain
3. Update nameservers
4. Enable caching and security features
5. Set SSL mode to "Full (strict)"

## Troubleshooting Guide

### Common Issues and Solutions

1. **Permission Denied Errors**:
   ```bash
   sudo chown -R deploy:www-data /var/www/portfolio
   sudo chmod -R 755 /var/www/portfolio
   ```

2. **GitHub Authentication Issues**:
   ```bash
   ssh -T git@github.com
   # Should return: Hi username! You've successfully authenticated
   ```

3. **Build Failures**:
   ```bash
   # Check Node.js version
   node --version
   # Clear npm cache
   npm cache clean --force
   # Remove node_modules and reinstall
   rm -rf node_modules package-lock.json
   npm install
   ```

4. **Nginx Configuration Errors**:
   ```bash
   sudo nginx -t
   sudo systemctl status nginx
   sudo tail -f /var/log/nginx/error.log
   ```

5. **Webhook Not Working**:
   ```bash
   # Check if webhook handler is running
   pm2 status
   # Check webhook logs
   pm2 logs webhook
   # Test webhook endpoint
   curl -X POST http://your-domain.com:9000/webhook
   ```

### Useful Commands

```bash
# Monitor deployments
tail -f /var/log/deployment.log

# Check system resources
htop
df -h
free -h

# Restart services
sudo systemctl restart nginx
pm2 restart all

# View GitHub Actions logs
gh run list
gh run view [run-id]

# Check SSL certificate
sudo certbot certificates

# Monitor real-time access logs
sudo tail -f /var/log/nginx/access.log
```

This comprehensive guide provides automated deployment with GitHub integration, monitoring, security, and maintenance procedures for your portfolio website on Ubuntu.