@echo off
setlocal enabledelayedexpansion
set "samples_folder=..\samples\"
set "extension_omega_txt=.txt"

set "folder_graficas_png=..\graficas\"
set  "png_ext=.png"

set "folder_graficas_fig=..\graficas\figs\"
set  "fig_ext=.fig"

set "resources_folder=..\resources\"
set "sampler_ejecutable=sampler.exe"
set "sampler_code=sampler_code_template.cpp"
set "exe_extension=.exe"
set "matlab_extension=.m"

:: BORRA TODOS LOS ARCHIVOS DE TEXTO CON MUESTREOS
if not exist %samples_folder% (
    echo [ERROR] No existe la carpeta %samples_folder%
    pause
    exit /b 1
)
del /q "%samples_folder%\*%extension_omega_txt%" "%samples_folder%\*%exe_extension%" "%samples_folder%\*%matlab_extension%" 2>nul

:: BORRA TODAS LAS FIGURAS EN PNG
if not exist %folder_graficas_png% (
    echo [ERROR] No existe la carpeta %folder_graficas_png%
    pause
    exit /b 1
)
del /q "%folder_graficas_png%\*%png_ext%" 2>nul

:: BORRA TODAS LAS FIGURAS GUARDADAS EN .FIG
if not exist %folder_graficas_fig% (
    echo [ERROR] No existe la carpeta %folder_graficas_fig%
    pause
    exit /b 1
)
del /q "%folder_graficas_fig%\*%fig_ext%" 2>nul

:: Ir a la carpeta de recursos y compilar el codigo
if not exist %resources_folder% (
    echo [ERROR] No existe la carpeta %resources_folder%
    pause
)
cd %resources_folder%
g++ %sampler_code% -o %sampler_ejecutable%

:wait
if not exist %sampler_ejecutable% (
    echo Waiting for the code to compile.
    goto :wait
)
copy %sampler_ejecutable% %samples_folder%
cd %samples_folder%
start "" %sampler_ejecutable%
exit
