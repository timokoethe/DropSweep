import { REPO_URL, SITE_NAME, SITE_URL } from "@/lib/seo";

const body = `# ai.txt for ${SITE_NAME} (${SITE_URL})
# Declares how AI systems may use the content of this site.
# All uses below are permitted for every agent.

User-Agent: *
Allow: /
Disallow:

# Permitted uses
Train: allow
Generate: allow
Index: allow
Summarize: allow

# Contact
Contact: ${REPO_URL}/issues
`;

export function GET(): Response {
  return new Response(body, {
    headers: { "Content-Type": "text/plain; charset=utf-8" },
  });
}

export const dynamic = "force-static";
