-- particles.lua
local gfx <const> = playdate.graphics

Particles = {}
local activeParticles = {}

function Particles:spawn(x, y, color, count)
    count = count or 10
    for i = 1, count do
        local p = {
            x = x,
            y = y,
            vx = math.random(-4, 4),
            vy = math.random(-4, 4),
            life = math.random(10, 20),
            size = math.random(1, 3),
            color = color or gfx.kColorBlack
        }
        table.insert(activeParticles, p)
    end
end

function Particles:update()
    gfx.setLineStyle(gfx.kLineStyleSmooth)
    for i = #activeParticles, 1, -1 do
        local p = activeParticles[i]
        
        -- Move particles
        p.x += p.vx
        p.y += p.vy
        
        -- Slow them down (friction)
        p.vx *= 0.9
        p.vy *= 0.9
        
        p.life -= 1
        
        -- Draw the particle
        gfx.setColor(p.color)
        gfx.fillCircleAtPoint(p.x, p.y, p.size)
        
        if p.life <= 0 then
            table.remove(activeParticles, i)
        end
    end
end