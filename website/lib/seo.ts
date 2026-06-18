export const SITE_NAME = "DropSweep";

export const SITE_DESCRIPTION =
  "Clean up your Mac Downloads folder from the menu bar. DropSweep groups clutter and moves what you no longer need to the Trash in one click.";

const configuredSiteUrl =
  process.env.NEXT_PUBLIC_SITE_URL ?? process.env.VERCEL_PROJECT_PRODUCTION_URL;

const normalizedSiteUrl = configuredSiteUrl
  ? configuredSiteUrl.replace(/^https?:\/\//, "").replace(/\/$/, "")
  : "dropsweep.itstimo.me";

export const SITE_URL = `https://${normalizedSiteUrl}`;

export const REPO_URL = "https://github.com/timokoethe/DropSweep";

export const SITE_ICON_PATH = "/icon.png";
export const SITE_ICON_URL = `${SITE_URL}${SITE_ICON_PATH}`;

export const APP_ICON_PATH = "/dropsweep-icon.png";
export const APP_ICON_URL = `${SITE_URL}${APP_ICON_PATH}`;

export const SOCIAL_IMAGE_PATH = "/SocialPreview.png";
export const SOCIAL_IMAGE_URL = `${SITE_URL}${SOCIAL_IMAGE_PATH}`;
