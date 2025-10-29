@echo off
setlocal enabledelayedexpansion
set "utils_folder=C:\Users\R\Downloads\ABCD_SERVOMECANISMOS\practica4\Sampler\utils"
set "root_folder=C:\Users\R\Downloads\ABCD_SERVOMECANISMOS\practica4\Sampler"
cd /d %root_folder%
call .\Sampler_venv\Scripts\activate
cd /d %utils_folder%
python analyze.py
pause
