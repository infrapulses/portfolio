#!/bin/bash

# Minimal Cost AWS Deployment Script
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
TERRAFORM_DIR="$ROOT_DIR/terraform/minimal-cost"

echo -e "${GREEN}💰 Minimal Cost AWS Deployment - Portfolio Website Only${NC}"
echo -e "${BLUE}Estimated monthly cost: $2-5 (vs $35-45 with AI)${NC}"

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
    
    if [ -z "$ALERT_EMAIL" ]; then
        print_error "ALERT_EMAIL is required for billing alerts"
        echo "Usage: DOMAIN_NAME=yourdomain.com ALERT_EMAIL=your@email.com $0"
        exit 1
    fi
    
    if [ -n "$SSL_CERTIFICATE_ARN" ]; then
        print_status "Using existing SSL certificate: $SSL_CERTIFICATE_ARN"
    fi
    
    if [ -z "$AWS_REGION" ]; then
        AWS_REGION="us-east-1"
        print_warning "AWS_REGION not set, using default: $AWS_REGION"
    fi
    
    print_success "Input validation passed"
}

# Function to update chatbot (disable AI features)
update_chatbot_for_static() {
    print_status "Updating chatbot for static-only deployment..."
    
    cd "$ROOT_DIR"
    
    # Create a backup of the original ChatBot.tsx
    cp src/components/ChatBot.tsx src/components/ChatBot.tsx.backup
    
    # Update ChatBot.tsx to disable AI model checking
    cat > src/components/ChatBot.tsx << 'EOF'
import React, { useState, useRef, useEffect } from 'react';
import { MessageCircle, Send, X, Bot, User, Minimize2 } from 'lucide-react';

interface Message {
  id: number;
  type: 'user' | 'bot';
  content: string;
  timestamp: Date;
}

const ChatBot = () => {
  const [isOpen, setIsOpen] = useState(false);
  const [isMinimized, setIsMinimized] = useState(false);
  const [messages, setMessages] = useState<Message[]>([
    {
      id: 1,
      type: 'bot',
      content: "Hi! I'm Kamal's Assistant. I can help you learn more about his skills, experience, and projects. This is a rule-based assistant - for the AI-powered version, please contact Kamal directly. What would you like to know?",
      timestamp: new Date()
    }
  ]);
  const [inputValue, setInputValue] = useState('');
  const [isTyping, setIsTyping] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  const predefinedResponses = {
    'skills': "I specialize in DevOps and SRE with expertise in Linux, Kubernetes, AWS, Grafana, Prometheus, and Wazuh SIEM. I'm also experienced with infrastructure automation, monitoring, and AI-driven operations.",
    'experience': "I have over 3 years of experience in infrastructure and system operations, working with enterprise environments. I've built monitoring systems, automated deployments, and managed critical infrastructure.",
    'projects': "I've worked on projects like VisionOps (monitoring platform), FutureOps (predictive infrastructure), Kubernetes automation, and SIEM implementations. You can see my portfolio above for detailed examples.",
    'contact': "You can reach me through the contact form above, or directly at techey.kamal@gmail.com. I'm always open to discussing new opportunities!",
    'ai': "I'm passionate about AI for infrastructure operations. I've worked with anomaly detection, predictive analytics, and AI-driven monitoring solutions for infrastructure management. For the full AI-powered assistant, please contact me directly.",
    'technologies': "I work with DevOps technologies including Kubernetes, Docker, AWS, Grafana, Prometheus, Wazuh, Terraform, Ansible, and various monitoring and automation tools.",
    'hello': "Hello! Nice to meet you! I'm here to help you learn more about my background and experience. What would you like to know?",
    'hire': "I'm always open to new DevOps and SRE opportunities! Feel free to reach out through the contact form or email me directly. I'd love to discuss how I can contribute to your infrastructure.",
    'resume': "You can view my detailed resume in the Resume section above, which includes my professional experience, education, and certifications in DevOps and infrastructure engineering.",
    'default': "That's an interesting question! I can tell you about my DevOps skills, infrastructure experience, projects, resume, or how to get in touch. What specifically would you like to know more about?"
  };

  const getResponse = (input: string): string => {
    const lowercaseInput = input.toLowerCase();
    
    if (lowercaseInput.includes('skill') || lowercaseInput.includes('technology') || lowercaseInput.includes('tech')) {
      return predefinedResponses.skills;
    } else if (lowercaseInput.includes('experience') || lowercaseInput.includes('background')) {
      return predefinedResponses.experience;
    } else if (lowercaseInput.includes('project') || lowercaseInput.includes('work') || lowercaseInput.includes('portfolio')) {
      return predefinedResponses.projects;
    } else if (lowercaseInput.includes('contact') || lowercaseInput.includes('email') || lowercaseInput.includes('reach')) {
      return predefinedResponses.contact;
    } else if (lowercaseInput.includes('ai') || lowercaseInput.includes('artificial') || lowercaseInput.includes('machine learning') || lowercaseInput.includes('ml')) {
      return predefinedResponses.ai;
    } else if (lowercaseInput.includes('hello') || lowercaseInput.includes('hi') || lowercaseInput.includes('hey')) {
      return predefinedResponses.hello;
    } else if (lowercaseInput.includes('hire') || lowercaseInput.includes('job') || lowercaseInput.includes('opportunity')) {
      return predefinedResponses.hire;
    } else if (lowercaseInput.includes('resume') || lowercaseInput.includes('cv')) {
      return predefinedResponses.resume;
    } else {
      return predefinedResponses.default;
    }
  };

  const handleSend = async () => {
    if (!inputValue.trim()) return;

    const userMessage: Message = {
      id: messages.length + 1,
      type: 'user',
      content: inputValue,
      timestamp: new Date()
    };

    setMessages(prev => [...prev, userMessage]);
    setInputValue('');
    setIsTyping(true);

    // Simulate response delay
    setTimeout(() => {
      const botResponse: Message = {
        id: messages.length + 2,
        type: 'bot',
        content: getResponse(inputValue),
        timestamp: new Date()
      };

      setMessages(prev => [...prev, botResponse]);
      setIsTyping(false);
    }, 1500);
  };

  const handleKeyPress = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSend();
    }
  };

  if (!isOpen) {
    return (
      <div className="fixed bottom-6 right-6 z-50">
        <button
          onClick={() => setIsOpen(true)}
          className="w-14 h-14 bg-gradient-to-r from-blue-600 to-purple-600 hover:from-blue-700 hover:to-purple-700 text-white rounded-full shadow-lg hover:shadow-xl flex items-center justify-center transition-all duration-300 transform hover:scale-105"
        >
          <MessageCircle className="w-6 h-6" />
        </button>
      </div>
    );
  }

  return (
    <div className={`fixed bottom-6 right-6 w-96 bg-white rounded-2xl shadow-2xl border border-gray-200 z-50 transition-all duration-300 ${
      isMinimized ? 'h-16' : 'h-96'
    }`}>
      {/* Header */}
      <div className="bg-gradient-to-r from-blue-600 to-purple-600 text-white p-4 rounded-t-2xl flex items-center justify-between">
        <div className="flex items-center space-x-3">
          <div className="w-8 h-8 bg-white/20 rounded-full flex items-center justify-center">
            <Bot className="w-5 h-5" />
          </div>
          <div>
            <h3 className="font-semibold">Kamal's Assistant</h3>
            <p className="text-xs opacity-80">Rule-based Responses</p>
          </div>
        </div>
        <div className="flex items-center space-x-2">
          <button
            onClick={() => setIsMinimized(!isMinimized)}
            className="p-1 hover:bg-white/20 rounded transition-colors"
          >
            <Minimize2 className="w-4 h-4" />
          </button>
          <button
            onClick={() => setIsOpen(false)}
            className="p-1 hover:bg-white/20 rounded transition-colors"
          >
            <X className="w-4 h-4" />
          </button>
        </div>
      </div>

      {!isMinimized && (
        <>
          {/* Messages */}
          <div className="h-64 overflow-y-auto p-4 space-y-4">
            {messages.map((message) => (
              <div
                key={message.id}
                className={`flex ${message.type === 'user' ? 'justify-end' : 'justify-start'}`}
              >
                <div
                  className={`max-w-xs px-4 py-2 rounded-lg ${
                    message.type === 'user'
                      ? 'bg-gradient-to-r from-blue-600 to-purple-600 text-white'
                      : 'bg-gray-100 text-gray-800'
                  }`}
                >
                  <div className="flex items-center space-x-2 mb-1">
                    {message.type === 'bot' ? <Bot className="w-4 h-4" /> : <User className="w-4 h-4" />}
                    <span className="text-xs opacity-70">
                      {message.timestamp.toLocaleTimeString()}
                    </span>
                  </div>
                  <p className="text-sm leading-relaxed">{message.content}</p>
                </div>
              </div>
            ))}
            
            {isTyping && (
              <div className="flex justify-start">
                <div className="bg-gray-100 px-4 py-2 rounded-lg">
                  <div className="flex items-center space-x-2">
                    <Bot className="w-4 h-4" />
                    <div className="flex space-x-1">
                      <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce"></div>
                      <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce delay-100"></div>
                      <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce delay-200"></div>
                    </div>
                  </div>
                </div>
              </div>
            )}
            <div ref={messagesEndRef} />
          </div>

          {/* Input */}
          <div className="border-t border-gray-200 p-4">
            <div className="flex space-x-2">
              <input
                type="text"
                value={inputValue}
                onChange={(e) => setInputValue(e.target.value)}
                onKeyPress={handleKeyPress}
                placeholder="Ask me anything..."
                className="flex-1 px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-sm"
              />
              <button
                onClick={handleSend}
                disabled={!inputValue.trim()}
                className="bg-gradient-to-r from-blue-600 to-purple-600 hover:from-blue-700 hover:to-purple-700 disabled:opacity-50 disabled:cursor-not-allowed text-white p-2 rounded-lg transition-all duration-300"
              >
                <Send className="w-4 h-4" />
              </button>
            </div>
            <div className="mt-2 text-xs text-gray-500 text-center">
              💡 For AI-powered responses, contact me directly
            </div>
          </div>
        </>
      )}
    </div>
  );
};

