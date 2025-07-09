#!/bin/bash

# AWS Deployment Script for Portfolio with AI Assistant
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
TERRAFORM_DIR="$ROOT_DIR/terraform"

echo -e "${GREEN}🚀 AWS Deployment Script for Portfolio with AI Assistant${NC}"

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

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check if required tools are installed
    local missing_tools=()
    
    if ! command -v aws &> /dev/null; then
        missing_tools+=("aws-cli")
    fi
    
    if ! command -v terraform &> /dev/null; then
        missing_tools+=("terraform")
    fi
    
    if ! command -v node &> /dev/null; then
        missing_tools+=("node.js")
    fi
    
    if ! command -v npm &> /dev/null; then
        missing_tools+=("npm")
    fi
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        print_error "Missing required tools: ${missing_tools[*]}"
        echo "Please install the missing tools and try again."
        exit 1
    fi
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        print_error "AWS credentials not configured or invalid"
        echo "Please run 'aws configure' to set up your credentials."
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

# Function to validate inputs
validate_inputs() {
    print_status "Validating inputs..."
    
    if [ -z "$DOMAIN_NAME" ]; then
        print_error "DOMAIN_NAME is required"
        echo "Usage: DOMAIN_NAME=yourdomain.com $0"
        exit 1
    fi
    
    if [ -z "$AWS_REGION" ]; then
        AWS_REGION="us-east-1"
        print_warning "AWS_REGION not set, using default: $AWS_REGION"
    fi
    
    if [ -z "$INSTANCE_TYPE" ]; then
        INSTANCE_TYPE="t3.small"
        print_warning "INSTANCE_TYPE not set, using default: $INSTANCE_TYPE"
    fi
    
    if [ -z "$PUBLIC_KEY_PATH" ]; then
        PUBLIC_KEY_PATH="$HOME/.ssh/id_rsa.pub"
        print_warning "PUBLIC_KEY_PATH not set, using default: $PUBLIC_KEY_PATH"
    fi
    
    if [ ! -f "$PUBLIC_KEY_PATH" ]; then
        print_error "Public key file not found: $PUBLIC_KEY_PATH"
        echo "Please generate SSH keys or specify correct path."
        exit 1
    fi
    
    print_success "Input validation passed"
}

# Function to build the application
build_application() {
    print_status "Building application..."
    
    cd "$ROOT_DIR"
    
    # Install dependencies
    npm ci
    
    # Build the project
    npm run build
    
    if [ ! -d "dist" ]; then
        print_error "Build failed - dist directory not found"
        exit 1
    fi
    
    print_success "Application built successfully"
}

# Function to initialize Terraform
init_terraform() {
    print_status "Initializing Terraform..."
    
    cd "$TERRAFORM_DIR"
    
    # Initialize Terraform
    terraform init
    
    print_success "Terraform initialized"
}

# Function to plan Terraform deployment
plan_terraform() {
    print_status "Planning Terraform deployment..."
    
    cd "$TERRAFORM_DIR"
    
    # Read public key
    PUBLIC_KEY=$(cat "$PUBLIC_KEY_PATH")
    
    # Create terraform.tfvars file
    cat > terraform.tfvars << EOF
domain_name = "$DOMAIN_NAME"
aws_region = "$AWS_REGION"
instance_type = "$INSTANCE_TYPE"
public_key = "$PUBLIC_KEY"
environment = "production"
EOF
    
    # Plan deployment
    terraform plan -var-file="terraform.tfvars"
    
    print_success "Terraform plan completed"
}

# Function to apply Terraform deployment
apply_terraform() {
    print_status "Applying Terraform deployment..."
    
    cd "$TERRAFORM_DIR"
    
    # Apply deployment
    terraform apply -var-file="terraform.tfvars" -auto-approve
    
    # Get outputs
    S3_BUCKET=$(terraform output -raw s3_bucket_name)
    CLOUDFRONT_DIST_ID=$(terraform output -raw cloudfront_distribution_id)
    EC2_IP=$(terraform output -raw ec2_public_ip)
    NAME_SERVERS=$(terraform output -json route53_name_servers | jq -r '.[]')
    
    print_success "Terraform deployment completed"
    
    # Save outputs for later use
    cat > "$ROOT_DIR/deployment-outputs.json" << EOF
{
    "s3_bucket": "$S3_BUCKET",
    "cloudfront_distribution_id": "$CLOUDFRONT_DIST_ID",
    "ec2_ip": "$EC2_IP",
    "domain_name": "$DOMAIN_NAME",
    "api_url": "https://api.$DOMAIN_NAME"
}
EOF
}

# Function to deploy website to S3
deploy_website() {
    print_status "Deploying website to S3..."
    
    cd "$ROOT_DIR"
    
    # Upload to S3
    aws s3 sync dist/ "s3://$S3_BUCKET" --delete
    
    # Invalidate CloudFront cache
    aws cloudfront create-invalidation \
        --distribution-id "$CLOUDFRONT_DIST_ID" \
        --paths "/*"
    
    print_success "Website deployed to S3 and CloudFront cache invalidated"
}

# Function to update chatbot configuration
update_chatbot_config() {
    print_status "Updating chatbot configuration..."
    
    cd "$ROOT_DIR"
    
    # Update ChatBot.tsx to use the new API URL
    sed -i.bak "s|http://localhost:8001|https://api.$DOMAIN_NAME|g" src/components/ChatBot.tsx
    
    # Rebuild with updated configuration
    npm run build
    
    # Re-deploy to S3
    aws s3 sync dist/ "s3://$S3_BUCKET" --delete
    
    # Invalidate CloudFront cache again
    aws cloudfront create-invalidation \
        --distribution-id "$CLOUDFRONT_DIST_ID" \
        --paths "/*"
    
    print_success "Chatbot configuration updated and redeployed"
}

