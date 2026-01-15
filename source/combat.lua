-- combat.lua
local gfx <const> = playdate.graphics

Combat = {}
local projectiles = {}

function Combat:fire(x, y, direction, type)
    local speed = 5
    local vx, vy = 0, 0
    
    -- Determine velocity based on player facing logic
    if direction == "left" then vx = -speed
    elseif direction == "right" then vx = speed
    elseif direction == "up" then vy = -speed
    elseif direction == "down" then vy = speed
    end

    local proj = {
        x = x,
        y = y,
        vx = vx,
        vy = vy,
        life = 40, -- frames until it fades
        type = type
    }
    table.insert(projectiles, proj)
end

function Combat:update()
    for i = #projectiles, 1, -1 do
        local p = projectiles[i]
        p.x += p.vx
        p.y += p.vy
        p.life -= 1
        
        -- Draw the projectile (a simple flickering circle for fire)
        gfx.setColor(gfx.kColorBlack)
        if p.life % 4 < 2 then -- Simple flicker effect
            gfx.fillCircleAtPoint(p.x, p.y, 4)
        else
            gfx.drawCircleAtPoint(p.x, p.y, 3)
        end
        
        -- Collision check with enemies
        for j = #Enemies.activeEnemies, 1, -1 do
            local e = Enemies.activeEnemies[j]
            local dx = p.x - e.x
            local dy = p.y - e.y
            local dist = math.sqrt(dx*dx + dy*dy)
            
            if dist < 12 then
                e.hp -= 5 -- High dragon damage
                p.life = 0 -- Destroy projectile on hit
                print("Direct hit!")
            end
        end

        if p.life <= 0 then
            table.remove(projectiles, i)
        end
    end
end