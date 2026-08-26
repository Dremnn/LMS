@echo off
chcp 65001 >nul
echo ========================================================
echo   DANG CAU HINH TCP/IP CHO SQL SERVER SQLEXPRESS
echo ========================================================

:: Kiem tra quyen Administrator va tu dong xin quyen
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Dang yeu cau quyen Administrator (UAC)...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

echo [1/3] Dang bat giao thuc TCP/IP...
reg add "HKLM\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL17.SQLEXPRESS\MSSQLServer\SuperSocketNetLib\Tcp" /v Enabled /t REG_DWORD /d 1 /f

echo [2/3] Dang dat Port 1433 cho IPAll...
reg add "HKLM\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL17.SQLEXPRESS\MSSQLServer\SuperSocketNetLib\Tcp\IPAll" /v TcpPort /t REG_SZ /d "1433" /f
reg add "HKLM\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL17.SQLEXPRESS\MSSQLServer\SuperSocketNetLib\Tcp\IPAll" /v TcpDynamicPorts /t REG_SZ /d "" /f

echo [3/3] Dang khoi dong lai dich vu SQL Server (SQLEXPRESS)...
net stop "MSSQL$SQLEXPRESS"
net start "MSSQL$SQLEXPRESS"

echo.
echo ========================================================
echo   DA CAU HINH THANH CONG! BAN CO THE TEST LAI KET NOI.
echo ========================================================
echo.
pause
