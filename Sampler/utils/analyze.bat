@echo off
cd ..
.\Sampler_venv\Scripts\activate
cd ..\..\utils
python analyze.py
pause
