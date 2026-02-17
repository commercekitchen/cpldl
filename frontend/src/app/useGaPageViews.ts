import { useEffect } from "react";
import { useLocation } from "react-router-dom";

declare global {
  interface Window {
    gtag?: (command: "event", action: string, params?: Record<string, unknown>) => void;
  }
}

export function useGaPageViews() {
  const location = useLocation();

  useEffect(() => {
    const page_path = location.pathname + location.search;
    const page_location = window.location.href;

    window.gtag?.("event", "page_view", {
      page_path,
      page_location,
      page_title: document.title,
    });
  }, [location]);
}
