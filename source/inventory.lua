-- inventory.lua
import "CoreLibs/graphics"
local gfx <const> = playdate.graphics

Inventory = {
    -- Current stockpiles of raw "Nude Food" ingredients
    materials = { 
        wood = 10, stone = 5, iron = 0, gold = 0, gems = 0,
        leather = 0, wheat_bundle = 0, paper = 0, herbs = 0,
        gunpowder = 0, raw_fish = 0, mysticalessence = 2
    },
    
    -- Finished items and tools
    tools = {
        {item = "rusty_pickaxe", count = 1, durability = 100}
    }
}

-- --- CRAFTING RECIPES ---
Recipes = {
    -- Basic Survival & Resources
    {name = "Bread", requires = {wheat_bundle = 3}, produces = "bread", type = "food"},
    {name = "Paper", requires = {wood = 2}, produces = "paper", type = "material"},
    
    -- Tools (New!)
    {name = "Stone Axe", requires = {wood = 2, stone = 2}, produces = "stone_axe", type = "tool"},
    {name = "Fishing Rod", requires = {wood = 3, leather = 1}, produces = "fishing_rod", type = "tool"},
    
    -- Gunpowder Mechanisms
    {name = "Landmine", requires = {iron = 1, gunpowder = 2}, produces = "landmine", type = "structure"},
    {name = "Cannon", requires = {iron = 5, wood = 2, gunpowder = 3}, produces = "cannon", type = "structure"},
    
    -- High Quality Meals (Nude Food)
    {name = "Fish Feast", requires = {raw_fish = 2, herbs = 1}, produces = "fish_feast", type = "food"},
    
    -- High Tier
    {name = "Dragon Essence", requires = {gold = 20, gems = 5}, produces = "dragon_essence", type = "transform"}
}

function Inventory:canCraft(recipe)
    for material, amount in pairs(recipe.requires) do
        if (self.materials[material] or 0) < amount then return false end
    end
    return true
end

function Inventory:addItem(itemType, amount)
    amount = amount or 1
    if self.materials[itemType] ~= nil then
        self.materials[itemType] += amount
        print("Stocked: " .. itemType)
    else
        -- Check if it's a tool/item already in the list to stack or add new
        local found = false
        for _, t in ipairs(self.tools) do
            if t.item == itemType then
                t.count += amount
                found = true
                break
            end
        end
        if not found then
            table.insert(self.tools, {item = itemType, count = amount, durability = 100})
        end
        print("New Item: " .. itemType)
    end
end

function Inventory:drawUI()
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(0, 220, 400, 20)
    gfx.setColor(gfx.kColorBlack)
    gfx.drawRect(0, 220, 400, 20)
    
    local hudText = string.format("Wood:%d Stone:%d Fish:%d Grain:%d", 
        self.materials.wood, self.materials.stone, 
        self.materials.raw_fish, self.materials.wheat_bundle)
    gfx.drawText(hudText, 10, 223)
end