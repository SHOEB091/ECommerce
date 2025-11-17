@echo off
REM Deployment Helper Script for Windows
REM Usage: deploy.bat [backend|flutter|all]

set DEPLOY_TYPE=%1
if "%DEPLOY_TYPE%"=="" set DEPLOY_TYPE=all

echo 🚀 Starting deployment process...

if "%DEPLOY_TYPE%"=="backend" goto deploy_backend
if "%DEPLOY_TYPE%"=="flutter" goto deploy_flutter
if "%DEPLOY_TYPE%"=="web" goto deploy_flutter
if "%DEPLOY_TYPE%"=="all" goto deploy_all
goto usage

:deploy_backend
echo 📦 Backend deployment instructions:
echo    1. Push to GitHub (Railway/Render auto-deploys)
echo    2. Set environment variables in your platform dashboard
goto end

:deploy_flutter
echo 🌐 Building Flutter Web...
cd ecommerce

set /p UPDATE_API="Update API base URL? (y/n): "
if /i "%UPDATE_API%"=="y" (
    set /p API_URL="Enter backend API URL: "
    if not "%API_URL%"=="" (
        powershell -Command "(Get-Content lib\utils\api.dart) -replace 'const String API_BASE = .*', 'const String API_BASE = ''%API_URL%/api/v1'';' | Set-Content lib\utils\api.dart"
        echo ✅ Updated API base URL
    )
)

echo Building web app...
call flutter clean
call flutter pub get
call flutter build web --release

echo ✅ Web build complete!
echo 📁 Build output: build\web
echo.
echo To deploy:
echo   Firebase: firebase deploy --only hosting
echo   Netlify:  Drag build\web folder to netlify.com
cd ..
goto end

:deploy_all
call :deploy_backend
echo.
call :deploy_flutter
goto end

:usage
echo Usage: deploy.bat [backend^|flutter^|all]
exit /b 1

:end
echo 🎉 Deployment process complete!
pause

