function csrfToken(): string | null {
  if (typeof document === "undefined") return null;
  const el = document.querySelector<HTMLMetaElement>('meta[name="csrf-token"]');
  return el?.content ?? null;
}

function requestMethod(input: RequestInfo, init: RequestInit): string {
  const method = init.method ?? (input instanceof Request ? input.method : "GET");
  return method.toUpperCase();
}

function needsCsrf(method: string): boolean {
  return method === "POST" || method === "PUT" || method === "PATCH" || method === "DELETE";
}

export async function apiFetch(input: RequestInfo, init: RequestInit = {}) {
  const headers = new Headers(init.headers ?? {});
  if (!headers.has("Accept")) headers.set("Accept", "application/json");

  const method = requestMethod(input, init);
  if (needsCsrf(method) && !headers.has("X-CSRF-Token")) {
    const token = csrfToken();
    if (token) headers.set("X-CSRF-Token", token);
  }

  const res = await fetch(input, {
    ...init,
    credentials: "include",
    headers,
  });

  if (res.redirected) {
    window.location.assign(res.url);
    throw new Error("Redirected");
  }

  return res;
}
