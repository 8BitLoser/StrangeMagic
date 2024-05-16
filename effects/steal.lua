local bs = require("BeefStranger.functions")
local info = require("BeefStranger.StrangeMagic.common")

local log = info.log
local debug = log.debug
local steal = info.magic.steal --Experimenting with centralized effect list
local inspect = require("inspect").inspect

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
                local rand = math.random(100)
                local stealChance = (playerLuck / (value )) * 10

                -- debug("%s - %sG", name, value)
                if  stealChance > rand then
                    tes3.messageBox("%s stolen from %s", name, target.object.name)
                    debug("%s - %s Stolen %sG, chance = %d/%s",i, name, value, stealChance, rand)
                    ---Add crime trigger
                    tes3.transferItem{from = target, to = tes3.mobilePlayer, item = item}
                    break
                elseif i >= 5 then
                    tes3.messageBox("Failed to steal anything")
                    ---maybe crime trigger here aswell
                    break
                else
                    debug("%s Failed to steal %d/%d", i, stealChance, rand)
                end
            end
        end
    end
    bs.onTick(e, stealAction)
end

local function addEffects()
    local bsSteal = bs.effect.create({
        id = steal.id,
        name = steal.name,
        school = steal.school,

        baseCost = 10,
        speed = 10,

        -- hasContinuousVFX = false,
        allowSpellmaking = true,
        hasNoMagnitude = true,
        hasNoDuration = true,
        canCastSelf = false,

        onTick = stealTick
        -- onCollision = onTranspose
    })
end
event.register("magicEffectsResolved", addEffects)