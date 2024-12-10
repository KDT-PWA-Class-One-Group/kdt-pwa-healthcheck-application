/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'standalone',
  async rewrites() {
    return {
      beforeFiles: [
        {
          source: '/api/:path*',
          destination: 'http://api:8000/:path*',
          has: [
            {
              type: 'query',
              key: 'health',
              value: undefined
            }
          ]
        },
      ],
    }
  },
}

module.exports = nextConfig
