# 📁 Portfolio Website Directory Structure

## Complete Project Structure

```
portfolio-website/
├── 📁 public/                          # Static assets served by Vite
│   ├── 📁 images/                      # All images for the website
│   │   ├── 📁 profile/                 # Profile photos
│   │   │   ├── hero-profile.jpg        # Main profile photo (400x400px)
│   │   │   └── about-profile.jpg       # About section photo (300x300px)
│   │   ├── 📁 portfolio/               # Project images
│   │   │   ├── visionops.jpg           # VisionOps project image
│   │   │   ├── futureops.jpg           # FutureOps project image
│   │   │   ├── siem-stack.jpg          # SIEM project image
│   │   │   ├── kubernetes-automation.jpg
│   │   │   ├── ai-anomaly-detection.jpg
│   │   │   └── network-monitoring.jpg
│   │   ├── 📁 icons/                   # Icons and favicons
│   │   │   ├── favicon.ico
│   │   │   ├── logo-192.png
│   │   │   └── logo-512.png
│   │   └── 📁 backgrounds/             # Background images (optional)
│   │       ├── hero-bg.jpg
│   │       └── section-bg.jpg
│   └── vite.svg                        # Default Vite icon
├── 📁 src/                             # React source code
│   ├── 📁 components/                  # React components
│   │   ├── About.tsx                   # About section
│   │   ├── ChatBot.tsx                 # AI chatbot
│   │   ├── Contact.tsx                 # Contact form
│   │   ├── Footer.tsx                  # Footer component
│   │   ├── Header.tsx                  # Navigation header
│   │   ├── Hero.tsx                    # Hero section
│   │   ├── Portfolio.tsx               # Portfolio showcase
│   │   ├── Resume.tsx                  # Resume section
│   │   └── Skills.tsx                  # Skills section
│   ├── App.tsx                         # Main app component
│   ├── main.tsx                        # App entry point
│   ├── index.css                       # Global styles
│   └── vite-env.d.ts                   # Vite type definitions
├── 📁 static-html/                     # Static HTML version
│   ├── index.html                      # Complete static website
│   ├── styles.css                      # All CSS styles
│   ├── script.js                       # JavaScript functionality
│   └── README.md                       # Static version docs
├── 📁 scripts/                         # Deployment scripts
│   ├── deploy-aws.sh                   # AWS deployment
│   ├── deploy-minimal-cost.sh          # Minimal cost deployment
│   └── upload-profile-images.sh        # Image upload script
├── 📁 terraform/                       # Infrastructure as Code
│   ├── 📁 minimal-cost/                # Minimal cost setup
│   │   ├── main.tf                     # Main infrastructure
│   │   ├── variables.tf                # Input variables
│   │   └── outputs.tf                  # Output values
│   ├── main.tf                         # Full infrastructure
│   ├── variables.tf                    # Variables
│   ├── outputs.tf                      # Outputs
│   └── user_data.sh                    # EC2 setup script
├── 📁 ai-infrastructure/               # AI model setup
│   ├── 📁 models/                      # AI models
│   │   ├── 📁 serving/                 # Model serving
│   │   └── 📁 training/                # Model training
│   ├── 📁 configs/                     # Configuration files
│   ├── 📁 data/                        # Training data
│   └── 📁 scripts/                     # AI scripts
├── 📁 .github/                         # GitHub configuration
│   ├── 📁 workflows/                   # GitHub Actions
│   │   ├── deploy.yml                  # Basic deployment
│   │   ├── deploy-aws.yml              # AWS deployment
│   │   └── deploy-minimal-cost.yml     # Minimal deployment
│   ├── 📁 ISSUE_TEMPLATE/              # Issue templates
│   └── PULL_REQUEST_TEMPLATE.md        # PR template
├── 📁 dist/                            # Built files (generated)
│   ├── index.html                      # Built HTML
│   ├── 📁 assets/                      # Built assets
│   └── 📁 images/                      # Copied images
├── 📁 node_modules/                    # Dependencies (generated)
├── 📄 Configuration Files
│   ├── package.json                    # Project dependencies
│   ├── package-lock.json               # Dependency lock file
│   ├── vite.config.ts                  # Vite configuration
│   ├── tsconfig.json                   # TypeScript config
│   ├── tsconfig.app.json               # App TypeScript config
│   ├── tsconfig.node.json              # Node TypeScript config
│   ├── tailwind.config.js              # Tailwind CSS config
│   ├── postcss.config.js               # PostCSS config
│   ├── eslint.config.js                # ESLint configuration
│   ├── .gitignore                      # Git ignore rules
│   └── nginx.conf                      # Nginx configuration
├── 📄 Documentation
│   ├── README.md                       # Main documentation
│   ├── CONTRIBUTING.md                 # Contribution guide
│   ├── CHANGELOG.md                    # Version history
│   ├── LICENSE                         # Project license
│   ├── deployment-guide.md             # Deployment instructions
│   ├── aws-deployment-guide.md         # AWS deployment
│   ├── MINIMAL-COST-DEPLOYMENT-GUIDE.md
│   ├── CERTIFICATE-SETUP-GUIDE.md
│   ├── CLOUDFRONT-GUI-DEPLOYMENT-GUIDE.md
│   └── S3-ACCESS-FIX-GUIDE.md
└── 📄 Deployment Files
    └── deploy.sh                       # Local deployment script
```

