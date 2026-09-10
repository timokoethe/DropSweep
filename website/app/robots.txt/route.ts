import { SITE_URL } from "@/lib/seo";

// Content signals declare how crawled content may be reused.
// See https://contentsignals.org — DropSweep allows all three uses.
const CONTENT_SIGNAL = "search=yes, ai-input=yes, ai-train=yes";

const body = `# Crawling is welcome. Content signals below declare permitted uses:
# search: building a search index and linking to this site
# ai-input: using this content as input to an AI answer
# ai-train: using this content to train an AI model
User-Agent: *
Content-Signal: ${CONTENT_SIGNAL}
Allow: /

Sitemap: ${SITE_URL}/sitemap.xml
`;

export function GET(): Response {
  return new Response(body, {
    headers: { "Content-Type": "text/plain; charset=utf-8" },
  });
}
