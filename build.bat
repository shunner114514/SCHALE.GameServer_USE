@echo off
setlocal enabledelayedexpansion

:: Replace the server name in appsetting.json (may not be effective for multiple instances)
:: 替换appsetting.json中的服务器名称(对于有多个实例的可能无效)
set "jsonFilePath=phrenapates\Phrenapates\appsettings.json"
set INSTANCE_NAME=""
for /f %%A in ('hostname') do set "hostName=%%A"
for /f "tokens=*" %%I in ('powershell -command "Get-Service | Where-Object { $_.Name -like 'MSSQL*' } | ForEach-Object { $_.Name -replace 'MSSQL\$(.*)', '$1' }"') do (
    set INSTANCE_NAME=%%I
) 
set "serverName=%hostName%\\%INSTANCE_NAME%"
powershell -Command "(Get-Content -path %jsonFilePath% -Raw) -replace '(?-i)\"data source=.*?\"', '\"data source=%serverName%;initial catalog=schale;trusted_connection=true;TrustServerCertificate=True\"' | Set-Content -Path %jsonFilePath%"
echo The server name in appsetting.json has been replaced ( your server name: %serverName% )
timeout /t 1

:: Get the local IP address (prefer WLAN, list four situations)
:: 获取本机IP地址(WLAN优先,列出四种情况)
set "adapter1=WLAN"
set "adapter2=以太网"
set "adapter3=Ethernet"
set "adapter4=Ethernet0"
set "ipAddress="
for /f "delims=" %%A in ('powershell -Command "(Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -eq '%adapter1%'}).IPAddress"') do (
    set "ipAddress=%%A"
)
if not defined ipAddress (
    for /f "delims=" %%B in ('powershell -Command "(Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -eq '%adapter2%'}).IPAddress"') do (
        set "ipAddress=%%B"
    )
)
if not defined ipAddress (
    for /f "delims=" %%C in ('powershell -Command "(Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -eq '%adapter3%'}).IPAddress"') do (
        set "ipAddress=%%C"
    )
)
if not defined ipAddress (
    for /f "delims=" %%D in ('powershell -Command "(Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -eq '%adapter4%'}).IPAddress"') do (
        set "ipAddress=%%D"
    )
)

:: Replace the IP in redirect_server.py
:: 替换redirect_server.py中IP
set "filePath=plana\Scripts\redirect_server_mitmproxy\redirect_server.py"
powershell -Command "(Get-Content -path %filePath% -Raw) -replace 'YOUR_SERVER_IP_ADDRESS', '%ipAddress%' | Set-Content -Path %filePath%"
echo Successfully replaced the IP in redirect_server.py ( your IPv4: %ipAddress% )
timeout /t 1

:: Compile and generate the server-side
:: 编译生成服务端
cd /d %~dp0phrenapates\Phrenapates
dotnet publish --configuration Release --runtime win-x64 --use-current-runtime --self-contained false -p:InvariantGlobalization=false
:: Generate a shortcut for the server-side (when generating the shortcut, remember to set the StartIn location, otherwise, the listening port will be the default 5000 when opened with the shortcut)
:: 生成服务端快捷方式(生成快捷方式时要记得设定起始位置(StartIn),否则使用快捷方式打开时的监听端口为(默认)5000)
set "targetPath=%~dp0phrenapates\Phrenapates\bin\Release\net8.0\win-x64\Phrenapates.exe"
set "shortcutPath=%~dp0Phrenapates.lnk"
set "startIn=%~dp0phrenapates\Phrenapates\bin\Release\net8.0\win-x64"
powershell ^
 $s=(New-Object -COM WScript.Shell).CreateShortcut('%shortcutPath%'); ^
 $s.TargetPath='%targetPath%'; ^
 $s.WorkingDirectory='%startIn%'; ^
 $s.Save()
echo Phrenapate.exe has been generated.
timeout /t 1

:: Run Phrenapate.exe to generate Config.json
:: 启动Phrenapate.exe以生成Config.json
start "" "%~dp0phrenapates\Phrenapates\bin\Release\net8.0\win-x64\Phrenapates.exe"
echo starting server... 
timeout /t 1

:: Check the IP in Config.json
:: 检查Config.json的IP
set "line="
set "counter1=0"
for /f "delims=" %%i in (%~dp0phrenapates\Phrenapates\bin\Release\net8.0\win-x64\Config.json) do (
    set /a counter1+=1
    if !counter1! equ 2 (
        set "line=%%i"
    )
)
for /f "tokens=2 delims=:," %%i in ('echo %line% ^| findstr /i "IRCAddress"') do (
    set "currentIP=%%i"
    set "currentIP=!currentIP:~2,-2!"
)
echo currentIP: %currentIP%
if "%currentIP%" neq "%ipAddress%" (
    echo yourIP: %ipAddress% , need change!
    set "line=!line:%currentIP%=%ipAddress%!"
        (for /f "delims=" %%i in (Config.json) do (
        set /a counter2+=1
        if !counter2! equ 2 (
            echo !line!
        ) else (
            echo %%i
        )
    )) > temp.txt
    move /y temp.txt Config.json
    echo Successfully replaced the IP in Config.json!
    timeout /t 1
) else (
    echo yourIP: %ipAddress%
    echo The IP addresses are identical, no changes required.
    timeout /t 1
)

:: Generate start.bat for starting mitmproxy
:: 生成start.bat,用于启动mitmproxy
set "start=%~dp0start.bat"
echo echo on > %start%
echo start /min cmd /k "cd plana\Scripts\redirect_server_mitmproxy&&mitmweb -m wireguard --no-http2 -s redirect_server.py --set termlog_verbosity=warn --ignore-hosts %ipAddress%" >> %start%
echo start.bat has been generated.
timeout /t 1

echo your server name  %serverName% 
echo your IPv4: %ipAddress% 

timeout /t 3

endlocal
pause