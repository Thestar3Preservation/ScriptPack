@echo off
title �ڽ� VHD�� �����.
echo �������� �� VHD�� ��θ� �����ּ���.
set /p rudfh=���: 
echo ������ �ڽ� ������ ��θ� �����ּ���.
set /p name=���: 
echo>c:\command_VHD.txt select vdisk file="%rudfh%"
rem echo>>c:\command_VHD.txt detach vdisk
echo>>c:\command_VHD.txt create vdisk file="%name%" parent="%rudfh%"
rem echo>>c:\command_VHD.txt attach vdisk
echo>>c:\command_VHD.txt exit
diskpart /s c:\command_VHD.txt
del /f c:\command_VHD.txt
pause