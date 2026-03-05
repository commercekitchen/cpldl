function csrfMetaToken(): string | null {
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

let cachedCsrfToken: string | null = null;
let pendingCsrfFetch: Promise<string | null> | null = null;

async function getCsrfToken(): Promise<string | null> {
  const metaToken = csrfMetaToken();
  if (metaToken) return metaToken;
  if (cachedCsrfToken) return cachedCsrfToken;

  if (!pendingCsrfFetch) {
    pendingCsrfFetch = fetch("/api/v1/csrf", { credentials: "include" })
      .then((r) => r.json())
      .then((data: { token?: string }) => {
        cachedCsrfToken = data.token ?? null;
        pendingCsrfFetch = null;
        return cachedCsrfToken;
      })
      .catch(() => {
        pendingCsrfFetch = null;
        return null;
      });
  }

  return pendingCsrfFetch;
}

export function invalidateCsrfCache() {
  cachedCsrfToken = null;
}

export async function apiFetch(input: RequestInfo, init: RequestInit = {}) {
  const headers = new Headers(init.headers ?? {});
  if (!headers.has("Accept")) headers.set("Accept", "application/json");

  const method = requestMethod(input, init);
  if (needsCsrf(method) && !headers.has("X-CSRF-Token")) {
    const token = await getCsrfToken();
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
