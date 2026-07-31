import { InfoPage } from "@/components/InfoPage";
import { createPageMetadata } from "@/lib/metadata";
import { REPO_URL } from "@/lib/seo";

const PRIVACY_DESCRIPTION =
  "How DropSweep handles files on your Mac and what limited technical data the product website processes.";

export const metadata = createPageMetadata({
  title: "Privacy",
  description: PRIVACY_DESCRIPTION,
  path: "/privacy",
});

const sectionClassName = "border-b border-border pb-10 last:border-0 last:pb-0";
const headingClassName = "text-xl font-semibold tracking-tight";
const paragraphClassName = "mt-4 text-sm leading-7 text-muted";

export default function PrivacyPage() {
  return (
    <InfoPage
      eyebrow="Last updated July 31, 2026"
      title="Privacy"
      description={PRIVACY_DESCRIPTION}
    >
      <div className="space-y-10">
        <section className={sectionClassName}>
          <h2 className={headingClassName}>The DropSweep app</h2>
          <p className={paragraphClassName}>
            DropSweep scans your Downloads folder locally on your Mac. File
            names, file contents, category results, and cleanup selections are
            not uploaded to the DropSweep website or its developer. The app
            does not require an account and does not include advertising or
            product analytics.
          </p>
        </section>

        <section className={sectionClassName}>
          <h2 className={headingClassName}>Updates</h2>
          <p className={paragraphClassName}>
            DropSweep uses Sparkle to check for app updates. Update checks read
            an appcast hosted on GitHub, and releases are downloaded from
            GitHub. These requests necessarily share standard technical request
            information, such as an IP address and user agent, with the
            respective infrastructure providers. Their own privacy terms apply
            to that processing.
          </p>
        </section>

        <section className={sectionClassName}>
          <h2 className={headingClassName}>This website</h2>
          <p className={paragraphClassName}>
            The DropSweep website is hosted by Vercel. Like other hosting
            providers, Vercel processes technical request data needed to serve
            and protect the site. The website does not provide user accounts,
            forms, advertising, or payment processing.
          </p>
          <p className={paragraphClassName}>
            The selected light or dark theme is stored locally in your browser.
            DropSweep does not receive that preference.
          </p>
        </section>

        <section className={sectionClassName}>
          <h2 className={headingClassName}>Analytics and performance</h2>
          <p className={paragraphClassName}>
            The website uses Vercel Web Analytics to understand aggregated page
            views and general usage. It also records a custom event when a
            download link is selected, including the button location, app
            version, and destination URL. Vercel states that this service stores
            anonymized data and does not use cookies. The website also uses
            Vercel Speed Insights to collect real-world performance measurements
            such as Core Web Vitals. These measurements help identify slow or
            unstable pages.
          </p>
          <p className={paragraphClassName}>
            Learn more in Vercel&apos;s{" "}
            <a
              href="https://vercel.com/docs/analytics/privacy-policy"
              target="_blank"
              rel="noreferrer"
              className="font-medium text-foreground underline decoration-border underline-offset-4 hover:decoration-foreground"
            >
              Analytics privacy documentation
            </a>{" "}
            and{" "}
            <a
              href="https://vercel.com/legal/privacy-policy"
              target="_blank"
              rel="noreferrer"
              className="font-medium text-foreground underline decoration-border underline-offset-4 hover:decoration-foreground"
            >
              Privacy Notice
            </a>
            .
          </p>
        </section>

        <section className={sectionClassName}>
          <h2 className={headingClassName}>External links</h2>
          <p className={paragraphClassName}>
            Links to GitHub, releases, documentation, and the developer&apos;s
            portfolio lead to independently operated websites. Those providers
            process visits under their own privacy terms.
          </p>
        </section>

        <section className={sectionClassName}>
          <h2 className={headingClassName}>Questions and changes</h2>
          <p className={paragraphClassName}>
            This page may be updated when DropSweep or its website changes. For
            privacy questions, contact the project maintainer through the{" "}
            <a
              href={REPO_URL}
              className="font-medium text-foreground underline decoration-border underline-offset-4 hover:decoration-foreground"
            >
              DropSweep repository
            </a>
            . Please do not include sensitive personal information in a public
            issue.
          </p>
        </section>
      </div>
    </InfoPage>
  );
}
