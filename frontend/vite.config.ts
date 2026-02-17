import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

const railsOrigin = process.env.RAILS_ORIGIN || "http://lvh.me:3000";

export default defineConfig(({ mode }) => {
  const isProd = mode === "production";

  return {
    plugins: [react()],

    // ✅ dev server should be rooted at /
    // ✅ production build assets will be served by Rails at /spa/
    base: isProd ? "/spa/" : "/",

    build: {
      outDir: "../public/spa",
      emptyOutDir: true,
      manifest: true,
    },

    server: {
      host: true,
      port: 5173,
      strictPort: true,
      proxy: {
        "/api": {
          target: railsOrigin,
          changeOrigin: true,
          secure: false,

          // Only needed if you keep your enforce_same_origin! in dev
          configure: (proxy) => {
            proxy.on("proxyReq", (proxyReq) => {
              proxyReq.setHeader("origin", railsOrigin);
              proxyReq.setHeader("referer", `${railsOrigin}/`);
            });
          },
        },
      },
    },
  };
});
