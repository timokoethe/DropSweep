import type { Metadata } from "next";
import { SoftwareApplicationJsonLd } from "@/components/SoftwareApplicationJsonLd";
import { WebSiteJsonLd } from "@/components/WebSiteJsonLd";
import {
  REPO_URL,
  SITE_DESCRIPTION,
  SITE_KEYWORDS,
  SITE_NAME,
  SITE_TITLE,
  SOCIAL_IMAGE_PATH,
} from "@/lib/seo";
import { Logo } from "@/components/Logo";
import { DownloadButton } from "@/components/DownloadButton";
import Image from "next/image";
import { SiteFooter } from "@/components/SiteFooter";
import { SiteHeader } from "@/components/SiteHeader";

export const metadata: Metadata = {
  title: { absolute: SITE_TITLE },
  description: SITE_DESCRIPTION,
  keywords: SITE_KEYWORDS,
  alternates: { canonical: "/" },
  openGraph: {
    title: SITE_TITLE,
    description: SITE_DESCRIPTION,
    url: "/",
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
    title: SITE_TITLE,
    description: SITE_DESCRIPTION,
    images: [{ url: SOCIAL_IMAGE_PATH, alt: "DropSweep app preview" }],
  },
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
      "max-image-preview": "large",
      "max-snippet": -1,
      "max-video-preview": -1,
    },
  },
  category: "technology",
};

const LATEST_RELEASE_URL = `${REPO_URL}/releases/latest`;
const RELEASE_API_URL =
  "https://api.github.com/repos/timokoethe/DropSweep/releases/latest";

type GitHubRelease = {
  tag_name?: string;
  html_url?: string;
  assets?: Array<{
    name?: string;
    browser_download_url?: string;
  }>;
};

type LatestRelease = {
  version: string | null;
  downloadUrl: string;
};

async function getLatestRelease(): Promise<LatestRelease> {
  try {
    const response = await fetch(RELEASE_API_URL, {
      headers: {
        Accept: "application/vnd.github+json",
        "X-GitHub-Api-Version": "2022-11-28",
      },
      next: { revalidate: 3600 },
    });

    if (!response.ok) {
      return { version: null, downloadUrl: LATEST_RELEASE_URL };
    }

    const release = (await response.json()) as GitHubRelease;
    const assets = Array.isArray(release.assets) ? release.assets : [];
    const downloadAsset =
      assets.find(
        (asset) =>
          typeof asset.name === "string" &&
          asset.name.toLowerCase().endsWith(".zip"),
      ) ??
      assets.find(
        (asset) =>
          typeof asset.name === "string" &&
          asset.name.toLowerCase().endsWith(".dmg"),
      );
    const assetUrl =
      typeof downloadAsset?.browser_download_url === "string"
        ? downloadAsset.browser_download_url
        : null;
    const releaseUrl =
      typeof release.html_url === "string" ? release.html_url : null;

    return {
      version: typeof release.tag_name === "string" ? release.tag_name : null,
      downloadUrl: assetUrl ?? releaseUrl ?? LATEST_RELEASE_URL,
    };
  } catch {
    return { version: null, downloadUrl: LATEST_RELEASE_URL };
  }
}

const categories = [
  { title: "Installers", hint: ".dmg, .pkg" },
  { title: "Archives", hint: ".zip, .xip, .tar" },
  { title: "PDFs", hint: "documents" },
  { title: "Screenshots", hint: "captures" },
  { title: "Images", hint: ".png, .jpg, .svg" },
  { title: "Folders", hint: "directories" },
  { title: "Other", hint: "everything else" },
];

const features = [
  {
    title: "Scans your Downloads",
    body: "See what is in your Downloads from the menu bar. No folders to configure.",
  },
  {
    title: "Groups the clutter",
    body: "Files and folders are shown by category, with item counts and sizes.",
  },
  {
    title: "Confirm before moving",
    body: "Review the summary before confirming that all listed items should move.",
  },
  {
    title: "Moves items to the Trash",
    body: "DropSweep moves items to the macOS Trash without emptying it.",
  },
];

function GitHubIcon({ className = "" }: { className?: string }) {
  return (
    <svg
      viewBox="0 0 16 16"
      fill="currentColor"
      aria-hidden
      className={className}
    >
      <path d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.01 8.01 0 0 0 16 8c0-4.42-3.58-8-8-8Z" />
    </svg>
  );
}

