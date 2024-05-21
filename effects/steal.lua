local bs = require("BeefStranger.functions")
local info = require("BeefStranger.StrangeMagic.common")

local log = info.log
local debug = log.debug
local steal = info.magic.steal --Experimenting with centralized effect list
local inspect = require("inspect").inspect
local config, luckImpact, valueImpact = require("BeefStranger.StrangeMagic.config") ---get config and setup placeholder a, b

local function stealCalc(luck, value) ---CHECK TARGET LUCK TOO MAYBE
    luckImpact = config.luckImpact or 0.035 ---Luck impact
    valueImpact = config.valueImpact  or 0.40 ---Impact of value
    local exponent = -(luckImpact * (luck - valueImpact * value))
    local chance = 1 / (1 + math.exp(exponent))
debug("luckImpact = %s, valueImpact = %s", luckImpact, valueImpact)
    return chance
end

---@param e tes3magicEffectTickEventData
local function stealTick(e)
    local target = e.effectInstance.target
    local playerLuck = tes3.mobilePlayer.luck.current
    local function stealAction()
        local shuffledInv = bs.shuffleInv(target.object.inventory)
        if bs.typeCheck(target, "npc") then
            for i, stack in pairs(shuffledInv) do
                local item = stack.object 
                local name, value = item.name, item.value
                local rand = math.random(100) -- used for clothes and crime on fail checks

                local roll = math.random() + 0.05
                local chance = math.max(0.05 ,stealCalc(playerLuck, value))
debug("clothing = %s", bs.typeCheck(item, tes3.objectType.clothing, true))

debug("luck = %d, value = %d, exponent = %.2f, chance = %.2f, roll = %.2f", playerLuck, value, -(luckImpact * (playerLuck - valueImpact * value)), chance, roll)

                if roll < chance then --dont take clothes pervert

                    if bs.typeCheck(item, "clothing") and rand > 10 then
debug("Clothes chance fail")
                        bs.msg("DEBUG: Clothes chance fail")
                        break
                    end

                    bs.msg("%s stolen from %s", name, target.object.name)
debug("%s - %s Stolen %sG, chance = %.2f / roll = %.2f",i, name, value, chance, roll)
                    tes3.transferItem{from = target, to = tes3.mobilePlayer, item = item}
                    tes3.triggerCrime{type = tes3.crimeType["pickpocket"], victim = target.object}
                    break
                else
                    bs.msg("Failed to steal anything")
debug("%s Failed to steal %sG %d/%d", i, value, chance, roll)

                    if rand < 10 then
                        tes3.triggerCrime{type = tes3.crimeType["pickpocket"], victim = target.object}
                        bs.msg("%s noticed your attempt!", target.object.name)
                    end

                    break
                end
            end
        end
    end
    bs.onTick(e, stealAction)
end

event.register("magicEffectsResolved", function()
    bs.effect.create({
        id = steal.id,
        name = steal.name,
        school = steal.school,
        description = "Test your Luck.",

        baseCost = 10,
        speed = 1,

        hasNoMagnitude = true,
        hasNoDuration = true,
        canCastSelf = false,

        onTick = stealTick
    })
end)