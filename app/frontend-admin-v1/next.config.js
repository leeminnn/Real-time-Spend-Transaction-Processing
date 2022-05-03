/** @type {import('next').NextConfig} */
const nextConfig = {
  experimental: {
    outputStandalone: true,
  },
  reactStrictMode: true,
  images: {
    domains: [
      "images.unsplash.com",
      "localhost",
      "itsag1t5-frontend-asset.s3.amazonaws.com",
    ],
  },
};

module.exports = nextConfig;
