@echo off
cd /d "%~dp0"
echo Installing required Python packages...
py -m pip install -r requirements.txt
if errorlevel 1 goto error
echo.
echo Downloading original SIH 2025 and 2026 source exports and generating SQL INSERT code...
py generate_original_data.py
if errorlevel 1 goto error
echo.
echo SUCCESS! Open 02_original_sih_data.sql in MySQL Workbench and execute it AFTER 01_schema.sql.
pause
exit /b 0
:error
echo.
echo Could not generate the original-data SQL file. Check internet access and Python installation.
pause
exit /b 1
