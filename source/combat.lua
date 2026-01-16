--- combat.lua
local gfx <const> = playdate.graphics

Combat = {}
local projectiles = {}

-- Function to trigger a projectile (Fire for Dragon, Shell for Cannon)
function Combat:fire(x, y, direction, type)
    -- Determine projectile stats based on type
    local speed = (type == "heavy_shell") and 3 or 5
    local vx, vy = 0, 0
    
    -- Calculate velocity based on direction
    if direction == "left" then vx = -speed
    elseif direction == "right" then vx = speed
    elseif direction == "up" then vy = -speed
    elseif direction == "down" then vy = speed
    else vx = speed -- Default fallback
    end

    local proj = {
        x = x,
        y = y,
        vx = vx,
        vy = vy,
        life = 45, -- How many frames it travels
        type = type,
        radius = (type == "heavy_shell") and 20 or 8 -- Damage radius
    }
    table.insert(projectiles, proj)
end

function Combat:update()
    for i = #projectiles, 1, -1 do
        local p = projectiles[i]
        
        -- Update position
        p.x += p.vx
        p.y += p.vy
        p.life -= 1
        
        -- Draw Projectile Graphics
        gfx.setColor(gfx.kColorBlack)
        if p.type == "heavy_shell" then
            -- Cannonball visual
            gfx.fillCircleAtPoint(p.x, p.y, 5)
        else
            -- Dragon fire visual (flickering effect)
            if p.life % 4 < 2 then
                gfx.fillCircleAtPoint(p.x, p.y, 4)
            else
                gfx.drawCircleAtPoint(p.x, p.y, 3)
            end
        end
        
        -- Collision check with Enemies
        local hit = false
        for j = #Enemies.activeEntities, 1, -1 do
            local e = Enemies.activeEntities[j]
            local dx = p.x - e.x
            local dy = p.y - e.y
            local dist = math.sqrt(dx*dx + dy*dy)
            
            -- If the projectile hits or is close enough for AOE
            if dist < p.radius then
                if p.type == "heavy_shell" then
                    e.hp -= 10 -- Massive damage
                    Particles:spawn(e.x, e.y, gfx.kColorBlack, 15) -- Big explosion
                else
                    e.hp -= 2 -- Standard dragon damage
                    Particles:spawn(e.x, e.y, nil, 5) -- Small embers
                end
                
                -- Fire breath passes through, shells explode on impact
                if p.type == "heavy_shell" then hit = true end
            end
        end
        
        -- Remove projectile if it hit something or ran out of life
        if hit or p.life <= 0 then
            table.remove(projectiles, i)
        end
    end
end