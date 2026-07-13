import type { Metadata } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import { Analytics } from "@vercel/analytics/next";
import { SpeedInsights } from "@vercel/speed-insights/next";
import {
  SITE_DESCRIPTION,
  SITE_AUTHOR,
  SITE_ICON_PATH,
  SITE_NAME,
  SITE_URL,
  SOCIAL_IMAGE_PATH,
} from "@/lib/seo";
import "./globals.css";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  metadataBase: new URL(SITE_URL),
  applicationName: SITE_NAME,
  title: {
    default: "DropSweep - Clean up your Downloads from the menu bar",
    template: `%s | ${SITE_NAME}`,
  },
  description: SITE_DESCRIPTION,
  keywords: [
    "DropSweep",
    "macOS Downloads cleaner",
    "menu bar app",
    "Downloads folder cleanup",
    "Mac cleanup app",
    "open source macOS app",
  ],
  authors: [SITE_AUTHOR],
  creator: SITE_AUTHOR.name,
  publisher: SITE_NAME,
  alternates: {
    canonical: "/",
  },
  icons: {
    icon: [
      {
        url: SITE_ICON_PATH,
        sizes: "256x256",
        type: "image/png",
      },
    ],
    apple: [
      {
        url: SITE_ICON_PATH,
        sizes: "256x256",
        type: "image/png",
      },
    ],
  },
  openGraph: {
    title: "DropSweep - Clean up your Downloads from the menu bar",
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
    title: "DropSweep - Clean up your Downloads from the menu bar",
    description: SITE_DESCRIPTION,
    images: [
      {
        url: SOCIAL_IMAGE_PATH,
        alt: "DropSweep app preview",
      },
    ],
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

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html
      lang="en"
      suppressHydrationWarning
      className={`${geistSans.variable} ${geistMono.variable} h-full antialiased`}
    >
      <head>
        <script
          dangerouslySetInnerHTML={{
            __html: `(function(){var t;try{t=localStorage.getItem("theme")}catch(e){}var d=t==="dark"||t==="light"?t:matchMedia("(prefers-color-scheme: dark)").matches?"dark":"light";document.documentElement.dataset.theme=d;document.documentElement.style.colorScheme=d})()`,
          }}
        />
      </head>
      <body className="min-h-full flex flex-col">
        {children}
        <Analytics />
        <SpeedInsights />
      </body>
    </html>
  );
}
