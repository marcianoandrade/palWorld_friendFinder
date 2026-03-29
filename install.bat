@echo off
chcp 65001 > nul
echo ============================================
echo     FriendFinder - Instalador Palworld
echo ============================================
echo.
set /p STEAM_PATH="Informe o caminho raiz da Steam (ex: C:\Program Files (x86)\Steam): "

set PALWORLD_MODS=%STEAM_PATH%\steamapps\common\Palworld\Pal\Binaries\Win64\ue4ss\Mods
set PALWORLD_PAKS=%STEAM_PATH%\steamapps\common\Palworld\Pal\Content\Paks\LogicMods

echo.
echo Verificando caminhos...

if not exist "%PALWORLD_MODS%" (
    echo ERRO: Pasta de mods nao encontrada: %PALWORLD_MODS%
    echo Verifique se o UE4SS esta instalado e o caminho da Steam esta correto.
    pause
    exit /b 1
)

echo Instalando script Lua...
xcopy /E /I /Y "FriendFinder" "%PALWORLD_MODS%\FriendFinder"

echo Criando pasta LogicMods...
if not exist "%PALWORLD_PAKS%" mkdir "%PALWORLD_PAKS%"

echo Instalando pak...
copy /Y "FriendFinder_P.pak" "%PALWORLD_PAKS%\FriendFinder_P.pak"

echo.
echo ============================================
echo     Instalacao concluida com sucesso!
echo ============================================
echo.
echo Inicie o Palworld e entre em uma sessao multiplayer.
echo O marcador aparecera automaticamente na bussola.
pause
