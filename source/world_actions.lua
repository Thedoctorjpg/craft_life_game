-- world_actions.lua
local gfx <const> = playdate.graphics

-- Utility: Check if player has a specific tool in their inventory
function hasTool(toolName)
    for _, t in ipairs(Inventory.tools) do
        if t.item == toolName then return true end
    end
    return false
end

function startFishing(player)
    -- Contextual check: Are we near the water? (Top of screen)
    if player.y > 50 then 
        print("Move closer to the water to fish!")
        return 
    end

    if hasTool("fishing_rod") then
        print("Casting line into the moana...")
        -- 30% chance to catch a fish
        if math.random() < 0.3 then
            Inventory:addItem("raw_fish", 1)
            Particles:spawn(player.x, player.y - 10, gfx.kColorWhite, 6)
            print("Caught a fresh snapper!")
        else
            print("Nothing biting yet...")
        end
    else
        print("You need a Fishing Rod! Craft one in the Kitchen.")
    end
end

function chopTree(player, tree)
    if hasTool("stone_axe") then
        tree.hp -= 1
        Particles:spawn(tree.x, tree.y, gfx.kColorBlack, 4)
        print("Chop!")
        -- Tree health/drop logic is handled in Enemies:update
    else
        print("This wood is too tough. You need an Axe!")
    end
end

function plantSeed(tx, ty)
    -- Turning soil into sustenance
    if Inventory.materials.wheat_bundle > 0 then
        Inventory.materials.wheat_bundle -= 1
        Enemies:spawn(tx, ty, "field")
        print("Planted wheat seeds.")
    else
        print("No seeds to plant!")
    end
end
