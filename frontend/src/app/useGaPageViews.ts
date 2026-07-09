import { useEffect } from "react";
import { useLocation } from "react-router-dom";
import { pushGaEvent } from "./analytics";

export function useGaPageViews() {
  const location = useLocation();

  useEffect(() => {
    const page_path = location.pathname + location.search;
    const page_location = window.location.href;

    pushGaEvent("page_view", {
      page_path,
      page_location,
      page_title: document.title,
    });
  }, [location]);
}
