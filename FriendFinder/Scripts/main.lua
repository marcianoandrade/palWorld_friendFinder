-- ============================================================
--  FriendFinder — Palworld Mod
--  Exibe marcadores dos membros da guilda na bússola (topo)
--  Compatível com: UE4SS 3.x | Palworld 1.x
-- ============================================================

local CONFIG = {
    -- Cores (R, G, B, A  —  valores 0.0 a 1.0)
    corMarcador  = { R = 0.2,  G = 0.9,  B = 1.0,  A = 1.0 },   -- azul ciano
    corNome      = { R = 1.0,  G = 1.0,  B = 1.0,  A = 1.0 },   -- branco
    corSombra    = { R = 0.0,  G = 0.0,  B = 0.0,  A = 0.85 },  -- sombra do texto

    -- Posição vertical do marcador na tela (pixels do topo)
    -- Ajuste se sua bússola estiver em posição diferente
    bussolaY     = 48,

    -- Quantos graus a bússola exibe de cada lado do centro (padrão Palworld ≈ 90°)
    meioFOV      = 90,

    -- Mostrar nome e distância junto com o marcador
    mostrarNome      = true,
    mostrarDistancia = true,
}

-- --------------------------------------------------------
-- Utilitários matemáticos
-- --------------------------------------------------------

local function NormalizarAngulo(a)
    a = a % 360
    if a > 180 then a = a - 360 end
    return a
end

-- Retorna o ângulo (graus) de "de" para "para" no plano XY
local function CalcularBearing(de, para)
    local dx = para.X - de.X
    local dy = para.Y - de.Y
    -- UE: X = frente, Y = direita, ângulo cresce para a direita
    return math.deg(math.atan(dy, dx))
end

-- Distância em metros (UE usa centímetros internamente)
local function Distancia(de, para)
    local dx = para.X - de.X
    local dy = para.Y - de.Y
    local dz = para.Z - de.Z
    return math.sqrt(dx * dx + dy * dy + dz * dz) / 100
end

-- --------------------------------------------------------
-- Desenho do marcador na bússola
--   posNorm: -1.0 (extremo esquerdo) .. 0 (centro) .. +1.0 (extremo direito)
-- --------------------------------------------------------

local function DesenharMarcador(canvas, screenW, nome, dist, posNorm)
    -- Posição X proporcional à largura da tela
    local centroX = screenW * 0.5
    local iconX   = centroX + posNorm * (screenW * 0.42)
    local iconY   = CONFIG.bussolaY

    local cor = CONFIG.corMarcador

    -- Seta triangular apontando para baixo ▼
    local meia = 7
    local alt  = 14
    canvas:K2_DrawLine({ X = iconX,        Y = iconY        }, { X = iconX - meia, Y = iconY - alt }, 2, cor)
    canvas:K2_DrawLine({ X = iconX,        Y = iconY        }, { X = iconX + meia, Y = iconY - alt }, 2, cor)
    canvas:K2_DrawLine({ X = iconX - meia, Y = iconY - alt  }, { X = iconX + meia, Y = iconY - alt }, 2, cor)

    -- Texto: nome + distância
    if CONFIG.mostrarNome then
        local label = nome
        if CONFIG.mostrarDistancia then
            if dist < 1000 then
                label = label .. "\n" .. string.format("%.0fm", dist)
            else
                label = label .. "\n" .. string.format("%.1fkm", dist / 1000)
            end
        end

        canvas:K2_DrawText(
            nil,                              -- fonte padrão do jogo
            label,
            { X = iconX - 24, Y = iconY - 52 },
            { X = 0.75, Y = 0.75 },           -- escala
            CONFIG.corNome,
            0,                                -- kern
            false,                            -- monoespaçado
            false,                            -- clip
            true,                             -- shadow
            false,                            -- outline
            CONFIG.corSombra,
            { X = 1, Y = 1 }                  -- offset sombra
        )
    end
end

-- --------------------------------------------------------
-- Tentativas de leitura do nome do jogador
-- (campo pode variar conforme patch do jogo)
-- --------------------------------------------------------

local function ObterNomeJogador(playerState)
    if not playerState then return nil end

    local campos = { "PlayerNamePrivate", "PlayerName", "SaveParameter" }
    for _, campo in ipairs(campos) do
        local ok, val = pcall(function() return playerState[campo] end)
        if ok and val then
            -- SaveParameter é uma struct, tenta achar NickName dentro dela
            if campo == "SaveParameter" then
                local ok2, nick = pcall(function() return val.NickName end)
                if ok2 and nick and tostring(nick):len() > 0 then
                    return tostring(nick)
                end
            else
                local s = tostring(val)
                if s and s:len() > 0 and s ~= "nil" then
                    return s
                end
            end
        end
    end
    return nil
end

-- --------------------------------------------------------
-- Hook principal — roda a cada frame do HUD
-- --------------------------------------------------------

RegisterHook("/Script/Engine.HUD:ReceiveDrawHUD", function(self, SizeX, SizeY)
    local ok, err = pcall(function()
        local hud = self:get()
        if not hud then return end

        local canvas = hud.Canvas
        if not canvas then return end

        local screenW = SizeX:get()
        local screenH = SizeY:get()

        -- Controlador e pawn do jogador local
        local pc = hud.PlayerOwner
        if not pc then return end

        local localPawn = pc.Pawn
        if not localPawn or not localPawn:IsValid() then return end

        local localPos = localPawn:K2_GetActorLocation()
        local localRot = localPawn:K2_GetActorRotation()
        local localYaw = localRot.Yaw

        -- Percorrer todos os personagens de jogador na cena
        local players = FindAllOf("PalPlayerCharacter")
        if not players then return end

        for _, player in ipairs(players) do
            if player ~= localPawn and player:IsValid() then
                pcall(function()
                    local pos  = player:K2_GetActorLocation()
                    local dist = Distancia(localPos, pos)

                    -- Ignorar jogadores absurdamente longe (carregamento parcial)
                    if dist > 50000 then return end

                    -- Nome
                    local nome = "Aliado"
                    local ps   = player.PlayerState
                    local n    = ObterNomeJogador(ps)
                    if n then nome = n end

                    -- Ângulo relativo ao olhar do jogador local
                    local bearing = CalcularBearing(localPos, pos)
                    local angRel  = NormalizarAngulo(bearing - localYaw)

                    -- Só desenha se estiver dentro do FOV da bússola
                    if math.abs(angRel) <= CONFIG.meioFOV then
                        local posNorm = angRel / CONFIG.meioFOV   -- -1 .. +1
                        DesenharMarcador(canvas, screenW, nome, dist, posNorm)
                    end
                end)
            end
        end
    end)

    -- Descomente a linha abaixo para depuração no console do UE4SS:
    -- if not ok then print("[FriendFinder] " .. tostring(err)) end
end)

print("[FriendFinder] Mod carregado — marcadores de guilda ativos.")
