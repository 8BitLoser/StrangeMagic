--=============================Config/Logging================================--
-- local config = require("BeefStranger.Magical Repairing.config")
local logger = require("logging.logger")
local log = logger.new { name = "StrangeMagic", logLevel = "DEBUG", logToConsole = true, }
-- if config.debug then log:setLogLevel("DEBUG") end
-- local log = require("BeefStranger.StrangeMagic.common").log
--=============================Config/Logging================================--
-- require("BeefStranger.StrangeMagic.common")

require("BeefStranger.StrangeMagic.effects.disarmTrapEffect")
require("BeefStranger.StrangeMagic.effects.repairEffect")
require("BeefStranger.StrangeMagic.effects.stumbleEffect")
require("BeefStranger.StrangeMagic.effects.transposeEffect")

local bs = require("BeefStranger.functions")
local spellMaker = require("BeefStranger.spellMaker")

local function initialized()
    print("[MWSE:StrangeMagic initialized]")
end
event.register(tes3.event.initialized, initialized)

local function registerSpells()
    spellMaker.create({
        id = "bsTranspose",
        name = "Transposistion",
        effect = tes3.effect.bsTranspose,
        alwaysSucceeds = true,
        min = 25,
        range = tes3.effectRange.target,
        radius = 10
    })

    spellMaker.create({
        id = "bsRepair",
        name = "Repair",
        effect = tes3.effect.repairEffect,
        alwaysSucceeds = true,
        min = 1,
        duration = 8,
        range = tes3.effectRange["self"],
    })

    spellMaker.create({
        id = "bsDisarm",
        name = "Disarm Test",
        effect = tes3.effect.bsDisarm,
        -- alwaysSucceeds = true,
        min = 35,
        -- duration = 0,
        range = tes3.effectRange.target,
    })

end
event.register("loaded", registerSpells, {priority = 1})

local function addSpells()
   tes3.addSpell({ reference = tes3.mobilePlayer, spell = "bsTranspose" })
   tes3.addSpell({ reference = tes3.mobilePlayer, spell = "bsRepair" })
   tes3.addSpell({ reference = tes3.mobilePlayer, spell = "bsDisarm" })
   tes3.mobilePlayer:equipMagic { source = "bsDisarm" }
end
event.register(tes3.event.loaded, addSpells)

local function onKeyDownI()
    if not tes3.menuMode()then
        -- log:debug("I Pressed")
        local target = bs.rayCast(900)
        if not target or not target.mobile then return end
        local saveWeap

        if target.mobile.readiedWeapon and target.mobile.readiedWeapon.object then
            saveWeap = target.mobile.readiedWeapon.object
            local iter = 0

            tes3.removeItem{reference = target, item = saveWeap}
            log:debug("remove %s from %s: starting 10s timer", saveWeap, target)
            ---for testing, better to just do (10, 1, function)
            local itemTimer = bs.timer(1, 10, function()

                iter = iter + 1

                log:debug("%s", iter)

                if iter == 10 then
                    tes3.addItem{reference = target, item = saveWeap}
                    log:debug("Re-add %s to %s", saveWeap, target)
                end
            end)
        end

        -- mobile:unequip({type = tes3.objectType.weapon})

        -- toggleWeapon(target)

        -- target.mobile:hitStun({knockDown = true})
        tes3.messageBox("Zap!")

        -- local typeName = bs.objectTypeNames[target.mobile.object.objectType] or "Unknown Type"
        -- log:debug("%s, tes3.objectType.%s", target.mobile.object.id, typeName)
        -- log:debug("%s, %s", target.mobile.object.name, target.mobile. readiedWeapon and target.mobile.readiedWeapon.object or "no weapon")
        -- log:debug("%s trap %s, locked %s, trapNode %s", target.object.name, target.lockNode.trap, target.lockNode.locked, target.lockNode)
        -- log:debug("objectFaction %s, playerFaction %s",target.object.faction[1].name, tes3.player.object.faction)

    end
end

event.register("keyDown", onKeyDownI, { filter = tes3.scanCode["i"] })

