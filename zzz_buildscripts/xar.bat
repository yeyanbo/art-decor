@echo off

if "%JAVA_HOME%"==() goto :requirements
if "%ANT_HOME%"==() goto :requirements

goto :requirements_met

:requirements_notice
echo Creates XAR files for every directory with a buid.xml
echo Requirements:
echo   Download and install the JDK from http://java.oracle.com
echo   NOTE: JRE is not enough
echo.
echo   Download and unzip ant from http://ant.apache.org/bindownload.cgi
echo   Set environment variables JAVA_HOME and ANT_HOME
echo   set PATH^=^%PATH^%;^%JAVA_HOME^%;^%ANT_HOME^%
goto :eof

:requirements_met

:: Cache working dir of current script
set WD=%~d0%~p0

:: Cache starting point for script
set PD=%WD%\..

set outputDir=%WD%..\..\xars

:: Create output directory
if not exist "%outputDir%" (
    echo Creating output directory %outputDir%
    mkdir "%outputDir%"
)

:: Remove any previous xars
if exist "%outputDir%*.xar" (
    echo Removing previous xars files from current working dir
    del /q %outputDir%*.xar
)

call :recurse "%PD%"
goto :movexars

:recurse
pushd %1
if not %~1==.svn (
    for /d %%i in (*) do call :recurse "%%i"
    if exist ".\build.xml" (
        call ant xar -buildfile "%CD%\build.xml"
    )
)
popd
goto :eof

:movexars
echo Moving xar files to %outputDir%
for /r %PD% %%F in (*.xar) do (
    move /y %%F "%outputDir%"
)

:eof