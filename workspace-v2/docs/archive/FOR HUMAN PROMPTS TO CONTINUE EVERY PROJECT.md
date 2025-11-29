# FOR HUMAN PROMPTS TO CONTINUE EVERY PROJECT

This file contains detailed instructions and prompts for continuing development on all active projects. Each project includes its location, current state, next steps, and specific prompts to use with Claude Code or other AI assistants.

---

## 🎨 **GIMP STREAMING PLATFORM**

### **Location**: `/home/seanos1a/gimp-streaming-platform`

### **Project Overview**
A comprehensive cloud-based platform for streaming GIMP sessions through WebRTC and VNC technologies with Kubernetes deployment.

### **Current State**
- ✅ Complete project documentation and architecture
- ✅ 20-week implementation roadmap with detailed phases
- ✅ Security framework and Kubernetes orchestration specs
- ⏳ **Next**: Week 1 - Project Setup and Infrastructure

### **Immediate Next Steps (Phase 1)**

#### **Week 1: Project Setup and Infrastructure**
```bash
# Use this prompt to continue development:
"Continue with Week 1 implementation of the GIMP streaming platform. Please:
1. Set up development Kubernetes cluster (EKS/GKE/minikube)
2. Initialize Git repository with proper branching strategy
3. Create CI/CD pipeline with GitHub Actions
4. Set up container registry (ECR/GCR/Harbor)
5. Install monitoring stack (Prometheus + Grafana)
6. Create development environment setup guide
7. Write architecture decision records (ADRs)

Focus on creating the foundational infrastructure before proceeding to Week 2."
```

#### **Key Files to Work On**:
- `/home/seanos1a/gimp-streaming-platform/scripts/setup-cluster.sh`
- `/home/seanos1a/gimp-streaming-platform/.github/workflows/ci-cd.yml`
- `/home/seanos1a/gimp-streaming-platform/k8s/development/`
- `/home/seanos1a/gimp-streaming-platform/docs/architecture/README.md`

#### **Current Phase**: Week 1 of 20
#### **Progress**: 5% (Documentation complete, infrastructure setup pending)

---

## 🔄 **REAL-TIME SYNC ECOSYSTEM**

### **1. Sync Server**
### **Location**: `/home/seanos1a/realtime-sync-server`

### **Project Overview**
Node.js server providing real-time synchronization across multiple devices using WebSocket connections.

### **Current State**
- ✅ Complete server implementation with Socket.IO
- ✅ JWT authentication and device management
- ✅ SQLite database with Redis caching
- ✅ Comprehensive API documentation
- ⏳ **Next**: Production deployment and client integration

### **Immediate Next Steps**
```bash
# Use this prompt to continue development:
"Continue development of the real-time sync server by implementing:
1. Production deployment with Docker containerization
2. Environment-specific configuration management
3. Load balancing and horizontal scaling setup
4. Enhanced error handling and logging
5. Performance monitoring and metrics
6. Integration tests for all API endpoints
7. WebSocket connection pooling optimization
8. Database migration scripts

Test the server with multiple concurrent connections and verify cross-device synchronization works correctly."
```

#### **Key Files to Work On**:
- `/home/seanos1a/realtime-sync-server/Dockerfile`
- `/home/seanos1a/realtime-sync-server/docker-compose.yml`
- `/home/seanos1a/realtime-sync-server/config/production.js`
- `/home/seanos1a/realtime-sync-server/tests/`

### **2. Sync Client**
### **Location**: `/home/seanos1a/codeserver-sync-client`

### **Project Overview**
Client-side library for cross-device synchronization in code-server environments.

### **Current State**
- ✅ TypeScript library structure with rollup build
- ⏳ **Next**: Core synchronization implementation

### **Immediate Next Steps**
```bash
# Use this prompt to continue development:
"Complete the code-server sync client implementation by:
1. Implementing core WebSocket connection management
2. Adding session persistence and restoration logic
3. Creating conflict resolution algorithms
4. Building TypeScript interfaces for all API types
5. Adding error handling and reconnection logic
6. Writing comprehensive unit tests
7. Creating example integration code
8. Building documentation for developers

Ensure the client integrates seamlessly with the sync server and handles network disruptions gracefully."
```

---

## 📰 **GLOBAL NEWS AI**

### **Location**: `/home/seanos1a/global-news-ai`

### **Project Overview**
AI-powered news aggregation and summarization application with multi-source support.

