@echo off
setlocal
set pdate=%date:~2,2%%date:~5,2%%date:~-2%
cd ..
md %pdate%
cd %pdate%
echo. > check.java
attrib +H check.java
start cmd /K ..\compile.cmd
rem �Է��� �����ڵ��Դϴ�.
rem �� ������ ���糯���� ������ ����� �۾������� ���, gedit�� �ڵ� �����Ϸ��� ���ÿ� �����Ű�� ������ �մϴ�.
rem start.vbs�� �� ������ ��׶���� �����ŵ�ϴ�.
rem compile.cmd�� ��Ģ�� ���� �������� �õ��ϰ� ����� ����ϰ� �� ������ ������ ��Ǯ�� ��ŵ�ϴ�.
C:\"Program Files"\gedit\bin\gedit.exe
