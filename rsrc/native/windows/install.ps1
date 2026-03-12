$ErrorActionPreference = "Stop"

$root = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..")).Path
$libs = Join-Path $root "libs"
$buildRoot = Join-Path $root ".native\windows-build"

New-Item -ItemType Directory -Force -Path $libs | Out-Null
if (Test-Path $buildRoot) { Remove-Item $buildRoot -Recurse -Force }
New-Item -ItemType Directory -Force -Path $buildRoot | Out-Null

git clone --depth 1 --branch 5.5 https://github.com/raysan5/raylib (Join-Path $buildRoot "raylib")
Push-Location (Join-Path $buildRoot "raylib")
New-Item -ItemType Directory -Force -Path build | Out-Null
Push-Location build
cmake .. -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON
cmake --build . --config Release
Copy-Item "raylib\Release\raylib.lib" $libs -Force
Copy-Item "raylib\Release\raylib.dll" $libs -Force
Pop-Location
Pop-Location

git clone --depth 1 --branch 4.0 https://github.com/raysan5/raygui (Join-Path $buildRoot "raygui")
Push-Location (Join-Path $buildRoot "raygui")
Copy-Item "src\raygui.h" "src\raygui.c" -Force
cl /O2 /I"$buildRoot\raylib\src" /D_USRDLL /D_WINDLL /DRAYGUI_IMPLEMENTATION /DBUILD_LIBTYPE_SHARED src\raygui.c /LD /Feraygui.dll /link /LIBPATH:$libs raylib.lib /subsystem:windows /machine:x64
Copy-Item "raygui.lib" $libs -Force
Copy-Item "raygui.dll" $libs -Force
Pop-Location

Remove-Item $buildRoot -Recurse -Force

Write-Host "Native libraries installed locally."
Write-Host ""
Write-Host "For local builds and runs that need repo-local native libs:"
Write-Host "  `$env:LIB = `"$libs;`$env:LIB`""
Write-Host "  `$env:PATH = `"$libs;`$env:PATH`""
