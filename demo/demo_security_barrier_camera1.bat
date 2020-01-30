:: Copyright (C) 2018-2019 Intel Corporation
:: SPDX-License-Identifier: Apache-2.0

@echo off
setlocal enabledelayedexpansion

set TARGET=CPU
set SAMPLE_OPTIONS=
set BUILD_FOLDER=%USERPROFILE%\Documents\Intel\OpenVINO

:: command line arguments parsing
:input_arguments_loop
if not "%1"=="" (
    if "%1"=="-d" (
        set TARGET=%2
        echo target = !TARGET!
        shift
    )
    if "%1"=="-sample-options" (
        set SAMPLE_OPTIONS=%2 %3 %4 %5 %6
        echo sample_options = !SAMPLE_OPTIONS!
        shift
    )
    if "%1"=="-help" (
        echo %~n0%~x0 is security barrier camera demo that showcases three models coming with the product
        echo.
        echo Options:
        echo -d name     Specify the target device to infer on; CPU, GPU, FPGA or MYRIAD are acceptable. Sample will look for a suitable plugin for device specified
        exit /b
    )
    shift
    goto :input_arguments_loop
)

set ROOT_DIR=%~dp0

set target_image_path=%ROOT_DIR%\car_1.bmp

if %TARGET% == MYRIAD (
    :: MYRIAD supports networks with FP16 format only
    set TARGET_PRECISION=FP16
) else (
    if %TARGET% == HDDL (
        :: HDDL supports networks with FP16 format only
        set TARGET_PRECISION=FP16
    ) else (
        set TARGET_PRECISION=FP32
    )
)
echo target_precision = !TARGET_PRECISION!

if exist "%ROOT_DIR%\..\..\bin\setupvars.bat" (
    call "%ROOT_DIR%\..\..\bin\setupvars.bat"
) else (
    echo setupvars.bat is not found, INTEL_OPENVINO_DIR can't be set
    goto error
)

echo INTEL_OPENVINO_DIR is set to %INTEL_OPENVINO_DIR%

:: Check if Python is installed
python --version 2>NUL
if errorlevel 1 (
   echo Error^: Python is not installed. Please install Python 3.5 ^(64-bit^) or higher from https://www.python.org/downloads/
   goto error
)

:: Check if Python version is equal or higher 3.4
for /F "tokens=* USEBACKQ" %%F IN (`python --version 2^>^&1`) DO (
   set version=%%F
)
echo %var%

for /F "tokens=1,2,3 delims=. " %%a in ("%version%") do (
   set Major=%%b
   set Minor=%%c
)

if "%Major%" geq "3" (
   if "%Minor%" geq "5" (
  set python_ver=okay
   )
)
if not "%python_ver%"=="okay" (
   echo Unsupported Python version. Please install Python 3.5 ^(64-bit^) or higher from https://www.python.org/downloads/
   goto error
)

:: install yaml python modules required for downloader.py
pip install --user pyyaml requests
if ERRORLEVEL 1 GOTO errorHandling


set models_path=%BUILD_FOLDER%\openvino_models\ir\%target_precision%
set models_cache=%BUILD_FOLDER%\openvino_models\ir\cache
set vehicle_license_plate_detection_model=vehicle-license-plate-detection-barrier-0106
set vehicle_attributes_recognition_model=vehicle-attributes-recognition-barrier-0039
set license_plate_recognition_model=license-plate-recognition-barrier-0001

if "%TARGET_PRECISION%" == "FP16" (
    set vehicle_license_plate_detection_model=%vehicle_license_plate_detection_model%-fp16
    set vehicle_attributes_recognition_model=%vehicle_attributes_recognition_model%-fp16
    set license_plate_recognition_model=%license_plate_recognition_model%-fp16
)

set vehicle_license_plate_detection_model_path=%models_path%\Security\object_detection\barrier\0106\dldt\%vehicle_license_plate_detection_model%
set vehicle_attributes_recognition_model_path=%models_path%\Security\object_attributes\vehicle\resnet10_update_1\dldt\%vehicle_attributes_recognition_model%
set license_plate_recognition_model_path=%models_path%\Security\optical_character_recognition\license_plate\dldt\%license_plate_recognition_model%

if not exist %models_cache% (
  mkdir %models_cache%
)

echo python "%INTEL_OPENVINO_DIR%\deployment_tools\tools\model_downloader\downloader.py" --name %vehicle_license_plate_detection_model% --output_dir %models_path% --cache_dir %models_cache%
python "%INTEL_OPENVINO_DIR%\deployment_tools\tools\model_downloader\downloader.py" --name %vehicle_license_plate_detection_model% --output_dir %models_path% --cache_dir %models_cache%

echo python "%INTEL_OPENVINO_DIR%\deployment_tools\tools\model_downloader\downloader.py" --name %vehicle_attributes_recognition_model% --output_dir %models_path% --cache_dir %models_cache%
python "%INTEL_OPENVINO_DIR%\deployment_tools\tools\model_downloader\downloader.py" --name %vehicle_attributes_recognition_model% --output_dir %models_path% --cache_dir %models_cache%

echo python "%INTEL_OPENVINO_DIR%\deployment_tools\tools\model_downloader\downloader.py" --name %license_plate_recognition_model% --output_dir %models_path% --cache_dir %models_cache%
python "%INTEL_OPENVINO_DIR%\deployment_tools\tools\model_downloader\downloader.py" --name %license_plate_recognition_model% --output_dir %models_path% --cache_dir %models_cache%

if "%PROCESSOR_ARCHITECTURE%" == "AMD64" (
   set "PLATFORM=x64"
) else (
   set "PLATFORM=Win32"
)

