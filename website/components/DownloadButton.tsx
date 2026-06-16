"use client";

import { track } from "@vercel/analytics";
import { Logo } from "@/components/Logo";

type DownloadButtonProps = {
  href: string;
  label: string;
  version: string | null;
};

export function DownloadButton({ href, label, version }: DownloadButtonProps) {
  return (
    <a
      href={href}
      onClick={() => {
        track("Download Clicked", {
          location: "hero",
          version,
          href,
        });
      }}
      className="inline-flex h-11 items-center justify-center gap-2 rounded-lg bg-foreground px-6 text-sm font-medium text-background transition-opacity hover:opacity-90"
    >
      <Logo className="h-4 w-4" />
      {label}
    </a>
  );
}
