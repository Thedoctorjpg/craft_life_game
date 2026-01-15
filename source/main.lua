-- ==========================================
-- CRAFT LIFE: Unified Main
-- Built on Nude Food Philosophy: Clean & Simple
-- ==========================================

import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/ui"

-- Import Modular Components
import "inventory"
import "enemies"
import "crafting_menu"
import "combat"
import "structures"
import "game_manager"
import "world_actions"

local gfx <const> = playdate.graphics

-- --- 1. GLOBAL GAME CONSTANTS ---
GameMode = { SURVIVAL = "survival", CREATOR = "creator" }
currentMode = GameMode.SURVIVAL

-- --- 2. PLAYER INITIALIZATION ---
player = {
    x = 200, y = 120, 
    vx = 0, vy = 0,
    character = "miner",
    originalCharacter = "miner",
    facing = "down",
    hearts = 5,
    maxHearts = 5,
    hungerTimer = 600, -- 10 seconds per hunger tick
    isTransformed = false,
    transformTimer = 0,
    transformCooldown = 0
}

characterTypes = {
    miner = { name = "Rusty", speed = 2, special = "double_ore" },
    dragon = { name = "Ancient Dragon", speed = 2.8, special = "fire_breath" }
}

-- --- 3. HELPER FUNCTIONS ---

function updatePlayer()
    local stats = characterTypes[player.character]
    local speed = stats.speed
    
    -- Movement Input
    if playdate.buttonIsPressed(playdate.kButtonLeft) then 
        player.vx = -speed; player.facing = "left"
    elseif playdate.buttonIsPressed(playdate.kButtonRight) then 
        player.vx = speed; player.facing = "right"
    else player.vx = 0 end

    if playdate.buttonIsPressed(playdate.kButtonUp) then 
        player.vy = -speed; player.facing = "up"
    elseif playdate.buttonIsPressed(playdate.kButtonDown) then 
        player.vy = speed; player.facing = "down"
    else player.vy = 0 end

    player.x += player.vx
    player.y += player.vy

    -- Keep on screen
    player.x = math.max(10, math.min(390, player.x))
    player.y = math.max(10, math.min(230, player.y))

    -- Transform Logic
    if player.isTransformed then
        player.transformTimer -= 1
        if player.transformTimer <= 0 then
            player.character = "miner"
            player.isTransformed = false
            player.transformCooldown = 300
        end
    end
    if player.transformCooldown > 0 then player.transformCooldown -= 1 end
end

function drawWorld()
    -- Draw Entities & Structures
    Structures:update(Enemies.activeEntities)
    Enemies:update(player)
    Combat:update()

    -- Draw Player
    gfx.setColor(gfx.kColorBlack)
    if player.isTransformed then
        gfx.fillCircleAtPoint(player.x, player.y, 10)
    else
        gfx.fillRect(player.x - 5, player.y - 5, 10, 10)
    end
end

function drawHUD()
    gfx.drawText("**" .. characterTypes[player.character].name .. "**", 10, 10)
    Inventory:drawUI()
    
    if currentMode == GameMode.CREATOR then
        gfx.drawText("CREATOR MODE", 300, 10)
    end
end

-- --- 4. MAIN UPDATE LOOP ---

function playdate.update()
    -- A. Handle Menu Logic
    if playdate.buttonJustPressed(playdate.kButtonB) then
        CraftingMenu:toggle()
    end

    if CraftingMenu:isOpen() then
        gfx.clear()
        drawWorld()
        CraftingMenu:update()
        CraftingMenu:draw()
    else
        -- B. Handle Mode Switching (Crank)
        if not playdate.isCrankDocked() and currentMode == GameMode.SURVIVAL then
            setGameMode(GameMode.CREATOR)
        elseif playdate.isCrankDocked() and currentMode == GameMode.CREATOR then
            setGameMode(GameMode.SURVIVAL)
        end

        -- C. Update Logic
        updatePlayer()
        updateSurvival(player)

        -- D. Actions (A Button)
        if playdate.buttonJustPressed(playdate.kButtonA) then
            if player.isTransformed then
                Combat:fire(player.x, player.y, player.facing, "fire")
            elseif player.y < 40 then
                startFishing(player)
            else
                -- Build default structure if enough wood
                if Inventory.materials.wood >= 5 then
                    Inventory.materials.wood -= 5
                    Structures:build(player.x, player.y, "wooden_wall")
                end
            end
        end

        -- E. Rendering
        gfx.clear()
        drawWorld()
        drawHUD()
    end
end