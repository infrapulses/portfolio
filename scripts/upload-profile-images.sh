#!/bin/bash

# Script to upload profile images to S3 bucket
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

echo -e "${GREEN}📸 Profile Image Upload Script${NC}"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if AWS CLI is installed
check_aws_cli() {
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI not found. Please install AWS CLI first."
        exit 1
    fi
    
    # Check if AWS credentials are configured
    if ! aws sts get-caller-identity &> /dev/null; then
        print_error "AWS credentials not configured. Please run 'aws configure' first."
        exit 1
    fi
    
    print_success "AWS CLI is configured and ready"
}

# Get S3 bucket name from Terraform output
get_bucket_name() {
    if [ -f "$ROOT_DIR/terraform/terraform.tfstate" ]; then
        ASSETS_BUCKET=$(cd "$ROOT_DIR/terraform" && terraform output -raw s3_assets_bucket_name 2>/dev/null)
    elif [ -f "$ROOT_DIR/terraform/minimal-cost/terraform.tfstate" ]; then
        ASSETS_BUCKET=$(cd "$ROOT_DIR/terraform/minimal-cost" && terraform output -raw s3_bucket_name 2>/dev/null)
    fi
    
    if [ -z "$ASSETS_BUCKET" ]; then
        print_error "Could not determine S3 bucket name from Terraform output"
        echo "Please provide the bucket name manually:"
        read -p "Enter S3 bucket name: " ASSETS_BUCKET
    fi
    
    print_status "Using S3 bucket: $ASSETS_BUCKET"
}

# Create profile directory structure
create_profile_structure() {
    print_status "Creating profile image directory structure..."
    
    mkdir -p "$ROOT_DIR/assets/profile"
    mkdir -p "$ROOT_DIR/assets/gallery"
    mkdir -p "$ROOT_DIR/assets/projects"
    
    print_success "Directory structure created"
}

# Download sample images if none exist
download_sample_images() {
    print_status "Checking for profile images..."
    
    PROFILE_DIR="$ROOT_DIR/assets/profile"
    
    # Hero profile image
    if [ ! -f "$PROFILE_DIR/kamal-raj-profile.jpg" ]; then
        print_warning "Hero profile image not found. Downloading sample image..."
        curl -L "https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg?auto=compress&cs=tinysrgb&w=400&h=400&fit=crop&crop=face" \
             -o "$PROFILE_DIR/kamal-raj-profile.jpg"
        print_success "Downloaded hero profile image"
    fi
    
    # About section profile image
    if [ ! -f "$PROFILE_DIR/kamal-raj-about.jpg" ]; then
        print_warning "About profile image not found. Downloading sample image..."
        curl -L "https://images.pexels.com/photos/3861969/pexels-photo-3861969.jpeg?auto=compress&cs=tinysrgb&w=600&h=600&fit=crop" \
             -o "$PROFILE_DIR/kamal-raj-about.jpg"
        print_success "Downloaded about profile image"
    fi
    
    print_status "Profile images ready for upload"
}

