import {
  APP_ICON_URL,
  REPO_URL,
  SITE_AUTHOR,
  SITE_DESCRIPTION,
  SITE_NAME,
  SITE_URL,
} from "@/lib/seo";

type SoftwareApplicationJsonLdProps = {
  downloadUrl: string;
  version: string | null;
};

export function SoftwareApplicationJsonLd({
  downloadUrl,
  version,
}: SoftwareApplicationJsonLdProps) {
  const jsonLd = {
    "@context": "https://schema.org",
    "@type": "SoftwareApplication",
    name: SITE_NAME,
    description: SITE_DESCRIPTION,
    url: SITE_URL,
    image: APP_ICON_URL,
    downloadUrl,
    codeRepository: REPO_URL,
    operatingSystem: "macOS 26 or later",
    softwareRequirements: "macOS 26 or later",
    applicationCategory: "UtilitiesApplication",
    license: `${REPO_URL}/blob/main/LICENSE`,
    featureList: [
      "Scan the macOS Downloads folder",
      "Group downloads by common file type",
      "Review the current item count from the menu bar",
      "Move Downloads items to the Trash",
      "Skip hidden files during scanning and cleanup",
    ],
    author: {
      "@type": "Person",
      ...SITE_AUTHOR,
    },
    softwareVersion: version ?? undefined,
    offers: {
      "@type": "Offer",
      price: "0",
      priceCurrency: "USD",
      url: downloadUrl,
    },
  };

  return (
    <script
      type="application/ld+json"
      dangerouslySetInnerHTML={{
        __html: JSON.stringify(jsonLd).replace(/</g, "\\u003c"),
      }}
    />
  );
}
