@IF [%1]==[] GOTO manual
@IF [%2]==[] GOTO secondArgumentMissing
@IF NOT [%3]==[] GOTO thirdArgumentPresent

@IF NOT EXIST %1 GOTO inputNotFound

@IF /I NOT [%~x1]==[.js] (
	IF /I NOT [%~x1]==[.css] (
		GOTO unsupportedFileType
	)
)

@IF /I "%~f1"=="%~f2" GOTO sameInputOutput


@SETLOCAL
@SET inputFilename=%~n1
@IF %inputFilename:~-4%==.min GOTO inputAlreadyMinified
@ENDLOCAL


@IF NOT EXIST %2 (
	GOTO noPromptOverwrite
)

@ECHO(
@ECHO Output file already exists: %2
@ECHO(
:promptOverwrite
@SETLOCAL
@SET /P confirmOverwrite=Overwrite? (Y/N) 
@IF /I [%confirmOverwrite%]==[Y] (
	ENDLOCAL
	GOTO noPromptOverwrite
)
@IF /I [%confirmOverwrite%]==[N] (
	ENDLOCAL
	ECHO(
	GOTO :EOF
)
@ENDLOCAL
@GOTO promptOverwrite

:noPromptOverwrite


@SETLOCAL

@SET inputFile="%~f1"
@SET outputFile="%~f2"

@PUSHD %APPDATA%\npm

@IF /I %~x1==.js (
	CALL uglifyjs -nc %inputFile% > %outputFile%
) ELSE (
	CALL recess --compress %inputFile% > %outputFile%
)

@POPD

@ENDLOCAL


@ECHO(
@ECHO DONE
@ECHO(
@GOTO :EOF


:manual
@ECHO(
@ECHO Syntax:
@ECHO(
@ECHO min inputfile outputfile
@ECHO(
@GOTO :EOF

:secondArgumentMissing
@ECHO(
@ECHO ERROR - Second argument is missing
@ECHO(
@GOTO :EOF

:thirdArgumentPresent
@ECHO(
@ECHO ERROR - Presence of a third argument
@ECHO(
@GOTO :EOF

:inputNotFound
@ECHO(
@ECHO ERROR - Input file not found: %1
@ECHO(
@GOTO :EOF

:unsupportedFileType
@ECHO(
@ECHO ERROR - Input file has to be JS or CSS
@ECHO(
@GOTO :EOF

:sameInputOutput
@ECHO(
@ECHO ERROR - Output file cannot be the same as input file
@ECHO(
@GOTO :EOF

:inputAlreadyMinified
@ECHO(
@ECHO ERROR - Input file is already a minified file
@ECHO(
@GOTO :EOF
