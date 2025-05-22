@echo off
REM Script to activate the Python virtual environment and run gemini_key_manager.py on Windows CMD

SET VENV_DIR=.venv
SET PYTHON_SCRIPT=gemini_key_manager.py
SET KEY_USAGE_FILE=key_usage.txt

echo Checking for and deleting %KEY_USAGE_FILE% if it exists...
IF EXIST "%KEY_USAGE_FILE%" (
    del "%KEY_USAGE_FILE%"
    echo %KEY_USAGE_FILE% deleted.
) ELSE (
    echo %KEY_USAGE_FILE% not found, skipping deletion.
)


IF NOT EXIST "%VENV_DIR%\Scripts\activate.bat" (
    echo Error: Virtual environment activation script not found in "%VENV_DIR%\Scripts\activate.bat".
    echo Please ensure the virtual environment is created and the path is correct.
    exit /b 1
)

echo Activating virtual environment...
call "%VENV_DIR%\Scripts\activate.bat"

if errorlevel 1 (
    echo Failed to activate virtual environment.
    exit /b 1
)

echo Running the main Python script: %PYTHON_SCRIPT%...
python %PYTHON_SCRIPT%

echo Script finished.