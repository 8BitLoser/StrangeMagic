local bs = require("BeefStranger.functions")
local info = require("BeefStranger.StrangeMagic.common")

local spell = {}

spell.learn = {
    id = "learnSpell",
    name = "Deconstruct Enchant",
    effect = info.learn.id,
    range = tes3.effectRange.self,
    cost = bs.lerp(100, 5, 90, tes3.mobilePlayer.enchant.current, false),
    duration = 0
}

spell.transpose = {
    id = info.transpose.name,
    name = "Transposition",
    effect = info.transpose.id,
    min = 25,
    range = tes3.effectRange.target,
    radius = 10
}

spell.repair = {
    id = info.repair.name,
    name = "Repair Test",
    effect = info.repair.id,
    min = 1,
    duration = 8,
    range = tes3.effectRange.self,
}

spell.disarm = {
    id = info.disarm.name,
    name = "Disarm Test",
    effect = info.disarm.id,
    -- alwaysSucceeds = true,
    min = 35,
    -- duration = 0,
    range = tes3.effectRange.target,
}

spell.stumble = {
    id = info.stumble.name,
    name = "Stumble Test",
    effect = info.stumble.id,
    radius = 20,
    -- alwaysSucceeds = true,
    min = 1,
    duration = 20,
    range = tes3.effectRange.target,
}

spell.suffocate = {
    id = info.suffocate.name,
    name = "Suffocate Test",
    effect = info.suffocate.id,
    effect2 = tes3.effect.light,
    min2 = 3,
    duration2 = 3,
    min = 2,
    range = tes3.effectRange.target,
    duration = 5,
}

return spell