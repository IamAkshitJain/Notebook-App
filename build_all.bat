@echo off
echo ===================================================
echo PaperCraft Studio - Multiplatform Build Pipeline
echo Targets: Android APK, Windows EXE, and Web
echo ===================================================

echo [1/4] Fetching dependencies...
call flutter pub get

echo [2/4] Building Web Release Bundle...
call flutter build web --release --web-renderer canvaskit

echo [3/4] Building Android APK (Release)...
call flutter build apk --release --split-per-abi

echo [4/4] Building Windows Desktop EXE...
call flutter build windows --release

echo ===================================================
echo Build pipeline executed successfully!
echo Outputs located in:
echo   - Android APK: build\app\outputs\flutter-apk\
echo   - Windows EXE: build\windows\x64\runner\Release\
echo   - Web Bundle:  build\web\
echo ===================================================
pause
