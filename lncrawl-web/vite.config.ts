import react from '@vitejs/plugin-react-swc';
import { defineConfig } from 'vite';
import { VitePWA } from 'vite-plugin-pwa';
import tsconfigPaths from 'vite-tsconfig-paths';

// https://vite.dev/config/
export default defineConfig({
  base: '/',
  build: {
    outDir: '../lncrawl/server/web',
    assetsDir: 'assets',
    emptyOutDir: true,
    rollupOptions: {
      output: {
        manualChunks: {
          'vendor-react': ['react', 'react-dom', 'react-router-dom'],
          'vendor-antd': ['antd', '@ant-design/icons'],
          'vendor-redux': ['@reduxjs/toolkit', 'react-redux', 'redux-persist'],
        },
      },
    },
  },
  plugins: [
    react(),
    tsconfigPaths(),
    VitePWA({
      registerType: 'autoUpdate',
      includeAssets: ['lncrawl.svg'],
      manifest: {
        name: 'Lightnovel Crawler',
        short_name: 'LNCrawl',
        description: 'Download novels from online sources and generate e-books',
        theme_color: '#009587',
        background_color: '#ffffff',
        display: 'standalone',
        categories: ['reader', 'novel', 'ebook', 'lightnovel'],
        icons: [
          {
            src: '/lncrawl.svg',
            sizes: 'any',
            type: 'image/svg+xml',
            purpose: 'any',
          },
        ],
      },
      workbox: {
        globPatterns: ['**/*.{js,css,html,ico,png,svg,woff2}'],
        navigateFallbackDenylist: [/^\/api/, /^\/static/, /^\/docs/],
      },
    }),
  ],
});
