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

common.debug = common.log.debug



---Log for common
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
            -- log:debug("%s has %s", spellInfo.seller, spellInfo.spellId)
            -- break
        else
            -- log:debug("Adding %s to %s", spellInfo.spellId, spellInfo.seller)
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

function common.createLootNotification(lootedItems)
    -- Define the notification box's unique ID and position
    local notifBoxID = tes3ui.registerID("bsLootNotificationBox") --Register name of UI

    local notifBox = tes3ui.createHelpLayerMenu({ id = notifBoxID }) --Help Layer is overlay and doesnt pause
    notifBox.absolutePosAlignX = 0.01  -- Left side of the screen
    notifBox.absolutePosAlignY = 0.1   -- Near the top of the screen
    notifBox.autoHeight = true  --Auto adjust height to size of contents
    notifBox.autoWidth = true
    notifBox.flowDirection = tes3.flowDirection.topToBottom
    -- notifBox.borderAllSides = 50
    -- notifBox.paddingAllSides = 50

    -- Title for the notification
    local titleBlock = notifBox:createBlock({}) --creates new block in notibox, to be used as title
    titleBlock.autoHeight = true
    titleBlock.autoWidth = true
    local titleLabel = titleBlock:createLabel({ text = "Items Looted:" }) --The actualy Title Text
    titleLabel.color = {1, 1, 1}  -- White color
    titleLabel.font = 1           -- Bold font

    -- -- List each looted item
    for name, stack in pairs(lootedItems) do --Get name, and stackSize for all lootedItems
        local itemBlock = notifBox:createBlock({}) --Create new block for item list display
        itemBlock.autoHeight = true
        itemBlock.autoWidth = true
        local itemLabel = itemBlock:createLabel({ text = name.." - "..tostring(stack) }) --Label is name - amount
        itemLabel.color = {0.8, 0.8, 0.8}  -- Light grey color
    end

    -- Update the layout and make the box visible
    notifBox:updateLayout() --updateLayout, no idea why but its required
    notifBox.visible = true --Make it display

    -- Set a timer to make the notification disappear after 3 seconds
    timer.start({ duration = 5, callback = function() notifBox:destroy() end })

    return true
end



return common