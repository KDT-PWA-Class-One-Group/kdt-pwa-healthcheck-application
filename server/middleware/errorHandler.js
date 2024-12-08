// 에러 로깅 미들웨어 추가
const errorHandler = (err, req, res, next) => {
  console.error('Error:', err.stack);

  // DB 관련 에러 특별 처리
  if (err.name === 'SequelizeConnectionError' || err.name === 'MongooseError') {
    return res.status(500).json({
      success: false,
      message: '데이터베이스 연결 오류가 발생했습니다.',
      error: process.env.NODE_ENV === 'development' ? err.message : null
    });
  }

  next(err);
};
