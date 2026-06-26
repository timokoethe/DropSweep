import type { Metadata } from "next";
import Link from "next/link";
import { Logo } from "@/components/Logo";
import { REPO_URL } from "@/lib/seo";

export const metadata: Metadata = {
  title: "Page not found",
  robots: {
    index: false,
    follow: true,
  },
};

export default function NotFound() {
  return (
    <main className="mx-auto flex min-h-[calc(100vh-4rem)] w-full max-w-5xl flex-1 flex-col items-center justify-center px-6 py-20 text-center">
      <Logo className="h-12 w-12" />
      <p className="mt-8 text-sm font-medium text-muted">404</p>
      <h1 className="mt-3 text-balance text-3xl font-semibold tracking-tight sm:text-5xl">
        Page not found.
      </h1>
      <p className="mt-4 max-w-md text-balance text-sm leading-relaxed text-muted">
        This page does not exist, but DropSweep is still ready to clean up your
        Downloads folder from the menu bar.
      </p>
      <div className="mt-8 flex flex-col items-center gap-3 sm:flex-row">
        <Link
          href="/"
          className="inline-flex h-11 items-center justify-center gap-2 rounded-lg bg-foreground px-6 text-sm font-medium text-background transition-opacity hover:opacity-90"
        >
          <Logo className="h-4 w-4" />
          Back to DropSweep
        </Link>
        <a
          href={REPO_URL}
          className="inline-flex h-11 items-center justify-center rounded-lg border border-border px-6 text-sm font-medium transition-colors hover:bg-card"
        >
          View on GitHub
        </a>
      </div>
    </main>
  );
}
