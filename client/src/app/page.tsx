'use client';

import { useState, useEffect } from 'react';

interface HealthRecord {
  id: number;
  patient_name: string;
  exam_date: string;
  exam_type: string;
  result: string | null;
  height: number | null;
  weight: number | null;
  blood_pressure: string | null;
  blood_sugar: number | null;
  created_at: string;
  updated_at: string;
}

interface ApiResponse {
  success: boolean;
  message: string;
  data: HealthRecord[];
}

export default function Home() {
  const [records, setRecords] = useState<HealthRecord[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetchHealthRecords();
  }, []);

  const fetchHealthRecords = async () => {
    try {
      const response = await fetch('/api/health-records');
      if (!response.ok) {
        throw new Error('데이터를 불러오는데 실패했습니다');
      }
      const result: ApiResponse = await response.json();
      if (!result.success) {
        throw new Error(result.message);
      }
      setRecords(result.data);
      setError(null);
    } catch (err) {
      setError(err instanceof Error ? err.message : '알 수 없는 오류가 발생했습니다');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gray-100">
      <header className="bg-white shadow">
        <div className="max-w-7xl mx-auto py-6 px-4">
          <h1 className="text-3xl font-bold text-gray-900">건강검진 시스템</h1>
        </div>
      </header>

      <main className="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
        {/* 검진 결과 목록 */}
        <div className="bg-white shadow overflow-hidden sm:rounded-lg">
          <div className="px-4 py-5 sm:px-6">
            <h2 className="text-lg font-medium text-gray-900">검진 결과 목록</h2>
            <p className="mt-1 text-sm text-gray-500">최근 검진 기록을 확인할 수 있습니다.</p>
          </div>
          <div className="border-t border-gray-200">
            {loading ? (
              <div className="p-4 text-center">로딩 중...</div>
            ) : error ? (
              <div className="p-4 text-center text-red-600">{error}</div>
            ) : (
              <ul className="divide-y divide-gray-200">
                {records.map((record) => (
                  <li key={record.id} className="px-4 py-4">
                    <div className="flex items-center justify-between">
                      <div>
                        <p className="text-sm font-medium text-gray-900">{record.patient_name}</p>
                        <p className="text-sm text-gray-500">{record.exam_type}</p>
                        <p className="text-sm text-gray-500">결과: {record.result || '없음'}</p>
                        {record.height && record.weight && (
                          <p className="text-sm text-gray-500">
                            신체: 키 {record.height}cm, 체중 {record.weight}kg
                          </p>
                        )}
                        {record.blood_pressure && (
                          <p className="text-sm text-gray-500">혈압: {record.blood_pressure}</p>
                        )}
                        {record.blood_sugar && (
                          <p className="text-sm text-gray-500">혈당: {record.blood_sugar}</p>
                        )}
                      </div>
                      <div className="text-sm text-gray-500">
                        <p>{new Date(record.exam_date).toLocaleDateString()}</p>
                        <p className="text-xs">
                          수정: {new Date(record.updated_at).toLocaleString()}
                        </p>
                      </div>
                    </div>
                  </li>
                ))}
              </ul>
            )}
          </div>
        </div>

        {/* API 상태 표시 */}
        <div className="mt-6 bg-white shadow sm:rounded-lg">
          <div className="px-4 py-5 sm:p-6">
            <h3 className="text-lg font-medium text-gray-900">시스템 상태</h3>
            <div className="mt-2 max-w-xl text-sm text-gray-500">
              <p>API 서버 연결 상태를 확인합니다.</p>
            </div>
            <div className="mt-3">
              <button
                type="button"
                onClick={fetchHealthRecords}
                className="inline-flex items-center px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
              >
                상로고침
              </button>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}
