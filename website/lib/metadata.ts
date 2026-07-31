import type { Metadata } from "next";
import { SITE_NAME, SOCIAL_IMAGE_PATH } from "@/lib/seo";

type PageMetadata = {
  title: string;
  description: string;
  path: `/${string}`;
};

export function createPageMetadata({
  title,
  description,
  path,
}: PageMetadata): Metadata {
  const absoluteTitle = `${title} | ${SITE_NAME}`;

  return {
    title,
    description,
    alternates: { canonical: path },
    openGraph: {
      title: absoluteTitle,
      description,
      url: path,
      siteName: SITE_NAME,
      images: [
        {
          url: SOCIAL_IMAGE_PATH,
          width: 1200,
          height: 630,
          alt: "DropSweep app preview",
        },
      ],
      locale: "en_US",
      type: "website",
    },
    twitter: {
      card: "summary_large_image",
      title: absoluteTitle,
      description,
      images: [{ url: SOCIAL_IMAGE_PATH, alt: "DropSweep app preview" }],
    },
    robots: {
      index: true,
      follow: true,
    },
  };
}
