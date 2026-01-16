-- combat.lua
local gfx <const> = playdate.graphics

Combat = {}
local projectiles = {}

function Combat:fire(x, y, direction, type)
    -- Cannons use heavy shells, Dragon uses fire breath
    local speed = (type == "heavy_shell") and 3 or 5
    local vx, vy = 0, 0
    
    if direction == "left" then vx = -speed
    elseif direction == "right" then vx = speed
    elseif direction == "up" then vy = -speed
    elseif direction == "down" then vy = speed
    else vx = speed -- Default right
    end

    local proj = {
        x = x, y = y, vx = vx, vy = vy,
        life = 45,
        type = type,
        radius = (type == "heavy_shell") and 15 or 6 -- Explosive radius
    }
    table.insert(projectiles, proj)
end

function Combat:update()
    for i = #projectiles, 1, -1 do
        local p = projectiles[i]
        p.x += p.vx
        p.y += p.vy
        p.life -= 1
        
        -- Draw Projectile
        gfx.setColor(gfx.kColorBlack)
        if p.type == "heavy_shell" then
            gfx.fillCircleAtPoint(p.x, p.y, 5) -- Cannon ball
        else
            if p.life % 4 < 2 then gfx.fillCircleAtPoint(p.x, p.y, 4)
            else gfx.drawCircleAtPoint(p.x, p.y, 3) end
        end
        
        -- Collision with Enemies
        for j = #Enemies.activeEntities, 1, -1 do
            local e = Enemies.activeEntities[j]
            local dx = p.x - e.x
            local dy = p.y - e.y
            local dist = math.sqrt(dx*dx + dy*dy)
            
            if dist < p.radius then
                local damage = (p.type == "heavy_shell") and 10 or 5
                e.hp -= damage
                p.life = 0 -- Destroy projectile
                print("Hit for " .. damage)
            end
        end

        if p.life <= 0 then
            table.remove(projectiles, i)
        end
    end
end