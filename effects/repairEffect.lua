local bs = require("BeefStranger.functions")
local effectMaker = require("BeefStranger.effectMaker")
local logger = require("logging.logger")
local log = logger.getLogger("StrangeMagic") or "Logger Not Found"

tes3.claimSpellEffectId("repairEffect", 23331)

--Greatness7
local slotPriorities = {
    tes3.armorSlot.shield,
    tes3.armorSlot.cuirass,
    tes3.armorSlot.leftPauldron,
    tes3.armorSlot.rightPauldron,
    tes3.armorSlot.leftBracer,
    tes3.armorSlot.rightBracer,
    tes3.armorSlot.leftGauntlet,
    tes3.armorSlot.rightGauntlet,
    tes3.armorSlot.helmet,
    tes3.armorSlot.greaves,
    tes3.armorSlot.boots,
}
local function addEffects()
    local repairEffect = effectMaker.create({
        id = tes3.effect.repairEffect,
        name = "Repair Effect",
        school = tes3.magicSchool.alteration,

        baseCost = 1,

        allowSpellmaking = true,

        onTick = function (e)
            if e.effectInstance.state == tes3.spellState.working then e:trigger() return end

            -- log:debug("state = %s", e.effectInstance.state)
            -- log:debug("duration - %s", e.sourceInstance.sourceEffects[1].duration)


            local startArmor = false
            if e.effectInstance.state == tes3.spellState["beginning"] then
                e:trigger() e:trigger()

                local eWeap = tes3.getEquippedItem({actor = tes3.player, objectType = tes3.objectType.weapon})
                --------------------------------------debug------------------------------------------------------
                -- log:debug("target = %s", e.effectInstance.target.object.name)
                -- local mag = e.effectInstance.effectiveMagnitude
                -- local duration = e.sourceInstance.sourceEffects[1].duration or 1
                -- log:debug("mag -%s, dur - %s, tDur -%s, iter - %s",mag, duration, 1/ duration, duration * mag)
                -------------------------------------------------------------------------------------------------
                if eWeap then
                    -- log:debug("mag = %s",e.effectInstance.effectiveMagnitude)
                    bs.effectTimer(e, function()
                        eWeap.itemData.condition = math.min(eWeap.itemData.condition + 1, eWeap.object.maxCondition)
                        log:debug("eWeap - %s, c - %s, mC = %s", eWeap.object.name, eWeap.itemData.condition + 1, eWeap.object.maxCondition)
                    end)

                    if eWeap.itemData.condition >= eWeap.object.maxCondition then
                        startArmor = true
                    end
                else startArmor = true
                end

                -- log:debug("startArmor - %s", startArmor)

                if startArmor then
                    for i, slot in ipairs(slotPriorities) do
                        local armor = tes3.getEquippedItem({
                            actor = tes3.player,
                            objectType = tes3.objectType.armor,
                            slot = slot,
                        })
                        if armor and armor.itemData.condition < armor.object.maxCondition then
                            --------------------------------------Debug-------------------------------------
                            -- local condition = armor.itemData.condition     --Get items condition
                            -- local maxCondition = armor.object.maxCondition --Get items max condition
                            -- log:debug("stack = %s, c - %s, mC - %s", armor.object.name, condition, maxCondition)
                            --------------------------------------------------------------------------------
                            bs.effectTimer(e, function()
                                -- log:debug("i - %s", i)
                                armor.itemData.condition = math.min(armor.itemData.condition + 1, armor.object.maxCondition)
                                log:debug("armor - %s, c - %s, mC = %s", armor.object.name, armor.itemData.condition, armor.object.maxCondition)
                            end)
                            break
                        end
                    end
                end
            end

            if e.effectInstance.state == tes3.spellState.ending then
                e.effectInstance.state = tes3.spellState.retired
                -- log:debug("ending")
            end
        end
    })
end
event.register("magicEffectsResolved", addEffects)
