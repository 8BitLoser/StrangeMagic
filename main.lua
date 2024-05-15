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
    ---------------DEBUG-------------
    bs.spell.create {
        id = "rangeTest",
        name = "RangeTester",
        effect = 220
    }
    ---------------DEBUG-------------
end
event.register("loaded", registerSpells, { priority = 1 })

--
----Still need to add stumble, disarm, and transpose to vendor
--
local function addSpells()
    --- galbedir, Balmora mages guild | Deconstruct Enchant Spell
    bs.sellSpell("galbedir", magic.learn.spellId)

    --- tanar llervi, Ald-ruhn mages guild | Repair Spell
    bs.sellSpell("tanar llervi", magic.repair.spellId)

    --- gildan, Ald-ruhn Gildans house| Transpose Spell
    bs.sellSpell("gildan", magic.transpose.spellId)

    --- sirilonwe, Vivec Mages Guild | Stumble
    bs.sellSpell("sirilonwe", magic.stumble.spellId)

    --- eraamion, Caldera Mages Guild | Disarm
    bs.sellSpell("eraamion", magic.disarm.spellId)



    ---------------DEBUG-------------
    bs.addSpell(tes3.player, "rangeTest")
    ---------------DEBUG-------------
end
event.register(tes3.event.loaded, addSpells)

bs.keyUp("p", function()
   local target = bs.rayCast(900) 
   debug("raycast - %s", target)
end)

local function onKeyDownI()
    if not tes3.menuMode() then
        tes3.mobilePlayer:exerciseSkill(tes3.skill.enchant, 100)
        bs.bulkAddSpells(tes3.player, magic) ---Add all spells to player
    end
end
event.register("keyDown", onKeyDownI, { filter = tes3.scanCode.i })
tes3.claimSpellEffectId("customFireDmg", 220)
-----==========TESTING









event.register(tes3.event.magicEffectsResolved, function()
    tes3.addMagicEffect({
        -- The ID we claimed before is now available in tes3.effect namespace
        id = tes3.effect.customFireDmg,

        -- This information is copied from the Construction Set
        name = "Range Tester",
        description = ("This spell effect produces a manifestation of elemental fire. Upon " ..
        "contact with an object, this manifestation explodes, causing damage."),
        baseCost = 5,
        school = tes3.magicSchool.destruction,
        size = 1.25,
        sizeCap = 50,
        speed = 1,
        lighting = { x = 0.99, y = 0.26, z = 0.53 },
        usesNegativeLighting = false,

        icon = "s\\Tx_S_fire_damage.tga",
        particleTexture = "vfx_firealpha00A.tga",
        castSound = "destruction cast",
        castVFX = "VFX_DestructCast",
        boltSound = "destruction bolt",
        boltVFX = "VFX_DestructBolt",
        hitSound = "destruction hit",
        hitVFX = "VFX_DestructHit",
        areaSound = "destruction area",
        areaVFX = "VFX_DestructArea",

        -- allowSpellmaking = true,
        canCastTouch = true,
        canCastTarget = true,
        canCastSelf = false,

        appliesOnce = false,
        hasNoDuration = false,
        hasNoMagnitude = false,
        illegalDaedra = false,
        unreflectable = false,
        casterLinked = false,
        nonRecastable = false,
        targetsAttributes = false,
        targetsSkills = false,

        onTick = function()end,
    })
end)
---------------DEBUG-------------


event.register(tes3.event.initialized, initialized)