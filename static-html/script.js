// Portfolio Website JavaScript

// DOM Elements
const mobileMenuBtn = document.getElementById('mobileMenuBtn');
const navMenu = document.getElementById('navMenu');
const navLinks = document.querySelectorAll('.nav-link');
const sections = document.querySelectorAll('section');
const chatbotToggle = document.getElementById('chatbotToggle');
const chatbotWindow = document.getElementById('chatbotWindow');
const chatbotClose = document.getElementById('chatbotClose');
const chatbotInput = document.getElementById('chatbotInput');
const chatbotSend = document.getElementById('chatbotSend');
const chatbotMessages = document.getElementById('chatbotMessages');
const contactForm = document.getElementById('contactForm');
const portfolioFilters = document.querySelectorAll('.filter-btn');
const portfolioItems = document.querySelectorAll('.portfolio-item');

// Mobile Menu Toggle
if (mobileMenuBtn && navMenu) {
    mobileMenuBtn.addEventListener('click', () => {
        navMenu.classList.toggle('active');
        mobileMenuBtn.classList.toggle('active');
    });
}

// Smooth Scrolling for Navigation Links
navLinks.forEach(link => {
    link.addEventListener('click', (e) => {
        e.preventDefault();
        const targetId = link.getAttribute('href').substring(1);
        const targetSection = document.getElementById(targetId);
        
        if (targetSection) {
            targetSection.scrollIntoView({
                behavior: 'smooth',
                block: 'start'
            });
        }
        
        // Close mobile menu if open
        if (navMenu.classList.contains('active')) {
            navMenu.classList.remove('active');
            mobileMenuBtn.classList.remove('active');
        }
    });
});

// Active Navigation Link on Scroll
function updateActiveNavLink() {
    let current = '';
    
    sections.forEach(section => {
        const sectionTop = section.offsetTop;
        const sectionHeight = section.clientHeight;
        
        if (window.pageYOffset >= sectionTop - 200) {
            current = section.getAttribute('id');
        }
    });
    
    navLinks.forEach(link => {
        link.classList.remove('active');
        if (link.getAttribute('href') === `#${current}`) {
            link.classList.add('active');
        }
    });
}

// Header Background on Scroll
function updateHeaderBackground() {
    const header = document.querySelector('.header');
    if (window.scrollY > 100) {
        header.style.background = 'rgba(255, 255, 255, 0.98)';
        header.style.backdropFilter = 'blur(20px)';
    } else {
        header.style.background = 'rgba(255, 255, 255, 0.95)';
        header.style.backdropFilter = 'blur(10px)';
    }
}

// Scroll Event Listener
window.addEventListener('scroll', () => {
    updateActiveNavLink();
    updateHeaderBackground();
    animateOnScroll();
});

// Animate Elements on Scroll
function animateOnScroll() {
    const elements = document.querySelectorAll('.skill-category, .portfolio-item, .timeline-item, .stat-item');
    
    elements.forEach(element => {
        const elementTop = element.getBoundingClientRect().top;
        const elementVisible = 150;
        
        if (elementTop < window.innerHeight - elementVisible) {
            element.classList.add('fade-in');
        }
    });
}

// Portfolio Filter Functionality
portfolioFilters.forEach(filter => {
    filter.addEventListener('click', () => {
        // Remove active class from all filters
        portfolioFilters.forEach(f => f.classList.remove('active'));
        // Add active class to clicked filter
        filter.classList.add('active');
        
        const filterValue = filter.getAttribute('data-filter');
        
        portfolioItems.forEach(item => {
            if (filterValue === 'all' || item.getAttribute('data-category') === filterValue) {
                item.style.display = 'block';
                setTimeout(() => {
                    item.style.opacity = '1';
                    item.style.transform = 'translateY(0)';
                }, 100);
            } else {
                item.style.opacity = '0';
                item.style.transform = 'translateY(20px)';
                setTimeout(() => {
                    item.style.display = 'none';
                }, 300);
            }
        });
    });
});

