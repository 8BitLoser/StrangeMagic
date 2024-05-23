--=============================Framework/Logging================================--
local bs = require("BeefStranger.functions")
local common = require("BeefStranger.StrangeMagic.common")
local magic = require("BeefStranger.StrangeMagic.common").magic

-- common.imports() --How to import from common when requiring common on imported files

bs.importDir("BeefStranger.StrangeMagic.effects")

local inspect = require("inspect").inspect



local log = bs.getLog("StrangeMagic")
local debug, info = log.debug, log.info
--=============================Framework/Logging================================--
local config = require("BeefStranger.StrangeMagic.config")

local function initialized()
    print("[MWSE:StrangeMagic initialized]")
    debug("BeepBoop")
    info("STRANGEMAGIC INFO TEST")
    bs.sound.register()
end

-- event.register("loaded", function ()
--     magic.learn.spell.cost = bs.lerp(100, 5, 90, tes3.mobilePlayer.enchant.current, false)
-- end, {priority = 2})

local function registerSpells()

    --Setting learn cost here, because it needs mobilePlayer to be loaded to calculate
    magic.learn.spell.cost = bs.lerp(100, 5, 90, tes3.mobilePlayer.enchant.current, false)

    bs.spell.create(magic.blink.spell)
    bs.spell.create(magic.disarm.spell)
    bs.spell.create(magic.learn.spell)
    bs.spell.create(magic.repair.spell)
    bs.spell.create(magic.speed.spell)
    bs.spell.create(magic.steal.spell)
    bs.spell.create(magic.stumble.spell)
    bs.spell.create(magic.transpose.spell)
 
end
event.register("loaded", registerSpells, { priority = 1 })

local function addSpells()
    common.distributeSpells()

    ---------Debug----------
    -- bs.addSpell(tes3.player, magic.speed.spell.id)
    -- tes3.mobilePlayer:equipMagic{source = magic.steal.spellId}
    -- bs.equipMagic(magic.steal.spellId)
    ------------------------
end
event.register(tes3.event.loaded, addSpells)

bs.keyUp("b", function ()
    tes3.showSpellmakingMenu{serviceActor = tes3.player}
end)

bs.keyUp(".", function ()
    
end)

bs.keyUp("i", function ()
    local target = bs.rayCast(900)
    if target and target.object then
        debug("%s - %s", target.object.name, bs.objectTypeNames[target.object.objectType])
        bs.msg("%s - %s", target.object.name, bs.objectTypeNames[target.object.objectType])
    end
end)


bs.keyUp("o", function ()
    debug("%s", inspect(config))
    bs.bulkAddSpells(tes3.player, magic) ---Add all spells to player

    for _, spells in pairs(magic) do
        bs.refreshSpell(tes3.player, spells.spell.id)
    end

end)

event.register(tes3.event.initialized, initialized)