export default ChatBot;
EOF

    print_success "Chatbot updated for static-only deployment"
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
    
    # Create terraform.tfvars file
    cat > terraform.tfvars << EOF
domain_name = "$DOMAIN_NAME"
aws_region = "$AWS_REGION"
alert_email = "$ALERT_EMAIL"
environment = "production"
$([ -n "$SSL_CERTIFICATE_ARN" ] && echo "ssl_certificate_arn = \"$SSL_CERTIFICATE_ARN\"")
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
    NAME_SERVERS=$(terraform output -json route53_name_servers | jq -r '.[]')
    
    print_success "Terraform deployment completed"
    
    # Save outputs for later use
    cat > "$ROOT_DIR/deployment-outputs.json" << EOF
{
    "s3_bucket": "$S3_BUCKET",
    "cloudfront_distribution_id": "$CLOUDFRONT_DIST_ID",
    "domain_name": "$DOMAIN_NAME",
    "deployment_type": "minimal-cost"
}
EOF
}

# Function to deploy website to S3
deploy_website() {
    print_status "Deploying website to S3..."
    
    cd "$ROOT_DIR"
    
    # Upload to S3 with optimized caching
    aws s3 sync dist/ "s3://$S3_BUCKET" \
        --delete \
        --cache-control "public, max-age=31536000" \
        --exclude "*.html" \
        --exclude "service-worker.js"
    
    # Upload HTML files with shorter cache
    aws s3 sync dist/ "s3://$S3_BUCKET" \
        --delete \
        --cache-control "public, max-age=0, must-revalidate" \
        --include "*.html" \
        --include "service-worker.js"
    
    # Invalidate CloudFront cache
    aws cloudfront create-invalidation \
        --distribution-id "$CLOUDFRONT_DIST_ID" \
        --paths "/*"
    
    print_success "Website deployed to S3 and CloudFront cache invalidated"
}

