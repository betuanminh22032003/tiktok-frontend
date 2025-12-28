/**
 * ============================================================================
 * TikTok Frontend - Health Check API
 * ============================================================================
 * Health check endpoint for Kubernetes probes.
 * Used by:
 * - Kubernetes livenessProbe (restart if unhealthy)
 * - Kubernetes readinessProbe (remove from service if not ready)
 * - Load balancer health checks
 * - Monitoring systems
 *
 * Response codes:
 * - 200: Healthy and ready
 * - 503: Unhealthy or not ready
 * ============================================================================
 */

import { NextResponse } from 'next/server'

/**
 * Health check response interface
 * Follows standard health check response format
 */
interface HealthCheckResponse {
  // Overall status: 'healthy' | 'unhealthy' | 'degraded'
  status: 'healthy' | 'unhealthy' | 'degraded'
  // Timestamp of the check
  timestamp: string
  // Application version from env or package.json
  version: string
  // Environment (development, staging, production)
  environment: string
  // Uptime in seconds
  uptime: number
  // Individual component checks
  checks: {
    // Memory usage check
    memory: {
      status: 'pass' | 'fail'
      used: number
      total: number
      percentage: number
    }
  }
}

// Track server start time for uptime calculation
const startTime = Date.now()

/**
 * GET /api/health
 * Health check endpoint for Kubernetes probes
 *
 * @returns Health check response with status 200 or 503
 */
export async function GET(): Promise<NextResponse<HealthCheckResponse>> {
  try {
    // Calculate uptime
    const uptime = Math.floor((Date.now() - startTime) / 1000)

    // Get memory usage (Node.js specific)
    const memoryUsage = process.memoryUsage()
    const usedMemory = memoryUsage.heapUsed
    const totalMemory = memoryUsage.heapTotal
    const memoryPercentage = Math.round((usedMemory / totalMemory) * 100)

    // Memory check: fail if using more than 90% of heap
    const memoryStatus = memoryPercentage < 90 ? 'pass' : 'fail'

    // Determine overall status
    const isHealthy = memoryStatus === 'pass'

    // Build response
    const response: HealthCheckResponse = {
      // Overall health status
      status: isHealthy ? 'healthy' : 'degraded',
      // ISO timestamp
      timestamp: new Date().toISOString(),
      // Application version from environment
      version: process.env.NEXT_PUBLIC_APP_VERSION || '1.0.0',
      // Current environment
      environment: process.env.NEXT_PUBLIC_APP_ENV || 'development',
      // Server uptime in seconds
      uptime,
      // Individual checks
      checks: {
        memory: {
          status: memoryStatus,
          used: Math.round(usedMemory / 1024 / 1024), // MB
          total: Math.round(totalMemory / 1024 / 1024), // MB
          percentage: memoryPercentage,
        },
      },
    }

    // Return response with appropriate status code
    return NextResponse.json(response, {
      status: isHealthy ? 200 : 503,
      headers: {
        // Prevent caching of health checks
        'Cache-Control': 'no-cache, no-store, must-revalidate',
        'Pragma': 'no-cache',
        'Expires': '0',
      },
    })
  } catch (error) {
    // If health check itself fails, return unhealthy
    const errorResponse: HealthCheckResponse = {
      status: 'unhealthy',
      timestamp: new Date().toISOString(),
      version: process.env.NEXT_PUBLIC_APP_VERSION || '1.0.0',
      environment: process.env.NEXT_PUBLIC_APP_ENV || 'development',
      uptime: Math.floor((Date.now() - startTime) / 1000),
      checks: {
        memory: {
          status: 'fail',
          used: 0,
          total: 0,
          percentage: 0,
        },
      },
    }

    return NextResponse.json(errorResponse, {
      status: 503,
      headers: {
        'Cache-Control': 'no-cache, no-store, must-revalidate',
      },
    })
  }
}

/**
 * HEAD /api/health
 * Lightweight health check for load balancers
 * Returns only status code, no body
 */
export async function HEAD(): Promise<NextResponse> {
  try {
    // Quick memory check
    const memoryUsage = process.memoryUsage()
    const memoryPercentage = (memoryUsage.heapUsed / memoryUsage.heapTotal) * 100

    // Return 200 if healthy, 503 if not
    return new NextResponse(null, {
      status: memoryPercentage < 90 ? 200 : 503,
      headers: {
        'Cache-Control': 'no-cache, no-store, must-revalidate',
      },
    })
  } catch {
    return new NextResponse(null, { status: 503 })
  }
}