## 🖼️ Image Directory Details

### Profile Images (`public/images/profile/`)
```
profile/
├── hero-profile.jpg          # Main profile photo for hero section
│                            # Size: 400x400px, Format: JPG, Max: 200KB
└── about-profile.jpg        # Profile photo for about section
                            # Size: 300x300px, Format: JPG, Max: 150KB
```

### Portfolio Images (`public/images/portfolio/`)
```
portfolio/
├── visionops.jpg            # VisionOps project screenshot
├── futureops.jpg            # FutureOps project screenshot
├── siem-stack.jpg           # SIEM project screenshot
├── kubernetes-automation.jpg # Kubernetes project screenshot
├── ai-anomaly-detection.jpg # AI project screenshot
└── network-monitoring.jpg   # Monitoring project screenshot
                            # Size: 800x600px, Format: JPG, Max: 300KB each
```

### Icons (`public/images/icons/`)
```
icons/
├── favicon.ico              # Website favicon (32x32px)
├── logo-192.png            # PWA icon (192x192px)
└── logo-512.png            # PWA icon (512x512px)
```

## 📂 How Images Are Used

### In React Components
```typescript
// Hero.tsx
<img src="/images/profile/hero-profile.jpg" alt="Profile" />

// About.tsx  
<img src="/images/profile/about-profile.jpg" alt="About" />

// Portfolio.tsx
<img src="/images/portfolio/visionops.jpg" alt="VisionOps" />
```

### In Static HTML
```html
<!-- Static version uses same paths -->
<img src="/images/profile/hero-profile.jpg" alt="Profile" />
```

### After Build (dist/)
```
dist/
├── index.html
├── assets/
│   ├── index-abc123.js
│   └── index-def456.css
└── images/                  # Copied from public/images/
    ├── profile/
    ├── portfolio/
    └── icons/
```

## 🚀 Deployment Structure

### Development Server
```
http://localhost:5173/
├── /                        # React app
├── /images/profile/         # Profile images
├── /images/portfolio/       # Portfolio images
└── /images/icons/           # Icons
```

### Production Server (Nginx)
```
/var/www/portfolio/
├── index.html               # Built React app
├── assets/                  # Built JS/CSS
└── images/                  # Static images
    ├── profile/
    ├── portfolio/
    └── icons/
```

### AWS S3 Structure
```
s3://yourdomain.com/
├── index.html
├── assets/
└── images/
    ├── profile/
    ├── portfolio/
    └── icons/
```

## 📝 Image Management Commands

### Add Your Images
```bash
# Create directories
mkdir -p public/images/{profile,portfolio,icons}

# Add your profile photos
cp your-profile-photo.jpg public/images/profile/hero-profile.jpg
cp your-about-photo.jpg public/images/profile/about-profile.jpg

# Add project screenshots
cp project1-screenshot.jpg public/images/portfolio/visionops.jpg
cp project2-screenshot.jpg public/images/portfolio/futureops.jpg
# ... add more project images
```

### Build and Deploy
```bash
# Development
npm run dev                  # Images served from public/

# Production build
npm run build               # Images copied to dist/images/

# Deploy to server
sudo cp -r dist/* /var/www/portfolio/
sudo systemctl reload nginx
```

## 🎯 Image Optimization Tips

### Recommended Sizes
- **Profile photos**: 400x400px (square)
- **Portfolio images**: 800x600px (4:3 ratio)
- **Icons**: 32x32px, 192x192px, 512x512px

### Compression
```bash
# Using ImageMagick
magick input.jpg -quality 85 -resize 800x600 output.jpg

# Using online tools
# - TinyPNG.com
# - Squoosh.app
# - Compressor.io
```

### File Formats
- **Photos**: JPG (smaller file size)
- **Graphics**: PNG (better quality)
- **Icons**: PNG or SVG
- **Modern**: WebP (best compression)

## 🔧 Nginx Configuration for Images

```nginx
# Cache images for 1 year
location ~* \.(jpg|jpeg|png|gif|ico|svg)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
    access_log off;
}

# Specific images directory
location /images/ {
    expires 1y;
    add_header Cache-Control "public, immutable";
    try_files $uri $uri/ =404;
}
```

This structure ensures your images are properly organized, efficiently served, and easily manageable across all deployment scenarios!