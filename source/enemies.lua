--- enemies.lua
local gfx <const> = playdate.graphics

Enemies = {}
Enemies.activeEntities = {}

local entityTypes = {
    cave_spider = { hp = 3, speed = 1.2, hostile = true, drop = "stone" },
    rock_golem = { hp = 15, speed = 0.6, hostile = true, drop = "gems" },
    cow = { hp = 5, speed = 0.4, hostile = false, drop = "leather" },
    pet = { hp = 10, speed = 1.0, hostile = false, followPlayer = true },
    tree = { hp = 1, speed = 0, hostile = false, drop = "wood" },
    wheat = { hp = 1, speed = 0, hostile = false, drop = "wheat_bundle" }
}

function Enemies:spawn(x, y, type)
    local config = entityTypes[type]
    local entity = {
        x = x, y = y,
        hp = config.hp,
        speed = config.speed,
        type = type,
        hostile = config.hostile,
        drop = config.drop,
        followPlayer = config.followPlayer
    }
    table.insert(Enemies.activeEntities, entity)
end

function Enemies:update(player)
    for i = #Enemies.activeEntities, 1, -1 do
        local e = Enemies.activeEntities[i]
        
        -- Collision with Structures (Moved inside update loop)
        local blocked = false
        if Structures and Structures.active then
            for _, s in ipairs(Structures.active) do
                local distS = math.sqrt((e.x - s.x)^2 + (e.y - s.y)^2)
                if distS < 15 then
                    blocked = true
                    s.hp -= 0.1
                    if s.config.type == "trap" then e.hp -= 0.5 end
                end
            end
        end

        -- Movement AI
        if not blocked then
            local targetX, targetY = player.x, player.y
            local dx = targetX - e.x
            local dy = targetY - e.y
            local dist = math.sqrt(dx*dx + dy*dy)
            
            if (e.followPlayer and dist > 30) or (e.hostile) then
                e.x += (dx / dist) * e.speed
                e.y += (dy / dist) * e.speed
            end
        end

        -- Draw
        if e.type == "cow" then gfx.drawRoundRect(e.x-6, e.y-4, 12, 8, 2)
        elseif e.type == "tree" then gfx.fillTriangle(e.x, e.y-10, e.x-6, e.y, e.x+6, e.y)
        else gfx.drawCircleInRect(e.x-4, e.y-4, 8, 8) end
        
        if e.hp <= 0 then
            if e.drop then Inventory:addItem(e.drop, 1) end
            table.remove(Enemies.activeEntities, i)
        end
    end
end