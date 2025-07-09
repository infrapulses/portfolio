import React, { useState, useEffect } from 'react';
import { Menu, X, MessageCircle, Mail, User, Briefcase, Code, FileText } from 'lucide-react';

const Header = () => {
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const [activeSection, setActiveSection] = useState('hero');
  const [isScrolled, setIsScrolled] = useState(false);

  useEffect(() => {
    const handleScroll = () => {
      // Update scroll state for header styling
      setIsScrolled(window.scrollY > 50);
      
      const sections = ['hero', 'about', 'skills', 'resume', 'portfolio', 'contact'];
      const scrollPosition = window.scrollY + 100;

      for (const section of sections) {
        const element = document.getElementById(section);
        if (element) {
          const offsetTop = element.offsetTop;
          const offsetBottom = offsetTop + element.offsetHeight;
          
          if (scrollPosition >= offsetTop && scrollPosition < offsetBottom) {
            setActiveSection(section);
            break;
          }
        }
      }
    };

    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  const scrollToSection = (sectionId: string) => {
    const element = document.getElementById(sectionId);
    if (element) {
      element.scrollIntoView({ behavior: 'smooth' });
    }
    setIsMenuOpen(false);
  };

  const navItems = [
    { id: 'hero', label: 'Home', icon: User },
    { id: 'about', label: 'About', icon: User },
    { id: 'skills', label: 'Skills', icon: Code },
    { id: 'resume', label: 'Resume', icon: FileText },
    { id: 'portfolio', label: 'Portfolio', icon: Briefcase },
    { id: 'contact', label: 'Contact', icon: Mail },
  ];

  return (
    <header className={`fixed top-0 left-0 right-0 z-50 transition-all duration-300 ${
      isScrolled 
        ? 'bg-white/95 backdrop-blur-md border-b border-gray-200 shadow-sm' 
        : 'bg-white/80 backdrop-blur-sm'
    }`}>
      <div className="container mx-auto px-4 py-4">
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-2 min-w-0 flex-shrink-0">
            <div className="w-8 h-8 bg-gradient-to-br from-blue-500 to-purple-600 rounded-lg flex items-center justify-center">
              <Code className="w-5 h-5 text-white" />
            </div>
            <span className="text-lg md:text-xl font-bold text-gray-900 truncate">Portfolio</span>
          </div>

          {/* Desktop Navigation */}
          <nav className="hidden lg:flex items-center space-x-6 xl:space-x-8">
            {navItems.map(({ id, label, icon: Icon }) => (
              <button
                key={id}
                onClick={() => scrollToSection(id)}
                className={`flex items-center space-x-1 xl:space-x-2 px-2 xl:px-3 py-2 rounded-lg transition-colors text-sm xl:text-base ${
                  activeSection === id
                    ? 'text-blue-600 bg-blue-50'
                    : 'text-gray-600 hover:text-blue-600 hover:bg-gray-50'
                }`}
              >
                <Icon className="w-4 h-4" />
                <span className="hidden xl:inline">{label}</span>
                <span className="xl:hidden">{label.slice(0, 4)}</span>
              </button>
            ))}
          </nav>

          {/* Medium Screen Navigation */}
          <nav className="hidden md:flex lg:hidden items-center space-x-2">
            {navItems.slice(0, 4).map(({ id, icon: Icon }) => (
              <button
                key={id}
                onClick={() => scrollToSection(id)}
                className={`p-2 rounded-lg transition-colors ${
                  activeSection === id
                    ? 'text-blue-600 bg-blue-50'
                    : 'text-gray-600 hover:text-blue-600 hover:bg-gray-50'
                }`}
                title={navItems.find(item => item.id === id)?.label}
              >
                <Icon className="w-5 h-5" />
              </button>
            ))}
            <div className="relative">
              <button
                onClick={() => setIsMenuOpen(!isMenuOpen)}
                className="p-2 rounded-lg text-gray-600 hover:text-blue-600 hover:bg-gray-50 transition-colors"
              >
                <Menu className="w-5 h-5" />
              </button>
              {isMenuOpen && (
                <div className="absolute right-0 top-full mt-2 w-48 bg-white rounded-lg shadow-lg border border-gray-200 py-2">
                  {navItems.slice(4).map(({ id, label, icon: Icon }) => (
                    <button
                      key={id}
                      onClick={() => {
                        scrollToSection(id);
                        setIsMenuOpen(false);
                      }}
                      className="flex items-center space-x-3 w-full px-4 py-2 text-left text-gray-600 hover:text-blue-600 hover:bg-gray-50 transition-colors"
                    >
                      <Icon className="w-4 h-4" />
                      <span>{label}</span>
                    </button>
                  ))}
                </div>
              )}
            </div>
          </nav>
          {/* Mobile Menu Button */}
          <div className="md:hidden flex items-center">
            <button
              onClick={() => setIsMenuOpen(!isMenuOpen)}
              className="p-2 rounded-lg hover:bg-gray-100 transition-colors"
            >
              {isMenuOpen ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
            </button>
          </div>
        </div>

        {/* Mobile Navigation */}
        {isMenuOpen && (
          <nav className="md:hidden mt-4 py-4 border-t border-gray-200 bg-white/95 backdrop-blur-sm rounded-lg">
            {navItems.map(({ id, label, icon: Icon }) => (
              <button
                key={id}
                onClick={() => {
                  scrollToSection(id);
                  setIsMenuOpen(false);
                }}
                className={`flex items-center space-x-3 w-full px-4 py-3 rounded-lg transition-colors ${
                  activeSection === id
                    ? 'text-blue-600 bg-blue-50'
                    : 'text-gray-600 hover:text-blue-600 hover:bg-gray-50'
                }`}
              >
                <Icon className="w-5 h-5" />
                <span>{label}</span>
              </button>
            ))}
          </nav>
        )}
      </div>
    </header>
  );
};

export default Header;