# Upload images to S3
upload_images() {
    print_status "Uploading profile images to S3..."
    
    PROFILE_DIR="$ROOT_DIR/assets/profile"
    
    # Upload hero profile image
    if [ -f "$PROFILE_DIR/kamal-raj-profile.jpg" ]; then
        aws s3 cp "$PROFILE_DIR/kamal-raj-profile.jpg" \
            "s3://$ASSETS_BUCKET/profile/kamal-raj-profile.jpg" \
            --content-type "image/jpeg" \
            --cache-control "public, max-age=31536000"
        print_success "Uploaded hero profile image"
    fi
    
    # Upload about profile image
    if [ -f "$PROFILE_DIR/kamal-raj-about.jpg" ]; then
        aws s3 cp "$PROFILE_DIR/kamal-raj-about.jpg" \
            "s3://$ASSETS_BUCKET/profile/kamal-raj-about.jpg" \
            --content-type "image/jpeg" \
            --cache-control "public, max-age=31536000"
        print_success "Uploaded about profile image"
    fi
    
    # Upload any additional images in the profile directory
    for img in "$PROFILE_DIR"/*.{jpg,jpeg,png,webp}; do
        if [ -f "$img" ]; then
            filename=$(basename "$img")
            if [[ "$filename" != "kamal-raj-profile.jpg" && "$filename" != "kamal-raj-about.jpg" ]]; then
                aws s3 cp "$img" \
                    "s3://$ASSETS_BUCKET/profile/$filename" \
                    --content-type "image/jpeg" \
                    --cache-control "public, max-age=31536000"
                print_success "Uploaded additional image: $filename"
            fi
        fi
    done
}

# Update source code with correct S3 URLs
update_source_code() {
    print_status "Updating source code with S3 URLs..."
    
    # Update Hero component
    sed -i.bak "s|https://your-s3-bucket-name.s3.amazonaws.com|https://$ASSETS_BUCKET.s3.amazonaws.com|g" \
        "$ROOT_DIR/src/components/Hero.tsx"
    
    # Update About component
    sed -i.bak "s|https://your-s3-bucket-name.s3.amazonaws.com|https://$ASSETS_BUCKET.s3.amazonaws.com|g" \
        "$ROOT_DIR/src/components/About.tsx"
    
    # Remove backup files
    rm -f "$ROOT_DIR/src/components/Hero.tsx.bak"
    rm -f "$ROOT_DIR/src/components/About.tsx.bak"
    
    print_success "Source code updated with correct S3 URLs"
}

# Verify uploads
verify_uploads() {
    print_status "Verifying uploaded images..."
    
    # Check hero profile image
    if aws s3 ls "s3://$ASSETS_BUCKET/profile/kamal-raj-profile.jpg" &>/dev/null; then
        print_success "✅ Hero profile image verified"
        echo "   URL: https://$ASSETS_BUCKET.s3.amazonaws.com/profile/kamal-raj-profile.jpg"
    else
        print_error "❌ Hero profile image not found"
    fi
    
    # Check about profile image
    if aws s3 ls "s3://$ASSETS_BUCKET/profile/kamal-raj-about.jpg" &>/dev/null; then
        print_success "✅ About profile image verified"
        echo "   URL: https://$ASSETS_BUCKET.s3.amazonaws.com/profile/kamal-raj-about.jpg"
    else
        print_error "❌ About profile image not found"
    fi
    
    # List all profile images
    print_status "All profile images in S3:"
    aws s3 ls "s3://$ASSETS_BUCKET/profile/" --human-readable
}

# Print usage instructions
print_usage() {
    echo ""
    echo -e "${GREEN}🎉 Profile Images Upload Completed!${NC}"
    echo ""
    echo -e "${YELLOW}📋 What was done:${NC}"
    echo "✅ Created local assets directory structure"
    echo "✅ Downloaded sample profile images (if needed)"
    echo "✅ Uploaded images to S3 bucket: $ASSETS_BUCKET"
    echo "✅ Updated source code with correct S3 URLs"
    echo "✅ Verified all uploads"
    echo ""
    echo -e "${YELLOW}🔄 Next Steps:${NC}"
    echo "1. Replace sample images with your actual photos:"
    echo "   - Hero image: $ROOT_DIR/assets/profile/kamal-raj-profile.jpg"
    echo "   - About image: $ROOT_DIR/assets/profile/kamal-raj-about.jpg"
    echo ""
    echo "2. Re-run this script to upload your custom images:"
    echo "   ./scripts/upload-profile-images.sh"
    echo ""
    echo "3. Build and deploy your website:"
    echo "   npm run build"
    echo "   # Deploy using your preferred method"
    echo ""
    echo -e "${YELLOW}💡 Image Guidelines:${NC}"
    echo "• Hero image: 400x400px, square, professional headshot"
    echo "• About image: 600x600px, square or portrait, casual/professional"
    echo "• Format: JPG or PNG, optimized for web"
    echo "• Size: Under 500KB each for fast loading"
    echo ""
    echo -e "${BLUE}🔗 Image URLs:${NC}"
    echo "Hero: https://$ASSETS_BUCKET.s3.amazonaws.com/profile/kamal-raj-profile.jpg"
    echo "About: https://$ASSETS_BUCKET.s3.amazonaws.com/profile/kamal-raj-about.jpg"
}

# Main execution
main() {
    # Check if help is requested
    if [[ "$1" == "--help" || "$1" == "-h" ]]; then
        echo "Profile Image Upload Script"
        echo ""
        echo "Usage: $0 [options]"
        echo ""
        echo "Options:"
        echo "  --help, -h    Show this help message"
        echo "  --verify      Only verify existing uploads"
        echo ""
        echo "This script will:"
        echo "1. Create local assets directory structure"
        echo "2. Download sample images if none exist"
        echo "3. Upload images to S3 bucket"
        echo "4. Update source code with correct URLs"
        echo "5. Verify all uploads"
        exit 0
    fi
    
    # Verify only mode
    if [[ "$1" == "--verify" ]]; then
        check_aws_cli
        get_bucket_name
        verify_uploads
        exit 0
    fi
    
    # Full execution
    check_aws_cli
    get_bucket_name
    create_profile_structure
    download_sample_images
    upload_images
    update_source_code
    verify_uploads
    print_usage
}

# Run main function
main "$@"