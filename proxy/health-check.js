const fs = require('fs');
const os = require('os');
const path = require('path');

function getSystemStats() {
    const totalMemory = os.totalmem();
    const freeMemory = os.freemem();
    const usedMemory = totalMemory - freeMemory;

    return {
        memory: {
            total: `${Math.round(totalMemory / 1024 / 1024)} MB`,
            free: `${Math.round(freeMemory / 1024 / 1024)} MB`,
            used: `${Math.round(usedMemory / 1024 / 1024)} MB`
        },
        uptime: `${Math.round(os.uptime() / 60)} minutes`
    };
}

function updateHealthCheck(nginxStats = {}) {
    try {
        // JSON 파일 읽기
        const healthCheckPath = path.join(__dirname, 'health-check.json');
        const healthCheck = JSON.parse(fs.readFileSync(healthCheckPath, 'utf8'));

        // 시스템 상태 업데이트
        const stats = getSystemStats();
        healthCheck.data.timestamp = new Date().toISOString();
        healthCheck.data.components.proxy.memory = stats.memory;
        healthCheck.data.components.proxy.uptime = stats.uptime;

        // Nginx 연결 상태 업데이트
        healthCheck.data.components.proxy.connections = {
            active: parseInt(nginxStats.connections_active || 0),
            reading: parseInt(nginxStats.connections_reading || 0),
            writing: parseInt(nginxStats.connections_writing || 0),
            waiting: parseInt(nginxStats.connections_waiting || 0)
        };

        // 업데이트된 JSON 저장
        fs.writeFileSync(healthCheckPath, JSON.stringify(healthCheck, null, 4));
        return healthCheck;
    } catch (error) {
        console.error('Error updating health check:', error);
        return {
            success: false,
            message: "헬스체크 업데이트 중 오류가 발생했습니다.",
            data: {
                component: "system",
                status: "error",
                timestamp: new Date().toISOString(),
                error: error.message
            }
        };
    }
}

// 주기적으로 상태 업데이트 (1분마다)
setInterval(() => {
    updateHealthCheck();
}, 60000);

// 초기 상태 업데이트
updateHealthCheck();

module.exports = { updateHealthCheck };
