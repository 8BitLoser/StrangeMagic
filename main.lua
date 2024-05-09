--=============================Config/Logging================================--
-- local config = require("BeefStranger.Magical Repairing.config")
local logger = require("logging.logger")
local log = logger.new { name = "StrangeMagic", logLevel = "DEBUG", logToConsole = true, }
-- if config.debug then log:setLogLevel("DEBUG") end
-- local log = require("BeefStranger.StrangeMagic.common").log
--=============================Config/Logging================================--
local info = require("BeefStranger.StrangeMagic.common")
local imports = info.imports() --How to import from common when requiring common on imported files
local bs = require("BeefStranger.functions")

local function initialized()

    print("[MWSE:StrangeMagic initialized]")
end
event.register(tes3.event.initialized, initialized)

local function registerSpells()
    bs.spell.create({
        id = "bsTranspose",
        name = "Transposistion",
        effect = info.transpose.id,
        alwaysSucceeds = true,
        min = 25,
        range = tes3.effectRange.target,
        radius = 10
    })

    bs.spell.create({
        id = "bsRepair",
        name = "Repair",
        effect = info.repair.id,
        alwaysSucceeds = true,
        min = 1,
        duration = 8,
        range = tes3.effectRange["self"],
    })

    bs.spell.create({
        id = "bsDisarm",
        name = "Disarm Test",
        effect = info.disarm.id,
        -- alwaysSucceeds = true,
        min = 35,
        -- duration = 0,
        range = tes3.effectRange.target,
    })

    bs.spell.create({
        id = "stumbleEffect",
        name = "Stumble Test",
        effect = info.stumble.id,
        radius = 20,
        -- alwaysSucceeds = true,
        min = 1,
        duration = 20,
        range = tes3.effectRange.target,
    })

    bs.spell.create{
        id = "gravity",
        name = "Gravity Test",
        effect = info.gravity.id,
        min = 1,
        range = tes3.effectRange.target
    }

end
event.register("loaded", registerSpells, {priority = 1})

local function addSpells()
   tes3.addSpell({ reference = tes3.mobilePlayer, spell = "bsTranspose" })
   tes3.addSpell({ reference = tes3.mobilePlayer, spell = "bsRepair" })
   tes3.addSpell({ reference = tes3.mobilePlayer, spell = "bsDisarm" })
   tes3.addSpell({ reference = tes3.mobilePlayer, spell = "stumbleEffect" })
   tes3.addSpell({ reference = tes3.mobilePlayer, spell = "gravity" })
   tes3.mobilePlayer:equipMagic { source = "gravity" }
end
event.register(tes3.event.loaded, addSpells)

local function onKeyDownI()
    if not tes3.menuMode()then
        -- log:debug("I Pressed")
        local target = bs.rayCast(900)
        if not target or not target.mobile then return end

        tes3.messageBox("Zap!")
    end
end

event.register("keyDown", onKeyDownI, { filter = tes3.scanCode["i"] })