### **Current State**
- ✅ Next.js 14 application with TypeScript
- ✅ AI summarization with OpenAI GPT integration
- ✅ Multi-source news aggregation (RSS + News API)
- ✅ CI/CD pipeline and Docker configuration
- ⏳ **Next**: Enhanced UI/UX and mobile optimization

### **Immediate Next Steps**
```bash
# Use this prompt to continue development:
"Enhance the Global News AI application by implementing:
1. Advanced search functionality with filters
2. User preference management and personalization
3. Mobile-responsive design improvements
4. Offline reading capabilities with service workers
5. Social sharing features
6. Bookmark categorization and tagging
7. Reading history and recommendations
8. Performance optimization for news feed loading
9. Error handling for API failures
10. Accessibility improvements (WCAG 2.1)

Test all features across different devices and ensure the AI summarization works reliably with various news sources."
```

---

## 🚀 **PORTFOLIO & AI PROJECTS**

### **1. Portfolio Hub**
### **Location**: `/home/seanos1a/portfolio-hub`

### **Current State**
- ✅ React 19 + TypeScript + Tailwind CSS
- ✅ Basic portfolio structure
- ⏳ **Next**: Content population and animations

### **Next Steps Prompt**:
```bash
"Complete the Portfolio Hub by:
1. Adding project showcase sections with detailed case studies
2. Implementing smooth scroll animations with Framer Motion
3. Creating contact form with backend integration
4. Adding skills visualization with interactive charts
5. Building dark/light theme toggle
6. Optimizing for SEO and performance
7. Adding testimonials section
8. Creating downloadable resume feature
9. Implementing analytics tracking
10. Deploying to production with CI/CD"
```

### **2. Sean's Landing Page (Orbit Portfolio)**
### **Location**: `/home/seanos1a/sean-s-landing-page`

### **Current State**
- ✅ React 19 with TypeScript and Vite
- ✅ Google GenAI integration
- ✅ Data visualization with Recharts
- ✅ Modern animations with Framer Motion
- ⏳ **Next**: Content refinement and deployment

### **Next Steps Prompt**:
```bash
"Refine Sean's Landing Page by:
1. Optimizing AI integration for better user interactions
2. Adding more interactive data visualizations
3. Implementing project case studies with detailed descriptions
4. Creating blog section with AI-assisted content generation
5. Adding newsletter subscription functionality
6. Implementing advanced SEO optimization
7. Creating admin panel for content management
8. Adding multilingual support
9. Implementing performance monitoring
10. Setting up analytics and user behavior tracking"
```

### **3. H2H (HeartToHeart AI)**
### **Location**: `/home/seanos1a/h2h`

### **Current State**
- ✅ React application with TypeScript
- ✅ Caddy reverse proxy configuration
- ⏳ **Next**: Core AI communication features

### **Next Steps Prompt**:
```bash
"Develop the H2H AI communication platform by:
1. Implementing core AI chat functionality
2. Adding conversation history and persistence
3. Creating user authentication and profiles
4. Building real-time messaging with WebSocket support
5. Adding voice input/output capabilities
6. Implementing conversation context management
7. Creating AI personality customization
8. Adding multi-language support
9. Implementing privacy and security features
10. Setting up monitoring and analytics"
```

---

## 📱 **MOBILE & SPECIALIZED PROJECTS**

### **1. EcoTracker App**
### **Location**: `/home/seanos1a/ecotracker-app`

### **Current State**
- ✅ React Native with Expo
- ✅ TypeScript implementation
- ✅ Navigation structure
- ⏳ **Next**: Core tracking features and data visualization

### **Next Steps Prompt**:
```bash
"Complete the EcoTracker mobile app by:
1. Implementing ecological activity tracking features
2. Adding carbon footprint calculation algorithms
3. Creating interactive charts for environmental impact
4. Building social features for community challenges
5. Adding GPS tracking for outdoor activities
6. Implementing camera integration for photo logging
7. Creating offline data synchronization
8. Adding push notifications for eco-reminders
9. Building achievement system and rewards
10. Publishing to App Store and Google Play"
```

### **2. Nebula UI**
### **Location**: `/home/seanos1a/nebula-ui`

### **Current State**
- ✅ UI component library
- ✅ Migrated to React 19
- ⏳ **Next**: Component library expansion and documentation

