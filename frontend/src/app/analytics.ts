declare global {
  interface Window {
    dataLayer?: Record<string, unknown>[];
  }
}

export function pushGaEvent(event: string, params: Record<string, unknown> = {}) {
  window.dataLayer = window.dataLayer || [];
  window.dataLayer.push({ event, ...params });
}
