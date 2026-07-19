import {
  SOFTWARE_ID,
  SITE_NAME,
  SITE_TITLE,
  SITE_URL,
  WEBPAGE_ID,
  WEBSITE_ID,
} from "@/lib/seo";

export function WebSiteJsonLd() {
  const jsonLd = {
    "@context": "https://schema.org",
    "@graph": [
      {
        "@type": "WebSite",
        "@id": WEBSITE_ID,
        name: SITE_NAME,
        alternateName: "DropSweep for macOS",
        url: `${SITE_URL}/`,
      },
      {
        "@type": "WebPage",
        "@id": WEBPAGE_ID,
        name: SITE_TITLE,
        url: `${SITE_URL}/`,
        isPartOf: { "@id": WEBSITE_ID },
        about: { "@id": SOFTWARE_ID },
        mainEntity: { "@id": SOFTWARE_ID },
        inLanguage: "en",
      },
    ],
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
