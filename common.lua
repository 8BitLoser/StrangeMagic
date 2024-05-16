local bs = require("BeefStranger.functions")
local common = {}

function common.imports()
    return
    require("BeefStranger.StrangeMagic.effects.disarmTrapEffect"),
    require("BeefStranger.StrangeMagic.effects.repairEffect"),
    require("BeefStranger.StrangeMagic.effects.stumbleEffect"),
    require("BeefStranger.StrangeMagic.effects.transposeEffect"),
    require("BeefStranger.StrangeMagic.effects.enchantLearn"),
    require("BeefStranger.StrangeMagic.effects.steal")
end



bs.createLog("StrangeMagic")
common.log = bs.getLog("StrangeMagic")
local log = common.log

--- Just a shorthand for log.debug()
--
---     local debug = common.debug
-- function common.debug(...)
--     common.log:debug(...)
-- end
---@enum magic 
common.magic = {
    repair = {
        name = "repairEffect",
        id = 23331,
        spellName = "Repair Equipment",
        spellId = "repairSpell",
        seller = "tanar llervi", --Ald-ruhn mages guild
        school = tes3.magicSchool["alteration"]
    },
    disarm = {
        name = "disarmEffect",
        id = 23332,
        spellName = "Disarm",
        spellId = "disarmSpell",
        seller = "eraamion",
        school = tes3.magicSchool["alteration"]
    },
    transpose = {
        name = "transposeEffect",
        id = 23333,
        spellName = "Transposition",
        spellId = "transposeSpell",
        seller = "gildan",
        school = tes3.magicSchool["mysticism"]
    },
    stumble = {
        name = "stumbleEffect",
        id = 23334,
        spellName = "Stumble",
        spellId = "stumbleSpell",
        seller = "sirilonwe",
        school = tes3.magicSchool["illusion"]
    },
    learn = {
        name = "enchantLearn",
        id = 23335,
        spellName = "Deconstruct Enchant",
        spellId = "learnSpell",
        seller = "galbedir",
        school = tes3.magicSchool["mysticism"]
    },
    steal = {
        name = "stealEffect",
        id = 23336,
        spellName = "Steal",
        spellId = "stealSpell",
        seller = "fargoth",
        school = tes3.magicSchool["illusion"]

    }
}

local magic = common.magic

function common.distributeSpells()
    for key, spellInfo in pairs(magic) do
        if tes3.hasSpell{reference = spellInfo.seller, spell = spellInfo.spellId} then
            log:debug("%s has %s", spellInfo.seller, spellInfo.spellId)
            -- break
        else
            log:debug("Adding %s to %s", spellInfo.spellId, spellInfo.seller)
            bs.sellSpell(spellInfo.seller, spellInfo.spellId)
        end
    end
end

function common.claimEffects()
    for key, effects in pairs(magic) do
        tes3.claimSpellEffectId(effects.name, effects.id)
    end
end

common.claimEffects()

return common