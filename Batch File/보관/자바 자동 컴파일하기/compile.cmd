@echo off
rem ���� ���丮���� ���� �ֱٿ� ������ �����Ǿ����� Ȯ���ڰ� java�� ������ ������ java class���Ϸ� �������ϰ�, �����Ϸ��� ������ �߰����� �ʾҴٸ� �����ŵ�ϴ�.
rem cmd â�� ���� �����Ű�� �ʰ�, ���������� �� â�� ����ϴ°� ���� ���� ����ܰ�� ����ҿ�ð��� �䱸�Ѵ�.
rem �۾��� ����ȭ�� ���� �Ϻ� ������ ��ü�ϰ� ����Ͽ���. cmd�� ����, Ž���⿡�� �������� ������ ��θ� ã�� �̵��ѵ� �ش� ��θ� �����ϰ�, cmd�� �ش� ��θ� �ٿ��־� ��θ� �����ѵ�, cmd(������ �۾� ��� ����)�� �����Ų��. --> start.cmd�� ��ġ�� ��θ� Ž���⿡�� ã�� �̵��ѵ�, start.cmd�� �����Ų��.
rem ��õ� ���� ���� ���Ŀ� ������ �ϳ��� ����ϴ�.
setlocal
:start
	FOR /F "delims=" %%i IN ('dir /TW /OD /A-S-DA *.java ^| find /I ".java"') DO SET target=%%i
	FOR /F "tokens=4,* delims= " %%i IN ("%target%") DO SET target=%%j
	if "%target%"=="check.java" (
		ping localhost -n 1 -w 100 > nul
		goto start
	)
	echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	javac "%target%" && java "%target:~0,-5%"
	echo.
	rem dosâ���� �����ϴ� dir����� �ʴ����� ���¸� �������� �ʴ´�. üũ������ �ϳ� �����ΰ�, üũ������ �ƴ� ������ �ֽ����Ϸ� �����ɶ�, �ð��� �����Ȱ����� �����Ѵ�.
	attrib -H check.java
	echo. > check.java
	attrib +H check.java
goto start
rem �� cmd���� ������ �۾������ ����� �������� �ʽ��ϴ�. ����, �ܺο����� �۾��ߴܸ��� �۾����Ḧ ��ų�� �ֽ��ϴ�. �� cmd������ ���ο��� ���ѷ����� ������ �Ǿ��ֽ��ϴ�.

rem ==========================Bakup Code==========================

	ping localhost -n 1 -w 100 > nul
exit /B
	rem echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
rem pause
rem echo %cmdcmdline%
rem dir /OD /A-H-S-DA *.java | find /I ".java" > tmp
rem set nl=^& echo.
rem FOR /F "delims=" %%i IN ('dir /OD /A-H-S-DA *.java ^| find /I ".java"') DO SET target=%%i
rem FOR /F "tokens=4,* delims= " %%i IN ("%target%") DO SET target=%%j
rem attrib tmp +h
rem set NLM=^


rem set NL=^^^%NLM%%NLM%^%NLM%%NLM%
rem FOR /F "delims=" %%i IN ('dir /OD /A-H-S-DA *.java ^| find /I ".java"') DO SET target=%target%%nl%%%i
FOR /F "delims=" %%i IN ('find /I ".java"') DO SET target=%target%%nl%%%i
echo "%target%"
FOR /F "delims=" %%i IN (tmp) DO SET target=%%i
del tmp
FOR /F "tokens=4,* delims= " %%i IN ("%target%") DO SET target=%%j
rem ��ġ���Ͽ��� bash�� ���� ���α׷� ������ ����� �����ϴ� �������� ����� ����. �׷���, ���� for������ ����Ͽ� ���������� �������� ������ �����Ҽ��� �ִ�.
echo %target%
rem javac %1.java && java %1
rem echo %errorlevel%
rem pause
