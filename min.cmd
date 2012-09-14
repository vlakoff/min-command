@SETLOCAL

@IF [%1]==[] GOTO manual
@IF NOT [%3]==[] GOTO thirdArgumentPresent
@IF NOT EXIST %1 GOTO inputNotFound

@IF /I NOT [%~x1]==[.js] (
	IF /I NOT [%~x1]==[.css] (
		GOTO unsupportedFileType
	)
)

@SET inputFullpath="%~f1"

@IF [%2]==[] (
	SET outputFullpath="%~dpn1.min%~x1"
	SET outputFilename=%~n1.min%~x1
) ELSE (
	IF /I "%~f1"=="%~f2" GOTO sameInputOutput
	IF /I NOT [%~x1]==[%~x2] GOTO typesMismatch
	SET outputFullpath="%~f2"
	SET outputFilename=%~nx2
)

@SET inputFilenameNoExt=%~n1
@IF %inputFilenameNoExt:~-4%==.min (
	GOTO inputAlreadyMinified
)


@IF NOT EXIST %outputFullpath% (
	GOTO noPromptOverwrite
)

@ECHO(
@ECHO   Output file already exists: %outputFilename%
@ECHO(
:promptOverwrite
:: attention a ne pas trimer l'espace a la fin de la ligne suivante
@SET /P confirmOverwrite=  Overwrite? (Y/N) 
@IF /I [%confirmOverwrite%]==[Y] (
	GOTO noPromptOverwrite
)
@IF /I [%confirmOverwrite%]==[N] (
	GOTO :EOF
)
@GOTO promptOverwrite

:noPromptOverwrite


@PUSHD %APPDATA%\npm

@IF /I %~x1==.js (
	CALL uglifyjs -nc %inputFullpath% > %outputFullpath%
) ELSE (
	CALL recess --compress %inputFullpath% > %outputFullpath%
)

@POPD

@GOTO weAreDone


:manual
@CALL :message Syntax:
@CALL :message min inputfile [outputfile]
@CALL :message if outputfile is omitted, will be inputfile with ".min" inserted
@GOTO :EOF

:thirdArgumentPresent
@CALL :message ERROR - Presence of a third argument
@GOTO :EOF

:inputNotFound
@CALL :message ERROR - Input file not found: %1
@GOTO :EOF

:unsupportedFileType
@CALL :message ERROR - Input file has to be JS or CSS
@GOTO :EOF

:sameInputOutput
@CALL :message ERROR - Input and output files are the same
@GOTO :EOF

:typesMismatch
@CALL :message ERROR - File extensions mismatch
@GOTO :EOF

:inputAlreadyMinified
@CALL :message ERROR - Input file is already a minified file
@GOTO :EOF

:weAreDone
@CALL :message DONE
@GOTO :EOF

:: subroutine
:message
@ECHO(
@ECHO   %*
@GOTO :EOF
