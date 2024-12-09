import express from 'express';
import cors from 'cors';
import { createServer } from 'http';
import { Server } from 'socket.io';
import dotenv from 'dotenv';
import path from 'path';
import { setupMetricsRoutes } from './routes/metrics.routes.js';
import { setupHealthRoutes } from './routes/health.routes.js';
import { setupMonitorRoutes } from './routes/monitor.routes.js';
import { logger } from './utils/logger.js';
import { setupMetricsCollection } from './services/metrics.service.js';

dotenv.config();

const app = express();
const httpServer = createServer(app);

// 미들웨어 설정
app.use(cors());
app.use(express.json());

// 정적 파일 제공
app.use(express.static(path.join(process.cwd(), 'public')));

// Socket.IO 설정
const io = new Server(httpServer, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST']
  },
  serveClient: true,
  path: '/socket.io'
});

// Socket.IO 연결 이벤트 처리
io.on('connection', (socket) => {
  logger.info('새로운 클라이언트가 연결되었습니다.');

  socket.on('disconnect', () => {
    logger.info('클라이언트가 연결을 해제했습니다.');
  });

  socket.on('error', (error) => {
    logger.error('Socket.IO 에러:', error);
  });
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
