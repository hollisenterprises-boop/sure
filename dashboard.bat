@echo off
cd /d "C:\Users\ashho\sure-src"
start "Deploy Dashboard Server" /min node bin\deploy_dashboard
timeout /t 2 /nobreak >nul
start "" "http://127.0.0.1:4567"
echo Dashboard server is running in a minimized window titled "Deploy Dashboard Server".
echo Closing THIS window won't stop it -- close that minimized window (or use Task Manager) to stop the dashboard.
echo.
pause
