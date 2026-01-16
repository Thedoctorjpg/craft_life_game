local gfx <const> = playdate.graphics

Inventory = {
    materials = { 
        wood = 10, stone = 5, iron = 0, gunpowder = 0, 
        raw_fish = 0, wheat_bundle = 0, leather = 0, herbs = 0
    },
    tools = {{item = "stone_axe", count = 1}}
}

Recipes = {
    {name = "Stone Axe", requires = {wood = 2, stone = 2}, produces = "stone_axe", type = "tool"},
    {name = "Fishing Rod", requires = {wood = 3, leather = 1}, produces = "fishing_rod", type = "tool"},
    {name = "Iron Shield", requires = {iron = 4, wood = 1}, produces = "shield", type = "structure"},
    {name = "Fish Feast", requires = {raw_fish = 2, herbs = 1}, produces = "fish_feast", type = "food"},
    {name = "Landmine", requires = {iron = 1, gunpowder = 2}, produces = "landmine", type = "structure"},
    {name = "Cannon", requires = {iron = 5, wood = 2, gunpowder = 3}, produces = "cannon", type = "structure"}
}

function Inventory:canCraft(recipe)
    for mat, amt in pairs(recipe.requires) do
        if (self.materials[mat] or 0) < amt then return false end
    end
    return true
end

function Inventory:addItem(itemType, amount)
    if self.materials[itemType] ~= nil then self.materials[itemType] += amount
    else table.insert(self.tools, {item = itemType, count = 1}) end
end

function Inventory:drawUI()
    gfx.drawText("W:"..self.materials.wood.." S:"..self.materials.stone.." F:"..self.materials.raw_fish, 10, 223)
end