set VSWHERE="false"
if exist "%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe" (
   set VSWHERE="true"
   cd "%ProgramFiles(x86)%\Microsoft Visual Studio\Installer"
) else if exist "%ProgramFiles%\Microsoft Visual Studio\Installer\vswhere.exe" (
      set VSWHERE="true"
      cd "%ProgramFiles%\Microsoft Visual Studio\Installer"
) else (
   echo "vswhere tool is not found"
)

set MSBUILD_BIN=
set VS_PATH=

if !VSWHERE! == "true" (
   for /f "usebackq tokens=*" %%i in (`vswhere -latest -products * -requires Microsoft.Component.MSBuild -property installationPath`) do (
      set VS_PATH=%%i
   )
   if exist "!VS_PATH!\MSBuild\14.0\Bin\MSBuild.exe" (
      set "MSBUILD_BIN=!VS_PATH!\MSBuild\14.0\Bin\MSBuild.exe"
   )
   if exist "!VS_PATH!\MSBuild\15.0\Bin\MSBuild.exe" (
      set "MSBUILD_BIN=!VS_PATH!\MSBuild\15.0\Bin\MSBuild.exe"
   )
   if exist "!VS_PATH!\MSBuild\Current\Bin\MSBuild.exe" (
      set "MSBUILD_BIN=!VS_PATH!\MSBuild\Current\Bin\MSBuild.exe"
   )
)

if "!MSBUILD_BIN!" == "" (
   if exist "C:\Program Files (x86)\MSBuild\14.0\Bin\MSBuild.exe" (
      set "MSBUILD_BIN=C:\Program Files (x86)\MSBuild\14.0\Bin\MSBuild.exe"
      set "MSBUILD_VERSION=14 2015"
   )
   if exist "C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\MSBuild\15.0\Bin\MSBuild.exe" (
      set "MSBUILD_BIN=C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\MSBuild\15.0\Bin\MSBuild.exe"
      set "MSBUILD_VERSION=15 2017"
   )
   if exist "C:\Program Files (x86)\Microsoft Visual Studio\2017\Professional\MSBuild\15.0\Bin\MSBuild.exe" (
      set "MSBUILD_BIN=C:\Program Files (x86)\Microsoft Visual Studio\2017\Professional\MSBuild\15.0\Bin\MSBuild.exe"
      set "MSBUILD_VERSION=15 2017"
   )
   if exist "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\MSBuild\15.0\Bin\MSBuild.exe" (
      set "MSBUILD_BIN=C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\MSBuild\15.0\Bin\MSBuild.exe"
      set "MSBUILD_VERSION=15 2017"
   )
) else (
   if not "!MSBUILD_BIN:2019=!"=="!MSBUILD_BIN!" set "MSBUILD_VERSION=16 2019"
   if not "!MSBUILD_BIN:2017=!"=="!MSBUILD_BIN!" set "MSBUILD_VERSION=15 2017"
   if not "!MSBUILD_BIN:2015=!"=="!MSBUILD_BIN!" set "MSBUILD_VERSION=14 2015"
)

if "!MSBUILD_BIN!" == "" (
   echo Build tools for Visual Studio 2015 / 2017 / 2019 cannot be found. If you use Visual Studio 2017 / 2019, please download and install build tools from https://www.visualstudio.com/downloads/#build-tools-for-visual-studio-2017
   GOTO errorHandling
)

set "SOLUTION_DIR64=%BUILD_FOLDER%\inference_engine_samples_build"

echo Creating Visual Studio !MSBUILD_VERSION! %PLATFORM% files in %SOLUTION_DIR64%... && ^
if exist "%SOLUTION_DIR64%\CMakeCache.txt" del "%SOLUTION_DIR64%\CMakeCache.txt"
cd "%INTEL_OPENVINO_DIR%\deployment_tools\inference_engine\samples" && cmake -E make_directory "%SOLUTION_DIR64%" && cd "%SOLUTION_DIR64%" && cmake -G "Visual Studio !MSBUILD_VERSION!" -A %PLATFORM% "%INTEL_OPENVINO_DIR%\deployment_tools\inference_engine\samples"
if ERRORLEVEL 1 GOTO errorHandling

echo "!MSBUILD_BIN!" Samples.sln /p:Configuration=Release /t:security_barrier_camera_demo /clp:ErrorsOnly /m
"!MSBUILD_BIN!" Samples.sln /p:Configuration=Release /t:security_barrier_camera_demo /clp:ErrorsOnly /m
if ERRORLEVEL 1 GOTO errorHandling


:runSample

cd "%SOLUTION_DIR64%\intel64\Release"
echo "%SOLUTION_DIR64%\intel64\Release\security_barrier_camera_demo.exe" -i "%target_image_path%" -m "%vehicle_license_plate_detection_model_path%.xml" -m_va "%vehicle_attributes_recognition_model_path%.xml" -m_lpr "%license_plate_recognition_model_path%.xml" -d !TARGET! -d_va !TARGET! -d_lpr !TARGET! !SAMPLE_OPTIONS!
security_barrier_camera_demo.exe -i "%target_image_path%" ^
                                 -m "%vehicle_license_plate_detection_model_path%.xml" ^
                                 -m_va "%vehicle_attributes_recognition_model_path%.xml" ^
                                 -m_lpr "%license_plate_recognition_model_path%.xml" ^
                                 -d !TARGET! -d_va !TARGET! -d_lpr !TARGET! !SAMPLE_OPTIONS!
if ERRORLEVEL 1 GOTO errorHandling

cd "%ROOT_DIR%"

goto :eof

:errorHandling
echo Error
cd "%ROOT_DIR%"