// Chatbot Functionality
const chatbotResponses = {
    'skills': "I specialize in DevOps and SRE with expertise in Linux, Kubernetes, AWS, Grafana, Prometheus, and Wazuh SIEM. I'm also experienced with infrastructure automation, monitoring, and AI-driven operations.",
    'experience': "I have over 3 years of experience in infrastructure and system operations, working with enterprise environments. I've built monitoring systems, automated deployments, and managed critical infrastructure.",
    'projects': "I've worked on projects like VisionOps (monitoring platform), FutureOps (predictive infrastructure), Kubernetes automation, and SIEM implementations. You can see my portfolio above for detailed examples.",
    'contact': "You can reach me through the contact form above, or directly at techey.kamal@gmail.com. I'm always open to discussing new opportunities!",
    'ai': "I'm passionate about AI for infrastructure operations. I've worked with anomaly detection, predictive analytics, and AI-driven monitoring solutions for infrastructure management.",
    'technologies': "I work with DevOps technologies including Kubernetes, Docker, AWS, Grafana, Prometheus, Wazuh, Terraform, Ansible, and various monitoring and automation tools.",
    'hello': "Hello! Nice to meet you! I'm here to help you learn more about my background and experience. What would you like to know?",
    'hire': "I'm always open to new DevOps and SRE opportunities! Feel free to reach out through the contact form or email me directly. I'd love to discuss how I can contribute to your infrastructure.",
    'resume': "You can view my detailed resume in the Resume section above, which includes my professional experience, education, and certifications in DevOps and infrastructure engineering.",
    'default': "That's an interesting question! I can tell you about my DevOps skills, infrastructure experience, projects, resume, or how to get in touch. What specifically would you like to know more about?"
};

function getChatbotResponse(input) {
    const lowercaseInput = input.toLowerCase();
    
    if (lowercaseInput.includes('skill') || lowercaseInput.includes('technology') || lowercaseInput.includes('tech')) {
        return chatbotResponses.skills;
    } else if (lowercaseInput.includes('experience') || lowercaseInput.includes('background')) {
        return chatbotResponses.experience;
    } else if (lowercaseInput.includes('project') || lowercaseInput.includes('work') || lowercaseInput.includes('portfolio')) {
        return chatbotResponses.projects;
    } else if (lowercaseInput.includes('contact') || lowercaseInput.includes('email') || lowercaseInput.includes('reach')) {
        return chatbotResponses.contact;
    } else if (lowercaseInput.includes('ai') || lowercaseInput.includes('artificial') || lowercaseInput.includes('machine learning') || lowercaseInput.includes('ml')) {
        return chatbotResponses.ai;
    } else if (lowercaseInput.includes('hello') || lowercaseInput.includes('hi') || lowercaseInput.includes('hey')) {
        return chatbotResponses.hello;
    } else if (lowercaseInput.includes('hire') || lowercaseInput.includes('job') || lowercaseInput.includes('opportunity')) {
        return chatbotResponses.hire;
    } else if (lowercaseInput.includes('resume') || lowercaseInput.includes('cv')) {
        return chatbotResponses.resume;
    } else {
        return chatbotResponses.default;
    }
}

function addMessage(content, isUser = false) {
    const messageDiv = document.createElement('div');
    messageDiv.className = `message ${isUser ? 'user-message' : 'bot-message'}`;
    
    const avatarDiv = document.createElement('div');
    avatarDiv.className = 'message-avatar';
    avatarDiv.innerHTML = isUser ? 
        '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle></svg>' :
        '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="8" r="7"></circle><polyline points="8.21,13.89 7,23 12,20 17,23 15.79,13.88"></polyline></svg>';
    
    const contentDiv = document.createElement('div');
    contentDiv.className = 'message-content';
    
    const textP = document.createElement('p');
    textP.textContent = content;
    
    const timeSpan = document.createElement('span');
    timeSpan.className = 'message-time';
    timeSpan.textContent = new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
    
    contentDiv.appendChild(textP);
    contentDiv.appendChild(timeSpan);
    
    messageDiv.appendChild(avatarDiv);
    messageDiv.appendChild(contentDiv);
    
    chatbotMessages.appendChild(messageDiv);
    chatbotMessages.scrollTop = chatbotMessages.scrollHeight;
}

