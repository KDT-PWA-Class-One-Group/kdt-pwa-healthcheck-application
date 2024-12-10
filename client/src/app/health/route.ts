import { NextResponse } from 'next/server';

export async function GET() {
  try {
    const responseData = {
      status: 'healthy',
      timestamp: Date.now(),
      uptime: process.uptime(),
      message: '정상',
      environment: process.env.NODE_ENV,
      service: 'client'
    };

    return NextResponse.json(responseData, { status: 200 });
  } catch (error) {
    return NextResponse.json({
      status: 'error',
      timestamp: Date.now(),
      message: error instanceof Error ? error.message : '알 수 없는 오류'
    }, { status: 500 });
  }
}
