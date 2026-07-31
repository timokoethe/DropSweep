import { InfoPage } from "@/components/InfoPage";
import { createPageMetadata } from "@/lib/metadata";
import { REPO_URL, SITE_URL } from "@/lib/seo";

const FAQ_DESCRIPTION =
  "Answers about how DropSweep scans your Downloads folder, handles files, protects hidden items, updates itself, and supports macOS.";

export const metadata = createPageMetadata({
  title: "Frequently asked questions",
  description: FAQ_DESCRIPTION,
  path: "/faq",
});

const questions = [
  {
    question: "What does DropSweep do?",
    answer:
      "DropSweep is a macOS menu bar app that scans the visible items directly inside your Downloads folder, groups them into useful categories, and lets you move the listed set to the Trash after confirmation.",
  },
  {
    question: "Does DropSweep permanently delete my files?",
    answer:
      "No. DropSweep moves confirmed items to the macOS Trash instead of permanently deleting them. You can review the item count and categories before starting a sweep.",
  },
  {
    question: "Which files does DropSweep scan?",
    answer:
      "It scans visible top-level entries in Downloads and groups regular files as installers, archives, PDFs, screenshots, or other files. Visible folders are listed separately and their size is included in the summary.",
  },
  {
    question: "What happens to hidden items?",
    answer:
      "Hidden items directly in the Downloads folder are skipped. If a visible folder is moved to the Trash, everything inside that folder moves with it, including any hidden contents.",
  },
  {
    question: "Does DropSweep upload file names or contents?",
    answer:
      "No. Scanning and cleanup happen locally on your Mac. The app only uses network access to check for and download updates through Sparkle and GitHub-hosted release infrastructure.",
  },
  {
    question: "What happens if an item cannot be moved to the Trash?",
    answer:
      "DropSweep continues processing the other listed items, reports anything that could not be moved, and scans Downloads again so the menu reflects the current state.",
  },
  {
    question: "Which version of macOS is required?",
    answer: "DropSweep requires macOS 26 or later.",
  },
  {
    question: "Can DropSweep launch when I sign in?",
    answer:
      "Yes. You can enable or disable Launch at Login from the DropSweep menu.",
  },
  {
    question: "How do updates work?",
    answer:
      "DropSweep uses Sparkle to check for signed updates. You can start an update check from the menu, and available releases are downloaded from the project's GitHub release infrastructure.",
  },
  {
    question: "Is DropSweep open source?",
    answer:
      "Yes. The source code is available on GitHub under the MIT License.",
  },
] as const;

export default function FAQPage() {
  const jsonLd = {
    "@context": "https://schema.org",
    "@type": "FAQPage",
    "@id": `${SITE_URL}/faq#faq`,
    url: `${SITE_URL}/faq`,
    name: "DropSweep frequently asked questions",
    mainEntity: questions.map(({ question, answer }) => ({
      "@type": "Question",
      name: question,
      acceptedAnswer: {
        "@type": "Answer",
        text: answer,
      },
    })),
  };

  return (
    <InfoPage
      eyebrow="Support"
      title="Frequently asked questions"
      description={FAQ_DESCRIPTION}
    >
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{
          __html: JSON.stringify(jsonLd).replace(/</g, "\\u003c"),
        }}
      />
      <div className="divide-y divide-border border-y border-border">
        {questions.map(({ question, answer }) => (
          <details key={question} className="group py-6">
            <summary className="flex cursor-pointer list-none items-center justify-between gap-6 font-medium marker:content-none">
              <span>{question}</span>
              <span
                aria-hidden="true"
                className="text-xl font-light text-muted transition-transform group-open:rotate-45"
              >
                +
              </span>
            </summary>
            <p className="max-w-2xl pt-4 text-sm leading-7 text-muted">
              {answer}
            </p>
          </details>
        ))}
      </div>
      <section className="mt-12 rounded-xl border border-border bg-card p-6">
        <h2 className="font-semibold">Still have a question?</h2>
        <p className="mt-2 text-sm leading-6 text-muted">
          Visit the open-source project to review the implementation, report a
          bug, or suggest an improvement.
        </p>
        <a
          href={`${REPO_URL}/issues`}
          className="mt-5 inline-flex h-10 items-center justify-center rounded-lg bg-foreground px-5 text-sm font-medium text-background transition-opacity hover:opacity-90"
        >
          Open GitHub Issues
        </a>
      </section>
    </InfoPage>
  );
}
