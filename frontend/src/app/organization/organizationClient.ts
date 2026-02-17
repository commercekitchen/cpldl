// src/app/organization/organizationClient.ts
import { apiFetch } from "../api/apiFetch";
import { resolveOrganizationFromSubdomain } from "./resolveOrganizationFromSubdomain";
import type { Organization, OrganizationConfig } from "./types";

class OrganizationClient {
  private cache = new Map<string, OrganizationConfig>();
  private inFlight = new Map<string, Promise<OrganizationConfig>>();

  async getConfig(): Promise<OrganizationConfig> {
    const organization = resolveOrganizationFromSubdomain(window.location.hostname);
    return this.getConfigForOrganization(organization);
  }

  async getConfigForOrganization(organization: Organization): Promise<OrganizationConfig> {
    const subdomain = organization.subdomain;
    const cached = this.cache.get(subdomain);
    if (cached) return cached;

    const existing = this.inFlight.get(subdomain);
    if (existing) return existing;

    const p = this.fetchConfig(subdomain)
      .then((cfg) => {
        this.cache.set(subdomain, cfg);
        return cfg;
      })
      .finally(() => {
        this.inFlight.delete(subdomain);
      });

    this.inFlight.set(subdomain, p);
    return p;
  }

  async refreshConfig(): Promise<OrganizationConfig> {
    const organization = resolveOrganizationFromSubdomain(window.location.hostname);
    this.cache.delete(organization.subdomain);
    return this.getConfigForOrganization(organization);
  }

  private async fetchConfig(subdomain: string): Promise<OrganizationConfig> {
    const res = await apiFetch(`/api/v1/organizations/${encodeURIComponent(subdomain)}/config`, {
      credentials: "include", // important if you use cookie-based auth
      headers: { Accept: "application/json" },
    });

    if (!res.ok) {
      // Let router/provider decide how to present failure
      throw new Error(`Failed to load organization config (${subdomain}): ${res.status}`);
    }

    const data = (await res.json()) as OrganizationConfig;

    // Optional: minimal sanity check
    if (!data || data.subdomain !== subdomain) {
      throw new Error(`Invalid organization config payload for subdomain=${subdomain}`);
    }

    return data;
  }
}

export const organizationClient = new OrganizationClient();
