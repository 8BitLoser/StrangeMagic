--=============================Framework/Logging================================--
local bs = require("BeefStranger.functions")
local common = require("BeefStranger.StrangeMagic.common")
local magic = require("BeefStranger.StrangeMagic.common").magic
common.imports() --How to import from common when requiring common on imported files

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
        radius = 5,
        min = 1,
        duration = 5,
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
        -- castType = 
        -- effect2 = tes3.effect.light,
        -- duration2 = 1
    }
end
event.register("loaded", registerSpells, { priority = 1 })

local function addSpells()
    common.distributeSpells()

    ---------Debug----------
    bs.addSpell(tes3.player, magic.steal.spellId)
    -- tes3.mobilePlayer:equipMagic{source = magic.steal.spellId}
    -- bs.equipMagic(magic.steal.spellId)
end
event.register(tes3.event.loaded, addSpells)


bs.keyUp("p", function()
--    local target = bs.rayCast(900)
--    if not target then return end
--    debug("`npc` NPC = %s", bs.typeCheck(target, "npc", true))
--    debug("tes3.objectType.npc NPC = %s", bs.typeCheck(target, tes3.objectType.npc))

--    local menu = tes3ui.createMenu{
--         id = "bsTest"
--     }
--     menu.alpha = 0.75
--     menu.absolutePosAlignX = 50
--     menu.absolutePosAlignY = 10
end)

-- bs.keyUp("l", function ()
--     local target = bs.rayCast(900)
--     bs.typeCheck(target, "npc", true)
--     debug("fight - %s", target.object.mobile.fight)
--     debug("flee value = %s", target.object.mobile.flee)
--     target.object.mobile:stopCombat()

--     target.object.mobile.fight = 0
--     target.object.mobile.flee = 1000


--     debug("%s - %s",target.object, type(target.object))
-- end)

bs.keyUp("i", function ()
    -- local target = bs.rayCast(900) 
    -- tes3.messageBox("I Pressed")
    -- -- debug("[1] - %s", target.object.inventory)
    -- -- tes3.mobilePlayer:exerciseSkill(tes3.skill.enchant, 100)
    -- bs.bulkAddSpells(tes3.player, magic) ---Add all spells to player

    tes3ui.showNotifyMenu("Notify:I pressed")
    bs.msg("MSG:I")


end)

local itemTest = {
    [1] = "beep",
    [2] = "boop"
}
---CHATGPT--- FIGURE OUT HOW THIS WORKS AND IMPLEMENT IT
-- local function createLootNotification(lootedItems)
--     -- Define the notification box's unique ID and position
--     local notifBoxID = tes3ui.registerID("LootNotificationBox")
--     local notifBox = tes3ui.createHelpLayerMenu({ id = notifBoxID })
--     notifBox.absolutePosAlignX = 0.01  -- Left side of the screen
--     notifBox.absolutePosAlignY = 0.1   -- Near the top of the screen
--     notifBox.autoHeight = true
--     notifBox.autoWidth = true
--     notifBox.flowDirection = tes3.flowDirection.topToBottom
--     notifBox.borderAllSides = 50
--     -- notifBox.paddingAllSides = 50

--     -- Title for the notification
--     local titleBlock = notifBox:createBlock({})
--     titleBlock.autoHeight = true
--     titleBlock.autoWidth = true
--     local titleLabel = titleBlock:createLabel({ text = "Items Looted:" })
--     titleLabel.color = {1, 1, 1}  -- White color
--     titleLabel.font = 1           -- Bold font

--     -- List each looted item
--     for _, item in ipairs(lootedItems) do
--         local itemBlock = notifBox:createBlock({})
--         itemBlock.autoHeight = true
--         itemBlock.autoWidth = true
--         local itemLabel = itemBlock:createLabel({ text = item })
--         itemLabel.color = {0.8, 0.8, 0.8}  -- Light grey color
--     end

--     -- Update the layout and make the box visible
--     notifBox:updateLayout()
--     notifBox.visible = true

--     -- Set a timer to make the notification disappear after 3 seconds
--     timer.start({ duration = 3, callback = function() notifBox:destroy() end })

--     return true
-- end


bs.keyUp("p", function()
    local target = bs.rayCast(500, true)
    debug("%s - %s", target and target.object.name, bs.objectTypeNames[target and target.object.objectType])
    end)

bs.keyUp("o", function ()
    debug("%s", config.combatOnly)

end)

event.register(tes3.event.initialized, initialized)