@echo off
rem Edit this line if you ever move the repo to a different folder.
set "REPO_PATH=/c/Users/ashho/sure-src"

"C:\Program Files\Git\bin\bash.exe" -lc "cd '%REPO_PATH%' && bash bin/deploy_locally %*"
echo.
echo Press any key to close this window...
pause >nul