# Function to setup GitHub secrets for minimal deployment
setup_github_secrets() {
    print_status "Setting up GitHub secrets..."
    
    if command -v gh &> /dev/null; then
        # Set GitHub secrets using GitHub CLI
        gh secret set AWS_ACCESS_KEY_ID --body "$(aws configure get aws_access_key_id)"
        gh secret set AWS_SECRET_ACCESS_KEY --body "$(aws configure get aws_secret_access_key)"
        gh secret set S3_BUCKET_NAME --body "$S3_BUCKET"
        gh secret set CLOUDFRONT_DISTRIBUTION_ID --body "$CLOUDFRONT_DIST_ID"
        gh secret set DOMAIN_NAME --body "$DOMAIN_NAME"
        
        print_success "GitHub secrets configured"
    else
        print_warning "GitHub CLI not found. Please manually set the following secrets:"
        echo "  - AWS_ACCESS_KEY_ID"
        echo "  - AWS_SECRET_ACCESS_KEY"
        echo "  - S3_BUCKET_NAME: $S3_BUCKET"
        echo "  - CLOUDFRONT_DISTRIBUTION_ID: $CLOUDFRONT_DIST_ID"
        echo "  - DOMAIN_NAME: $DOMAIN_NAME"
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
    
    # Test direct S3 access
    if curl -s -o /dev/null -w "%{http_code}" "http://$S3_BUCKET.s3-website-$AWS_REGION.amazonaws.com" | grep -q "200"; then
        print_success "S3 website is accessible"
    else
        print_warning "S3 website may not be accessible yet"
    fi
}