### **Next Steps Prompt**:
```bash
"Expand the Nebula UI component library by:
1. Adding advanced components (data tables, forms, modals)
2. Creating comprehensive Storybook documentation
3. Implementing theming system with CSS variables
4. Adding accessibility features (ARIA labels, keyboard navigation)
5. Creating component unit tests with React Testing Library
6. Building design system guidelines
7. Adding animation utilities and transitions
8. Implementing dark/light theme variants
9. Creating npm package for distribution
10. Setting up automated visual regression testing"
```

---

## 🔧 **INFRASTRUCTURE & DEVOPS TASKS**

### **Development Environment Setup**
```bash
# Use this prompt for infrastructure improvements:
"Improve the development environment by:
1. Setting up automated backup system for all projects
2. Creating centralized logging and monitoring
3. Implementing security scanning and vulnerability detection
4. Building automated deployment pipelines
5. Creating disaster recovery procedures
6. Setting up performance monitoring and alerting
7. Implementing secret management system
8. Creating development environment consistency checks
9. Building CI/CD templates for reuse
10. Setting up cost optimization and resource monitoring"
```

### **Mobile Development Workflow Enhancement**
```bash
"Enhance the mobile development workflow by:
1. Improving code-server mobile interface responsiveness
2. Adding touch-optimized terminal features
3. Implementing mobile-specific keyboard shortcuts
4. Creating mobile device testing integration
5. Adding remote debugging capabilities
6. Building mobile performance monitoring
7. Creating mobile deployment automation
8. Implementing mobile crash reporting
9. Adding mobile analytics integration
10. Creating mobile user testing workflows"
```

---

## 🤖 **AI INTEGRATION IMPROVEMENTS**

### **Claude Orchestrator Enhancement**
```bash
"Enhance the AI integration systems by:
1. Improving context window management and compression
2. Adding quality gate automation
3. Implementing A/B testing for AI model performance
4. Creating custom workflow templates
5. Adding cost optimization for AI API calls
6. Building AI response caching system
7. Implementing AI model fallback strategies
8. Creating AI usage analytics and reporting
9. Adding AI safety and content filtering
10. Building custom AI skill development tools"
```

---

## 📋 **PROJECT MANAGEMENT REMINDERS**

### **Best Practices for Each Project**
1. **Always read existing code before making changes**
2. **Test locally before committing** (`npm run dev`, `npm test`)
3. **Use TodoWrite tool for multi-step tasks**
4. **Commit only when explicitly requested**
5. **Follow existing code patterns and conventions**
6. **Add comprehensive error handling at system boundaries**
7. **Write tests for new functionality**
8. **Update documentation when adding features**
9. **Use bash aliases for mobile development** (`c`, `cdev`, `cplan`)
10. **Leverage GitHub CLI for all GitHub operations**

### **AI Model Selection Guide**
- **Claude Sonnet 4.5**: File operations, git workflows, coordination
- **Gemini 3 Pro Preview**: Complex algorithms, research, advanced reasoning
- **Enhanced Orchestrator**: Automated workflows with quality gates (`co "task"`)

### **Emergency Procedures**
- **Code rollback**: Use `Esc + Esc` in Claude Code for checkpoints
- **Server issues**: Check `/home/seanos1a/.claude/mobile-dev-prompt.md`
- **Deployment problems**: Use `/sandbox` command for risky operations

---

## 🎯 **IMMEDIATE ACTION ITEMS**

### **This Week Priority Order**:
1. **GIMP Platform** - Start Week 1 infrastructure setup
2. **Sync Server** - Production deployment preparation
3. **Sync Client** - Core implementation completion
4. **Global News AI** - Mobile optimization
5. **Portfolio projects** - Content population

### **Success Metrics to Track**:
- **GIMP Platform**: Infrastructure setup completion
- **Sync Server**: 100+ concurrent connections test
- **Global News AI**: Mobile performance scores
- **Portfolio Sites**: SEO optimization completion
- **Mobile Apps**: App store submission readiness

---

**Last Updated**: November 24, 2025
**Maintained By**: Human Developer + AI Assistant Collaboration
**Review Frequency**: Weekly - Update project states and next steps

---

**How to Use This File**:
1. Choose the project you want to work on
2. Copy the provided prompt for that project
3. Paste it into Claude Code or your AI assistant
4. Follow the generated implementation steps
5. Update this file with progress and new next steps
6. Repeat until projects are complete

**Tip**: Start with the highest priority project and work through the steps systematically. Each prompt is designed to be comprehensive and actionable.