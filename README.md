# TikTok Clone - Production Frontend

<div align="center">

![TikTok Clone](https://img.shields.io/badge/TikTok-Clone-ff0050?style=for-the-badge&logo=tiktok&logoColor=white)
![Next.js](https://img.shields.io/badge/Next.js-16-black?style=for-the-badge&logo=next.js&logoColor=white)
![TypeScript](https://img.shields.io/badge/TypeScript-5-3178C6?style=for-the-badge&logo=typescript&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-Ready-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![ArgoCD](https://img.shields.io/badge/ArgoCD-GitOps-EF7B4D?style=for-the-badge&logo=argo&logoColor=white)

**A production-ready TikTok clone frontend built with Next.js, deployed on Kubernetes via GitOps**

[Features](#features) • [Quick Start](#quick-start) • [Development](#development) • [Deployment](#deployment) • [Architecture](#architecture)

</div>

---

## 📋 Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Quick Start](#quick-start)
- [Development](#development)
- [Docker](#docker)
- [Kubernetes Deployment](#kubernetes-deployment)
- [GitOps with ArgoCD](#gitops-with-argocd)
- [CI/CD Pipeline](#cicd-pipeline)
- [Project Structure](#project-structure)
- [Environment Configuration](#environment-configuration)
- [Contributing](#contributing)

---

## ✨ Features

### Application Features
- 📱 **Vertical Video Feed** - TikTok-style infinite scrolling video feed
- 👤 **User Profiles** - Profile pages with user videos and stats
- 📤 **Video Upload** - Upload and share videos with captions
- ❤️ **Interactions** - Like, comment, and share functionality
- 🔍 **Discovery** - Search and explore content
- 📲 **Mobile-First** - Responsive design optimized for mobile

### Technical Features
- ⚡ **Next.js 16** - Latest App Router with React 19
- 🎨 **TailwindCSS** - Utility-first styling
- 🔄 **SWR** - Stale-while-revalidate data fetching
- 🐳 **Docker** - Multi-stage optimized builds (~50MB image)
- ☸️ **Kubernetes** - Production-grade Helm charts
- 🔄 **GitOps** - ArgoCD for declarative deployments
- 🚀 **CI/CD** - GitHub Actions automation

---

## 🛠 Tech Stack

| Category | Technology |
|----------|------------|
| Framework | Next.js 16 (App Router) |
| Language | TypeScript 5 |
| Styling | TailwindCSS |
| State Management | React Hooks + SWR |
| Animation | Framer Motion |
| Container | Docker (Alpine) |
| Orchestration | Kubernetes + Helm |
| GitOps | ArgoCD |
| CI/CD | GitHub Actions |

---

## 🚀 Quick Start

### Prerequisites

- Node.js 20+
- npm 10+
- Docker (optional)
- kubectl (for Kubernetes deployment)
- Helm 3+ (for Kubernetes deployment)

### Local Development

```bash
# Clone the repository
git clone https://github.com/your-org/tiktok-frontend.git
cd tiktok-frontend

# Install dependencies
npm install

# Copy environment variables
cp .env.example .env.local

# Start development server (with Turbopack)
npm run dev

# Open http://localhost:3000
```

---

## 💻 Development

### Available Scripts

```bash
# Development server with hot reload
npm run dev

# Production build
npm run build

# Start production server
npm start

# Run linter
npm run lint

# Fix lint issues
npm run lint:fix

# Type checking
npm run type-check

# Format code
npm run format

# Run tests
npm run test

# Run tests with coverage
npm run test:coverage

# Clean build artifacts
npm run clean
```

### Code Quality

```bash
# Run all checks (recommended before committing)
npm run lint && npm run type-check && npm run test
```

---

## 🐳 Docker

### Build Image

```bash
# Build production image
docker build -t tiktok-fe:latest .

# Build with custom environment
docker build \
  --build-arg NEXT_PUBLIC_API_URL=https://api.example.com \
  --build-arg NEXT_PUBLIC_APP_ENV=production \
  -t tiktok-fe:1.0.0 .
```

### Run Container

```bash
# Run locally
docker run -p 3000:3000 tiktok-fe:latest

# Run with environment variables
docker run -p 3000:3000 \
  -e NEXT_PUBLIC_API_URL=https://api.example.com \
  tiktok-fe:latest

# Run in detached mode
docker run -d -p 3000:3000 --name tiktok-fe tiktok-fe:latest
```

### Docker Compose (Development)

```bash
# Start with docker-compose
docker-compose up -d

# View logs
docker-compose logs -f

# Stop
docker-compose down
```

---

## ☸️ Kubernetes Deployment

### Using Helm

```bash
# Add your Helm repository (if hosted)
helm repo add tiktok-charts https://charts.example.com
helm repo update

# Install to development environment
helm install tiktok-fe ./charts/tiktok-fe \
  --namespace tiktok-dev \
  --create-namespace \
  -f ./charts/tiktok-fe/values-dev.yaml

# Install to staging environment
helm install tiktok-fe ./charts/tiktok-fe \
  --namespace tiktok-staging \
  --create-namespace \
  -f ./charts/tiktok-fe/values-staging.yaml

# Install to production environment
helm install tiktok-fe ./charts/tiktok-fe \
  --namespace tiktok-prod \
  --create-namespace \
  -f ./charts/tiktok-fe/values-prod.yaml
```

### Upgrade Deployment

```bash
# Upgrade with new values
helm upgrade tiktok-fe ./charts/tiktok-fe \
  --namespace tiktok-prod \
  -f ./charts/tiktok-fe/values-prod.yaml

# Upgrade with new image tag
helm upgrade tiktok-fe ./charts/tiktok-fe \
  --namespace tiktok-prod \
  --set image.tag=1.2.0 \
  -f ./charts/tiktok-fe/values-prod.yaml
```

### Rollback

```bash
# View history
helm history tiktok-fe -n tiktok-prod

# Rollback to previous version
helm rollback tiktok-fe -n tiktok-prod

# Rollback to specific revision
helm rollback tiktok-fe 2 -n tiktok-prod
```

### Useful kubectl Commands

```bash
# Check pod status
kubectl get pods -n tiktok-prod -l app.kubernetes.io/name=tiktok-fe

# View logs
kubectl logs -n tiktok-prod -l app.kubernetes.io/name=tiktok-fe -f

# Describe deployment
kubectl describe deployment -n tiktok-prod tiktok-fe

# Port forward for local access
kubectl port-forward -n tiktok-prod svc/tiktok-fe 8080:80

# Scale deployment
kubectl scale deployment -n tiktok-prod tiktok-fe --replicas=5

# Restart deployment
kubectl rollout restart deployment -n tiktok-prod tiktok-fe
```

---

## 🔄 GitOps with ArgoCD

### Prerequisites

1. ArgoCD installed in your cluster
2. Repository connected to ArgoCD

### Deploy Applications

```bash
# Apply ArgoCD project
kubectl apply -f argocd/project.yaml

# Deploy to development
kubectl apply -f argocd/applications/dev.yaml

# Deploy to staging
kubectl apply -f argocd/applications/staging.yaml

# Deploy to production (manual sync required)
kubectl apply -f argocd/applications/prod.yaml
```

### Sync via CLI

```bash
# Login to ArgoCD
argocd login argocd.example.com

# List applications
argocd app list

# Sync development
argocd app sync tiktok-fe-dev

# Sync staging
argocd app sync tiktok-fe-staging

# Sync production (requires confirmation)
argocd app sync tiktok-fe-prod

# View application status
argocd app get tiktok-fe-prod
```

### Promotion Workflow

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│     Dev     │───▶│   Staging   │───▶│ Production  │
└─────────────┘    └─────────────┘    └─────────────┘
       │                  │                   │
  Auto-sync          Auto-sync          Manual-sync
       │                  │                   │
   develop              main               main
    branch             branch             branch
```

---

## 🔧 CI/CD Pipeline

### GitHub Actions Workflows

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `ci.yml` | Push/PR | Lint, test, build verification |
| `docker-build.yml` | CI success, tags | Build and push Docker image |
| `deploy.yml` | Manual | Deploy to specific environment |

### CI Pipeline

```yaml
# Triggered on push to main/develop and PRs
Jobs:
  1. quality   - ESLint, TypeScript, Prettier
  2. test      - Unit tests with coverage
  3. build     - Next.js production build
  4. security  - npm audit, Trivy scan
```

### CD Pipeline

```yaml
# Triggered after CI passes
Jobs:
  1. prepare   - Determine environment and tag
  2. build     - Multi-arch Docker build
  3. scan      - Security vulnerability scan
  4. deploy    - Update Helm values (trigger ArgoCD)
```

### Manual Deployment

1. Go to Actions → "Deploy to Environment"
2. Click "Run workflow"
3. Select environment (dev/staging/prod)
4. Optionally specify image tag
5. Provide deployment reason

---

## 📁 Project Structure

```
tiktok-frontend/
├── app/                      # Next.js App Router
│   ├── api/                  # API routes
│   │   └── health/           # Health check endpoint
│   ├── components/           # React components
│   ├── context/              # React context providers
│   ├── hooks/                # Custom React hooks
│   ├── layouts/              # Page layouts
│   ├── post/                 # Post pages
│   ├── profile/              # Profile pages
│   ├── providers/            # Provider components
│   ├── stores/               # State stores
│   ├── upload/               # Upload page
│   ├── layout.tsx            # Root layout
│   ├── page.tsx              # Home page
│   └── types.tsx             # TypeScript types
├── charts/                   # Helm charts
│   └── tiktok-fe/
│       ├── templates/        # Kubernetes manifests
│       ├── Chart.yaml        # Chart metadata
│       ├── values.yaml       # Base values
│       ├── values-dev.yaml   # Dev overrides
│       ├── values-staging.yaml
│       └── values-prod.yaml
├── argocd/                   # ArgoCD manifests
│   ├── applications/         # Application definitions
│   │   ├── dev.yaml
│   │   ├── staging.yaml
│   │   └── prod.yaml
│   └── project.yaml          # ArgoCD project
├── config/                   # Application config
│   └── env.ts                # Environment configuration
├── libs/                     # Shared utilities
├── public/                   # Static assets
├── .github/workflows/        # GitHub Actions
│   ├── ci.yml                # CI workflow
│   ├── docker-build.yml      # Build workflow
│   └── deploy.yml            # Deploy workflow
├── Dockerfile                # Multi-stage Docker build
├── .dockerignore             # Docker ignore rules
└── package.json              # Dependencies
```

---

## ⚙️ Environment Configuration

### Environment Files

| File | Purpose |
|------|---------|
| `.env.example` | Template with all variables |
| `.env.development` | Development defaults |
| `.env.staging` | Staging configuration |
| `.env.production` | Production configuration |
| `.env.local` | Local overrides (gitignored) |

### Key Variables

```bash
# Application
NEXT_PUBLIC_APP_ENV=production
NEXT_PUBLIC_APP_NAME=TikTok Clone
NEXT_PUBLIC_APP_VERSION=1.0.0

# API
NEXT_PUBLIC_API_URL=https://api.example.com
NEXT_PUBLIC_API_TIMEOUT=30000

# Features
NEXT_PUBLIC_ENABLE_UPLOAD=true
NEXT_PUBLIC_ENABLE_COMMENTS=true

# Storage
NEXT_PUBLIC_CDN_URL=https://cdn.example.com
```

---

## 🏗 Architecture

### High-Level Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                        User Browser                           │
└──────────────────────────┬───────────────────────────────────┘
                           │ HTTPS
                           ▼
┌──────────────────────────────────────────────────────────────┐
│                    Ingress Controller                         │
│                    (NGINX / Traefik)                         │
└──────────────────────────┬───────────────────────────────────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────────────┐
│                   Kubernetes Service                          │
│                    (ClusterIP)                               │
└──────────────────────────┬───────────────────────────────────┘
                           │
              ┌────────────┼────────────┐
              ▼            ▼            ▼
         ┌────────┐   ┌────────┐   ┌────────┐
         │ Pod 1  │   │ Pod 2  │   │ Pod 3  │
         │Next.js │   │Next.js │   │Next.js │
         └────────┘   └────────┘   └────────┘
              │            │            │
              └────────────┼────────────┘
                           │
                           ▼
                    ┌─────────────┐
                    │ Backend API │
                    └─────────────┘
```

### GitOps Flow

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   GitHub    │────▶│  GitHub     │────▶│   GitHub    │
│   Actions   │     │  Container  │     │  Repository │
│   (CI)      │     │  Registry   │     │  (values)   │
└─────────────┘     └─────────────┘     └──────┬──────┘
                                               │
                                               │ watches
                                               ▼
                                        ┌─────────────┐
                                        │   ArgoCD    │
                                        │   (GitOps)  │
                                        └──────┬──────┘
                                               │
                                               │ syncs
                                               ▼
                                        ┌─────────────┐
                                        │ Kubernetes  │
                                        │  Cluster    │
                                        └─────────────┘
```

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines

- Follow the existing code style
- Write tests for new features
- Update documentation as needed
- Keep commits atomic and well-described

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<div align="center">

**Built with ❤️ for learning and production use**

[⬆ Back to Top](#tiktok-clone---production-frontend)

</div>

| Key           | Type   |
| ------------- | ------ |
| `Document ID` | String |
| `user_id`     | String |
| `video_url`   | String |
| `text`        | String |
| `created_at`  | String |

Post Indexes:
| KEY | TYPE | ATTRIBUTE | ASC/DESC |
| ------------- | ------------- | ------------- | ------------- |
| user_id | key | user_id | asc |

Profile Settings (Update Permissions):
| Add Role | PERMISSIONS |
| ------------- | ------------- |
| All guests | Read |
| All users | Create, Read, Update, Delete |

### Like Collection:

| Key           | Type   |
| ------------- | ------ |
| `Document ID` | String |
| `user_id`     | String |
| `post_id`     | String |

Like Indexes:
| KEY | TYPE | ATTRIBUTE | ASC/DESC |
| ------------- | ------------- | ------------- | ------------- |
| user_id | key | user_id | asc |
| id | unique | id | asc |
| post_id | key | post_id | asc |

Like Settings (Update Permissions):
| Add Role | PERMISSIONS |
| ------------- | ------------- |
| All guests | Read |
| All users | Create, Read, Update, Delete |

### Comment Collection:

| Key           | Type   |
| ------------- | ------ |
| `Document ID` | String |
| `user_id`     | String |
| `post_id`     | String |
| `text`        | String |
| `created_at`  | String |

Comment Indexes:
| KEY | TYPE | ATTRIBUTE | ASC/DESC |
| ------------- | ------------- | ------------- | ------------- |
| post_id | key | post_id | asc |

Comment Settings (Update Permissions):
| Add Role | PERMISSIONS |
| ------------- | ------------- |
| All guests | Read |
| All users | Create, Read, Update, Delete |

Once you've connected your application to AppWrite. Run the commands.

```
npm i

npm run dev
```

You should be good to go! If you need any more help, take a look at the tutorial video by clicking the image above.
