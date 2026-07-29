import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "YTPro Control Panel",
  description: "YoutubePro Remote Control Dashboard",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <head>
        <link
          href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@300;400;500;700&display=swap"
          rel="stylesheet"
        />
      </head>
      <body className="bg-dark-900 text-gray-100 font-mono antialiased">{children}</body>
    </html>
  );
}
