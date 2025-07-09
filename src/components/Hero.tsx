import React from 'react';
import { ArrowDown, Github, Linkedin, Mail, MessageCircle } from 'lucide-react';

const Hero = () => {
  const scrollToSection = (sectionId: string) => {
    const element = document.getElementById(sectionId);
    if (element) {
      element.scrollIntoView({ behavior: 'smooth' });
    }
  };

  return (
    <section id="hero" className="min-h-screen bg-gradient-to-br from-blue-50 via-white to-purple-50 flex items-center justify-center relative overflow-hidden pt-20 md:pt-24">
      {/* Background Elements */}
      <div className="absolute inset-0 opacity-30">
        <div className="absolute top-20 left-20 w-72 h-72 bg-blue-200 rounded-full mix-blend-multiply filter blur-xl animate-pulse"></div>
        <div className="absolute top-40 right-20 w-72 h-72 bg-purple-200 rounded-full mix-blend-multiply filter blur-xl animate-pulse delay-1000"></div>
        <div className="absolute bottom-20 left-1/2 w-72 h-72 bg-emerald-200 rounded-full mix-blend-multiply filter blur-xl animate-pulse delay-2000"></div>
      </div>

      <div className="container mx-auto px-4 text-center relative z-10 py-8">
        <div className="max-w-4xl mx-auto">
          {/* Profile Image */}
          <div className="mb-6 md:mb-8">
            <div className="w-24 h-24 sm:w-28 sm:h-28 md:w-32 md:h-32 mx-auto rounded-full overflow-hidden shadow-2xl border-4 border-white">
              <img 
                src="https://your-s3-bucket-name.s3.amazonaws.com/profile/kamal-raj-profile.jpg" 
                alt="Kamal Raj - DevOps & SRE Engineer" 
                className="w-full h-full object-cover"
                onError={(e) => {
                  // Fallback to default image if S3 image fails to load
                  e.currentTarget.src = "https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg?auto=compress&cs=tinysrgb&w=400&h=400&fit=crop&crop=face";
                }}
              />
            </div>
          </div>

          {/* Main Content */}
          <h1 className="text-3xl sm:text-4xl md:text-5xl lg:text-6xl xl:text-7xl font-bold text-gray-900 mb-4 md:mb-6 leading-tight">
            Hello, I'm{' '}
            <span className="bg-gradient-to-r from-blue-600 to-purple-600 bg-clip-text text-transparent">
              Kamal Raj
            </span>
          </h1>
          
          <p className="text-lg sm:text-xl md:text-2xl text-gray-600 mb-6 md:mb-8 leading-relaxed">
            DevOps & SRE Engineer, AI Enthusiast
          </p>
          
          <p className="text-base sm:text-lg text-gray-500 mb-8 md:mb-12 max-w-3xl mx-auto leading-relaxed px-4">
I am an experienced IT professional specializing in <b>DevOps and Site Reliability Engineering (SRE)</b> with a strong background in <u>system operations, infrastructure management, and automation</u>. My expertise spans across virtualization,Cloud operation, networking, storage, and monitoring, making me well-suited for roles such as <b><strong><i><em>DevOps & SRE Engineer, Storage Engineer, System Administrator.</em></i></strong></b>
          </p>

          {/* CTA Buttons */}
          <div className="flex flex-col sm:flex-row gap-4 justify-center items-center mb-8 md:mb-12 px-4">
            <button
              onClick={() => scrollToSection('portfolio')}
              className="w-full sm:w-auto bg-gradient-to-r from-blue-600 to-purple-600 hover:from-blue-700 hover:to-purple-700 text-white px-6 md:px-8 py-3 md:py-4 rounded-lg font-semibold text-base md:text-lg shadow-lg hover:shadow-xl transform hover:-translate-y-1 transition-all duration-300 flex items-center justify-center space-x-2"
            >
              <span>View My Work</span>
              <ArrowDown className="w-5 h-5" />
            </button>
            
            <button
              onClick={() => scrollToSection('contact')}
              className="w-full sm:w-auto bg-white hover:bg-gray-50 text-gray-900 px-6 md:px-8 py-3 md:py-4 rounded-lg font-semibold text-base md:text-lg shadow-lg hover:shadow-xl transform hover:-translate-y-1 transition-all duration-300 border border-gray-200 flex items-center justify-center space-x-2"
            >
              <MessageCircle className="w-5 h-5" />
              <span>Let's Talk</span>
            </button>
          </div>

          {/* Social Links */}
          <div className="flex justify-center space-x-4 md:space-x-6">
            <a
              href="https://github.com/infrapulses"
              target="_blank"
              rel="noopener noreferrer"
              className="w-10 h-10 md:w-12 md:h-12 bg-white rounded-full flex items-center justify-center text-gray-600 hover:text-gray-900 hover:bg-gray-100 shadow-lg hover:shadow-xl transform hover:-translate-y-1 transition-all duration-300"
            >
              <Github className="w-5 h-5 md:w-6 md:h-6" />
            </a>
            <a
              href="https://linkedin.com"
              target="_blank"
              rel="noopener noreferrer"
              className="w-10 h-10 md:w-12 md:h-12 bg-white rounded-full flex items-center justify-center text-gray-600 hover:text-blue-600 hover:bg-blue-50 shadow-lg hover:shadow-xl transform hover:-translate-y-1 transition-all duration-300"
            >
              <Linkedin className="w-5 h-5 md:w-6 md:h-6" />
            </a>
            <a
              href="mailto:techey.kamal@gmail.com"
              className="w-10 h-10 md:w-12 md:h-12 bg-white rounded-full flex items-center justify-center text-gray-600 hover:text-emerald-600 hover:bg-emerald-50 shadow-lg hover:shadow-xl transform hover:-translate-y-1 transition-all duration-300"
            >
              <Mail className="w-5 h-5 md:w-6 md:h-6" />
            </a>
          </div>
        </div>
      </div>

      {/* Scroll Indicator */}
      <div className="absolute bottom-4 md:bottom-8 left-1/2 transform -translate-x-1/2 animate-bounce">
        <ArrowDown className="w-6 h-6 text-gray-400" />
      </div>
    </section>
  );
};

export default Hero;