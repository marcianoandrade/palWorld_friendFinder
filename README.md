# FriendFinder - Palworld Mod

Mod para Palworld que exibe marcadores de direção na bússola apontando para aliados no mesmo servidor multiplayer.

## Funcionalidades

- Marcador na bússola para cada aliado conectado
- Mostra distância em metros até o aliado
- Atualiza a cada 3 segundos
- Filtra jogadores muito próximos (< 20m) para evitar ruído visual
- Marcador sempre visível independente da distância

## Como funciona

O mod é dividido em duas partes:

### Script Lua (UE4SS)
O arquivo `FriendFinder/Scripts/main.lua` roda via UE4SS (Unreal Engine 4 Script System).
A cada 3 segundos ele:
1. Busca todos os `PalPlayerCharacter` na cena
2. Identifica o jogador local via `GetOwningPlayer` da bússola
3. Para cada aliado a mais de 20m de distância, reutiliza um `WBP_IngameCompass_CustomMarker_C` existente
4. Chama `SetTargetLocation` no marker com a posição do aliado
5. Remove o limite de distância (`HiddenDistance`) para o marker sempre aparecer

### Blueprint (DEPRECATED)
O `WBP_FF_Marker` foi criado como widget Blueprint herdando de `PalUICompassIconBase`.
Atualmente não é utilizado pois a abordagem de reutilizar markers nativos do jogo
se mostrou mais estável. Mantido no repositório para referência futura.

### Assets (.pak)
Os assets cozidos ficam em `pdk/cooked/` e são empacotados em `FriendFinder_P.pak`
instalado na pasta `LogicMods` do Palworld.

## Instalação

### Automática
Execute `install.bat` e informe o caminho raiz da sua instalação Steam quando solicitado.

### Manual
1. Copie a pasta `FriendFinder/` para:
   `<Steam>\steamapps\common\Palworld\Pal\Binaries\Win64\ue4ss\Mods\`
2. Copie `FriendFinder_P.pak` para:
   `<Steam>\steamapps\common\Palworld\Pal\Content\Paks\LogicMods\`

## Requisitos

- [UE4SS](https://github.com/UE4SS-RE/RE-UE4SS) instalado no Palworld
- Palworld versão compatível com o pak gerado

## Estrutura do repositório
```
FriendFinder/
  Scripts/
    main.lua          # Script principal UE4SS
  enabled.txt         # Habilita o mod no UE4SS
pdk/
  cooked/             # Assets Blueprint cozidos (.uasset/.uexp)
install.bat           # Instalador automático
INSTALAR.txt          # Instruções manuais
```
