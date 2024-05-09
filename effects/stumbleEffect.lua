local bs = require("BeefStranger.functions")
-- local logger = require("logging.logger")
-- local info = require("BeefStranger.StrangeMagic.common") --Experimenting with centralized effect list
local log = require("BeefStranger.StrangeMagic.common").log
local stumble = require("BeefStranger.StrangeMagic.common").stumble



-- local log = info.log
-- local stumble = info.stumble

-- tes3.claimSpellEffectId(stumble.name, stumble.reg)
-- math.randomseed(os.time())

---@param e tes3magicEffectTickEventData
local function stumbleTick(e)
    local function stumbleTimer()
        local target = e.effectInstance.target
        local duration = bs.getEffect(e, stumble.id) and math.max(1, bs.getEffect(e, stumble.id).duration) or 1
        local iter = duration
        log:debug("timer - %s/%s", iter, duration)

        local function stun()
            iter = iter - 1
            log:debug("timer - %s/%s - knockDown %s", iter, duration, target.mobile.isKnockedDown)

            local rando = math.random() < .60

            log:debug("%s", rando)

            if not target.mobile.isKnockedDown and rando then
                tes3.removeSound{sound = bs.sound.Sixth_Bell}
                tes3.playSound{ sound = bs.sound.Sixth_Bell, pitch = 0.3, volume = .85}

                target.mobile:hitStun({knockDown = true})
            end
        end
        bs.timer{dur = 1, cb = stun, iter = duration}
    end
    bs.onTick(e, stumbleTimer)
end


local function addEffects()
    local stumbleEffect = bs.effect.create({
        id = stumble.id,
        name = "Stumble Effect",
        school = tes3.magicSchool.illusion,
        hasNoMagnitude = true,
        hitSound = bs.sound.endboom1,

        onTick = stumbleTick,
    })
end
event.register("magicEffectsResolved", addEffects)