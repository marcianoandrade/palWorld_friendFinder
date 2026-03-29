local markers = {}

LoopInGameThreadWithDelay(3000, function()
    local players = FindAllOf("PalPlayerCharacter")
    if not players or #players < 2 then return end

    local compass = FindFirstOf("WBP_Ingame_Compass_C")
    if not compass then return end

    local iconCanvas = compass.IconCanvas
    if not iconCanvas then return end

    local pc = compass:GetOwningPlayer()
    if not pc then return end

    local localPawn = pc:K2_GetPawn()
    if not localPawn then return end

    local localLoc = localPawn:K2_GetActorLocation()

    local existingMarkers = FindAllOf("WBP_IngameCompass_CustomMarker_C")
    if not existingMarkers or #existingMarkers == 0 then return end

    local markerIndex = 1
    for _, p in ipairs(players) do
        if p ~= localPawn then
            local loc = p:K2_GetActorLocation()
            local dx = loc.X - localLoc.X
            local dy = loc.Y - localLoc.Y
            local dist = math.sqrt(dx*dx + dy*dy)

            if dist > 2000 then
                local name = tostring(p:GetFullName())

                if not markers[name] then
                    -- Pega apenas o ultimo marker da lista (menos provavel de ser usado)
                    local m = existingMarkers[#existingMarkers - (markerIndex - 1)]
                    if m and m:IsValid() then
                        markers[name] = m
                        -- Remove limite de distancia
                        markers[name].HiddenDistance = 999999999.0
                        markers[name].CurrentDistance = 999999999.0
                        markerIndex = markerIndex + 1
                        print("[FF] Marker associado para: " .. name)
                    end
                end

                if markers[name] and markers[name]:IsValid() then
                    markers[name]:SetTargetLocation(loc, true)
                    markers[name].HiddenDistance = 999999999.0
                end
            end
        end
    end
end)

print("[FF] FriendFinder carregado")
