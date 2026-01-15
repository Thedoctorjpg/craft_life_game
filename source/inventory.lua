-- inventory.lua
import "CoreLibs/graphics"
local gfx <const> = playdate.graphics

Inventory = {
    materials = { 
        wood = 5, stone = 0, iron = 0, gold = 0, gems = 0,
        leather = 0, wheat_bundle = 0, paper = 0, mysticalessence = 2, herbs = 0
    },
    tools = {{item = "rusty_pickaxe", count = 1, durability = 100}},
    potions = {},
    buildables = {}
}

Recipes = {
    {name = "Paper", requires = {wood = 2}, produces = "paper", type = "material"},
    {name = "Bread", requires = {wheat_bundle = 3}, produces = "bread", type = "food"},
    {name = "Book", requires = {paper = 3, leather = 1}, produces = "book", type = "item"},
    {name = "Wood Wall", requires = {wood = 5}, produces = "wooden_wall", type = "structure"},
    {name = "Stone Wall", requires = {stone = 8}, produces = "stone_wall", type = "structure"},
    {name = "Spike Trap", requires = {iron = 2, wood = 2}, produces = "spike_trap", type = "structure"},
    {name = "Stone Sword", requires = {stone = 3, wood = 1}, produces = "stone_sword", type = "tool"},
    {name = "Healing Potion", requires = {herbs = 3}, produces = "health_potion", type = "potion"},
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
    else
        table.insert(self.tools, {item = itemType, count = amount, durability = 100})
    end
end

function Inventory:drawUI()
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(0, 220, 400, 20)
    gfx.setColor(gfx.kColorBlack)
    gfx.drawText(string.format("Wd: %d | St: %d | Lthr: %d | Wht: %d", 
        self.materials.wood, self.materials.stone, self.materials.leather, self.materials.wheat_bundle), 10, 223)
end