export default async function Home() {
  const release = await getLatestRelease();
  const downloadLabel = "Download for macOS";

  return (
    <div className="flex flex-col min-h-full">
      <WebSiteJsonLd />
      <SoftwareApplicationJsonLd
        downloadUrl={release.downloadUrl}
        version={release.version}
      />

      <SiteHeader />

      <main className="mx-auto w-full max-w-[1480px] flex-1 px-6 lg:px-10">
        <section className="home-hero">
          <div className="hero-copy">
            <span className="hero-badge">
              <span
                aria-hidden="true"
                className="h-2 w-2 rounded-full bg-emerald-500"
              />
              A tiny app for your Mac&apos;s menu bar
            </span>
            <h1>
              Clear your
              <br />
              Downloads.
              <br />
              Get back to work.
            </h1>
            <p className="hero-description">
              See what&apos;s in your Downloads, then move all listed items to
              the Trash after confirmation.
            </p>
            <div className="hero-actions">
              <DownloadButton
                href={release.downloadUrl}
                label="Download for macOS"
                version={release.version}
              />
              <a
                href={REPO_URL}
                target="_blank"
                rel="noreferrer"
                className="inline-flex items-center gap-3 text-muted transition-colors hover:text-foreground"
              >
                <GitHubIcon className="h-6 w-6" />
                View on GitHub
              </a>
            </div>
            <p className="mt-4 text-sm text-muted">
              Free · Open source · macOS 26+
            </p>
            <ul className="hero-reassurance">
              <li>Files go to the Trash.</li>
              <li>File names and contents stay on your Mac.</li>
            </ul>
          </div>
          <figure className="hero-preview">
            <Image
              src="/Image.png"
              width={1600}
              height={1100}
              unoptimized
              preload
              alt="DropSweep in the macOS menu bar, showing Downloads grouped by category and a Move Listed Items to Trash button."
              className="h-auto w-full rounded-[20px] border border-border shadow-2xl"
            />
            <figcaption className="mt-4 text-center text-sm text-muted">
              Your Downloads, at a glance.
            </figcaption>
          </figure>
        </section>

        {/* Features */}
        <section className="border-t border-border py-20">
          <h2 className="sr-only">How DropSweep works</h2>
          <div className="grid gap-x-12 gap-y-10 sm:grid-cols-2">
            {features.map((f) => (
              <div key={f.title}>
                <h3 className="text-base font-semibold">{f.title}</h3>
                <p className="mt-2 text-sm leading-relaxed text-muted">
                  {f.body}
                </p>
              </div>
            ))}
          </div>
        </section>

        {/* Categories */}
        <section className="border-t border-border py-20">
          <h2 className="text-2xl font-semibold tracking-tight">
            Your Downloads, grouped.
          </h2>
          <p className="mt-2 max-w-md text-sm text-muted">
            See the types of files in Downloads and how much space each category
            uses.
          </p>
          <div className="mt-8 grid grid-cols-2 gap-3 sm:grid-cols-3">
            {categories.map((c) => (
              <div
                key={c.title}
                className="rounded-xl border border-border bg-card px-4 py-3"
              >
                <p className="text-sm font-medium">{c.title}</p>
                <p className="text-xs text-muted">{c.hint}</p>
              </div>
            ))}
          </div>
        </section>

        <section className="grid gap-8 border-t border-border py-16 md:grid-cols-[1fr_1.2fr] md:gap-16">
          <div>
            <p className="text-sm font-medium text-muted">Getting started</p>
            <h2 className="mt-3 max-w-sm text-3xl font-semibold tracking-tight">
              From download
              <br />
              to menu bar.
            </h2>
            <p className="mt-4 max-w-sm text-sm leading-6 text-muted">
              A quick setup, then your Downloads are a glance away.
            </p>
          </div>
          <ol className="divide-y divide-border">
            {[
              {
                title: "Download & unzip",
                body: "Download DropSweep for macOS and unzip the file.",
              },
              {
                title: "Move to Applications",
                body: "Drag DropSweep into your Applications folder.",
              },
              {
                title: "Open & find DropSweep",
                body: "Open the app, then look for its icon in your Mac’s menu bar.",
              },
            ].map((step, index) => (
              <li
                key={step.title}
                className="flex gap-5 py-5 first:pt-0 last:pb-0"
              >
                <span
                  aria-hidden="true"
                  className="flex size-9 shrink-0 items-center justify-center rounded-full border border-border bg-card text-sm font-medium"
                >
                  {index + 1}
                </span>
                <div>
                  <h3 className="font-medium">{step.title}</h3>
                  <p className="mt-1 text-sm leading-6 text-muted">
                    {step.body}
                  </p>
                </div>
              </li>
            ))}
          </ol>
        </section>

        <section className="border-t border-border py-16">
          <h2 className="text-2xl font-semibold tracking-tight">
            Before you sweep.
          </h2>
          <div className="mt-8 grid gap-8 md:grid-cols-3">
            <div>
              <h3 className="font-semibold">What gets moved?</h3>
              <p className="mt-3 text-sm leading-7 text-muted">
                After confirmation, DropSweep attempts to move all listed files
                and folders from Downloads to the Trash. You cannot select
                individual items. Hidden items directly in Downloads and
                recognized incomplete downloads are skipped. A listed folder
                moves with all its contents, including hidden files. Any
                failures are reported.
              </p>
            </div>
            <div>
              <h3 className="font-semibold">Can I recover my files?</h3>
              <p className="mt-3 text-sm leading-7 text-muted">
                Yes, while they are still in the Trash. Open the Trash in Finder
                and use Put Back to restore an item. DropSweep does not empty
                the Trash. Moving items there does not immediately free their
                disk space.
              </p>
            </div>
            <div>
              <h3 className="font-semibold">What do I need?</h3>
              <p className="mt-3 text-sm leading-7 text-muted">
                A Mac running macOS 26 or later. DropSweep is free and open
                source. Scanning and moving files happen locally; file names and
                contents stay on your Mac.
              </p>
            </div>
          </div>
          <a
            href="/faq"
            className="mt-8 inline-block text-sm underline underline-offset-4"
          >
            Read all FAQs
          </a>
        </section>

        {/* CTA */}
        <section className="border-t border-border py-20 text-center">
          <h2 className="text-2xl font-semibold tracking-tight">
            Ready to sweep?
          </h2>
          <p className="mx-auto mt-2 max-w-md text-sm text-muted">
            Review your Downloads from the menu bar and decide when to move all
            listed items to the Trash.
          </p>
          <a
            href={release.downloadUrl}
            className="mt-8 inline-flex h-11 items-center justify-center gap-2 rounded-lg bg-foreground px-6 text-sm font-medium text-background transition-opacity hover:opacity-90"
          >
            <Logo className="h-4 w-4" />
            {downloadLabel}
          </a>
        </section>
      </main>

      <SiteFooter />
    </div>
  );
}
