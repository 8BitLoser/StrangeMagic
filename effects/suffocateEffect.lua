local info = require("BeefStranger.StrangeMagic.common")
local bs = require("BeefStranger.functions")

-----Not finding how to make actual breath decrease, might need to setup timer that damages when
-----timer is higher than holdBreathTime
bs.debug(true)

local log = info.log
local suffocate = info.magic.suffocate

---@param e tes3magicEffectCollisionEventData
local function onSuffocateCol(e)
    if e.collision then
    end
end

---@param e tes3magicEffectTickEventData
local function onSuffocateTick(e)
    local target = e.effectInstance.target
    local function suffocation()
        bs.effectTimer(e, function()
            target.mobile:applyDamage { damage = 1, playerAttack = true }
        end)
    end
    bs.onTick(e, suffocation)
end

local function addEffects()
    bs.effect.create({
        id = suffocate.id,
        name = "Suffocate Effect",
        school = tes3.magicSchool["mysticism"],
        hasNoMagnitude = false,
        hitSound = bs.sound.WindBag,
        baseCost = 5,

        onCollision = onSuffocateCol,
        onTick = onSuffocateTick,
    })
end
event.register("magicEffectsResolved", addEffects)


-- local function onKeyDownI()
--     if not tes3.menuMode()then
--         -- log:debug("I Pressed")
--         local target = bs.rayCast(900)
--         if not target then return end

--         tes3.messageBox("suffocate")
--     end
-- end
-- event.register("keyDown", onKeyDownI, { filter = tes3.scanCode["i"] })
