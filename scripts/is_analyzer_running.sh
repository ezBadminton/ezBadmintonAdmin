isRunning=$(powershell -Command "(Get-CimInstance Win32_Process -Filter \"CommandLine like '%analyze --watch --write=analyzer_problems.log'\" | measure | Select-Object -expand count) -gt 0")
if [ "$isRunning" = True ]
then
    exit 0
else
    exit 1
fi