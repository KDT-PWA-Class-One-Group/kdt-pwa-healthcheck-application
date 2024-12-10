import * as fs from 'fs';
import { exec } from 'child_process';
import { promisify } from 'util';

const execAsync = promisify(exec);

/** 
 * @type {string[]}
 * @description Docker와 PostgreSQL 환경에 필요한 사전지식 목록
 */
const Prerequisites: string[] = [
    "Docker 기본 명령어 사용법 이해",
    "docker-compose.yml 파일 구조 이해",
    "PostgreSQL 초기화 스크립트(init.sql) 작성법",
    "pg_hba.conf 및 postgresql.conf 설정 문법"
];

/**
 * @function checkpoint
 * @description Docker 및 DB 컨테이너 상태를 점검하고 문제 해결 가이드를 제공합니다.
 * @param {string} logs - 컨테이너 로그 문자열
 * @returns {Promise<string>} 분석 결과 및 개선 프롬프트 메시지
 */
export const checkpoint = async (logs: string): Promise<string> => {
    try {
        // 컨테이너 상태 확인
        const { stdout: containerStatus } = await execAsync('docker ps -a');
        const isContainerRunning = containerStatus.includes('healthcheck-db');

        // 로그 분석
        const hasDatabaseExistError = logs.includes("already exists");
        
        // 설정 파일 존재 여부 확인
        const configFiles = ['init.sql', 'postgresql.conf', 'pg_hba.conf'].map(file => 
            fs.existsSync(`${__dirname}/${file}`)
        );

        // 문제 상황에 따른 가이드 메시지 생성
        let guide = "다음 단계별 명령을 실행하기 전에 아래 사항을 확인하세요:\n\n";

        if (!isContainerRunning) {
            guide += "1. DB 컨테이너가 실행되지 않았습니다. 다음 명령어로 상태를 확인하세요:\n";
            guide += "   docker ps -a | grep healthcheck-db\n\n";
        }

        if (hasDatabaseExistError) {
            guide += "2. 데이터베이스가 이미 존재합니다. init.sql을 수정하세요:\n";
            guide += "   - DROP DATABASE IF EXISTS healthcheck; 구문 추가 검토\n\n";
        }

        if (configFiles.some(exists => !exists)) {
            guide += "3. 필수 설정 파일이 누락되었습니다:\n";
            guide += "   - 모든 설정 파일이 /db 디렉토리에 존재하는지 확인\n\n";
        }

        guide += "4. 문제 해결 후 다음 명령어로 재시작하세요:\n";
        guide += "   docker compose down --volumes && docker compose up -d\n";

        return guide;
    } catch (error) {
        return `오류 발생: ${error.message}`;
    }
};

// 사용 예시
if (require.main === module) {
    (async () => {
        const exampleLogs = "Error: database \"healthcheck\" already exists";
        const result = await checkpoint(exampleLogs);
        console.log("결과 메시지:", result);
    })();
} 