local bs = require("BeefStranger.functions")
local info = require("BeefStranger.StrangeMagic.common")

local debug, speed = info.debug, info.magic.speed
local data

local function applySpeed()
    local player = tes3.mobilePlayer
    local base = player.health.base
    if not data.speedActive then
        
        bs.setBase(player, "health", (base - 30), true)
        bs.modCurrent(player, "speed", 175)
        debug("Speed not active, modding stats")
        data.speedActive = true
    elseif data.speedActive then
        bs.setBase(player, "health", (base + 30), true)
        bs.modCurrent(player, "speed", -175)
        debug("Speed active, returning stats")
        data.speedActive = false
    end
end


event.register("loaded", function ()
    tes3.player.data.StrangeMagic = tes3.player.data.StrangeMagic or {}
    data = tes3.player.data.StrangeMagic
    data.speedActive = data.speedActive or false
    
    -- if data.speedActive then
    --     bs.modBase(tes3.mobilePlayer, "health", -30, false)
    -- end
end)

---@param e tes3magicEffectTickEventData
local function speedTick(e)
    bs.onTick(e, function ()


        applySpeed()



    end)
end

bs.keyUp("g", function ()
    debug("baseSpeed - %s", tes3.mobilePlayer.speed.base)
    tes3.mobilePlayer.speed.base = tes3.mobilePlayer.speed.base + 20
end)

event.register("magicEffectsResolved", function ()
    local speedForce = bs.effect.create{
        id = speed.id,
        name = speed.name,
        baseCost = 60,
        school = speed.school,
        canCastTarget = false,
        canCastTouch = false,
        hasNoDuration = true,
        hasNoMagnitude = true,
        allowSpellmaking = false,
        allowEnchanting = false,

        onTick = speedTick
    }
end)