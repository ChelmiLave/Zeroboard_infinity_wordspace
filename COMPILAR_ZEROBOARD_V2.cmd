@echo off
setlocal
pushd "%~dp0Aplicacion" || goto failed
where flutter.bat >nul 2>nul
if errorlevel 1 (
    echo Flutter no esta en el PATH.
    goto failed
)
call flutter pub get
if errorlevel 1 goto failed
call flutter build apk --debug
if errorlevel 1 goto failed
copy /Y "build\app\outputs\flutter-apk\app-debug.apk" "%~dp0ZeroBoard-1.1-Flutter.apk" >nul
if errorlevel 1 goto failed
popd
echo APK lista en "%~dp0ZeroBoard-1.1-Flutter.apk"
pause
exit /b 0

:failed
echo Error de compilacion. Revisa el mensaje anterior.
pause
exit /b 1
