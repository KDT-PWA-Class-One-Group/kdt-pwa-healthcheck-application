import React from 'react';
import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Health Check Application",
  description: "A health check application for monitoring services",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