function sendMessage() {
    const message = chatbotInput.value.trim();
    if (!message) return;
    
    // Add user message
    addMessage(message, true);
    chatbotInput.value = '';
    
    // Simulate typing delay
    setTimeout(() => {
        const response = getChatbotResponse(message);
        addMessage(response, false);
    }, 1000);
}

// Chatbot Event Listeners
if (chatbotToggle && chatbotWindow) {
    chatbotToggle.addEventListener('click', () => {
        chatbotWindow.classList.toggle('active');
    });
}

if (chatbotClose) {
    chatbotClose.addEventListener('click', () => {
        chatbotWindow.classList.remove('active');
    });
}

if (chatbotSend) {
    chatbotSend.addEventListener('click', sendMessage);
}

if (chatbotInput) {
    chatbotInput.addEventListener('keypress', (e) => {
        if (e.key === 'Enter') {
            sendMessage();
        }
    });
}

// Contact Form Handling
if (contactForm) {
    contactForm.addEventListener('submit', (e) => {
        e.preventDefault();
        
        const formData = new FormData(contactForm);
        const name = formData.get('name');
        const email = formData.get('email');
        const subject = formData.get('subject');
        const message = formData.get('message');
        
        // Simulate form submission
        const submitBtn = contactForm.querySelector('button[type="submit"]');
        const originalText = submitBtn.innerHTML;
        
        submitBtn.innerHTML = `
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <circle cx="12" cy="12" r="10"></circle>
                <path d="M12 6v6l4 2"></path>
            </svg>
            <span>Sending...</span>
        `;
        submitBtn.disabled = true;
        
        setTimeout(() => {
            submitBtn.innerHTML = `
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path>
                    <polyline points="22,4 12,14.01 9,11.01"></polyline>
                </svg>
                <span>Message Sent!</span>
            `;
            
            // Reset form
            contactForm.reset();
            
            // Reset button after 3 seconds
            setTimeout(() => {
                submitBtn.innerHTML = originalText;
                submitBtn.disabled = false;
            }, 3000);
        }, 2000);
    });
}

// Download Resume Functionality
const downloadBtn = document.querySelector('.download-btn');
if (downloadBtn) {
    downloadBtn.addEventListener('click', (e) => {
        e.preventDefault();
        alert('Resume download functionality would be implemented here. In a real scenario, this would download a PDF file.');
    });
}

// Skill Bar Animation
function animateSkillBars() {
    const skillBars = document.querySelectorAll('.skill-progress');
    
    skillBars.forEach(bar => {
        const rect = bar.getBoundingClientRect();
        if (rect.top < window.innerHeight && rect.bottom > 0) {
            const width = bar.style.width;
            bar.style.width = '0%';
            setTimeout(() => {
                bar.style.width = width;
            }, 200);
        }
    });
}

// Portfolio Link Handlers
document.querySelectorAll('.portfolio-link').forEach(link => {
    link.addEventListener('click', (e) => {
        e.preventDefault();
        const href = link.getAttribute('href');
        
        if (href === '#') {
            alert('Live demo currently not available - Working on deployment! 🚀\n\nThis project is being prepared for live demonstration. Please check back soon or contact me directly for more details.');
        } else {
            window.open(href, '_blank');
        }
    });
});

// Intersection Observer for Animations
const observerOptions = {
    threshold: 0.1,
    rootMargin: '0px 0px -50px 0px'
};

const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.classList.add('fade-in');
            
            // Animate skill bars when skills section is visible
            if (entry.target.classList.contains('skills')) {
                setTimeout(animateSkillBars, 500);
            }
        }
    });
}, observerOptions);

// Observe elements for animation
document.querySelectorAll('.skill-category, .portfolio-item, .timeline-item, .stat-item, .about, .skills, .resume, .portfolio, .contact').forEach(el => {
    observer.observe(el);
});

