@echo off
REM Script to update API URL in Flutter app
REM Usage: update-api-url.bat <your-backend-url>

if "%1"=="" (
    echo Usage: update-api-url.bat ^<your-backend-url^>
    echo Example: update-api-url.bat https://my-app.railway.app
    exit /b 1
)

set API_URL=%1
echo Updating API URL to: %API_URL%

REM Update api.dart
powershell -Command "(Get-Content ecommerce\lib\utils\api.dart) -replace 'const String API_BASE = .*', 'const String API_BASE = ''%API_URL%/api/v1'';' | Set-Content ecommerce\lib\utils\api.dart"

REM Update main.dart for cart service
powershell -Command "(Get-Content ecommerce\lib\main.dart) -replace 'host: ''localhost''', 'host: ''%API_URL:~8%'', useHttps: true' | Set-Content ecommerce\lib\main.dart"
powershell -Command "(Get-Content ecommerce\lib\main.dart) -replace 'port: 5000', 'port: 443' | Set-Content ecommerce\lib\main.dart"

echo.
echo ✅ API URL updated successfully!
echo.
echo Files updated:
echo   - ecommerce\lib\utils\api.dart
echo   - ecommerce\lib\main.dart
echo.
echo Next steps:
echo   1. cd ecommerce
echo   2. flutter clean
echo   3. flutter pub get
echo   4. flutter build apk --release
echo.

