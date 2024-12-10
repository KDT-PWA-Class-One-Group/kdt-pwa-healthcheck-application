import { Application, Request, Response } from 'express';
import { logger } from '../utils/logger.js';
import fetch from 'node-fetch';

interface ServiceHealthResponse {
  status?: string;
  message?: string;
  [key: string]: any;
}

export const setupHealthRoutes = (app: Application) => {
  // 기본 헬스체크 엔드포인트
  app.get('/health', async (req: Request, res: Response) => {
    try {
      const services = {
        api: await checkServiceHealth('http://healthcheck-api:8000', 'API'),
        client: await checkServiceHealth('http://healthcheck-client:3000', 'Client'),
        proxy: await checkServiceHealth('http://healthcheck-proxy:80', 'Proxy')
      };

      const allHealthy = Object.values(services).every(service => service.status === 'healthy');

      const healthStatus = {
        status: allHealthy ? 'healthy' : 'degraded',
        timestamp: Date.now(),
        uptime: process.uptime(),
        memory: process.memoryUsage(),
        services
      };

      res.status(allHealthy ? 200 : 503).json(healthStatus);

      if (!allHealthy) {
        logger.warn('일부 서비스가 정상 작동하지 않습니다:', services);
      } else {
        logger.info('모든 서비스가 정상 작동 중입니다.');
      }
    } catch (error) {
      logger.error('헬스체크 오류:', error);
      res.status(500).json({
        status: 'error',
        timestamp: Date.now(),
        error: '헬스체크 중 오류가 발생했습니다.',
        details: error instanceof Error ? error.message : '알 수 없는 오류'
      });
    }
  });

  // 상세 모니터링 정보 엔드포인트
  app.get('/health/details', async (req: Request, res: Response) => {
    try {
      const services = {
        api: await checkServiceHealth('http://healthcheck-api:8000', 'API'),
        client: await checkServiceHealth('http://healthcheck-client:3000', 'Client'),
        proxy: await checkServiceHealth('http://healthcheck-proxy:80', 'Proxy')
      };

      const systemInfo = {
        platform: process.platform,
        nodeVersion: process.version,
        memory: process.memoryUsage(),
        uptime: process.uptime(),
        cpuUsage: process.cpuUsage()
      };

      const healthStatus = {
        status: Object.values(services).every(service => service.status === 'healthy') ? 'healthy' : 'degraded',
        timestamp: Date.now(),
        system: systemInfo,
        services
      };

      res.json(healthStatus);
    } catch (error) {
      logger.error('상세 헬스체크 오류:', error);
      res.status(500).json({
        error: '헬스체크 중 오류가 발생했습니다.',
        details: error instanceof Error ? error.message : '알 수 없는 오류'
      });
    }
  });
};

async function checkServiceHealth(url: string, serviceName: string) {
  const startTime = Date.now();
  try {
    logger.info(`${serviceName} 헬스체크 시도 중... (${url})`);

    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 5000);

    let healthCheckUrl;
    if (serviceName === 'Client' && process.env.CLIENT_URL) {
      healthCheckUrl = process.env.CLIENT_URL;  // 환경 변수에서 클라이언트 헬스체크 URL 사용
    } else {
      healthCheckUrl = `${url}/health`;  // 다른 서비스는 기본 /health 사용
    }
    logger.info(`헬스체크 URL: ${healthCheckUrl}`);

    const response = await fetch(healthCheckUrl, {
      method: 'GET',
      signal: controller.signal,
      headers: {
        'Accept': 'application/json'
      }
    });

    clearTimeout(timeoutId);
    const responseTime = Date.now() - startTime;

    if (response.ok) {
      interface HealthResponse {
        status: string;
        message: string;
      }

      const data = await response.json() as HealthResponse;
      logger.info(`${serviceName} 헬스체크 성공 (${responseTime}ms)`, JSON.stringify(data));
      return {
        status: data.status || 'healthy',  // status가 없으면 'healthy' 사용
        responseTime,
        message: data.message || '정상'     // message가 없으면 '정상' 사용
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
    return {
      status: 'unreachable',
      responseTime,
      message: error instanceof Error ? error.message : '알 수 없는 오류'
    };
  }
}
