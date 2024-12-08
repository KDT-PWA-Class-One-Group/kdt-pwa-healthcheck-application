const dbConfig = {
  // 연결 재시도 옵션 추가
  retry: {
    max: 3,
    interval: 1000
  },

  // 커넥션 풀 설정
  pool: {
    max: 5,
    min: 0,
    acquire: 30000,
    idle: 10000
  },

  // 타임아웃 설정
  timeout: 5000
};
