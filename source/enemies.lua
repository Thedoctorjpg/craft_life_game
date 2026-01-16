local gfx <const> = playdate.graphics

Enemies = {}
Enemies.activeEntities = {}

local entityTypes = {
    cave_bomber = { hp = 4, speed = 1.4, hostile = true, drop = "gunpowder", image = "cave_bomber" },
    horse = { hp = 10, speed = 1.8, hostile = false, image = "horse" },
    pet = { hp = 10, speed = 1.0, hostile = false, followPlayer = true },
    tree = { hp = 3, speed = 0, hostile = false, drop = "wood" }
}

function Enemies:checkFeeding(e)
    if Inventory.materials.wheat_bundle > 0 then
        Inventory.materials.wheat_bundle -= 1
        e.hp = 10
        Particles:spawn(e.x, e.y, gfx.kColorWhite, 8)
        return true
    end
    return false
end

function Enemies:feedPet(e)
    if Inventory.materials.raw_fish > 0 then
        Inventory.materials.raw_fish -= 1
        Particles:spawn(e.x, e.y, gfx.kColorWhite, 10)
        return true
    end
    return false
end

function Enemies:update(player)
    for i = #self.activeEntities, 1, -1 do
        local e = self.activeEntities[i]
        -- Movement and logic...
        if e.image then
            local img = gfx.image.new(e.image)
            if img then img:drawCentered(e.x, e.y) end
        else
            gfx.drawCircleAtPoint(e.x, e.y, 5)
        end
        if e.hp <= 0 then
            if e.drop then Inventory:addItem(e.drop, 2) end
            table.remove(self.activeEntities, i)
        end
    end
end