# Function to print deployment summary
print_deployment_summary() {
    echo ""
    echo -e "${GREEN}🎉 Minimal Cost Deployment Summary${NC}"
    echo "=================================="
    echo ""
    echo -e "${BLUE}Website URL:${NC} https://$DOMAIN_NAME"
    echo -e "${BLUE}S3 Bucket:${NC} $S3_BUCKET"
    echo -e "${BLUE}CloudFront Distribution:${NC} $CLOUDFRONT_DIST_ID"
    echo ""
    echo -e "${YELLOW}📋 Next Steps:${NC}"
    echo "1. Update your GoDaddy DNS settings with these nameservers:"
    echo "$NAME_SERVERS" | sed 's/^/   - /'
    echo ""
    echo "2. Wait 24-48 hours for DNS propagation"
    echo ""
    echo "3. Test your website"
    echo ""
    echo -e "${GREEN}💰 Cost Savings:${NC}"
    echo "   - Monthly cost: ~$2-5 (vs $35-45 with AI)"
    echo "   - Annual savings: ~$360-480"
    echo "   - Features removed: AI Assistant, EC2, Load Balancer"
    echo "   - Features kept: Professional website, SSL, CDN, Custom domain"
    echo ""
    echo -e "${YELLOW}🔧 Management:${NC}"
    echo "   - Deploy updates: Push to GitHub (automated)"
    echo "   - Monitor costs: AWS Billing Dashboard"
    echo "   - Billing alerts: Configured for >$10/month"
    echo ""
    echo -e "${BLUE}💡 To add AI later:${NC}"
    echo "   - Use the full terraform configuration"
    echo "   - Deploy EC2 instance with AI model"
    echo "   - Update chatbot configuration"
    echo ""
    echo -e "${GREEN}✅ Minimal cost deployment completed successfully!${NC}"
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
        echo "Minimal Cost AWS Deployment Script"
        echo ""
        echo "Usage:"
        echo "  DOMAIN_NAME=yourdomain.com ALERT_EMAIL=your@email.com $0"
        echo ""
        echo "Environment Variables:"
        echo "  DOMAIN_NAME  - Your domain name (required)"
        echo "  ALERT_EMAIL  - Email for billing alerts (required)"
        echo "  AWS_REGION   - AWS region (default: us-east-1)"
        echo ""
        echo "Examples:"
        echo "  DOMAIN_NAME=example.com ALERT_EMAIL=admin@example.com $0"
        exit 0
    fi
    
    # Run deployment steps
    check_prerequisites
    validate_inputs
    update_chatbot_for_static
    build_application
    init_terraform
    plan_terraform
    
    # Confirm before applying
    echo ""
    echo -e "${YELLOW}💰 This will deploy a minimal cost setup (~$2-5/month)${NC}"
    echo -e "${YELLOW}❌ AI Assistant will be disabled to save costs${NC}"
    echo ""
    read -p "Do you want to proceed with the minimal cost deployment? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_warning "Deployment cancelled by user"
        exit 0
    fi
    
    apply_terraform
    deploy_website
    setup_github_secrets
    test_deployment
    print_deployment_summary
}

# Run main function
main "$@"