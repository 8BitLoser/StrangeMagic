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

bs.onLoad(function ()
    tes3.player.data.StrangeMagic = tes3.player.data.StrangeMagic or {}
    data = tes3.player.data.StrangeMagic
    data.speedActive = data.speedActive or false
--     local health = tes3.mobilePlayer.health
--     local base = health.base

--     -- if data.speedActive then
--     --     local activeSpeed = base - 30
--     --     tes3.setStatistic{reference = tes3.mobilePlayer, "health", base = activeSpeed }
--     --     bs.setBase(tes3.mobilePlayer, "health", activeSpeed, false)
--     -- end

--     debug("health loaded base - %s, adjust - %s", base , (base - 30))

--     bs.timer{dur = 1, iter = 1, cb = function ()
--         debug("delay done")
--         tes3.setStatistic({reference = tes3.mobilePlayer, name = "health", value = 16 })
--     end}

    -- debug("base - %s", base)
    -- debug("baseRaw - %s", tes3.mobilePlayer.health.baseRaw)
    -- debug("current - %s", tes3.mobilePlayer.health.current)
    -- debug("currentRaw - %s", tes3.mobilePlayer.health.currentRaw)
    -- debug("normalized - %s", tes3.mobilePlayer.health.normalized)

    -- bs.timer{dur = 0.1, iter = -1, cb = function ()
    --     local player = tes3.mobilePlayer
    --     local base = player.health.base
    --     debug("Timer -- base - %s, adjust - %s", base , (base - 30))
    -- end}


end, 5)


event.register("loaded", function ()
    if data.speedActive then
        debug("SpeedActive - lowering health")

    end
end, {priority = 1})

---@param e tes3magicEffectTickEventData
local function speedTick(e)
    -- bs.onTick(e, function ()
    --     applySpeed()
    -- end)
end

bs.keyUp("g", function ()
    tes3.setStatistic({reference = tes3.mobilePlayer, name = "health", value = 13 })
    debug("base - %s", tes3.mobilePlayer.health.base)
    debug("baseRaw - %s", tes3.mobilePlayer.health.baseRaw)
    debug("current - %s", tes3.mobilePlayer.health.current)
    debug("currentRaw - %s", tes3.mobilePlayer.health.currentRaw)
    debug("normalized - %s", tes3.mobilePlayer.health.normalized)

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