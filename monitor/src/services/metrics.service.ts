import { Server } from 'socket.io';
import { register, collectDefaultMetrics, Counter, Histogram } from 'prom-client';
import { logger } from '../utils/logger';

// Prometheus 메트릭스 설정
collectDefaultMetrics();

// 커스텀 메트릭스 정의
export const httpRequestsTotal = new Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'path', 'status']
});

export const httpRequestDuration = new Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'path', 'status']
});

export const setupMetricsCollection = (io: Server) => {
  const metricsInterval = 5000; // 5초마다 메트릭스 수집

  setInterval(async () => {
    try {
      const metrics = await register.getMetricsAsJSON();
      io.emit('metrics', metrics);
    } catch (error) {
      logger.error('메트릭스 수집 중 오류 발생:', error);
    }
  }, metricsInterval);
};

export const getMetrics = async () => {
  try {
    return await register.metrics();
  } catch (error) {
    logger.error('메트릭스 조회 중 오�� 발생:', error);
    throw error;
  }
};
