@echo off
rem 현재 디렉토리에서 가장 최근에 내용이 수정되었으며 확장자가 java로 끝나는 파일을 java class파일로 컴파일하고, 컴파일러가 오류를 발견하지 않았다면 실행시킵니다.
rem cmd 창을 띄운뒤 종료시키지 않고, 지속적으로 그 창만 사용하는게 보다 적은 수행단계와 수행소요시간을 요구한다.
rem 작업의 간략화를 위해 일부 과정을 대체하고 대신하였다. cmd를 띄우고, 탐색기에서 컴파일할 파일의 경로를 찾아 이동한뒤 해당 경로를 복사하고, cmd에 해당 경로를 붙여넣어 경로를 수정한뒤, cmd(컴파일 작업 명령 집합)을 실행시킨다. --> start.cmd가 위치한 경로를 탐색기에서 찾아 이동한뒤, start.cmd를 실행시킨다.
rem 재시도 마다 시작 전후에 빈줄이 하나씩 생깁니다.
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
	rem dos창에서 지원하는 dir명령은 초단위의 상태를 보고하지 않는다. 체크파일을 하나 만들어두고, 체크파일이 아닌 파일이 최신파일로 감지될때, 시간이 변동된것으로 간주한다.
	attrib -H check.java
	echo. > check.java
	attrib +H check.java
goto start
rem 이 cmd파일 내에서 작업종료는 명령은 존재하지 않습니다. 오직, 외부에서의 작업중단만이 작업종료를 시킬수 있습니다. 이 cmd파일은 내부에서 무한루프를 돌도록 되어있습니다.

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
rem 배치파일에선 bash와 같은 프로그램 수행의 결과를 저장하는 직접적인 기능이 없다. 그러나, 여러 for구문을 사용하여 간접적으로 실행결과를 변수에 저장할수는 있다.
echo %target%
rem javac %1.java && java %1
rem echo %errorlevel%
rem pause
