import type { Organization } from "./types";

export function resolveOrganizationFromSubdomain(hostname: string): Organization {
  const host = hostname.toLowerCase();

  if (
    host === "www.digitallearn.org" ||
    host === "digitallearn.org" ||
    host === "www.staging.digitallearn.org" ||
    host === "staging.digitallearn.org"
  ) {
    return {
      subdomain: "www",
      hostname: host,
      isPublic: true,
      requiresAuthByDefault: false,
      features: {},
    };
  }

  // Production: subdomain.digitallearn.org
  const prodMatch = host.match(/^([a-z0-9-]+)\.digitallearn\.org$/);

  // Staging: subdomain.staging.digitallearn.org
  const stagingMatch = host.match(/^([a-z0-9-]+)\.staging\.digitallearn\.org$/);

  // Local dev helpers:
  // - subdomain.lvh.me
  // - subdomain.staging.lvh.me
  const localMatch = host.match(/^([a-z0-9-]+)\.lvh\.me(?::\d+)?$/);
  const localStagingMatch = host.match(/^([a-z0-9-]+)\.staging\.lvh\.me(?::\d+)?$/);

  const subdomain =
    stagingMatch?.[1] ?? localStagingMatch?.[1] ?? prodMatch?.[1] ?? localMatch?.[1] ?? "www";

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
