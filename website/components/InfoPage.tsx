import type { ReactNode } from "react";
import { SiteFooter } from "@/components/SiteFooter";
import { SiteHeader } from "@/components/SiteHeader";

type InfoPageProps = {
  eyebrow: string;
  title: string;
  description: string;
  children: ReactNode;
};

export function InfoPage({
  eyebrow,
  title,
  description,
  children,
}: InfoPageProps) {
  return (
    <div className="flex min-h-full flex-col">
      <SiteHeader />
      <main className="mx-auto w-full max-w-3xl flex-1 px-6 py-16 sm:py-24">
        <header className="border-b border-border pb-12">
          <p className="text-sm font-medium text-muted">{eyebrow}</p>
          <h1 className="mt-4 text-balance text-4xl font-semibold tracking-tight sm:text-5xl">
            {title}
          </h1>
          <p className="mt-5 max-w-2xl text-balance text-base leading-7 text-muted sm:text-lg">
            {description}
          </p>
        </header>
        <div className="py-12">{children}</div>
      </main>
      <SiteFooter />
    </div>
  );
}
