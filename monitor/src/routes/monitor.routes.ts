import { Router, Request, Response } from 'express';
import { getMetrics } from '../services/metrics.service.js';
import { logger } from '../utils/logger.js';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';
import fetch from 'node-fetch';

interface ServiceHealthResponse {
  status: string;
  message: string;
  timestamp?: number;
}

// ESM에서 경로 처리
const currentDir = dirname(fileURLToPath(import.meta.url));
const publicPath = join(currentDir, '../../public/index.html');

export const setupMonitorRoutes = (app: Router) => {
  // 모니터링 데이터 API
  app.get('/api/monitor', async (req: Request, res: Response) => {
    try {
      // 1. 시스템 상태 정보
      const systemStatus = {
        uptime: process.uptime(),
        timestamp: Date.now(),
        memory: process.memoryUsage(),
        cpu: process.cpuUsage()
      };

      // 2. 메트릭스 정보
      const metrics = await getMetrics();

      // 3. 서비스 헬스체크
      const services = {
        api: await checkServiceHealth('http://api:8000', 'API'),
        client: await checkServiceHealth('http://client:3000', 'Client'),
        proxy: await checkServiceHealth('http://proxy:80', 'Proxy')
      };

      // 4. 통합 정보 반환
      const monitoringData = {
        status: 'ok',
        timestamp: Date.now(),
        system: systemStatus,
        metrics: metrics,
        services: services
      };

      res.json(monitoringData);
    } catch (error) {
      logger.error('통합 모니터링 데이터 조회 오류:', error);
      res.status(500).json({
        status: 'error',
        error: '모니터링 데이터 조회 중 오류가 발생했습니다.',
        details: error instanceof Error ? error.message : '알 수 없는 오류'
      });
    }
  });

  // 대시보드 UI 제공
  app.get('/monitor', (req: Request, res: Response) => {
    res.sendFile(publicPath);
  });
};

async function checkServiceHealth(url: string, serviceName: string): Promise<{ status: string; responseTime: number; message?: string }> {
  const startTime = Date.now();
  try {
    logger.info(`${serviceName} 헬스체크 시도 중... (${url})`);

    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 5000);

    const healthCheckUrl = `${url.replace(/\/$/, '')}/health`;
    logger.info(`헬스체크 URL: ${healthCheckUrl}`);

    const response = await fetch(healthCheckUrl, {
      method: 'GET',
      signal: controller.signal,
      headers: {
        'Accept': 'application/json'
      },
      timeout: 5000
    });

    clearTimeout(timeoutId);
    const responseTime = Date.now() - startTime;

    if (response.ok) {
      const data = await response.json() as ServiceHealthResponse;
      logger.info(`${serviceName} 헬스체크 성공 (${responseTime}ms)`, JSON.stringify(data));
      return {
        status: data.status === 'healthy' ? 'healthy' : 'unhealthy',
        responseTime,
        message: data.message || '정상'
      };
    } else {
      const message = `HTTP 상태 코드: ${response.status}`;
      logger.warn(`${serviceName} 헬스체크 실패: ${message}`);
      return {
        status: 'unhealthy',
        responseTime,
        message
      };
    }
  } catch (error) {
    const responseTime = Date.now() - startTime;
    const message = error instanceof Error ? error.message : '알 수 없는 오류';

    if (error instanceof Error && error.name === 'AbortError') {
      logger.error(`${serviceName} 헬스체크 타임아웃`);
      return {
        status: 'timeout',
        responseTime,
        message: '응답 시간 초과'
      };
    }

    logger.error(`${serviceName} 헬스체크 실패:`, error);
    return {
      status: 'unreachable',
      responseTime,
      message
    };
  }
}
