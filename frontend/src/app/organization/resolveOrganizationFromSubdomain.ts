import type { Organization } from "./types";

export function resolveOrganizationFromSubdomain(hostname: string): Organization {
  const host = hostname.toLowerCase();

  if (host === "www.digitallearn.org" || host === "digitallearn.org") {
    return {
      subdomain: "www",
      hostname: host,
      isPublic: true,
      requiresAuthByDefault: false,
      features: {},
    };
  }

  // subdomain.digitallearn.org
  const match = host.match(/^([a-z0-9-]+)\.digitallearn\.org$/);
  const subdomain = match?.[1] ?? "www";

  return {
    subdomain,
    hostname: host,
    isPublic: false,
    requiresAuthByDefault: true,
    features: {
      // enable per-partner toggles here
      customContent: true,
    },
  };
}