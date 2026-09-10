import {
  PORTFOLIO_URL,
  REPO_URL,
  SITE_DESCRIPTION,
  SITE_NAME,
  SITE_URL,
} from "@/lib/seo";

const body = `# ${SITE_NAME}

> ${SITE_DESCRIPTION}

${SITE_NAME} is a free and open-source macOS menu bar app. It scans the visible
items directly inside the user's Downloads folder, groups them into categories,
and moves the confirmed set to the Trash. Scanning and cleanup happen locally on
the Mac; nothing is uploaded. macOS 26 or later is required. MIT licensed.

## Pages

- [Home](${SITE_URL}/): What ${SITE_NAME} does, how a sweep works, and how to download it.
- [FAQ](${SITE_URL}/faq): Answers about scanning, trashing, hidden items, updates, and macOS support.
- [Privacy](${SITE_URL}/privacy): What data the app and the website do and do not collect.

## Key facts

- Categories: installers, archives, PDFs, screenshots, other files, and folders.
- Items are moved to the macOS Trash, never permanently deleted, and only after confirmation.
- Only visible top-level entries in Downloads are scanned; hidden items in the Downloads root are skipped.
- Hidden contents inside a visible folder move to the Trash together with that folder.
- Items that cannot be moved are reported, and the remaining items are still processed.
- Updates are delivered as signed Sparkle updates from the project's GitHub releases.
- Launch at Login can be enabled or disabled from the menu.

## Source

- [GitHub repository](${REPO_URL}): Source code, releases, and issue tracker.
- [Project page](${PORTFOLIO_URL}): Background on the project by its author.

## Usage

This content may be used for search indexing, as AI input, and for AI training.
See ${SITE_URL}/robots.txt and ${SITE_URL}/.well-known/ai.txt.
`;

export function GET(): Response {
  return new Response(body, {
    headers: { "Content-Type": "text/plain; charset=utf-8" },
  });
}

export const dynamic = "force-static";
