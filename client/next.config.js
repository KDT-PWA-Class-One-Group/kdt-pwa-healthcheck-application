/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'standalone',
  // API 요청을 프록시로 전달
  async rewrites() {
    return [
      {
        source: '/api/:path*',
        destination: '/api/:path*'
      }
    ]
  },
  // 추가 설정
  reactStrictMode: true,
  swcMinify: true,
  poweredByHeader: false,
  // App Router 관련 설정 수정
  experimental: {
    serverActions: true
  },
  // 정적 최적화
  optimizeFonts: true,
  productionBrowserSourceMaps: false,
  // 압축 설정
  compress: true,
  // 캐시 설정
  generateEtags: true,
  // 서버 설정
  serverRuntimeConfig: {
    port: 3000,
    hostname: '0.0.0.0'
  },
  // 클라이언트 설정
  publicRuntimeConfig: {
    apiUrl: '/api'
  }
}

module.exports = nextConfig
