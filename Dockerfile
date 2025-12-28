# ============================================================================
# TikTok Frontend - Production Dockerfile
# ============================================================================
# Multi-stage Docker build optimized for:
# - Minimal image size (~50MB)
# - Fast builds with layer caching
# - Security (non-root user, minimal packages)
# - Multi-architecture support (amd64, arm64)
#
# Build stages:
# 1. base     - Common Node.js setup
# 2. deps     - Install dependencies
# 3. builder  - Build Next.js application
# 4. runner   - Production runtime
# ============================================================================

# -----------------------------------------------------------------------------
# Stage 1: BASE
# -----------------------------------------------------------------------------
# Set up the base Node.js environment used by all subsequent stages.
# Using Alpine for minimal image size (~5MB base).
# -----------------------------------------------------------------------------
FROM node:20-alpine AS base

# Set working directory for all stages
WORKDIR /app

# Environment variables for build optimization
# CI=true optimizes npm for CI environments (faster, no progress bars)
ENV CI=true
# Disable Next.js telemetry during build
ENV NEXT_TELEMETRY_DISABLED=1

# -----------------------------------------------------------------------------
# Stage 2: DEPS
# -----------------------------------------------------------------------------
# Install all dependencies in a separate stage for better caching.
# Dependencies only change when package*.json changes.
# -----------------------------------------------------------------------------
FROM base AS deps

# Install build dependencies required for native modules
# - libc6-compat: Required for some npm packages on Alpine
# - python3, make, g++: Required for node-gyp (native module compilation)
# These are only needed in this stage, not in the final image
RUN apk add --no-cache \
    libc6-compat \
    python3 \
    make \
    g++

# Copy package files first (better cache utilization)
# Only copy what's needed for npm install
COPY package.json package-lock.json* ./

# Install dependencies based on lock file presence
# --legacy-peer-deps: Required for React 19 compatibility
# --ignore-scripts: Security - don't run postinstall scripts during build
RUN if [ -f package-lock.json ]; then \
        # Production install with legacy-peer-deps for React 19
        npm install --legacy-peer-deps --ignore-scripts; \
    else \
        # Fallback if no lock file (not recommended for production)
        echo "Warning: package-lock.json not found" && \
        npm install --legacy-peer-deps --ignore-scripts; \
    fi

# -----------------------------------------------------------------------------
# Stage 3: BUILDER
# -----------------------------------------------------------------------------
# Build the Next.js application with production optimizations.
# This stage creates the standalone output for minimal runtime.
# -----------------------------------------------------------------------------
FROM base AS builder

# Build-time arguments for environment configuration
# These are injected during docker build via --build-arg
ARG NEXT_PUBLIC_APP_ENV=production
ARG NEXT_PUBLIC_API_URL=https://api.example.com
ARG NEXT_PUBLIC_CDN_URL=https://cdn.example.com
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

# Set build-time environment variables
# These become baked into the Next.js build
ENV NEXT_PUBLIC_APP_ENV=${NEXT_PUBLIC_APP_ENV}
ENV NEXT_PUBLIC_API_URL=${NEXT_PUBLIC_API_URL}
ENV NEXT_PUBLIC_CDN_URL=${NEXT_PUBLIC_CDN_URL}

# Copy dependencies from deps stage
COPY --from=deps /app/node_modules ./node_modules

# Copy source code
# Use .dockerignore to exclude unnecessary files
COPY . .

# Build the Next.js application
# Output: .next/standalone (minimal server)
# Output: .next/static (static assets)
RUN npm run build

# -----------------------------------------------------------------------------
# Stage 4: RUNNER
# -----------------------------------------------------------------------------
# Minimal production runtime with only what's needed to run the app.
# Security hardened with non-root user.
# -----------------------------------------------------------------------------
FROM node:20-alpine AS runner

# Set working directory
WORKDIR /app

# Set production environment
ENV NODE_ENV=production
# Disable telemetry in production
ENV NEXT_TELEMETRY_DISABLED=1
# Port the application listens on
ENV PORT=3000
# Hostname for Next.js server (0.0.0.0 allows external connections)
ENV HOSTNAME="0.0.0.0"

# Install only runtime dependencies
# - dumb-init: Proper signal handling for Node.js in containers
# - curl: For health checks
RUN apk add --no-cache \
    dumb-init \
    curl

# Create non-root user for security
# Running as root in containers is a security risk
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 --ingroup nodejs nextjs

# Copy public assets (static files like images, fonts)
COPY --from=builder /app/public ./public

# Set correct permissions for prerender cache
# Next.js needs to write to .next directory at runtime
RUN mkdir -p .next && chown nextjs:nodejs .next

# Copy standalone Next.js build output
# This includes only what's needed to run the server (~50MB total)
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./

# Copy static assets
# These are served directly by Next.js
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

# Switch to non-root user before running the application
USER nextjs

# Expose the application port (documentation only)
# Actual port binding happens at container runtime
EXPOSE 3000

# Add labels for image metadata (OCI standard)
# These are useful for image inspection and registry UI
LABEL org.opencontainers.image.title="TikTok Frontend" \
      org.opencontainers.image.description="TikTok Clone Frontend Application" \
      org.opencontainers.image.source="https://github.com/your-org/tiktok-frontend" \
      org.opencontainers.image.vendor="TikTok Clone" \
      org.opencontainers.image.licenses="MIT"

# Health check to verify the application is running
# Kubernetes will also use livenessProbe/readinessProbe
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/api/health || exit 1

# Use dumb-init as PID 1 for proper signal handling
# This ensures graceful shutdown on SIGTERM from Kubernetes
ENTRYPOINT ["dumb-init", "--"]

# Start the Next.js standalone server
# Using node directly (not npm) for faster startup
CMD ["node", "server.js"]
