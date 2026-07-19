import type { Metadata } from "next";
import { SoftwareApplicationJsonLd } from "@/components/SoftwareApplicationJsonLd";
import { WebSiteJsonLd } from "@/components/WebSiteJsonLd";
import {
  PORTFOLIO_URL,
  REPO_URL,
  SITE_DESCRIPTION,
  SITE_KEYWORDS,
  SITE_NAME,
  SITE_TITLE,
  SOCIAL_IMAGE_PATH,
} from "@/lib/seo";
import { Logo } from "@/components/Logo";
import { DownloadButton } from "@/components/DownloadButton";
import { MacAppPreview } from "@/components/MacAppPreview";
import { ThemeToggle } from "@/components/ThemeToggle";

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
          asset.name.toLowerCase().endsWith(".dmg"),
      ) ??
      assets.find(
        (asset) =>
          typeof asset.name === "string" &&
          asset.name.toLowerCase().endsWith(".zip"),
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
  { title: "Folders", hint: "directories" },
  { title: "Other", hint: "everything else" },
];

const features = [
  {
    title: "Scans your Downloads",
    body: "Opens straight from the menu bar and reads what's piling up — no setup, no folders to configure.",
  },
  {
    title: "Groups the clutter",
    body: "Installers, archives, PDFs, screenshots and stray folders are sorted into clear categories at a glance.",
  },
  {
    title: "One-click cleanup",
    body: "Send everything you don't need to the Trash in a single tap, then get back to what you were doing.",
  },
  {
    title: "Safe by design",
    body: "Items move to the Trash — never permanently deleted — while hidden items at the top level of Downloads stay untouched.",
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
  const downloadLabel = release.version
    ? `Download ${release.version}`
    : "Download for macOS";

  return (
    <div className="flex flex-col min-h-full">
      <WebSiteJsonLd />
      <SoftwareApplicationJsonLd
        downloadUrl={release.downloadUrl}
        version={release.version}
      />

      {/* Nav */}
      <header className="sticky top-0 z-10 border-b border-border bg-background/80 backdrop-blur-md">
        <div className="mx-auto flex h-14 max-w-5xl items-center justify-between px-6">
          <div className="flex items-center gap-2 font-semibold tracking-tight">
            <Logo className="h-5 w-5" />
            DropSweep
          </div>
          <div className="flex items-center gap-3">
            <ThemeToggle />
            <a
              href={REPO_URL}
              target="_blank"
              rel="noreferrer"
              className="inline-flex items-center gap-2 text-sm text-muted transition-colors hover:text-foreground"
            >
              <GitHubIcon className="h-4 w-4" />
              GitHub
            </a>
          </div>
        </div>
      </header>

      <main className="mx-auto w-full max-w-5xl flex-1 px-6">
        {/* Hero */}
        <section className="flex flex-col items-center pt-16 pb-20 text-center sm:pt-24">
          <span className="mb-6 inline-flex items-center gap-2 rounded-full border border-border bg-card px-3 py-1 text-xs font-medium text-muted">
            <span className="h-1.5 w-1.5 rounded-full bg-emerald-500" />
            Lives in your macOS menu bar
          </span>

          <h1 className="max-w-2xl text-balance text-4xl font-semibold tracking-tight sm:text-6xl">
            Keep your Downloads folder clean.
          </h1>

          <p className="mt-6 max-w-xl text-balance text-lg text-muted">
            DropSweep scans your Downloads, groups the clutter into clear
            categories, and moves what you don&apos;t need to the Trash — all in
            a single click.
          </p>

          <div className="mt-10 flex flex-col items-center gap-3 sm:flex-row">
            <DownloadButton
              href={release.downloadUrl}
              label={downloadLabel}
              version={release.version}
            />
            <a
              href={REPO_URL}
              target="_blank"
              rel="noreferrer"
              className="inline-flex h-11 items-center justify-center gap-2 rounded-lg border border-border px-6 text-sm font-medium transition-colors hover:bg-card"
            >
              <GitHubIcon className="h-4 w-4" />
              View on GitHub
            </a>
          </div>

          <p className="mt-5 text-xs text-muted">Free · Open source · macOS</p>

          <div className="mt-16">
            <MacAppPreview />
          </div>
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
            Everything, sorted.
          </h2>
          <p className="mt-2 max-w-md text-sm text-muted">
            DropSweep recognises the files that usually pile up and keeps them
            grouped so you always know what you&apos;re clearing.
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

        {/* CTA */}
        <section className="border-t border-border py-20 text-center">
          <h2 className="text-2xl font-semibold tracking-tight">
            Ready to sweep?
          </h2>
          <p className="mx-auto mt-2 max-w-md text-sm text-muted">
            Tiny download, lives quietly in your menu bar, and keeps your
            Downloads tidy for good.
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

      {/* Footer */}
      <footer className="border-t border-border">
        <div className="mx-auto flex max-w-5xl flex-col items-center justify-between gap-3 px-6 py-8 text-sm text-muted sm:flex-row">
          <div className="flex items-center gap-2">
            <Logo className="h-4 w-4" />
            <span>DropSweep</span>
          </div>
          <div className="flex items-center gap-6">
            <a
              href={PORTFOLIO_URL}
              className="transition-colors hover:text-foreground"
            >
              Implementation
            </a>
            <a
              href="https://itstimo.me"
              target="_blank"
              rel="noreferrer"
              className="transition-colors hover:text-foreground"
            >
              Timo Köthe
            </a>
            <span>© {new Date().getFullYear()}</span>
          </div>
        </div>
      </footer>
    </div>
  );
}
