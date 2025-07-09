# Contributing to Portfolio Website

Thank you for your interest in contributing to this portfolio website project! This document provides guidelines and information for contributors.

## 🤝 How to Contribute

### Reporting Issues

Before creating an issue, please:

1. **Search existing issues** to avoid duplicates
2. **Use the issue templates** when available
3. **Provide detailed information** including:
   - Clear description of the problem
   - Steps to reproduce
   - Expected vs actual behavior
   - Screenshots or error messages
   - Browser and OS information
   - Node.js and npm versions

### Suggesting Features

Feature requests are welcome! Please:

1. **Check existing feature requests** first
2. **Explain the use case** and why it would be valuable
3. **Provide implementation details** if you have ideas
4. **Consider the scope** - keep features focused and relevant

### Code Contributions

#### Getting Started

1. **Fork the repository**
   ```bash
   git clone https://github.com/infrapulses/portfolio-website.git
   cd portfolio-website
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

4. **Start development server**
   ```bash
   npm run dev
   ```

#### Development Guidelines

##### Code Style

- **TypeScript**: Use TypeScript for all new code
- **ESLint**: Follow the existing ESLint configuration
- **Prettier**: Code will be automatically formatted
- **Naming**: Use descriptive names for variables and functions
- **Comments**: Add comments for complex logic

##### Component Guidelines

- **Functional Components**: Use functional components with hooks
- **Props Interface**: Define TypeScript interfaces for all props
- **Default Props**: Use default parameters instead of defaultProps
- **Accessibility**: Ensure components are accessible (ARIA labels, keyboard navigation)

Example component structure:
```typescript
import React from 'react';
import { SomeIcon } from 'lucide-react';

interface ComponentProps {
  title: string;
  description?: string;
  onClick?: () => void;
}

const MyComponent: React.FC<ComponentProps> = ({ 
  title, 
  description = '', 
  onClick 
}) => {
  return (
    <div className="component-container">
      <h2>{title}</h2>
      {description && <p>{description}</p>}
      {onClick && (
        <button onClick={onClick} aria-label={`Action for ${title}`}>
          <SomeIcon className="w-4 h-4" />
        </button>
      )}
    </div>
  );
};

export default MyComponent;
```

##### Styling Guidelines

- **Tailwind CSS**: Use Tailwind utility classes
- **Responsive Design**: Ensure mobile-first responsive design
- **Consistent Spacing**: Use Tailwind's spacing scale
- **Color Scheme**: Maintain consistent color palette
- **Animations**: Use subtle, purposeful animations

##### Performance Guidelines

- **Bundle Size**: Keep bundle size minimal
- **Image Optimization**: Use optimized images
- **Lazy Loading**: Implement lazy loading where appropriate
- **Code Splitting**: Use dynamic imports for large components

#### Testing

While this project doesn't currently have tests, contributions that add testing are welcome:

- **Unit Tests**: Test individual components
- **Integration Tests**: Test component interactions
- **E2E Tests**: Test user workflows
- **Accessibility Tests**: Ensure WCAG compliance

#### Commit Guidelines

Use conventional commit messages:

```
type(scope): description

[optional body]

[optional footer]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `perf`: Performance improvements
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

Examples:
```
feat(chatbot): add new response categories
fix(contact): resolve form validation issue
docs(readme): update installation instructions
style(hero): improve mobile responsiveness
```

#### Pull Request Process

1. **Update documentation** if needed
2. **Test your changes** thoroughly
3. **Run linting** with `npm run lint`
4. **Build the project** with `npm run build`
5. **Create a pull request** with:
   - Clear title and description
   - Reference to related issues
   - Screenshots for UI changes
   - Testing instructions

##### Pull Request Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Tested locally
- [ ] Responsive design tested
- [ ] Accessibility tested
- [ ] Cross-browser tested

## Screenshots
(If applicable)

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No console errors
```

## 🏗️ Project Structure

Understanding the project structure helps with contributions:

```
src/
├── components/          # React components
│   ├── About.tsx       # About section component
│   ├── ChatBot.tsx     # AI chatbot component
│   ├── Contact.tsx     # Contact form component
│   ├── Footer.tsx      # Footer component
│   ├── Header.tsx      # Navigation header
│   ├── Hero.tsx        # Hero section component
│   └── Portfolio.tsx   # Portfolio showcase
├── App.tsx             # Main application component
├── main.tsx            # Application entry point
└── index.css           # Global styles
```

## 🎨 Design System

### Colors
- Primary: Blue gradient (`from-blue-600 to-purple-600`)
- Secondary: Gray scale (`gray-50` to `gray-900`)
- Accent: Various colors for categories and highlights

### Typography
- Headings: Bold, large sizes with proper hierarchy
- Body: Regular weight, readable line height
- Code: Monospace font for technical content

### Spacing
- Use Tailwind's spacing scale (4, 6, 8, 12, 16, 20, etc.)
- Consistent margins and padding
- Proper section spacing

### Components
- Consistent border radius (`rounded-lg`, `rounded-xl`)
- Subtle shadows for depth
- Smooth transitions and hover effects

## 🚀 Deployment Contributions

Contributions to deployment and DevOps are welcome:

- **CI/CD Improvements**: Enhance GitHub Actions workflows
- **Performance Optimization**: Improve build and runtime performance
- **Security Enhancements**: Add security measures
- **Monitoring**: Improve logging and monitoring
- **Documentation**: Update deployment guides

## 📚 Resources

- [React Documentation](https://react.dev/)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
- [Tailwind CSS Documentation](https://tailwindcss.com/docs)
- [Lucide React Icons](https://lucide.dev/)
- [Vite Documentation](https://vitejs.dev/)

## 🤔 Questions?

If you have questions about contributing:

1. **Check existing issues** and discussions
2. **Create a discussion** for general questions
3. **Create an issue** for specific problems
4. **Reach out** via the contact form on the website

## 🙏 Recognition

Contributors will be recognized in:

- **README.md** contributors section
- **GitHub contributors** page
- **Release notes** for significant contributions

Thank you for contributing to make this portfolio website better! 🎉