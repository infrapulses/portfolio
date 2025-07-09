#!/bin/bash

# User data script for EC2 instance setup
# This script installs and configures the AI model server

set -e

# Variables
DOMAIN_NAME="${domain_name}"
LOG_FILE="/var/log/user-data.log"

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE
}

log "Starting user data script execution"

# Update system
log "Updating system packages"
yum update -y

# Install required packages
log "Installing required packages"
yum install -y \
    python3 \
    python3-pip \
    git \
    nginx \
    htop \
    curl \
    wget \
    unzip \
    amazon-cloudwatch-agent

# Install Docker
log "Installing Docker"
amazon-linux-extras install docker -y
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user

# Install Node.js (for potential future use)
log "Installing Node.js"
curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
yum install -y nodejs

# Create application directory
log "Creating application directory"
mkdir -p /opt/ai-model
chown ec2-user:ec2-user /opt/ai-model

# Clone your repository
cd /home/ec2-user
git clone https://github.com/infrapulses/portfolio-website.git

# Setup AI model service
cd portfolio-website/ai-infrastructure

# Install Python dependencies
log "Installing Python dependencies"
pip3 install --upgrade pip

# Create requirements file
cat > /opt/ai-model/requirements.txt << 'EOF'
torch>=2.0.0
transformers>=4.30.0
fastapi>=0.100.0
uvicorn>=0.23.0
pydantic>=2.0.0
pandas>=2.0.0
numpy>=1.24.0
scikit-learn>=1.3.0
mlflow>=2.6.0
python-dotenv>=1.0.0
requests>=2.31.0
aiofiles>=23.0.0
python-multipart>=0.0.6
structlog>=23.1.0
prometheus-client>=0.17.1
EOF

pip3 install -r /opt/ai-model/requirements.txt

# Create AI model service script
log "Creating AI model service"
cat > /opt/ai-model/app.py << 'EOF'
#!/usr/bin/env python3
"""
Production AI Model API Server
"""

import os
import logging
import uvicorn
from fastapi import FastAPI, HTTPException, Depends, Security
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from datetime import datetime
import json

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Security
security = HTTPBearer()

class PredictionRequest(BaseModel):
    text: str
    return_probabilities: bool = True

class PredictionResponse(BaseModel):
    experience_level: str
    confidence: float
    probabilities: dict = None
    processing_time: float
    timestamp: str

# Initialize FastAPI
app = FastAPI(
    title="Kamal's AI Assistant API",
    description="Custom AI model for experience classification",
    version="1.0.0"
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mock model responses (replace with actual model)
def get_mock_prediction(text: str):
    """Mock prediction function - replace with actual model"""
    import random
    
    # Simple keyword-based classification for demo
    text_lower = text.lower()
    
    if any(word in text_lower for word in ['expert', 'advanced', 'senior', 'lead', 'architect']):
        level = 2
        confidence = 0.85 + random.random() * 0.1
    elif any(word in text_lower for word in ['intermediate', 'experience', 'skilled', 'proficient']):
        level = 1
        confidence = 0.75 + random.random() * 0.15
    else:
        level = 0
        confidence = 0.65 + random.random() * 0.2
    
    labels = ['Beginner/Learning', 'Intermediate', 'Advanced/Expert']
    
    # Generate probabilities
    probs = [0.1, 0.1, 0.1]
    probs[level] = confidence
    remaining = 1.0 - confidence
    for i in range(3):
        if i != level:
            probs[i] = remaining / 2
    
    return {
        'experience_level': labels[level],
        'confidence': confidence,
        'probabilities': {labels[i]: probs[i] for i in range(3)}
    }

async def verify_token(credentials: HTTPAuthorizationCredentials = Security(security)):
    """Verify API token"""
    token = credentials.credentials
    expected_token = os.getenv("API_TOKEN", "your-secret-token")
    
    if token != expected_token:
        raise HTTPException(status_code=401, detail="Invalid authentication token")
    return token

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "model_loaded": True,
        "timestamp": datetime.now().isoformat(),
        "version": "1.0.0"
    }

@app.post("/predict", response_model=PredictionResponse)
async def predict(
    request: PredictionRequest,
    token: str = Depends(verify_token)
):
    """Make experience level prediction"""
    start_time = datetime.now()
    
    try:
        # Get prediction (replace with actual model)
        result = get_mock_prediction(request.text)
        
        processing_time = (datetime.now() - start_time).total_seconds()
        
        response = PredictionResponse(
            experience_level=result['experience_level'],
            confidence=result['confidence'],
            probabilities=result['probabilities'] if request.return_probabilities else None,
            processing_time=processing_time,
            timestamp=datetime.now().isoformat()
        )
        
        logger.info(f"Prediction: {response.experience_level} (confidence: {result['confidence']:.3f})")
        return response
        
    except Exception as e:
        logger.error(f"Prediction failed: {e}")
        raise HTTPException(status_code=500, detail=f"Prediction failed: {str(e)}")

