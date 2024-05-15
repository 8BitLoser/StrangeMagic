local bs = require("BeefStranger.functions")
local info = require("BeefStranger.StrangeMagic.common")

local debug = info.debug
local stumble = info.magic.stumble

---@param e tes3magicEffectTickEventData
local function stumbleTick(e)
    local du = bs.duration(e, 241)
    local function stumbleTimer()
        local target = e.effectInstance.target
        local duration = bs.getEffect(e, stumble.id) and math.max(1, bs.getEffect(e, stumble.id).duration) or 1
        local iter = duration
        debug("timer - %s/%s", iter, duration)

        local function stun()
            iter = iter - 1
            debug("timer - %s/%s - knockDown %s", iter, duration, target.mobile.isKnockedDown)

            local rando = math.random() < .60

            debug("%s", rando)

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
        school = tes3.magicSchool["illusion"],
        hasNoMagnitude = true,
        hitSound = bs.sound.endboom1,
        baseCost = 5,

        allowSpellmaking = true,
        onTick = stumbleTick,
    })
end
event.register("magicEffectsResolved", addEffects)