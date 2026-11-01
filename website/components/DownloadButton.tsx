"use client";

import { track } from "@vercel/analytics";

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
      className="inline-flex h-14 items-center justify-center gap-2 rounded-xl bg-foreground px-6 text-base font-medium text-background transition-opacity hover:opacity-90"
    >
      <span aria-hidden="true" className="download-icon" />
      {label}
    </a>
  );
}
