-- enemies.lua
local gfx <const> = playdate.graphics

Enemies = {}
Enemies.activeEntities = {}

local entityTypes = {
    -- Hostiles
    cave_spider = { hp = 3, speed = 1.2, hostile = true, drop = "stone" },
    rock_golem = { hp = 15, speed = 0.6, hostile = true, drop = "gems" },
    cave_bomber = { hp = 4, speed = 1.4, hostile = true, drop = "gunpowder", image = "cave_bomber" },
    
    -- Friendlies
    cow = { hp = 5, speed = 0.4, hostile = false, drop = "leather" },
    horse = { hp = 10, speed = 1.8, hostile = false, followPlayer = false, image = "horse" },
    
    -- Resources
    tree = { hp = 1, speed = 0, hostile = false, drop = "wood" },
    field = { hp = 1, speed = 0, hostile = false, drop = "wheat_bundle" }
}

function Enemies:checkFeeding(e)
    if e.type == "horse" and Inventory.materials.wheat_bundle > 0 then
        Inventory.materials.wheat_bundle -= 1
        e.hp = math.min(e.hp + 2, 10)
        Particles:spawn(e.x, e.y, gfx.kColorWhite, 8) 
        return true
    end
    return false
end

function Enemies:spawn(x, y, type)
    local config = entityTypes[type]
    if not config then return end
    
    local entity = {
        x = x, y = y,
        hp = config.hp,
        speed = config.speed,
        type = type,
        hostile = config.hostile,
        drop = config.drop,
        image = config.image
    }
    table.insert(Enemies.activeEntities, entity)
end

function Enemies:update(player)
    for i = #Enemies.activeEntities, 1, -1 do
        local e = Enemies.activeEntities[i]
        
        -- 1. Collision with Structures
        local blocked = false
        if Structures and Structures.active then
            for j = #Structures.active, 1, -1 do
                local s = Structures.active[j]
                local distS = math.sqrt((e.x - s.x)^2 + (e.y - s.y)^2)
                if distS < 15 then
                    blocked = true
                    s.hp -= 0.1 
                    if s.config.type == "explosive_trap" then
                        e.hp -= s.config.damage
                        s.hp = 0 
                        Particles:spawn(s.x, s.y, gfx.kColorBlack, 20)
                    end
                end
            end
        end

        -- 2. Movement
        if not blocked and (e.hostile or e.followPlayer) then
            local dx = player.x - e.x
            local dy = player.y - e.y
            local dist = math.sqrt(dx*dx + dy*dy)
            if dist > 0 then
                e.x += (dx / dist) * e.speed
                e.y += (dy / dist) * e.speed
            end
        end

        -- 3. Rendering with PNG Support
        gfx.setColor(gfx.kColorBlack)
        if e.image then
            local img = gfx.image.new(e.image)
            if img then
                img:drawCentered(e.x, e.y)
            else
                -- Fallback if image fails to load
                gfx.drawCircleAtPoint(e.x, e.y, 6)
            end
        elseif e.type == "tree" then
            gfx.fillTriangle(e.x, e.y-10, e.x-6, e.y, e.x+6, e.y)
        else
            gfx.drawCircleInRect(e.x-4, e.y-4, 8, 8)
        end
        
        -- 4. Death
        if e.hp <= 0 then
            if e.drop then Inventory:addItem(e.drop, 1) end
            table.remove(Enemies.activeEntities, i)
        end
    end
end