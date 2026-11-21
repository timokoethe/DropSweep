"use client";

import { track } from "@vercel/analytics";

type DownloadButtonProps = {
  href: string;
  label: string;
  version: string | null;
  location: "hero" | "bottom-cta";
  className?: string;
};

export function DownloadButton({ href, label, version, location, className }: DownloadButtonProps) {
  return (
    <a
      href={href}
      onClick={() => {
        track("Download Clicked", {
          location,
          version,
          href,
        });
      }}
      className={className ?? "download-button"}
    >
      <span aria-hidden="true" className="download-icon" />
      {label}
    </a>
  );
}
