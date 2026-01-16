-- main.lua
-- ... (imports and player setup remain the same) ...

function playdate.update()
    if CraftingMenu:isOpen() then
        gfx.clear()
        drawWorld()
        CraftingMenu:update()
        CraftingMenu:draw()
    else
        updatePlayer()
        
        if playdate.buttonJustPressed(playdate.kButtonA) then
            local actionTaken = false
            
            -- Check for nearby entities
            for _, e in ipairs(Enemies.activeEntities) do
                local dist = math.sqrt((player.x - e.x)^2 + (player.y - e.y)^2)
                if dist < 25 then
                    if e.type == "potato" then
                        harvestPotato(player, e)
                        actionTaken = true
                        break
                    elseif e.type == "tree" then
                        chopTree(player, e)
                        actionTaken = true
                        break
                    end
                end
            end
            
            -- Fallback to Fishing or Building
            if not actionTaken then
                if player.y < 45 then
                    startFishing(player)
                elseif Inventory.materials.wood >= 5 then
                    Structures:build(player.x, player.y, "wooden_wall")
                end
            end
        end

        gfx.clear()
        drawWorld()
        Particles:update()
        drawHUD()
    end
end