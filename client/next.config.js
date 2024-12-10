/** @type {import('next').NextConfig} */
const nextConfig = {
  basePath: '/monitor',
  output: 'standalone',
  async rewrites() {
    return {
      beforeFiles: [
        {
          source: '/api/:path*',
          destination: 'http://healthcheck-api:8000/:path*',
        },
      ],
      afterFiles: [],
      fallback: [],
    }
  },
  experimental: {
    // appDir 옵션 제거
  },
}

module.exports = nextConfig
