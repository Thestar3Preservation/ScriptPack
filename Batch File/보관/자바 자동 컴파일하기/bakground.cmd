@echo off
setlocal
set pdate=%date:~2,2%%date:~5,2%%date:~-2%
cd ..
md %pdate%
cd %pdate%
echo. > check.java
attrib +H check.java
start cmd /K ..\compile.cmd
rem 입력이 유니코드입니다.
rem 이 파일은 현재날자의 폴더를 만들어 작업폴더로 삼고, gedit와 자동 컴파일러를 동시에 실행시키는 역할을 합니다.
rem start.vbs는 이 파일을 백그라운드로 실행시킵니다.
rem compile.cmd는 규칙에 따라 컴파일을 시도하고 결과를 출력하고 이 과정을 간단히 되풀이 시킵니다.
C:\"Program Files"\gedit\bin\gedit.exe
