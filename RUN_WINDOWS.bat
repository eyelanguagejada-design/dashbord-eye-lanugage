@echo off
setlocal
echo Starting PostgreSQL...
docker compose up -d
if errorlevel 1 goto :error
if not exist .env.local copy .env.example .env.local
echo.
echo IMPORTANT: Fill .env.local with your Daftra credentials, then press any key.
pause
call npm install
if errorlevel 1 goto :error
call npx prisma generate
if errorlevel 1 goto :error
call npx prisma db push
if errorlevel 1 goto :error
call npm run dev
exit /b 0
:error
echo Setup failed. Review the command output above.
pause
exit /b 1
