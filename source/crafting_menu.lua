-- crafting_menu.lua
import "CoreLibs/graphics"
import "CoreLibs/ui"

local gfx <const> = playdate.graphics

CraftingMenu = {}
local isVisible = false
local gridview = playdate.ui.gridview.new(0, 20) -- cell width, cell height
gridview:setNumberOfRows(#Recipes)
gridview:setSectionHeaderHeight(24)

-- Menu state
local selectedIndex = 1

function CraftingMenu:toggle()
    isVisible = not isVisible
    -- Reset selection when opening
    if isVisible then gridview:setSelection(1, 1, 1) end
end

function CraftingMenu:isOpen()
    return isVisible
end

function CraftingMenu:update()
    if not isVisible then return end

    -- Handle Input for scrolling
    if playdate.buttonJustPressed(playdate.kButtonUp) then
        gridview:selectPreviousRow(true)
    elseif playdate.buttonJustPressed(playdate.kButtonDown) then
        gridview:selectNextRow(true)
    end

    -- Handle Crafting (A Button)
    if playdate.buttonJustPressed(playdate.kButtonA) then
        local _, row = gridview:getSelection()
        local recipe = Recipes[row]
        
        if Inventory:canCraft(recipe) then
            -- Logic from your Development Kitchen:
            -- 1. Consume materials
            for mat, amt in pairs(recipe.requires) do
                Inventory.materials[mat] -= amt
            end
            -- 2. Add product
            Inventory:addItem(recipe.produces, 1)
            print("Successfully crafted: " .. recipe.name)
        else
            print("Not enough fresh ingredients!")
        end
    end
end

function CraftingMenu:draw()
    if not isVisible then return end

    -- Draw Background Overlay
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRoundRect(40, 20, 320, 200, 4)
    gfx.setColor(gfx.kColorBlack)
    gfx.drawRoundRect(40, 20, 320, 200, 4)

    gfx.drawTextAligned("**CRAFTING KITCHEN**", 200, 30, kTextAlignment.center)
    gfx.drawLine(50, 50, 350, 50)

    -- Draw Scrollable Grid
    gridview:drawInRect(50, 60, 140, 150)

    -- Draw Details for Selected Recipe
    local _, row = gridview:getSelection()
    local recipe = Recipes[row]
    
    self:drawRecipeDetails(recipe, 200, 60)
end

function CraftingMenu:drawRecipeDetails(recipe, x, y)
    gfx.drawText("**" .. recipe.name .. "**", x, y)
    gfx.drawText("Requires:", x, y + 25)
    
    local offset = 45
    for mat, amt in pairs(recipe.requires) do
        local current = Inventory.materials[mat] or 0
        local color = current >= amt and " " or "*" -- Mark missing ingredients
        gfx.drawText(string.format("- %s: %d/%d", mat, current, amt), x + 5, y + offset)
        offset += 15
    end
    
    gfx.drawText("(A) to Mix Ingredients", x, y + 130)
end

-- Gridview logic for drawing rows
function gridview:drawCell(section, row, column, selected, x, y, width, height)
    if selected then
        gfx.fillRoundRect(x, y, width, height, 4)
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    else
        gfx.setImageDrawMode(gfx.kDrawModeCopy)
    end
    gfx.drawText(Recipes[row].name, x + 5, y + 2)
end