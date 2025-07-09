import React from 'react';
import { Code, Server, Monitor, ShieldCheck, Cloud, Brain, Zap } from 'lucide-react';

const About = () => {
  const skills = [
    {
      category: 'Infrastructure & Ops',
      icon: Server,
      color: 'from-indigo-500 to-indigo-600',
      items: ['Linux', 'Proxmox', 'VMware', 'SAN/NAS (Pure, Synology)', 'Cisco SAN Switches']
    },
    {
      category: 'Monitoring & Observability',
      icon: Monitor,
      color: 'from-emerald-500 to-emerald-600',
      items: ['Grafana', 'Prometheus', 'InfluxDB', 'Blackbox Exporter', 'Entuity']
    },
    {
      category: 'Cloud & Container',
      icon: Cloud,
      color: 'from-sky-500 to-sky-600',
      items: ['AWS', 'Kubernetes', 'Docker', 'Terraform (Basic)', 'CI/CD (GitHub Actions)']
    },
    {
      category: 'Security & Automation',
      icon: ShieldCheck,
      color: 'from-rose-500 to-rose-600',
      items: ['Wazuh SIEM', 'OWASP ZAP', 'Ansible (Learning)', 'System Hardening', 'DevSecOps']
    },
    {
      category: 'AI/ML (Infra-side)',
      icon: Brain,
      color: 'from-orange-500 to-orange-600',
      items: ['AI for Anomaly Detection', 'Performance Prediction', 'On-Prem Deployment', 'VisionOps (Project)']
    }
  ];

  const stats = [
    { label: 'Years Experience', value: '3+' },
    { label: 'Environments Managed', value: '20+' },
    { label: 'Monitoring Dashboards', value: '100+' },
    { label: 'Infra Projects', value: '10+' }
  ];

  return (
    <section id="about" className="py-20 bg-white">
      <div className="container mx-auto px-4">
        <div className="text-center mb-16">
          <h2 className="text-4xl md:text-5xl font-bold text-gray-900 mb-6">About Me</h2>
          <p className="text-xl text-gray-600 max-w-3xl mx-auto leading-relaxed">
            I’m Kamal Raj — a system operations specialist turned infrastructure ninja. With a soul for observability and 
            a mind wired for automation, I bring old-school reliability to the bleeding edge of DevOps, SRE, and AI-driven monitoring.
          </p>
        </div>

        <div className="grid lg:grid-cols-2 gap-12 items-center mb-20">
          {/* Story */}
          <div className="space-y-6 order-2 lg:order-1">
            <h3 className="text-2xl font-bold text-gray-900 mb-4">My Story</h3>
            <p className="text-gray-600 leading-relaxed">
             My journey started with blinking LEDs and bare-metal Linux boxes. Over the past 3+ years, I've been in the trenches 
              of IT operations — monitoring enterprise networks, maintaining virtual environments, managing storage arrays, and 
              ensuring uptime for mission-critical systems.
            </p>
            <p className="text-gray-600 leading-relaxed">
              Today, I engineer robust, secure, and observable infrastructure — blending tools like Grafana, Prometheus, 
              Kubernetes, and Wazuh to build real-time insights for infra and apps. I’m currently building <strong>VisionOps</strong>, 
              a futuristic monitoring & security suite for SMBs that merges observability, compliance, and AI insights into one.
            </p>
            <div className="flex items-center space-x-4 pt-4">
              <Zap className="w-8 h-8 text-yellow-500" />
              <span className="text-lg font-semibold text-gray-900">Bridging tradition with tech evolution</span>
            </div>
          </div>

          {/* Stats */}
          <div className="order-1 lg:order-2">
            {/* Profile Image for About Section */}
            <div className="mb-8 lg:mb-0 flex justify-center lg:justify-end">
              <div className="w-48 h-48 md:w-56 md:h-56 rounded-2xl overflow-hidden shadow-xl border-4 border-white">
                <img 
                  src="https://your-s3-bucket-name.s3.amazonaws.com/profile/kamal-raj-about.jpg" 
                  alt="Kamal Raj - About Photo" 
                  className="w-full h-full object-cover"
                  onError={(e) => {
                    // Fallback to default image if S3 image fails to load
                    e.currentTarget.src = "https://images.pexels.com/photos/3861969/pexels-photo-3861969.jpeg?auto=compress&cs=tinysrgb&w=600&h=600&fit=crop";
                  }}
                />
              </div>
            </div>
            
            {/* Stats Grid */}
            <div className="grid grid-cols-2 gap-6">
            {stats.map((stat, index) => (
              <div key={index} className="bg-gradient-to-br from-gray-50 to-gray-100 p-6 rounded-xl text-center hover:shadow-lg transition-shadow">
                <div className="text-3xl font-bold text-gray-900 mb-2">{stat.value}</div>
                <div className="text-gray-600">{stat.label}</div>
              </div>
            ))}
            </div>
          </div>
        </div>

        {/* Skills */}
        <div>
          <h3 className="text-3xl font-bold text-gray-900 text-center mb-12">Technical Skills</h3>
          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
            {skills.map((skill, index) => (
              <div key={index} className="bg-white p-6 rounded-xl border border-gray-200 hover:border-gray-300 hover:shadow-lg transition-all duration-300">
                <div className={`w-12 h-12 bg-gradient-to-r ${skill.color} rounded-lg flex items-center justify-center mb-4`}>
                  <skill.icon className="w-6 h-6 text-white" />
                </div>
                <h4 className="text-lg font-semibold text-gray-900 mb-3">{skill.category}</h4>
                <ul className="space-y-2">
                  {skill.items.map((item, itemIndex) => (
                    <li key={itemIndex} className="text-gray-600 flex items-center space-x-2">
                      <Code className="w-4 h-4 text-gray-400" />
                      <span>{item}</span>
                    </li>
                  ))}
                </ul>
              </div>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
};

export default About;