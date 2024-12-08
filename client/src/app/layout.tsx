import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "건강검진 시스템",
  description: "정기 건강검진 관리 시스템",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="ko">
      <body>{children}</body>
    </html>
  );
}
