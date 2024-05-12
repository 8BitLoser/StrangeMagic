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
    bs.sound.register()
end
event.register(tes3.event.initialized, initialized)

local function registerSpells()
    bs.spell.create({
        id = info.transpose.name,
        name = "Transposition",
        effect = info.transpose.id,
        alwaysSucceeds = true,
        min = 25,
        range = tes3.effectRange.target,
        radius = 10
    })

    bs.spell.create({
        id = info.repair.name,
        name = "Repair Test",
        effect = info.repair.id,
        alwaysSucceeds = true,
        min = 1,
        duration = 8,
        range = tes3.effectRange["self"],
    })

    bs.spell.create({
        id = info.disarm.name,
        name = "Disarm Test",
        effect = info.disarm.id,
        -- alwaysSucceeds = true,
        min = 35,
        -- duration = 0,
        range = tes3.effectRange.target,
    })

    bs.spell.create({
        id = info.stumble.name,
        name = "Stumble Test",
        effect = info.stumble.id,
        radius = 20,
        -- alwaysSucceeds = true,
        min = 1,
        duration = 20,
        range = tes3.effectRange.target,
    })

    bs.spell.create{
        id = info.suffocate.name,
        name = "Suffocate Test",
        effect = info.suffocate.id,
        effect2 = tes3.effect.light,
        min2 = 3,
        duration2 = 3,
        min = 2,
        range = tes3.effectRange.target,
        alwaysSucceeds = true,
        duration = 5,
    }

    bs.spell.create{
        id = info.learn.name,
        name = "Learn Test",
        effect = info.learn.id,
        min = 2,
        range = tes3.effectRange.self,
        alwaysSucceeds = true,
        -- duration = 5,
    }

end
event.register("loaded", registerSpells, {priority = 1})

local function addSpells()
   tes3.addSpell({ reference = tes3.mobilePlayer, spell = info.transpose.name })
   tes3.addSpell({ reference = tes3.mobilePlayer, spell = info.repair.name })
   tes3.addSpell({ reference = tes3.mobilePlayer, spell = info.disarm.name })
   tes3.addSpell({ reference = tes3.mobilePlayer, spell = info.stumble.name })
   tes3.addSpell({ reference = tes3.mobilePlayer, spell = info.suffocate.name })
   tes3.addSpell({ reference = tes3.mobilePlayer, spell = info.learn.name })
   tes3.mobilePlayer:equipMagic { source = info.transpose.name }
end
event.register(tes3.event.loaded, addSpells)

local function onKeyDownI()
    if not tes3.menuMode()then
        



        -- -- log:debug("I Pressed")
        -- local target = bs.rayCast(900)
        -- if not target or not target.mobile then return end

        -- tes3.messageBox("Zap!")
    end
end
event.register("keyDown", onKeyDownI, { filter = tes3.scanCode["i"] })

