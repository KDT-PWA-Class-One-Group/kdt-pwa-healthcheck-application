'use client';

import { useState, useEffect } from 'react';

interface HealthRecord {
  id: number;
  user_name: string;
  check_date: string;
  health_status: string;
}

interface ApiResponse {
  success: boolean;
  message: string;
  data: HealthRecord[];
}

export default function Home() {
  const [records, setRecords] = useState<HealthRecord[]>([]);
  const [userName, setUserName] = useState('');
  const [healthStatus, setHealthStatus] = useState('');
  const [error, setError] = useState('');

  useEffect(() => {
    fetchRecords();
  }, []);

  const fetchRecords = async () => {
    try {
      const response = await fetch('/api/health-records');
      if (!response.ok) {
        throw new Error('데이터를 불러오는데 실패했습니다');
      }
      const result: ApiResponse = await response.json();
      if (result.success && Array.isArray(result.data)) {
        setRecords(result.data);
        setError('');
      } else {
        throw new Error(result.message || '데이터 형식이 올바르지 않습니다');
      }
    } catch (error) {
      console.error('Error fetching records:', error);
      setError('데이터를 불러오는데 실패했습니다');
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      const response = await fetch('/api/health-records', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ user_name: userName, health_status: healthStatus }),
      });
      if (!response.ok) {
        throw new Error('기록 추가에 실패했습니다');
      }
      const result: ApiResponse = await response.json();
      if (result.success) {
        fetchRecords();
        setUserName('');
        setHealthStatus('');
        setError('');
      } else {
        throw new Error(result.message || '기록 추가에 실패했습니다');
      }
    } catch (error) {
      console.error('Error creating record:', error);
      setError('기록 추가에 실패했습니다');
    }
  };

  return (
    <main className="p-8">
      <h1 className="text-2xl font-bold mb-6">건강검진 기록</h1>
      
      {error && (
        <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
          {error}
        </div>
      )}

      <form onSubmit={handleSubmit} className="mb-8">
        <div className="flex gap-4">
          <input
            type="text"
            value={userName}
            onChange={(e) => setUserName(e.target.value)}
            placeholder="이름"
            className="border p-2 rounded"
            required
          />
          <input
            type="text"
            value={healthStatus}
            onChange={(e) => setHealthStatus(e.target.value)}
            placeholder="건강 상태"
            className="border p-2 rounded"
            required
          />
          <button 
            type="submit" 
            className="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600 transition-colors"
          >
            추가
          </button>
        </div>
      </form>

      <div className="grid gap-4">
        {records.length === 0 ? (
          <p className="text-gray-500">등록된 건강검진 기록이 없습니다.</p>
        ) : (
          records.map((record) => (
            <div key={record.id} className="border p-4 rounded shadow-sm hover:shadow-md transition-shadow">
              <h3 className="font-bold">{record.user_name}</h3>
              <p>검진일: {new Date(record.check_date).toLocaleDateString()}</p>
              <p>상태: {record.health_status}</p>
            </div>
          ))
        )}
      </div>
    </main>
  );
}
