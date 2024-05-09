local common = {}

function common.imports()
    return
    require("BeefStranger.StrangeMagic.effects.disarmTrapEffect"),
    require("BeefStranger.StrangeMagic.effects.repairEffect"),
    require("BeefStranger.StrangeMagic.effects.stumbleEffect"),
    require("BeefStranger.StrangeMagic.effects.transposeEffect"),
    require("BeefStranger.StrangeMagic.effects.gravityEffect")
end



common.logger = require("logging.logger")
common.log = common.logger.getLogger("StrangeMagic") or "Logger Not Found"


common.repair = {
    name = "repairEffect",
    id = 23331,
}

common.disarm = {
    name = "disarmEffect",
    id = 23332
}

common.transpose = {
    name = "transposeEffect",
    id = 23333
}

common.stumble = {
    name = "stumbleEffect",
    id = 23334,
}

common.gravity = {
    name = "gravityEffect",
    id = 23335
}



tes3.claimSpellEffectId(common.repair.name, common.repair.id)
tes3.claimSpellEffectId(common.disarm.name, common.disarm.id)
tes3.claimSpellEffectId(common.transpose.name, common.transpose.id)
tes3.claimSpellEffectId(common.stumble.name, common.stumble.id)
tes3.claimSpellEffectId(common.gravity.name, common.gravity.id)



return common

--local log = require("BeefStranger.StrangeMagic.common").log