local bs = require("BeefStranger.functions")
local effectMaker = require("BeefStranger.effectMaker")
local logger = require("logging.logger")
local log = logger.getLogger("StrangeMagic") or "Logger Not Found"

local disarmID = 23334

tes3.claimSpellEffectId("bsDisarm", disarmID)

---@param target tes3reference
local function disarmEffect(target, disarmMag) --Shoved into a function to make it work for Touch spells too, hopefully it doesnt break anything
    if target.object.objectType == tes3.objectType.container or target.object.objectType == tes3.objectType.door then
        local trap = target.lockNode.trap
        local disarmChance

        if trap and trap.effects then
           -- log:debug("trap - %s", trap.name)
            local totalTrapMag = 0
            for i, effect in ipairs(trap.effects) do                --For every effect in the trap spell, set effect to it. (not sure any vanilla one has more than 1 effect, but check anyway)
                if effect and effect.max > 0 then                   --If an effect is found and that effect has a magnitude higher than 0
                    local effectiveMag = effectMaker.getMag(effect) --Set effectiveMag to the calculated eMag (the getMag function becuase the built in way doesnt work without e:triggers and theres no trigger on collisions)
                    local trapDuration = effect.duration            --Grab the effects duration to add to calc

                    totalTrapMag = (totalTrapMag + effectiveMag) --Add the value of every effect to totalTrapMag (The for loop goes through each, so this is done the same amount of times as there is effects)
                    disarmChance = (totalTrapMag + (trapDuration * 0.25) + (target.lockNode.level * 0.25))  --Disarm chance = TotalMags + 25% of Duration + 25% of lock level
                  --  log:debug("Trap: %d, trapMag: %s, trapDur: %s, Lock Level: %s", i, effectiveMag, trapDuration, (target.lockNode.level * 0.25))
                end
            end
           -- log:debug("disarmMag = %s, disarmChance: %s", disarmMag, disarmChance)
            if disarmMag >= disarmChance then
                tes3.setTrap({ reference = target, spell = nil })
                tes3.game:clearTarget()                        --Update tooltip
                tes3.playSound({ sound = "Disarm Trap" })      --Play disarm sound
                tes3.playSound({ sound = "alteration hit", volume = 0.75 })

                tes3.createVisualEffect({ lifespan = 1, reference = target, magicEffectId = disarmID, }) --Play the effects ve on the target
            else
                tes3.createVisualEffect({ lifespan = 1, reference = target, magicEffectId = disarmID, })
                tes3.playSound({ sound = "Disarm Trap Fail" }) --Play fail sound on fail
                tes3.playSound({ sound = "alteration hit", volume = 0.75 })
            end
        end
    end
end


---@param e tes3magicEffectCollisionEventData
local function onDisarmCollision(e)
    if e.collision then
        local target = e.collision.colliderRef
        -- local disarmMag
        
        --Get disarm mag even if its in a custom spell
        local complexMag = effectMaker.getComplexMag(e, disarmID)

        log:debug("FUNCTION complexMag = %s", complexMag)

        
        -- for _, effects in ipairs(e.sourceInstance.sourceEffects) do
        --     if effects.id == tes3.effect.bsDisarm then
        --         disarmMag = effectMaker.getMag(effects) -- set disarmMag to bsDisarms effectiveMag
        --         log:debug("FOR DisarmMag - %s", disarmMag)
        --     end
        -- end
        disarmEffect(target, complexMag)
    end
end

--- @param e spellCastedEventData
local function onDisarmTouch(e)
    local touchTarget = tes3.getPlayerTarget()

    local touchMag

    if touchTarget == nil then return end

    for _, effects in ipairs(e.source.effects) do
        if effects.id == tes3.effect.bsDisarm then
            if effects.rangeType == tes3.effectRange.touch then
                touchMag = effectMaker.getMag(effects)

                --log:debug("touchMag = %s", touchMag)
                disarmEffect(touchTarget, touchMag)
            end
        end
    end
end
event.register(tes3.event.spellCasted, onDisarmTouch)

local function addEffects()
    local bsDisarm = effectMaker.create({
        id = tes3.effect.bsDisarm,
        name = "Disarm Effect",
        school = tes3.magicSchool["alteration"],
        baseCost = 15,

        hasContinuousVFX = true,

        allowSpellmaking = true,
        hasNoDuration = true,

        canCastTouch = true,
        canCastSelf = false,
        canCastTarget = true,
        lighting = {0.831, 0.22, 0.831},

        casterLinked = false,

        onCollision = onDisarmCollision
    })
end
event.register("magicEffectsResolved", addEffects)