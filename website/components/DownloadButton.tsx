"use client";

import { track } from "@vercel/analytics";
import type { ReactNode } from "react";

type DownloadButtonProps = {
  href: string;
  label: string;
  version: string | null;
  location: "hero" | "bottom-cta";
  className?: string;
  icon?: ReactNode;
};

export function DownloadButton({ href, label, version, location, className, icon }: DownloadButtonProps) {
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
      className={className ?? "inline-flex h-14 items-center justify-center gap-2 rounded-xl bg-foreground px-6 text-base font-medium text-background transition-opacity hover:opacity-90"}
    >
      {icon ?? <span aria-hidden="true" className="download-icon" />}
      {label}
    </a>
  );
}
