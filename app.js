// 에러 처리 미들웨어 등록
app.use(errorHandler);

// DB 헬스체크 엔드포인트 추가
app.get('/health', async (req, res) => {
  try {
    await db.authenticate();
    res.status(200).json({ status: 'healthy' });
  } catch (error) {
    res.status(500).json({ status: 'unhealthy', error: error.message });
  }
});
