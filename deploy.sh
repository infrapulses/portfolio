#!/bin/bash

# Portfolio Deployment Script
set -e

echo "🚀 Starting portfolio deployment..."

# Build the application
echo "📦 Building application..."
npm run build

# Backup current deployment
echo "💾 Creating backup..."
sudo cp -r /var/www/portfolio /var/www/portfolio.backup.$(date +%Y%m%d_%H%M%S) 2>/dev/null || true

# Deploy new build
echo "🚀 Deploying new build..."
sudo rm -rf /var/www/portfolio/*
sudo cp -r dist/* /var/www/portfolio/

# Set proper permissions
echo "🔐 Setting permissions..."
sudo chown -R www-data:www-data /var/www/portfolio
sudo chmod -R 755 /var/www/portfolio

# Test nginx configuration
echo "🧪 Testing nginx configuration..."
sudo nginx -t

# Reload nginx
echo "🔄 Reloading nginx..."
sudo systemctl reload nginx

# Clean old backups (keep last 5)
echo "🧹 Cleaning old backups..."
ls -t /var/www/portfolio.backup.* 2>/dev/null | tail -n +6 | xargs sudo rm -rf 2>/dev/null || true

echo "✅ Deployment completed successfully!"
echo "🌐 Your portfolio is live at: https://yourdomain.com"