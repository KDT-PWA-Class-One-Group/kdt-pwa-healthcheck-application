import { Application, Request, Response } from 'express';
import { logger } from '../utils/logger';

export const setupHealthRoutes = (app: Application) => {
  // 기본 헬스체크 엔드포인트
  app.get('/health', async (req: Request, res: Response) => {
    try {
      const services = {
        api: await checkServiceHealth(process.env.API_URL || 'http://localhost:8000', 'API'),
        client: await checkServiceHealth(process.env.CLIENT_URL || 'http://localhost:3000', 'Client'),
        proxy: await checkServiceHealth(process.env.PROXY_URL || 'http://localhost:80', 'Proxy')
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
        api: await checkServiceHealth(process.env.API_URL || 'http://localhost:8000', 'API'),
        client: await checkServiceHealth(process.env.CLIENT_URL || 'http://localhost:3000', 'Client'),
        proxy: await checkServiceHealth(process.env.PROXY_URL || 'http://localhost:80', 'Proxy')
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

async function checkServiceHealth(url: string, serviceName: string): Promise<{ status: string; responseTime: number; message?: string }> {
  const startTime = Date.now();
  try {
    logger.info(`${serviceName} 헬스체크 시도 ��... (${url})`);

    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 5000); // 5초 타임아웃

    const response = await fetch(`${url}/health`, {
      signal: controller.signal
    });

    clearTimeout(timeout);
    const responseTime = Date.now() - startTime;

    if (response.ok) {
      logger.info(`${serviceName} 헬스체크 성공 (${responseTime}ms)`);
      return {
        status: 'healthy',
        responseTime,
        message: '정상'
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
