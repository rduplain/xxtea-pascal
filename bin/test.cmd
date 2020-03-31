@echo off

REM - Test `cipher` executable on Windows.
REM -
REM - Intended usage from project root:
REM -
REM -      fpc -ocipher.exe -Xs -XS -XX Cipher.pas
REM -      .\bin\test.cmd .\cipher.exe
REM -
REM - Note that Windows ships with a (separate) `cipher.exe` system utility.

REM - Accept argument or show usage if not given.
if "%~1" == "" (
  call echo usage: test CIPHER
  call echo.
  call echo CIPHER is path to `cipher` executable under test.
  exit /b 2
)

set CIPHER=%~1

REM - test_help
call echo Test help output...
call %CIPHER% -h > test.dat
call find /c "128-bit encryption key." test.dat > NUL
if %errorlevel% neq 0 (
  call echo FAIL!
  exit /b 1
)

REM - test_empty
call echo Test that empty input gives empty output...

call cipher -k secret encrypt < NUL > test.dat
for /f %%i in ("test.dat") do set size=%%~zi
if %size% neq 0 (
  call echo FAIL!
  exit /b 1
)

call cipher -k secret decrypt < NUL > test.dat
for /f %%i in ("test.dat") do set size=%%~zi
if %size% neq 0 (
  call echo FAIL!
  exit /b 1
)

REM - test_encrypt
call echo Test that encryption is not plaintext...
call echo Hello, world! | call %CIPHER% -k secret encrypt > test.dat
call find /c "world" test.dat > NUL
if %errorlevel% equ 0 (
  echo FAIL!
  exit /b 1
)

REM - test_round_trip
call echo Test a round-trip encrypt/decrypt...
call echo Hello, world! | call %CIPHER% -k secret encrypt > encrypt.dat
call %CIPHER% -k secret decrypt < encrypt.dat > test.dat
call find /c "Hello, world!" test.dat > NUL
if %errorlevel% neq 0 (
  call echo FAIL!
  exit /b 1
)

REM - test_invalid_key
call echo Test an invalid key...
call echo Hello, world! | call %CIPHER% -k secret encrypt > encrypt.dat
call %CIPHER% -k invalid decrypt < encrypt.dat > test.dat
call find /c "Hello, world!" test.dat > NUL
if %errorlevel% equ 0 (
  call echo FAIL!
  exit /b 1
)

REM - test_suite
call del test.dat encrypt.dat
call echo All tests passed.
