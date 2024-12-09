'use client';

import { useState, useEffect } from 'react';

interface SystemMemory {
  rss: number;
  heapTotal: number;
  heapUsed: number;
}

interface SystemInfo {
  uptime: number;
  timestamp: number;
  memory: SystemMemory;
}

interface ServiceStatus {
  status: 'healthy' | 'unhealthy';
  responseTime: number;
  message: string;
}

interface MonitorData {
  system: SystemInfo;
  services: {
    [key: string]: ServiceStatus;
  };
}

export default function MonitorPage() {
  const [monitorData, setMonitorData] = useState<MonitorData | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    async function fetchMonitorData() {
      try {
        const response = await fetch('/api/monitor');
        if (!response.ok) {
          throw new Error('모니터링 데이터를 가져오는 데 실패했습니다.');
        }
        const data = await response.json();
        setMonitorData(data);
      } catch (err) {
        setError(err instanceof Error ? err.message : '알 수 없는 오류가 발생했습니다.');
      }
    }

    // 초기 데이터 로드
    fetchMonitorData();

    // 10초마다 데이터 갱신
    const interval = setInterval(fetchMonitorData, 10000);

    // 컴포넌트 언마운트 시 인터벌 정리
    return () => clearInterval(interval);
  }, []);

  if (error) return <div>오류: {error}</div>;
  if (!monitorData) return <div>로딩 중...</div>;

  return (
    <div className="container mx-auto p-6">
      <h1 className="text-3xl font-bold mb-6">시스템 모니터링</h1>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {/* 시스템 상태 */}
        <div className="bg-white shadow-md rounded-lg p-6">
          <h2 className="text-xl font-semibold mb-4">시스템 상태</h2>
          <div>
            <p>업타임: {monitorData.system.uptime.toFixed(2)}초</p>
            <p>타임스탬프: {new Date(monitorData.system.timestamp).toLocaleString()}</p>
          </div>
        </div>

        {/* 메모리 사용량 */}
        <div className="bg-white shadow-md rounded-lg p-6">
          <h2 className="text-xl font-semibold mb-4">메모리 사용량</h2>
          <div>
            <p>총 메모리: {(monitorData.system.memory.rss / 1024 / 1024).toFixed(2)} MB</p>
            <p>힙 총 크기: {(monitorData.system.memory.heapTotal / 1024 / 1024).toFixed(2)} MB</p>
            <p>힙 사용량: {(monitorData.system.memory.heapUsed / 1024 / 1024).toFixed(2)} MB</p>
          </div>
        </div>

        {/* 서비스 상태 */}
        <div className="bg-white shadow-md rounded-lg p-6">
          <h2 className="text-xl font-semibold mb-4">서비스 상태</h2>
          <div>
            {Object.entries(monitorData.services).map(([service, status]) => (
              <div key={service} className="mb-2">
                <span className="font-medium">{service}: </span>
                <span className={`font-bold ${status.status === 'healthy' ? 'text-green-600' : 'text-red-600'}`}>
                  {status.status}
                </span>
              </div>
            ))}
          </div>
        </div>

        {/* 원시 데이터 */}
        <div className="bg-white shadow-md rounded-lg p-6 md:col-span-2">
          <h2 className="text-xl font-semibold mb-4">원시 모니터링 데이터</h2>
          <pre className="bg-gray-100 p-4 rounded-md overflow-x-auto text-sm">
            {JSON.stringify(monitorData, null, 2)}
          </pre>
        </div>
      </div>
    </div>
  );
}
