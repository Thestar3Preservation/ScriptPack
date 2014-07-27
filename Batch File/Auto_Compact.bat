@echo off
TITLE VHD를 자동으로 최적화시키기.
if not exist c:\windows\system32\sdelete.exe (
echo sdelete.exe파일이 설치되어 있지 않습니다.
echo 아래 경로에서 파일을 받아 설치한뒤 작업을 다시해주세요.
echo http://technet.microsoft.com/en-us/sysinternals/bb897443.aspx
exit /b
)
echo 최적화 시킬 VHD파일의 경로를 적어주세요.
set /p rudfh=경로: 
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
echo vhd파일의 드라이브 문자(ex:a)를 입력해 주세요.
set /p answk=드라이브 문자: 
sdelete -z %answk%:
echo>c:\command_VHD.txt select vdisk file="%rudfh%"
echo>>c:\command_VHD.txt detach vdisk
echo>>c:\command_VHD.txt compact vdisk
echo>>c:\command_VHD.txt exit
diskpart /s c:\command_VHD.txt
del /f c:\command_VHD.txt
pause
rem exit /b