# Function to setup GitHub secrets
setup_github_secrets() {
    print_status "Setting up GitHub secrets..."
    
    if command -v gh &> /dev/null; then
        # Set GitHub secrets using GitHub CLI
        gh secret set AWS_ACCESS_KEY_ID --body "$(aws configure get aws_access_key_id)"
        gh secret set AWS_SECRET_ACCESS_KEY --body "$(aws configure get aws_secret_access_key)"
        gh secret set S3_BUCKET_NAME --body "$S3_BUCKET"
        # Copy AI model files to EC2  
        scp -i ${{ secrets.EC2_KEY }} -r ai-infrastructure/ ec2-user@${{ secrets.EC2_IP }}:/home/ec2-user/
        
        print_success "GitHub secrets configured"
    else
        print_warning "GitHub CLI not found. Please manually set the following secrets:"
        echo "  - AWS_ACCESS_KEY_ID"
        echo "  - AWS_SECRET_ACCESS_KEY"
        echo "  - S3_BUCKET_NAME: $S3_BUCKET"
        echo "  - CLOUDFRONT_DISTRIBUTION_ID: $CLOUDFRONT_DIST_ID"
        echo "  - EC2_IP: $EC2_IP"
    fi
}

# Function to test deployment
test_deployment() {
    print_status "Testing deployment..."
    
    # Test website
    if curl -s -o /dev/null -w "%{http_code}" "https://$DOMAIN_NAME" | grep -q "200"; then
        print_success "Website is accessible"
    else
        print_warning "Website may not be accessible yet (DNS propagation can take time)"
    fi
    
    # Test API (may fail initially due to DNS)
    if curl -s -o /dev/null -w "%{http_code}" "https://api.$DOMAIN_NAME/health" | grep -q "200"; then
        print_success "AI API is accessible"
    else
        print_warning "AI API may not be accessible yet (DNS propagation can take time)"
    fi
    
    # Test direct EC2 access
    if curl -s -o /dev/null -w "%{http_code}" "http://$EC2_IP:8001/health" | grep -q "200"; then
        print_success "AI API is running on EC2"
    else
        print_warning "AI API may still be starting up on EC2"
    fi
}

# Function to print deployment summary
print_deployment_summary() {
    echo ""
    echo -e "${GREEN}🎉 Deployment Summary${NC}"
    echo "===================="
    echo ""
    echo -e "${BLUE}Website URL:${NC} https://$DOMAIN_NAME"
    echo -e "${BLUE}API URL:${NC} https://api.$DOMAIN_NAME"
    echo -e "${BLUE}EC2 IP:${NC} $EC2_IP"
    echo ""
    echo -e "${YELLOW}📋 Next Steps:${NC}"
    echo "1. Update your GoDaddy DNS settings with these nameservers:"
    echo "$NAME_SERVERS" | sed 's/^/   - /'
    echo ""
    echo "2. Wait 24-48 hours for DNS propagation"
    echo ""
    echo "3. Test your website and AI assistant"
    echo ""
    echo -e "${YELLOW}💰 Estimated Monthly Cost:${NC}"
    case $INSTANCE_TYPE in
        "t3.small")
            echo "   - Total: ~$35-45/month"
            ;;
        "t3.medium")
            echo "   - Total: ~$50-60/month"
            ;;
        *)
            echo "   - Total: ~$60-75/month"
            ;;
    esac
    echo ""
    echo -e "${YELLOW}🔧 Management Commands:${NC}"
    echo "   - SSH to EC2: ssh -i ~/.ssh/id_rsa ec2-user@$EC2_IP"
    echo "   - Manage AI service: /opt/ai-model/manage.sh {start|stop|restart|status|logs}"
    echo "   - View logs: sudo journalctl -u ai-model -f"
    echo ""
    echo -e "${GREEN}✅ Deployment completed successfully!${NC}"
}

# Function to cleanup on error
cleanup_on_error() {
    print_error "Deployment failed. Cleaning up..."
    
    cd "$TERRAFORM_DIR"
    
    # Optionally destroy resources (uncomment if needed)
    # terraform destroy -var-file="terraform.tfvars" -auto-approve
    
    print_warning "Please check the error messages above and try again."
}

# Main deployment function
main() {
    # Set error handling
    trap cleanup_on_error ERR
    
    # Check if help is requested
    if [[ "$1" == "--help" || "$1" == "-h" ]]; then
        echo "AWS Deployment Script for Portfolio with AI Assistant"
        echo ""
        echo "Usage:"
        echo "  DOMAIN_NAME=yourdomain.com $0"
        echo ""
        echo "Environment Variables:"
        echo "  DOMAIN_NAME      - Your domain name (required)"
        echo "  AWS_REGION       - AWS region (default: us-east-1)"
        echo "  INSTANCE_TYPE    - EC2 instance type (default: t3.small)"
        echo "  PUBLIC_KEY_PATH  - Path to SSH public key (default: ~/.ssh/id_rsa.pub)"
        echo ""
        echo "Examples:"
        echo "  DOMAIN_NAME=example.com $0"
        echo "  DOMAIN_NAME=example.com AWS_REGION=us-west-2 INSTANCE_TYPE=t3.medium $0"
        exit 0
    fi
    
    # Run deployment steps
    check_prerequisites
    validate_inputs
    build_application
    init_terraform
    plan_terraform
    
    # Confirm before applying
    echo ""
    read -p "Do you want to proceed with the deployment? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_warning "Deployment cancelled by user"
        exit 0
    fi
    
    apply_terraform
    deploy_website
    update_chatbot_config
    setup_github_secrets
    test_deployment
    print_deployment_summary
}

# Run main function
main "$@"