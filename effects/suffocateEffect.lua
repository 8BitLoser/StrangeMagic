local info = require("BeefStranger.StrangeMagic.common")
local bs = require("BeefStranger.functions")

-----Not finding how to make actual breath decrease, might need to setup timer that damages when
-----timer is higher than holdBreathTime

local log = info.log
local suffocate = info.suffocate

---@param e tes3magicEffectCollisionEventData
local function onSuffocateCol(e)
    if e.collision then
        tes3.messageBox("YO!")
        local ref = e.collision.colliderRef
        log:debug("before holdBreath - %s", ref.mobile.holdBreathTime)
        -- ref.mobile.holdBreathTime = -100
        -- log:debug("after holdBreath - %s", ref.mobile.holdBreathTime)
    end
end

local breathTime = {}

---@param e tes3magicEffectTickEventData
local function onSuffocateTick(e)
    local target = e.effectInstance.target
    local targetBreath

    local breathKey = target.id

    if not breathTime[breathKey] then
        breathTime[breathKey] = target.mobile.holdBreathTime
    end
   
    local function suffocation()
        -- targetBreath = target.mobile.holdBreathTime
        -- targetBreath = target.mobile.holdBreathTime
        log:debug("targetBreath %s", breathTime[breathKey])
        local duration = bs.duration(e, suffocate.id)

        log:debug("duration - %s", duration)
        local iter = 0
        bs.timer { dur = 1, iter = 3, cb = function()
            target.mobile.holdBreathTime = -1
            iter = iter + 1
            target.mobile:applyDamage { damage = 1, playerAttack = false }
            log:debug("timer - %s", iter)
        end }
    end

    if bs.state(e) == tes3.spellState.ending then
        tes3.messageBox("ENDING")
        -- target.mobile.holdBreathTime = targetBreath
        target.mobile.holdBreathTime = breathTime[breathKey]
        log:debug("after targetBreath - %s", breathTime[breathKey])
        log:debug("after holdBreath - %s", target.mobile.holdBreathTime)
    end

    -- log:debug("state = %s", bs.stateId[bs.state(e)])
    bs.onTick(e, suffocation)
end

local function addEffects()
    bs.effect.create({
        id = suffocate.id,
        name = "Suffocate Effect",
        school = tes3.magicSchool["mysticism"],
        hasNoMagnitude = true,
        hitSound = bs.sound.endboom1,

        onCollision = onSuffocateCol,
        onTick = onSuffocateTick,
    })
end
event.register("magicEffectsResolved", addEffects)


local function onKeyDownI()
    if not tes3.menuMode()then
        -- log:debug("I Pressed")
        local target = bs.rayCast(900)
        if not target then return end

        log:debug("before holdBreath - %s", target.mobile.holdBreathTime)

        tes3.messageBox("suffocate")
    end
end
event.register("keyDown", onKeyDownI, { filter = tes3.scanCode["i"] })