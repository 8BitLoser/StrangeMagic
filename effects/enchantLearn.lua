local info = require("BeefStranger.StrangeMagic.common")
local bs = require("BeefStranger.functions")

-----Not finding how to make actual breath decrease, might need to setup timer that damages when
-----timer is higher than holdBreathTime
bs.debug(true)

local log = info.log
local learn = info.learn

---@param e tes3magicEffectCollisionEventData
local function onLearnCol(e)
    if e.collision then
    end
end


---@param e tes3magicEffectTickEventData
local function onLearnTick(e)
    -- bs.onTick(e, aaaa)
end

local function addEffects()
    bs.effect.create({
        id = learn.id,
        name = "Learn Enchantment Effect",
        school = tes3.magicSchool["mysticism"],

        hitSound = bs.sound.WindBag,

        onCollision = onLearnCol,
        onTick = onLearnTick,
    })
end
event.register("magicEffectsResolved", addEffects)