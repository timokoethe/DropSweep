import type { MetadataRoute } from "next";
import { SITE_LAST_MODIFIED, SITE_URL } from "@/lib/seo";

export default function sitemap(): MetadataRoute.Sitemap {
  return ["", "/faq", "/privacy"].map((path) => ({
    url: `${SITE_URL}${path}`,
    lastModified: SITE_LAST_MODIFIED,
  }));
}
