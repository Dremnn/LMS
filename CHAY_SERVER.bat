@echo off
color 0A
title LMS Tomcat Server

set "JAVA_HOME=E:\Eclipse Adoptium\jdk-25.0.4.7-hotspot"
set "PATH=%JAVA_HOME%\bin;%PATH%"

echo ===================================================
echo   DANG DONG GOI MA NGUON (MAVEN BUILD)
echo ===================================================

cd /d "E:\Github\LMS\lms-project"

call E:\apache-maven-3.9.9\bin\mvn.cmd clean package -DskipTests
if %errorlevel% neq 0 (
    color 0C
    echo.
    echo ===================================================
    echo LOI: Bien dich Code that bai! Vui long kiem tra.
    echo ===================================================
    pause
    exit /b %errorlevel%
)

echo.
echo ===================================================
echo   XOA CACHE VA BAN DEPLOY CU TREN TOMCAT
echo ===================================================
set TOMCAT_DIR=E:\apache-tomcat-11.0.25\apache-tomcat-11.0.25
if exist "%TOMCAT_DIR%\webapps\lms-project" rmdir /s /q "%TOMCAT_DIR%\webapps\lms-project"
if exist "%TOMCAT_DIR%\webapps\lms-project.war" del /f /q "%TOMCAT_DIR%\webapps\lms-project.war"
if exist "%TOMCAT_DIR%\work\Catalina\localhost\lms-project" rmdir /s /q "%TOMCAT_DIR%\work\Catalina\localhost\lms-project"

echo.
echo ===================================================
echo   COPY BAN DEPLOY MOI (lms-project.war)
echo ===================================================
copy /Y "E:\Github\LMS\lms-project\target\lms-project.war" "%TOMCAT_DIR%\webapps\lms-project.war"

echo.
echo ===================================================
echo   KHOI DONG TOMCAT SERVER...
echo ===================================================
cd /d "%TOMCAT_DIR%\bin"
call startup.bat

echo.
echo Hoan thanh! Web da mo o dia chi: http://localhost:8080/lms-project/
pause