@app.get("/model-info")
async def model_info(token: str = Depends(verify_token)):
    """Get model information"""
    return {
        "model_type": "Experience Classification",
        "labels": ["Beginner/Learning", "Intermediate", "Advanced/Expert"],
        "model_loaded": True,
        "description": "Custom model trained with sample dataset"
    }

if __name__ == "__main__":
    uvicorn.run(
        "app:app",
        host="0.0.0.0",
        port=8001,
        reload=False,
        log_level="info"
    )
EOF

# Make the script executable
chmod +x /opt/ai-model/app.py

# Create systemd service for AI model
log "Creating systemd service"
cat > /etc/systemd/system/ai-model.service << 'EOF'
[Unit]
Description=AI Model API Server
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/opt/ai-model
Environment=API_TOKEN=your-secret-token
Environment=PYTHONPATH=/opt/ai-model
ExecStart=/usr/bin/python3 /opt/ai-model/app.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Configure Nginx
log "Configuring Nginx"
cat > /etc/nginx/conf.d/ai-model.conf << EOF
server {
    listen 80;
    server_name api.${DOMAIN_NAME};
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    
    # Rate limiting
    limit_req_zone \$binary_remote_addr zone=api:10m rate=10r/s;
    
    location / {
        limit_req zone=api burst=20 nodelay;
        
        proxy_pass http://localhost:8001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
    
    # Health check endpoint
    location /health {
        proxy_pass http://localhost:8001/health;
        access_log off;
    }
}
EOF

# Remove default Nginx configuration
rm -f /etc/nginx/conf.d/default.conf

# Configure CloudWatch agent
log "Configuring CloudWatch agent"
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << 'EOF'
{
    "logs": {
        "logs_collected": {
            "files": {
                "collect_list": [
                    {
                        "file_path": "/var/log/user-data.log",
                        "log_group_name": "/aws/ec2/ai-model",
                        "log_stream_name": "{instance_id}/user-data"
                    },
                    {
                        "file_path": "/var/log/nginx/access.log",
                        "log_group_name": "/aws/ec2/ai-model",
                        "log_stream_name": "{instance_id}/nginx-access"
                    },
                    {
                        "file_path": "/var/log/nginx/error.log",
                        "log_group_name": "/aws/ec2/ai-model",
                        "log_stream_name": "{instance_id}/nginx-error"
                    }
                ]
            }
        }
    },
    "metrics": {
        "namespace": "AI-Model",
        "metrics_collected": {
            "cpu": {
                "measurement": [
                    "cpu_usage_idle",
                    "cpu_usage_iowait",
                    "cpu_usage_user",
                    "cpu_usage_system"
                ],
                "metrics_collection_interval": 60
            },
            "disk": {
                "measurement": [
                    "used_percent"
                ],
                "metrics_collection_interval": 60,
                "resources": [
                    "*"
                ]
            },
            "mem": {
                "measurement": [
                    "mem_used_percent"
                ],
                "metrics_collection_interval": 60
            }
        }
    }
}
EOF

# Start and enable services
log "Starting services"
systemctl daemon-reload
systemctl enable ai-model
systemctl start ai-model

systemctl enable nginx
systemctl start nginx

systemctl enable amazon-cloudwatch-agent
systemctl start amazon-cloudwatch-agent

# Create log rotation
log "Setting up log rotation"
cat > /etc/logrotate.d/ai-model << 'EOF'
/var/log/user-data.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 644 root root
}
EOF

# Create health check script
log "Creating health check script"
cat > /opt/ai-model/health-check.sh << 'EOF'
#!/bin/bash

# Health check script
API_URL="http://localhost:8001/health"
LOG_FILE="/var/log/health-check.log"

# Function to log with timestamp
log_health() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $LOG_FILE
}

# Check API health
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" $API_URL)

if [ $HTTP_STATUS -eq 200 ]; then
    log_health "API health check passed"
else
    log_health "API health check failed with status $HTTP_STATUS"
    # Restart service if unhealthy
    systemctl restart ai-model
    log_health "Restarted ai-model service"
fi
EOF

chmod +x /opt/ai-model/health-check.sh

# Add health check to crontab
log "Setting up health check cron job"
echo "*/5 * * * * /opt/ai-model/health-check.sh" | crontab -

# Set proper permissions
chown -R ec2-user:ec2-user /opt/ai-model

# Create startup script for easy management
cat > /opt/ai-model/manage.sh << 'EOF'
#!/bin/bash

case "$1" in
    start)
        sudo systemctl start ai-model nginx
        echo "Services started"
        ;;
    stop)
        sudo systemctl stop ai-model nginx
        echo "Services stopped"
        ;;
    restart)
        sudo systemctl restart ai-model nginx
        echo "Services restarted"
        ;;
    status)
        sudo systemctl status ai-model nginx
        ;;
    logs)
        sudo journalctl -u ai-model -f
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|logs}"
        exit 1
        ;;
esac
EOF

chmod +x /opt/ai-model/manage.sh

log "User data script completed successfully"

# Final status check
sleep 30
if curl -s http://localhost:8001/health > /dev/null; then
    log "AI Model API is running successfully"
else
    log "AI Model API failed to start - check logs"
fi

log "Setup completed. AI Model API should be available on port 8001"