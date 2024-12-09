import { Router, Request, Response } from 'express';
import { getMetrics } from '../services/metrics.service';
import { logger } from '../utils/logger';

const router = Router();

export const setupMonitorRoutes = (app: Router) => {
  router.get('/monitor', async (req: Request, res: Response) => {
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
        api: await checkServiceHealth(process.env.API_URL || 'http://localhost:8000'),
        client: await checkServiceHealth(process.env.CLIENT_URL || 'http://localhost:3000'),
        proxy: await checkServiceHealth(process.env.PROXY_URL || 'http://localhost:80')
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
      res.status(500).json({ error: '모니터링 데이터 조회 중 오류가 발생했습니다.' });
    }
  });

  app.use('/api', router);
};

async function checkServiceHealth(url: string): Promise<{ status: string; responseTime: number }> {
  const startTime = Date.now();
  try {
    const response = await fetch(`${url}/health`);
    const responseTime = Date.now() - startTime;
    return {
      status: response.ok ? 'healthy' : 'unhealthy',
      responseTime
    };
  } catch (error) {
    return {
      status: 'unreachable',
      responseTime: Date.now() - startTime
    };
  }
}
