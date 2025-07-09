# Professional Portfolio Website with AI Chatbot

A modern, responsive portfolio website built with React, TypeScript, and Tailwind CSS, featuring an interactive AI chatbot for visitor engagement.

![Portfolio Preview](https://images.pexels.com/photos/196644/pexels-photo-196644.jpeg?auto=compress&cs=tinysrgb&w=1200&h=600&fit=crop)

## 🚀 Features

- **Modern Design**: Clean, professional interface with smooth animations
- **Responsive Layout**: Optimized for all devices and screen sizes
- **AI-Powered Chatbot**: Interactive assistant with machine learning capabilities to analyze and respond about your skills and experience
- **Contact Form**: Functional contact form with validation
- **Portfolio Showcase**: Filterable project gallery with detailed descriptions
- **Performance Optimized**: Fast loading with optimized assets and code splitting
- **SEO Friendly**: Proper meta tags and semantic HTML structure
- **Accessibility**: WCAG compliant with keyboard navigation support
- **Enterprise AI Integration**: Local AI model training and deployment for intelligent responses

## 🛠️ Tech Stack

- **Frontend**: React 18, TypeScript, Tailwind CSS
- **Icons**: Lucide React
- **Build Tool**: Vite
- **Deployment**: Ubuntu Server with Nginx
- **CI/CD**: GitHub Actions
- **AI/ML**: PyTorch, Transformers, MLflow for model training and serving
- **Monitoring**: PM2, Custom health checks

## 📋 Prerequisites

- Node.js 18.x or higher
- npm or yarn package manager
- Git for version control

## 🚀 Quick Start

### Local Development

1. **Clone the repository**
   ```bash
   git clone https://github.com/infrapulses/portfolio-website.git
   cd portfolio-website
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Start development server**
   ```bash
   npm run dev
   ```

4. **Open your browser**
   Navigate to `http://localhost:5173`

### Building for Production

```bash
# Build the project
npm run build

# Preview the build
npm run preview
```

## 🎨 Customization

### Personal Information

Update the following files with your information:

1. **Hero Section** (`src/components/Hero.tsx`):
   - Replace "Your Name" with your actual name
   - Update the description and bio
   - Add your social media links

2. **About Section** (`src/components/About.tsx`):
   - Modify skills and technologies
   - Update experience statistics
   - Customize your story

3. **Portfolio Section** (`src/components/Portfolio.tsx`):
   - Add your actual projects
   - Update project descriptions and technologies
   - Replace placeholder images with your project screenshots

4. **Contact Information** (`src/components/Contact.tsx`):
   - Update email, phone, and location
   - Modify contact form submission logic

### Styling

The project uses Tailwind CSS for styling. Key customization areas:

- **Colors**: Modify the gradient colors in components
- **Fonts**: Update font families in `tailwind.config.js`
- **Spacing**: Adjust margins and padding throughout components
- **Animations**: Customize transitions and hover effects

### AI Chatbot

The chatbot responses are defined in `src/components/ChatBot.tsx`. Update the `predefinedResponses` object with your specific information:

```typescript
const predefinedResponses = {
  'skills': "Your skills description...",
  'experience': "Your experience details...",
  'projects': "Your projects information...",
  // Add more responses
};
```

## 📁 Project Structure

```
portfolio-website/
├── public/                 # Static assets
├── src/
│   ├── components/        # React components
│   │   ├── About.tsx     # About section
│   │   ├── ChatBot.tsx   # AI chatbot component
│   │   ├── Contact.tsx   # Contact form
│   │   ├── Footer.tsx    # Footer component
│   │   ├── Header.tsx    # Navigation header
│   │   ├── Hero.tsx      # Hero/landing section
│   │   └── Portfolio.tsx # Portfolio showcase
│   ├── App.tsx           # Main app component
│   ├── main.tsx          # App entry point
│   └── index.css         # Global styles
├── .github/
│   └── workflows/        # GitHub Actions
├── deployment-guide.md   # Deployment instructions
└── README.md            # This file
```

## 🚀 Deployment

### Automated Deployment with GitHub Actions

This project includes automated deployment to Ubuntu servers using GitHub Actions. See the [Deployment Guide](deployment-guide.md) for detailed instructions.

### Manual Deployment

1. **Build the project**
   ```bash
   npm run build
   ```

2. **Upload the `dist` folder** to your web server

3. **Configure your web server** to serve the static files

### Deployment Platforms

The built application can be deployed to various platforms:

- **Ubuntu Server** (recommended - see deployment guide)
- **Netlify**: Connect your GitHub repository
- **Vercel**: Import your GitHub repository
- **AWS S3 + CloudFront**: Upload build files to S3
- **GitHub Pages**: Enable in repository settings

## 🔧 Available Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run preview` - Preview production build
- `npm run lint` - Run ESLint

## 🌟 Performance Features

- **Code Splitting**: Automatic code splitting with Vite
- **Image Optimization**: Optimized images from Pexels
- **Lazy Loading**: Components load as needed
- **Caching**: Proper cache headers for static assets
- **Compression**: Gzip compression enabled
- **CDN Ready**: Optimized for CDN deployment

## 🔒 Security Features

- **Content Security Policy**: Implemented in deployment
- **HTTPS**: SSL certificates with Let's Encrypt
- **Security Headers**: X-Frame-Options, X-XSS-Protection, etc.
- **Input Validation**: Form validation and sanitization
- **Rate Limiting**: Nginx rate limiting configured

## 📱 Browser Support

- Chrome (latest)
- Firefox (latest)
- Safari (latest)
- Edge (latest)
- Mobile browsers (iOS Safari, Chrome Mobile)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed contribution guidelines.

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🐛 Bug Reports

If you find a bug, please create an issue with:

- Bug description
- Steps to reproduce
- Expected behavior
- Screenshots (if applicable)
- Browser and OS information

## 💡 Feature Requests

Feature requests are welcome! Please create an issue with:

- Feature description
- Use case explanation
- Implementation suggestions (optional)

## 📞 Support

- **Documentation**: Check this README and the deployment guide
- **Issues**: Create a GitHub issue for bugs or questions
- **Discussions**: Use GitHub Discussions for general questions

## 🙏 Acknowledgments

- **React Team** for the amazing framework
- **Tailwind CSS** for the utility-first CSS framework
- **Lucide** for the beautiful icons
- **Pexels** for the stock photos
- **Vite** for the fast build tool

## 📊 Project Stats

![GitHub stars](https://img.shields.io/github/stars/Kamal-Raj123/portfolio-website?style=social)
![GitHub forks](https://img.shields.io/github/forks/Kamal-Raj123/portfolio-website?style=social)
![GitHub issues](https://img.shields.io/github/issues/Kamal-Raj123/portfolio-website)
![GitHub license](https://img.shields.io/github/license/Kamal-Raj123/portfolio-website)

---

**Built with ❤️ by [Kamal Raj](https://github.com/Kamal-Raj123)**

*Last updated: December 2024*