import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/sound"

local gfx <const> = playdate.graphics
local spr <const> = playdate.sprites
local snd <const> = playdate.sound

-- Load your assets (import PNGs to source/ as sprites, MP3s to sounds/)
local playerSprite = gfx.image.new("character_rusty_pickaxe")  -- Your voxel dude!
local pickBlowSFX = snd.sfx.new("pickaxe-blow")  -- From your sounds/
local beeBuzz = snd.sfx.new("bee-flying-loop", {loop=true})

-- World: 1-bit tilemap (20x20 rooms, procedural gen)
local TILE_SIZE = 8
local WORLD_WIDTH, WORLD_HEIGHT = 400/TILE_SIZE, 240/TILE_SIZE
local worldTiles = {}  -- 0=air, 1=dirt, 2=clay, 3=coal, 4=gold_ore, 5=bee_hive

function generateCave()
    -- Perlin-ish noise for layers: surface dirt -> deep gold
    for x=1,WORLD_WIDTH do
        for y=1,WORLD_HEIGHT do
            local depth = y / WORLD_HEIGHT
            if depth < 0.3 then worldTiles[x+y*WORLD_WIDTH] = 1  -- dirt
            elseif depth < 0.6 then worldTiles[x+y*WORLD_WIDTH] = 2  -- clay
            elseif depth < 0.8 then worldTiles[x+y*WORLD_WIDTH] = 3  -- coal
            elseif depth > 0.8 then worldTiles[x+y*WORLD_WIDTH] = 4  -- gold
            else worldTiles[x+y*WORLD_WIDTH] = 0 end
            -- Random bees: 1% hives in clay
            if math.random() < 0.01 then worldTiles[x+y*WORLD_WIDTH] = 5 end
        end
    end
end

-- Player
local player = {x=100, y=100, vx=0, vy=0, holding="rusty_pickaxe", hunger=4, hearts=3}

function player:update()
    -- D-pad move
    local move = playdate.getVector()
    self.x += move.x * 2
    self.y += move.y * 2
    -- A: Mine (crank speeds it!)
    if playdate.buttonJustPressed(playdate.kButtonA) then
        local crankPos = playdate.crankPosition()  -- Crank = faster dig
        local digs = math.floor(crankPos / 360) + 1
        for i=1,digs do mineNearby(self.x, self.y) end
        pickBlowSFX:play()
    end
    -- Hunger tick
    self.hunger -= 0.01
    if self.hunger <= 0 then self.hearts -= 1; self.hunger=4 end  -- Eat at surface!
end

function mineNearby(px, py)
    local tx, ty = math.floor(px/TILE_SIZE), math.floor(py/TILE_SIZE)
    local tile = worldTiles[tx + ty * WORLD_WIDTH]
    if tile > 0 then
        -- Drop item! (inventory array later)
        worldTiles[tx + ty * WORLD_WIDTH] = 0
        if tile == 5 then angryBees() end  -- Danger!
    end
end

function angryBees()
    beeBuzz:play()
    -- Swarm: particles chase player, damage on touch
end

-- Draw loop
function playdate.update()
    gfx.clear()
    -- Render world tiles (use your block_textures/)
    for x=1,WORLD_WIDTH do for y=1,WORLD_HEIGHT do
        local tileImg = getTileImage(worldTiles[x+y*WORLD_WIDTH])
        if tileImg then tileImg:draw((x-1)*TILE_SIZE, (y-1)*TILE_SIZE) end
    end end
    -- Draw player
    playerSprite:draw(player.x, player.y)
    -- UI: hunger bar (green rects), hearts (3 icons)
    player:update()
end

-- Init
generateCave()
playdate.timer.performAfterDelay(100, function() playdate.setCrankIndicator(playdate.crankIndicatorType.kFull) end)  -- Crank UI!

-- In player table add:
player.crankEscape = 0  -- 0-100% escape progress

-- In playdate.update()
local crankTicks = playdate.getCrankTicks(6)  -- 6 ticks per full turn
if crankTicks > 0 then
    -- Normal mining boost
    local digs = crankTicks * 3  -- full turn ~18 digs!
    for i=1, digs do mineNearby(player.x, player.y) end
    -- Or cave-in escape
    if inCaveIn then
        player.crankEscape += crankTicks * 5
        if player.crankEscape >= 100 then escapeCaveIn() end
        playdate.graphics.drawText("CRANK TO ESCAPE!", 10, 200)  -- UI prompt
    end
end

-- Cave-in trigger example (in mineNearby or timer)
function startCaveIn()
    inCaveIn = true
    player.crankEscape = 0
    whooshSound:play()  -- panic!
end
-- Inventory setup
local inventory = {
    {tool="rusty_pickaxe", count=1},
    {tool="spade", count=1},
    {tool="axe", count=0},
    {tool=nil, count=0},
    {tool=nil, count=0}
}
local selectedSlot = 1

-- Input to swap
if playdate.buttonJustPressed(playdate.kButton1) then selectedSlot = 1 end
-- ... up to 5

-- Draw bottom bar
function drawInventory()
    for i=1,5 do
        local x = (i-1)*40 + 20
        gfx.drawRect(x-10, 220, 40, 20)  -- slot box
        if i == selectedSlot then gfx.setColor(gfx.kColorWhite) else gfx.setColor(gfx.kColorBlack) end
        gfx.fillRect(x-10, 220, 40, 20)
        if inventory[i].tool then
            -- Load sprite: e.g. gfx.image.new("images/"..inventory[i].tool):draw(x, 220)
            gfx.drawText(inventory[i].tool:sub(1,5), x, 225)  -- placeholder
        end
    end
end

-- In update: call drawInventory()
-- When mining: use inventory[selectedSlot].tool for speed/damage
local highScore = {depth = 0, gold = 0}
local player = {..., maxDepth = 0, goldSmelted = 0}

-- Update depth
if player.y / TILE_SIZE > player.maxDepth then
    player.maxDepth = player.y / TILE_SIZE
    if player.maxDepth > highScore.depth then highScore.depth = player.maxDepth end
end

-- On smelt (craft gold bar): highScore.gold +=1

-- Save/Load
local datastore = playdate.datastore
function saveProgress()
    local data = {depth = highScore.depth, gold = highScore.gold}
    datastore.write("highscore", data)
end

function loadProgress()
    local data = datastore.read("highscore")
    if data then
        highScore = data
    end
end

-- Call loadProgress() at start, saveProgress() on quit or milestones
-- Draw: gfx.drawText("Deepest: "..highScore.depth.." | Gold: "..highScore.gold, 10, 10)
-- Setup at init
local bgm = playdate.sound.fileplayer.new("sounds/modern-stylish-background.mp3")
bgm:setVolume(0.6)
bgm:play(0)  -- 0 = infinite loop

-- Effects as separate players
local pickSFX = playdate.sound.fileplayer.new("sounds/pickaxe-blow.mp3")
local goldSFX = playdate.sound.fileplayer.new("sounds/star-shinning.mp3")

-- On mine success
pickSFX:play()

-- On gold find
goldSFX:play()
-- Or layer: if gold then bgm:setRate(1.1) for temp hype, then reset
