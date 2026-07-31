import Link from "next/link";
import { Logo } from "@/components/Logo";
import { PORTFOLIO_URL } from "@/lib/seo";

export function SiteFooter() {
  return (
    <footer className="border-t border-border">
      <div className="mx-auto flex max-w-5xl flex-col items-center justify-between gap-4 px-6 py-8 text-sm text-muted sm:flex-row">
        <Link
          href="/"
          className="flex items-center gap-2 transition-colors hover:text-foreground"
        >
          <Logo className="h-4 w-4" />
          <span>DropSweep</span>
        </Link>
        <nav
          aria-label="Footer"
          className="flex flex-wrap items-center justify-center gap-x-6 gap-y-3"
        >
          <Link href="/faq" className="transition-colors hover:text-foreground">
            FAQ
          </Link>
          <Link
            href="/privacy"
            className="transition-colors hover:text-foreground"
          >
            Privacy
          </Link>
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
        </nav>
      </div>
    </footer>
  );
}
