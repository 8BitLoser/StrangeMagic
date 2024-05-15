local bs = require("BeefStranger.functions")
local common = {}

function common.imports()
    return
    require("BeefStranger.StrangeMagic.effects.disarmTrapEffect"),
    require("BeefStranger.StrangeMagic.effects.repairEffect"),
    require("BeefStranger.StrangeMagic.effects.stumbleEffect"),
    require("BeefStranger.StrangeMagic.effects.transposeEffect"),
    require("BeefStranger.StrangeMagic.effects.enchantLearn")
end

bs.createLog("StrangeMagic")
common.log = bs.getLog("StrangeMagic")

--- Just a shorthand for log.debug()
--
---     local debug = common.debug
function common.debug(...)
    common.log:debug(...)
end
common.magic = {
    repair = {
        name = "repairEffect",
        id = 23331,
        spellName = "Repair Equipment",
        spellId = "repairSpell",
    },
    disarm = {
        name = "disarmEffect",
        id = 23332,
        spellName = "Disarm",
        spellId = "disarmSpell",
        school = tes3.magicSchool.alteration
    },
    transpose = {
        name = "transposeEffect",
        id = 23333,
        spellName = "Transposition",
        spellId = "transposeSpell"
    },
    stumble = {
        name = "stumbleEffect",
        id = 23334,
        spellName = "Stumble",
        spellId = "stumbleSpell"
    },
    learn = {
        name = "enchantLearn",
        id = 23335,
        spellName = "Deconstruct Enchant",
        spellId = "learnSpell"
    }
}

local magic = common.magic

tes3.claimSpellEffectId(magic.repair.name, magic.repair.id)
tes3.claimSpellEffectId(magic.disarm.name, magic.disarm.id)
tes3.claimSpellEffectId(magic.transpose.name, magic.transpose.id)
tes3.claimSpellEffectId(magic.stumble.name, magic.stumble.id)
tes3.claimSpellEffectId(magic.learn.name, magic.learn.id)

return common