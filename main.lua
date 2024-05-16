--=============================Framework/Logging================================--
local bs = require("BeefStranger.functions")
local common = require("BeefStranger.StrangeMagic.common")
local magic = require("BeefStranger.StrangeMagic.common").magic
common.imports() --How to import from common when requiring common on imported files

local log = common.log
local debug, info = log.debug, log.info
--=============================Framework/Logging================================--
local config = require("BeefStranger.StrangeMagic.config")

local function initialized()
    print("[MWSE:StrangeMagic initialized]")
    debug("BeepBoop")
    info("STRANGEMAGIC INFO TEST")
    bs.sound.register()
end

local function registerSpells()

    bs.spell.create { --Added
        id = magic.transpose.spellId,
        name = magic.transpose.spellName,
        effect = magic.transpose.id,
        min = 25,
        range = tes3.effectRange.target,
        radius = 10
    }

    bs.spell.create { --Added
        id = magic.repair.spellId,
        name = magic.repair.spellName,
        effect = magic.repair.id,
        min = 2,
        duration = 5,
        range = tes3.effectRange["self"],
    }

    bs.spell.create { --Added
        id = magic.disarm.spellId,
        name = magic.disarm.spellName,
        effect = magic.disarm.id,
        min = 35,
        range = tes3.effectRange.target,
    }

    bs.spell.create { --Added
        id = magic.stumble.spellId,
        name = magic.stumble.spellName,
        effect = magic.stumble.id,
        radius = 20,
        min = 1,
        duration = 20,
        range = tes3.effectRange.target,
    }

    bs.spell.create { --Added
        id = magic.learn.spellId,
        name = magic.learn.spellName,
        effect = magic.learn.id,
        range = tes3.effectRange.self,
        cost = bs.lerp(100, 5, 90, tes3.mobilePlayer.enchant.current, false),
        duration = 0
    }

    bs.spell.create{
        id = magic.steal.spellId,
        name = magic.steal.spellName,
        effect = magic.steal.id,
        range = tes3.effectRange.target,
        alwaysSucceeds = true,
        cost = 0,
        duration = 1,
    }
end
event.register("loaded", registerSpells, { priority = 1 })

local function addSpells()
    common.distributeSpells()

    ---------Debug----------
    bs.addSpell(tes3.player, magic.steal.spellId)
    -- tes3.mobilePlayer:equipMagic{source = magic.steal.spellId}
    bs.equipMagic(magic.steal.spellId)
end
event.register(tes3.event.loaded, addSpells)


bs.keyUp("p", function()
   local target = bs.rayCast(900)
   if not target then return end
   debug("`npc` NPC = %s", bs.typeCheck(target, "npc", true))
   debug("tes3.objectType.npc NPC = %s", bs.typeCheck(target, tes3.objectType.npc))
end)

bs.keyUp("i", function ()
    local target = bs.rayCast(900) 
    tes3.messageBox("I Pressed")
    debug("[1] - %s", target.object.inventory)
    tes3.mobilePlayer:exerciseSkill(tes3.skill.enchant, 100)
    bs.bulkAddSpells(tes3.player, magic) ---Add all spells to player
end)

event.register(tes3.event.initialized, initialized)