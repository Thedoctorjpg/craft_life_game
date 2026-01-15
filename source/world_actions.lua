-- world_actions.lua
function startFishing(player)
    -- Check if player is near water (simple coordinate check for now)
    if player.y < 40 then 
        print("Casting line...")
        -- 20% chance to catch a fish every 2 seconds
        if math.random() < 0.2 then
            Inventory:addItem("raw_fish", 1)
            print("Caught a fresh snapper!")
        end
    end
end

function plantSeed(tx, ty)
    -- "Nude Food" farming: Turning soil into sustenance
    if Inventory.materials.seeds > 0 then
        Inventory.materials.seeds -= 1
        Enemies:spawn(tx, ty, "wheat_sprout") -- Spawns a timer-based entity
    end
end