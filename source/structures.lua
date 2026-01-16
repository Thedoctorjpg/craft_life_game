local gfx <const> = playdate.graphics

Structures = {}
Structures.active = {}

local defenseTypes = {
    wooden_wall = { hp = 20, type = "barrier" },
    shield = { hp = 100, type = "barrier", image = "shield" },
    landmine = { hp = 1, damage = 15, type = "explosive" },
    cannon = { hp = 20, fireRate = 60, type = "auto" }
}

function Structures:build(x, y, type)
    local config = defenseTypes[type]
    table.insert(self.active, {x=x, y=y, hp=config.hp, config=config, timer=0})
end

function Structures:update(enemies)
    for i = #self.active, 1, -1 do
        local s = self.active[i]
        if s.config.image then
            local img = gfx.image.new(s.config.image)
            if img then img:drawCentered(s.x, s.y) end
        else
            gfx.drawRect(s.x-8, s.y-8, 16, 16)
        end
        -- Explode logic for landmines
        if s.config.type == "explosive" then
            for _, e in ipairs(enemies) do
                if math.abs(e.x - s.x) < 15 and math.abs(e.y - s.y) < 15 then
                    e.hp -= s.config.damage
                    s.hp = 0
                    Particles:spawn(s.x, s.y, gfx.kColorBlack, 20)
                end
            end
        end
        if s.hp <= 0 then table.remove(self.active, i) end
    end
end