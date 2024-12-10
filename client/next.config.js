/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'standalone',
  experimental: {
    serverActions: true
  },
  async rewrites() {
    return {
      beforeFiles: [
        {
          source: '/api/:path*',
          destination: 'http://api:8000/:path*',
        },
      ],
      afterFiles: [],
      fallback: [],
    }
  }
}

module.exports = nextConfig
