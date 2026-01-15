-- structures.lua
local gfx <const> = playdate.graphics

Structures = {}
Structures.active = {}

local defenseTypes = {
    wooden_wall = { hp = 20, color = gfx.kColorBlack, type = "barrier" },
    stone_wall = { hp = 50, color = gfx.kColorBlack, type = "barrier" },
    spike_trap = { hp = 10, damage = 2, type = "trap" },
    turret = { hp = 15, range = 60, fireRate = 30, type = "auto" }
}

function Structures:build(x, y, type)
    local config = defenseTypes[type]
    local s = {
        x = x, y = y,
        hp = config.hp,
        type = type,
        config = config,
        timer = 0
    }
    table.insert(self.active, s)
end

function Structures:update(enemies)
    for i = #self.active, 1, -1 do
        local s = self.active[i]
        
        -- Draw Structure
        gfx.setColor(gfx.kColorBlack)
        if s.config.type == "barrier" then
            gfx.fillRect(s.x - 8, s.y - 8, 16, 16)
        elseif s.config.type == "trap" then
            gfx.drawRect(s.x - 6, s.y - 6, 12, 12)
            gfx.drawLine(s.x-6, s.y-6, s.x+6, s.y+6) -- Spike visual
        end

        -- Logic for Turrets (Auto-defense)
        if s.config.type == "auto" then
            s.timer += 1
            if s.timer >= s.config.fireRate then
                -- Find nearest enemy
                for _, e in ipairs(enemies) do
                    local dist = math.sqrt((s.x-e.x)^2 + (s.y-e.y)^2)
                    if dist < s.config.range then
                        Combat:fire(s.x, s.y, "right", "bolt") -- Automate defense
                        s.timer = 0
                        break
                    end
                end
            end
        end

        -- Damage handling
        if s.hp <= 0 then table.remove(self.active, i) end
    end
end