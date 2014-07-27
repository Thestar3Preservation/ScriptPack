@echo off
title 자식 VHD를 만들기.
echo 기준점이 될 VHD의 경로를 적어주세요.
set /p rudfh=경로: 
echo 생성될 자식 파일의 경로를 적어주세요.
set /p name=경로: 
echo>c:\command_VHD.txt select vdisk file="%rudfh%"
rem echo>>c:\command_VHD.txt detach vdisk
echo>>c:\command_VHD.txt create vdisk file="%name%" parent="%rudfh%"
rem echo>>c:\command_VHD.txt attach vdisk
echo>>c:\command_VHD.txt exit
diskpart /s c:\command_VHD.txt
del /f c:\command_VHD.txt
pause