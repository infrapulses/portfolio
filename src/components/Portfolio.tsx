import React, { useState } from 'react';
import { ExternalLink, Github, Calendar, Tag } from 'lucide-react';

const Portfolio = () => {
  const [activeFilter, setActiveFilter] = useState('All');

  const projects = [
    {
      id: 1,
      title: 'VisionOps',
      category: 'Web App',
      description: 'Unified observability + security platform for SMBs with Grafana, Prometheus, and Wazuh. Deployed across hybrid Kubernetes clusters.',
      image: '/images/portfolio/visionops.jpg',
      technologies: ['Grafana', 'Prometheus', 'Wazuh', 'Kubernetes', 'Jenkins'],
      liveUrl: '#',
      githubUrl: 'https://github.com/infrapulses/Vision-ops_project',
      date: '2025'
    },
    {
      id: 2,
      title: 'FutureOps',
      category: 'Prediction Power',
      description: 'A cutting-edge predictive infrastructure platform that combines AI, observability, and automation. FutureOps empowers teams with custom forecasting, real-time alerts, and adaptive dashboards — designed to grow with your infra.',
      image: '/images/portfolio/futureops.jpg',
      technologies: ['Python', 'Grafana', 'Prometheus', 'Custom ML Models', 'Ansible', 'FastAPI'],
      liveUrl: '#',
      githubUrl: 'https://github.com/infrapulses/Futureops',
      date: '2025'
    },
    {
      id: 3,
      title: 'SIEM + Compliance Stackp',
      category: 'Security',
      description: 'Deployed and customized Wazuh for real-time SIEM, log collection, and alerting. Added compliance report generation via custom scripting.',
      image: '/images/portfolio/siem-stack.jpg',
      technologies: ['Wazuh', 'Linux', 'Logstash', 'Shell Scripting'],
      liveUrl: '#',
      githubUrl: '#',
      date: '2023'
    },
    {
      id: 4,
      title: 'Kubernetes Infra Automation',
      category: 'CloudOps',
      description: 'Built end-to-end Kubernetes infrastructure with Terraform, Docker, and GitHub Actions for CI/CD and app deployment.',
      image: '/images/portfolio/kubernetes-automation.jpg',
      technologies: ['Terraform', 'Kubernetes', 'GitHub Actions', 'Docker'],
      liveUrl: '#',
      githubUrl: '#',
      date: '2024'
    },
    {
      id: 5,
      title: 'AI-Driven Anomaly Detection',
      category: 'AI',
      description: 'Integrated ML models in Prometheus alert pipeline to detect anomalies in system performance. Deployed without GPU on-prem.',
      image: '/images/portfolio/ai-anomaly-detection.jpg',
      technologies: ['Python', 'Scikit-learn', 'Prometheus', 'FastAPI'],
      liveUrl: '#',
      githubUrl: '#',
      date: '2024'
    },
    {
      id: 6,
      title: 'Network Storage Monitoring',
      category: 'Monitoring',
      description: 'Monitored SAN, NAS, and switches using SNMP exporters and Entuity. Built Grafana dashboards for performance insight.',
      image: '/images/portfolio/network-monitoring.jpg',
      technologies: ['Grafana', 'SNMP Exporter', 'Cisco SAN', 'Entuity'],
      liveUrl: '#',
      githubUrl: '#',
      date: '2022'
    }
  ];

  const categories = ['All', 'Monitoring', 'Security', 'AI', 'CloudOps', 'Prediction & Automation'];

  const filteredProjects = activeFilter === 'All' 
    ? projects 
    : projects.filter(project => project.category === activeFilter);

  return (
    <section id="portfolio" className="py-20 bg-gradient-to-br from-gray-50 to-white">
      <div className="container mx-auto px-4">
        <div className="text-center mb-16">
          <h2 className="text-4xl md:text-5xl font-bold text-gray-900 mb-6">My Portfolio</h2>
          <p className="text-xl text-gray-600 max-w-3xl mx-auto leading-relaxed">
            Infra is my canvas, and automation is my brush. Here's a curated collection of infrastructure, security, and AI-powered monitoring projects that reflect my passion for resilient systems.
          </p>
        </div>

        {/* Filter Buttons */}
        <div className="flex flex-wrap justify-center gap-4 mb-12">
          {categories.map((category) => (
            <button
              key={category}
              onClick={() => setActiveFilter(category)}
              className={`px-6 py-3 rounded-lg font-semibold transition-all duration-300 ${
                activeFilter === category
                  ? 'bg-gradient-to-r from-blue-600 to-purple-600 text-white shadow-lg'
                  : 'bg-white text-gray-700 hover:bg-gray-100 border border-gray-200'
              }`}
            >
              {category}
            </button>
          ))}
        </div>

        {/* Projects Grid */}
        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
          {filteredProjects.map((project) => (
            <div key={project.id} className="bg-white rounded-xl overflow-hidden shadow-lg hover:shadow-xl transition-all duration-300 group">
              <div className="relative overflow-hidden">
                <img 
                  src={project.image} 
                  alt={project.title}
                  className="w-full h-48 object-cover group-hover:scale-105 transition-transform duration-300"
                  onError={(e) => {
                    // Fallback to Pexels image if local image fails
                    const fallbackImages = {
                      'visionops.jpg': 'https://images.pexels.com/photos/6476253/pexels-photo-6476253.jpeg?auto=compress&cs=tinysrgb&w=800',
                      'futureops.jpg': 'https://images.pexels.com/photos/373543/pexels-photo-373543.jpeg?auto=compress&cs=tinysrgb&w=800',
                      'siem-stack.jpg': 'https://images.pexels.com/photos/669612/pexels-photo-669612.jpeg?auto=compress&cs=tinysrgb&w=800',
                      'kubernetes-automation.jpg': 'https://images.pexels.com/photos/1181676/pexels-photo-1181676.jpeg?auto=compress&cs=tinysrgb&w=800',
                      'ai-anomaly-detection.jpg': 'https://images.pexels.com/photos/3861969/pexels-photo-3861969.jpeg?auto=compress&cs=tinysrgb&w=800',
                      'network-monitoring.jpg': 'https://images.pexels.com/photos/325229/pexels-photo-325229.jpeg?auto=compress&cs=tinysrgb&w=800'
                    };
                    const filename = project.image.split('/').pop();
                    e.currentTarget.src = fallbackImages[filename] || 'https://images.pexels.com/photos/1181676/pexels-photo-1181676.jpeg?auto=compress&cs=tinysrgb&w=800';
                  }}
                />
                <div className="absolute inset-0 bg-gradient-to-t from-black/50 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
                <div className="absolute top-4 right-4 bg-white/90 px-3 py-1 rounded-full text-sm font-medium text-gray-700">
                  {project.category}
                </div>
              </div>
              
              <div className="p-6">
                <div className="flex items-center justify-between mb-3">
                  <h3 className="text-xl font-bold text-gray-900">{project.title}</h3>
                  <div className="flex items-center text-gray-500 text-sm">
                    <Calendar className="w-4 h-4 mr-1" />
                    {project.date}
                  </div>
                </div>
                
                <p className="text-gray-600 mb-4 leading-relaxed">{project.description}</p>
                
                <div className="flex flex-wrap gap-2 mb-4">
                  {project.technologies.map((tech, index) => (
                    <span key={index} className="flex items-center bg-gray-100 text-gray-700 px-3 py-1 rounded-full text-sm">
                      <Tag className="w-3 h-3 mr-1" />
                      {tech}
                    </span>
                  ))}
                </div>
                
                <div className="flex space-x-4">
                  <a
                    href={project.liveUrl}
                    className="flex items-center space-x-2 bg-gradient-to-r from-blue-600 to-purple-600 hover:from-blue-700 hover:to-purple-700 text-white px-4 py-2 rounded-lg font-medium transition-all duration-300 flex-1 justify-center"
                    onClick={(e) => {
                      if (project.liveUrl === '#') {
                        e.preventDefault();
                        alert('Live demo currently not available - Working on deployment! 🚀\n\nThis project is being prepared for live demonstration. Please check back soon or view the source code on GitHub.');
                      }
                    }}
                  >
                    <ExternalLink className="w-4 h-4" />
                    <span>Live Demo</span>
                  </a>
                  <a
                    href={project.githubUrl}
                    className="flex items-center space-x-2 bg-gray-800 hover:bg-gray-900 text-white px-4 py-2 rounded-lg font-medium transition-all duration-300 flex-1 justify-center"
                    onClick={(e) => {
                      if (project.githubUrl === '#') {
                        e.preventDefault();
                        alert('Source code repository is being organized! 📝\n\nThe code for this project is currently being cleaned up and documented for public release. Stay tuned!');
                      }
                    }}
                  >
                    <Github className="w-4 h-4" />
                    <span>Code</span>
                  </a>
                </div>
                
                {/* Status Notes */}
                {(project.liveUrl === '#' || project.githubUrl === '#') && (
                  <div className="mt-4 p-3 bg-yellow-50 border border-yellow-200 rounded-lg">
                    <div className="flex items-start space-x-2">
                      <div className="w-2 h-2 bg-yellow-400 rounded-full mt-2 flex-shrink-0"></div>
                      <div className="text-sm text-yellow-800">
                        {project.liveUrl === '#' && project.githubUrl === '#' ? (
                          <span><strong>Status:</strong> Live demo and source code are being prepared for public release. This project showcases my hands-on experience with the listed technologies.</span>
                        ) : project.liveUrl === '#' ? (
                          <span><strong>Status:</strong> Live demo deployment in progress. Source code available on GitHub.</span>
                        ) : (
                          <span><strong>Status:</strong> Source code repository being organized for public release. Live demo available above.</span>
                        )}
                      </div>
                    </div>
                  </div>
                )}
              </div>
            </div>
          ))}
        </div>
        
        {/* General Portfolio Note */}
        <div className="mt-12 bg-blue-50 border border-blue-200 rounded-xl p-6">
          <div className="text-center">
            <h4 className="text-lg font-semibold text-blue-900 mb-2">🚀 Portfolio Status Update</h4>
            <p className="text-blue-800 leading-relaxed">
              I'm actively working on deploying live demos and organizing source code repositories for public access. 
              These projects represent real-world implementations I've built and deployed in enterprise environments. 
              For immediate access to any specific project details or demonstrations, feel free to <a href="#contact" className="underline font-medium hover:text-blue-600">contact me directly</a>.
            </p>
          </div>
        </div>
      </div>
    </section>
  );
};

export default Portfolio;