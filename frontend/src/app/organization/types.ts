export type Organization = {
  subdomain: string;
  hostname: string;
  isPublic: boolean;
  requiresAuthByDefault: boolean;
  features: Record<string, boolean>;
};

export type CustomText = {
  homeHeaderEn?: string;
  homeSubheaderEn?: string;
  homeHeaderEs?: string;
  homeSubheaderEs?: string;
};

export type OrganizationConfig = {
  subdomain: string;
  displayName: string;
  mainSite: boolean;
  bannerText: string;
  customText?: CustomText;
  trainingSiteLink?: string;
  footerLinks?: Array<{
    title: string;
    url: string;
    openInNewTab?: boolean;
    isInternal?: boolean;
  }>;

  theme: {
    logoUrl?: string;
    footerLogoUrl?: string;
    footerLogoDestinationUrl?: string;
    plaFooterLogoUrl?: string;
    plaFooterLogoDestinationUrl?: string;
    primaryColor?: string;
    secondaryColor?: string;
    fontFamily?: string;
    radius?: number;
  };

  features: {
    loginRequired?: boolean;
    userSurveyEnabled?: string;
    userSurveyLink?: string;
    spanishSurveyLink?: string;
    phoneNumberSignIn: boolean;
    signUpAllowed?: boolean;
    surveyRequired: boolean;
  };
};
