local bs = require("BeefStranger.functions")
local info = require("BeefStranger.StrangeMagic.common")

local disarm = info.magic.disarm
local debug = info.debug



local function vfx(target, isSuccess) --Function to handle vfx/sound, false = failed
    local sound = isSuccess and "Disarm Trap" or "Disarm Trap Fail"

    tes3.playSound({ sound = sound })      --Play disarm/fail sound
    tes3.playSound({ sound = "alteration hit", volume = 0.75 }) --Play hit sound at a lower volume
    bs.glowFX(target, disarm.id)
end

---@param target tes3reference
local function disarmEffect(target, disarmMag) --Shoved into a function to make it work for Touch spells too, hopefully it doesnt break anything
    if target.object.objectType == tes3.objectType.container or target.object.objectType == tes3.objectType.door then
        local owner = target.itemData and target.itemData.owner
        local trap = target.lockNode.trap
        local disarmChance

        if trap and trap.effects then
           -- debug("trap - %s", trap.name)
            local totalTrapMag = 0
            for i, effect in ipairs(trap.effects) do                --For every effect in the trap spell, set effect to it. (not sure any vanilla one has more than 1 effect, but checking anyway)
                if effect and effect.max > 0 then                   --If an effect is found and that effect has a magnitude higher than 0
                    local effectiveMag = bs.effect.getMag(effect) --Set effectiveMag to the calculated eMag (the getMag function becuase the built in way doesnt work without e:triggers and theres no trigger on collisions)
                    local trapDuration = effect.duration            --Grab the effects duration to add to calc

                    totalTrapMag = (totalTrapMag + effectiveMag) --Add the value of every effect to totalTrapMag (The for loop goes through each, so this is done the same amount of times as there is effects)
                    disarmChance = (totalTrapMag + (trapDuration * 0.25) + (target.lockNode.level * 0.25))  --Disarm chance = TotalMags + 25% of Duration + 25% of lock level
                  --  debug("Trap: %d, trapMag: %s, trapDur: %s, Lock Level: %s", i, effectiveMag, trapDuration, (target.lockNode.level * 0.25))
                end
            end
           debug("disarmMag = %s, disarmChance: %s", disarmMag, disarmChance)
            if disarmMag >= disarmChance then
                tes3.setTrap({ reference = target, spell = nil })
                
                if tes3.hasOwnershipAccess{reference = tes3.player, target = target} == false then
                    tes3.triggerCrime{type = tes3.crimeType.trespass, victim = owner}
                end

                tes3.game:clearTarget()                        --Update tooltip
                vfx(target, true) --vfx function
            else
                vfx(target, false)
            end
        else
            vfx(target, false)
        end
    end
end


---@param e tes3magicEffectCollisionEventData
local function onDisarmCollision(e)
    if e.collision then
        local target = e.collision.colliderRef

        -- debug("%s", target.mobile.object.name)

        --Get disarm mag even if its in a custom spell
        local complexMag = bs.effect.getComplexMag(e, disarm.id)
        local magTimer = (complexMag / 10)

        if target.mobile and target.mobile.readiedWeapon then
            local saveWeap = target.mobile.readiedWeapon.object

            tes3.removeItem { reference = target, item = saveWeap }
            debug("remove %s from %s: starting %ss timer", saveWeap, target, magTimer)

            bs.timer{dur = magTimer, cb = function()
                tes3.addItem { reference = target, item = saveWeap }
                debug("Re-add %s to %s", saveWeap, target)
            end}
        end
        disarmEffect(target, complexMag)
    end
end

--- @param e spellCastedEventData
local function onDisarmTouch(e)
    local touchTarget = tes3.getPlayerTarget()

    local touchMag

    if touchTarget == nil then return end

    for _, effects in ipairs(e.source.effects) do
        if effects.id == disarm.id then
            if effects.rangeType == tes3.effectRange.touch then
                touchMag = bs.effect.getMag(effects)

                --debug("touchMag = %s", touchMag)
                disarmEffect(touchTarget, touchMag)
            end
        end
    end
end
event.register(tes3.event.spellCasted, onDisarmTouch)

local function addEffects()
    local effectMakerDisarm = bs.effect.create({
        id = disarm.id,
        name = "Disarm Effect",
        school = disarm.school,
        baseCost = 10,

        hasContinuousVFX = true,

        allowSpellmaking = true,
        hasNoDuration = true,
        hitSound = bs.bsSound.bashImpact,

        canCastTouch = true,
        canCastSelf = false,
        canCastTarget = true,
        lighting = {0.831, 0.22, 0.831},

        casterLinked = false,

        onCollision = onDisarmCollision
    })
end
event.register("magicEffectsResolved", addEffects)