import { NextResponse } from "next/server";

export async function GET() {
  console.log("[Health Check] 요청 시작 -", new Date().toISOString());

  try {
    const responseData = {
      status: "healthy",
      timestamp: Date.now(),
      uptime: process.uptime(),
      message: "정상",
      environment: process.env.NODE_ENV,
      path: "/api/health",
    };

    console.log(
      "[Health Check] 응답 데이터:",
      JSON.stringify(responseData, null, 2)
    );

    return NextResponse.json(responseData, {
      status: 200,
      headers: {
        "Content-Type": "application/json",
      },
    });
  } catch (error: unknown) {
    console.error("[Health Check] 오류 발생:", error);
    const errorMessage =
      error instanceof Error
        ? {
            name: error.name,
            message: error.message,
            stack: error.stack,
          }
        : String(error);
    console.error("[Health Check] 오류 상세:", errorMessage);

    return NextResponse.json(
      {
        status: "unhealthy",
        timestamp: Date.now(),
        message: "오류 발생",
        error: errorMessage,
      },
      {
        status: 500,
      }
    );
  }
}
