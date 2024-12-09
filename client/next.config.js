/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'standalone',
  async rewrites() {
    return [
      {
        source: '/api/:path*',
        destination: 'http://healthcheck-api:8000/:path*',
      },
    ]
  },
}

module.exports = nextConfig
