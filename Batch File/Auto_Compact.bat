@echo off
TITLE VHD�� �ڵ����� ����ȭ��Ű��.
if not exist c:\windows\system32\sdelete.exe (
echo sdelete.exe������ ��ġ�Ǿ� ���� �ʽ��ϴ�.
echo �Ʒ� ��ο��� ������ �޾� ��ġ�ѵ� �۾��� �ٽ����ּ���.
echo http://technet.microsoft.com/en-us/sysinternals/bb897443.aspx
exit /b
)
echo ����ȭ ��ų VHD������ ��θ� �����ּ���.
set /p rudfh=���: 
goto OUT
for %%a in ( A: B: C: D: E: F: G: H: I: J: K: L: M: N: O: P: Q: R: S: T: U: V: W: X: Y: Z: ) do (
 if not exist %%a (
  set answk=%%a
  goto OUT
 )
)
:OUT
echo>c:\command_VHD.txt select vdisk file="%rudfh%"
echo>>c:\command_VHD.txt attach vdisk
rem echo>>c:\command_VHD.txt select partition=1
rem echo>>c:\command_VHD.txt assign letter=%answk%
echo>>c:\command_VHD.txt exit
diskpart /s c:\command_VHD.txt
echo:
echo vhd������ ����̺� ����(ex:a)�� �Է��� �ּ���.
set /p answk=����̺� ����: 
sdelete -z %answk%:
echo>c:\command_VHD.txt select vdisk file="%rudfh%"
echo>>c:\command_VHD.txt detach vdisk
echo>>c:\command_VHD.txt compact vdisk
echo>>c:\command_VHD.txt exit
diskpart /s c:\command_VHD.txt
del /f c:\command_VHD.txt
pause
rem exit /b