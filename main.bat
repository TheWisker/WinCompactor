@echo off
title Windows Compactor

net session >nul 2>&1
if not %errorLevel% EQU 0 echo "Administrator privileges required!" && exit

set /p _disk=Enter drive letter:
set /p _defrg=Defragment drive? [Ny]:

echo "Removing hyberfile.sys!"
powercfg -h off

echo "Removing pagefile.sys!"
wmic pagefileset where 'name="%_disk%:\pagefile.sys"' delete

echo "Doing some cleaning!"
cleanmgr /sagerun
del %temp%\*.* /s /q
cleanmgr /verylowdisk /d
del C:\Windows\prefetch\*.*/s/q
Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase

echo "Running debloater!"
powershell -Command "& {.debloater\Windows10SysPrepDebloater.ps1 -Sysprep -Debloat -Privacy}"

echo "Disabling some services!"
regsvr32.exe /u hnetmon.dll

echo "Resetting network!"
netsh winsock reset 

echo "Flushing DNS cache!"
ipconfig /flushdns

echo "Following packages should be removed:"
powershell -Command "& {Get-AppXProvisionedPackage -Online | Select PackageName}"
echo "Remove by running: Remove-AppXProvisionedPackage -Online -PackageName {package-name}"
pause

echo "Compacting OS!"
Compact.exe /CompactOS:always

echo "Defragmenting drive %_disk%:\!"
if /i "%_defrg%" == "y" defrag %_disk%: /o

echo "Scanning for system problems!"
sfc /scannow

echo "This are the remaining programs:"
wmic product get name

echo "Opening optimizer!"
optimizer/optimizer.exe

echo "All done!"
pause