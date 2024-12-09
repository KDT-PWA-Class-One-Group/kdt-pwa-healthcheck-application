import express from 'express';
import cors from 'cors';
import { createServer } from 'http';
import { Server } from 'socket.io';
import dotenv from 'dotenv';
import path from 'path';
import { setupMetricsRoutes } from './routes/metrics.routes';
import { setupHealthRoutes } from './routes/health.routes';
import { setupMonitorRoutes } from './routes/monitor.routes';
import { logger } from './utils/logger';
import { setupMetricsCollection } from './services/metrics.service';

dotenv.config();

const app = express();
const httpServer = createServer(app);
const io = new Server(httpServer, {
  cors: {
    origin: process.env.CLIENT_URL || 'http://localhost:3000',
    methods: ['GET', 'POST']
  }
});

// 미들웨어 설정
app.use(cors());
app.use(express.json());

// 정적 파일 제공
app.use(express.static(path.join(__dirname, '../public')));

// 모니터링 대시보드 라우트
app.get('/monitor', (req, res) => {
  res.sendFile(path.join(__dirname, '../public/index.html'));
});

// API 라우트 설정
setupHealthRoutes(app);
setupMetricsRoutes(app);
setupMonitorRoutes(app);

// 실시간 메트릭스 수집 시작
setupMetricsCollection(io);

const PORT = process.env.PORT || 3001;

httpServer.listen(PORT, () => {
  logger.info(`모니터링 서버가 포트 ${PORT}에서 실행 중입니다.`);
  logger.info(`모니터링 대시보드: http://localhost:${PORT}/monitor`);
  logger.info(`헬스체크 엔드포인트: http://localhost:${PORT}/health`);
});
