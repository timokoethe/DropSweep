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
      className={className ?? "download-button"}
    >
      {icon ?? <span aria-hidden="true" className="download-icon" />}
      {label}
    </a>
  );
}
