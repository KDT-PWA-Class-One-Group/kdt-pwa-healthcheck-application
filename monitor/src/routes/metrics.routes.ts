import { Router, Request, Response } from 'express';
import { getMetrics } from '../services/metrics.service';
import { logger } from '../utils/logger';

const router = Router();

export const setupMetricsRoutes = (app: Router) => {
  // Prometheus 메트릭스 엔드포인트
  router.get('/metrics', async (req: Request, res: Response) => {
    try {
      const metrics = await getMetrics();
      res.set('Content-Type', 'text/plain');
      res.send(metrics);
    } catch (error) {
      logger.error('메트릭스 엔드포인트 오류:', error);
      res.status(500).json({ error: '메트릭스 조회 중 오류가 발생했습니다.' });
    }
  });

  // 시스템 상태 메트릭스
  router.get('/status', async (req: Request, res: Response) => {
    try {
      const status = {
        uptime: process.uptime(),
        timestamp: Date.now(),
        memory: process.memoryUsage(),
        cpu: process.cpuUsage()
      };
      res.json(status);
    } catch (error) {
      logger.error('시스템 상태 조회 오류:', error);
      res.status(500).json({ error: '시스템 상태 조회 중 오류가 발생했습니다.' });
    }
  });

  app.use('/api', router);
};