// Typing Effect for Hero Title
function typeWriter(element, text, speed = 100) {
    let i = 0;
    element.innerHTML = '';
    
    function type() {
        if (i < text.length) {
            element.innerHTML += text.charAt(i);
            i++;
            setTimeout(type, speed);
        }
    }
    
    type();
}

// Initialize typing effect when page loads
window.addEventListener('load', () => {
    const heroTitle = document.querySelector('.hero-title');
    if (heroTitle) {
        const originalText = heroTitle.textContent;
        typeWriter(heroTitle, originalText, 50);
    }
});

// Smooth reveal animations
function revealOnScroll() {
    const reveals = document.querySelectorAll('.skill-category, .portfolio-item, .timeline-item');
    
    reveals.forEach(element => {
        const windowHeight = window.innerHeight;
        const elementTop = element.getBoundingClientRect().top;
        const elementVisible = 150;
        
        if (elementTop < windowHeight - elementVisible) {
            element.classList.add('fade-in');
        }
    });
}

// Add scroll event for reveals
window.addEventListener('scroll', revealOnScroll);

// Initialize on page load
document.addEventListener('DOMContentLoaded', () => {
    updateActiveNavLink();
    updateHeaderBackground();
    revealOnScroll();
    
    // Add fade-in class to elements already in view
    setTimeout(() => {
        const elementsInView = document.querySelectorAll('.hero-content, .about-content');
        elementsInView.forEach(el => el.classList.add('fade-in'));
    }, 500);
});

// Prevent form submission on demo
document.addEventListener('submit', (e) => {
    if (e.target.tagName === 'FORM') {
        e.preventDefault();
    }
});

// Add loading states and micro-interactions
document.querySelectorAll('.btn').forEach(btn => {
    btn.addEventListener('mouseenter', () => {
        btn.style.transform = 'translateY(-2px)';
    });
    
    btn.addEventListener('mouseleave', () => {
        btn.style.transform = 'translateY(0)';
    });
});

// Add ripple effect to buttons
function createRipple(event) {
    const button = event.currentTarget;
    const circle = document.createElement('span');
    const diameter = Math.max(button.clientWidth, button.clientHeight);
    const radius = diameter / 2;
    
    circle.style.width = circle.style.height = `${diameter}px`;
    circle.style.left = `${event.clientX - button.offsetLeft - radius}px`;
    circle.style.top = `${event.clientY - button.offsetTop - radius}px`;
    circle.classList.add('ripple');
    
    const ripple = button.getElementsByClassName('ripple')[0];
    if (ripple) {
        ripple.remove();
    }
    
    button.appendChild(circle);
}

// Add ripple effect to primary buttons
document.querySelectorAll('.btn-primary').forEach(btn => {
    btn.addEventListener('click', createRipple);
});

// Add CSS for ripple effect
const style = document.createElement('style');
style.textContent = `
    .btn {
        position: relative;
        overflow: hidden;
    }
    
    .ripple {
        position: absolute;
        border-radius: 50%;
        background-color: rgba(255, 255, 255, 0.6);
        transform: scale(0);
        animation: ripple 0.6s linear;
        pointer-events: none;
    }
    
    @keyframes ripple {
        to {
            transform: scale(4);
            opacity: 0;
        }
    }
`;
document.head.appendChild(style);

// Console welcome message
console.log(`
🚀 Welcome to Kamal Raj's Portfolio!
====================================

Thanks for checking out the code! This portfolio showcases:
• Modern vanilla JavaScript
• Responsive CSS design
• Interactive animations
• Accessible components

Feel free to reach out if you have any questions!
Email: techey.kamal@gmail.com

Built with ❤️ and lots of coffee ☕
`);

// Performance monitoring
if ('performance' in window) {
    window.addEventListener('load', () => {
        setTimeout(() => {
            const perfData = performance.getEntriesByType('navigation')[0];
            console.log(`Page loaded in ${Math.round(perfData.loadEventEnd - perfData.loadEventStart)}ms`);
        }, 0);
    });
}