import {
  APP_ICON_URL,
  REPO_URL,
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
    codeRepository: REPO_URL,
    operatingSystem: "macOS",
    applicationCategory: "UtilitiesApplication",
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
