@echo off
setlocal

:: Define paths (use quotes to handle spaces)
set "root_folder=C:\Users\R\Downloads\ABCD_SERVOMECANISMOS\practica4\Sampler"
set "utils_folder=%root_folder%\utils"
set "venv_activate=%root_folder%\Sampler_venv\Scripts\activate.bat"

:: --- Change to root folder (with drive!) ---
echo Changing to root folder: %root_folder%
cd /d "%root_folder%" || (
    echo ERROR: Could not change to %root_folder%
    pause
    exit /b 1
)

:: --- Activate virtual environment ---
echo Activating virtual environment...
call "%venv_activate%" || (
    echo ERROR: Failed to activate virtual environment at %venv_activate%
    pause
    exit /b 1
)

:: --- Change to utils folder ---
echo Changing to utils folder: %utils_folder%
cd /d "%utils_folder%" || (
    echo ERROR: Could not change to %utils_folder%
    pause
    exit /b 1
)

:: --- Run Python script ---
echo Running analyze.py...
python analyze.py || (
    echo ERROR: Python script failed.
    pause
    exit /b 1
)

exit
