export type Organization = {
  subdomain: string;
  hostname: string;
  isPublic: boolean;
  requiresAuthByDefault: boolean;
  features: Record<string, boolean>;
};

export type OrganizationConfig = {
  subdomain: string;
  displayName: string;

  theme: {
    logoUrl?: string;
    footerLogoUrl?: string;
    footerLogoDestinationUrl: string;
    primaryColor?: string;
    secondaryColor?: string;
    fontFamily?: string;
    radius?: number;
  };

  features: {
    userSurveyEnabled?: string;
    userSurveyLink?: string;
    spanishSurveyLink?: string;
    phoneNumberSignIn: boolean;
    surveyRequired: boolean;
  };
};
