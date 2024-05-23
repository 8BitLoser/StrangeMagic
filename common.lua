local bs = require("BeefStranger.functions")
local common = {}

bs.createLog("StrangeMagic")

common.log = bs.getLog("StrangeMagic")
common.debug = common.log.debug

---Log for common
local log = common.log

-- function common.requireHelper(filePath)
--     -----------
--     local basePath = "Data Files/mwse/mods/"
--     local modPath = "BeefStranger.StrangeMagic.effects"

--     local path = basePath..modPath:gsub("%.", "/") .. "/"
-- -----------------

--     log.debug("filePath %s", path)
--     for file in lfs.dir(filePath) do
--         local fileName = file:match("(.+)%.lua$")
--         if fileName then
--             log.debug(modPath..".".. fileName)
--             dofile("BeefStranger.StrangeMagic.effects." .. fileName)
--         end
--     end
-- end

-- function common.imports()
--     common.requireHelper("Data Files/MWSE/mods/BeefStranger/StrangeMagic/effects/")
-- end

---@enum magic 
common.magic = {
    repair = {
        idName = "repairEffect",
        id = 23331,
        name = "Repair",
        seller = "tanar llervi", --Ald-ruhn mages guild
        school = tes3.magicSchool["alteration"],
        spell = {
            name = "Repair Equipment",
            id = "repairSpell",
            effect = 23331,
            min = 2,
            duration = 5,
            range = tes3.effectRange.self,
        }
    },
    disarm = {
        idName = "disarmEffect",
        id = 23332,
        name = "Disarm",
        seller = "eraamion",
        school = tes3.magicSchool["alteration"],
        spell = {
            name = "Disarm",
            id = "disarmSpell",
            effect = 23332,
            min = 35,
            range = tes3.effectRange.target,
        }
    },
    transpose = {
        idName = "transposeEffect",
        id = 23333,
        name = "Transposition",
        seller = "gildan",
        school = tes3.magicSchool["mysticism"],
        spell = {
            name = "Transposition",
            id = "transposeSpell",
            effect = 23333,
            min = 0,
            range = tes3.effectRange.target,
            radius = 10,
            cost = 55
        }
    },
    stumble = {
        idName = "stumbleEffect",
        id = 23334,
        name = "Stumble",
        seller = "sirilonwe",
        school = tes3.magicSchool["illusion"],
        spell = {
            name = "Stumble",
            id = "stumbleSpell",
            effect = 23334,
            min = 1,
            duration = 6,
            range = tes3.effectRange.target,
        }
    },
    learn = {
        idName = "enchantLearn",
        id = 23335,
        name = "Deconstruct Enchant",
        seller = "galbedir",
        school = tes3.magicSchool["mysticism"],
        spell = {
            name = "Deconstruct Enchant",
            id = "learnSpell",
            effect = 23335,
            range = tes3.effectRange.self,
            duration = 0,
        }
    },
    steal = {
        idName = "stealEffect",
        id = 23336,
        name = "Steal",
        seller = "fargoth",
        school = tes3.magicSchool["illusion"],
        spell = {
            name = "Steal",
            id = "stealSpell",
            effect = 23336,
            range = tes3.effectRange.target,
            alwaysSucceeds = true,
            cost = 25,
        }
    },
    speed = {
        idName = "speedForce",
        id = 23337,
        name = "Fleet Feet",
        school = tes3.magicSchool["restoration"],
        spell = {
            name = "Fleet Feet",
            id = "speedSpell",
            effect = 23337,
            range = tes3.effectRange.self,
            min = 5,
            cost = 25,
        }
    },
    blink = {
        idName = "bsBlink",
        id = 23338,
        name = "Blink",
        school = tes3.magicSchool["mysticism"],

        spell = {
            name = "Blink",
            id = "blinkSpell",
            effect = 23338,
            range = tes3.effectRange.target,
            min = 25,
            max = 55,
        }
    },
}
local magic = common.magic

function common.distributeSpells()
    for key, spellInfo in pairs(magic) do
        if spellInfo.seller and not tes3.hasSpell{reference = spellInfo.seller, spell = spellInfo.spell.id} then
            -- log:debug("%s has %s", spellInfo.seller, spellInfo.spellId)
            -- break

            -- log:debug("Adding %s to %s", spellInfo.spellId, spellInfo.seller)
            bs.sellSpell(spellInfo.seller, spellInfo.spell.id)
        end
    end
end

function common.claimEffects()
    for key, effects in pairs(magic) do
        tes3.claimSpellEffectId(effects.idName, effects.id)
    end
end

common.claimEffects()

--loot notification for transpose
function common.createLootNotification(lootedItems)
    --Learning and struggling with UI
    -- Define the notification box's unique ID and position
    local notifBoxID = tes3ui.registerID("bsLootNotificationBox") --Register name of UI

    local notifBox = tes3ui.createHelpLayerMenu({ id = notifBoxID }) --Help Layer is overlay and doesnt pause
    notifBox.absolutePosAlignX = 0.01  -- Left side of the screen
    notifBox.absolutePosAlignY = 0.1   -- Near the top of the screen
    notifBox.autoHeight = true  --Auto adjust height to size of contents
    notifBox.autoWidth = true
    notifBox.flowDirection = tes3.flowDirection.topToBottom

    -- Title for the notification
    local lootTitle = notifBox:createBlock({}) --creates new block in notibox, to be used as title
    lootTitle.autoHeight = true
    lootTitle.autoWidth = true

    local titleLabel = lootTitle:createLabel({ text = "Items Looted:" }) --The actualy Title Text
    titleLabel.color = {1, 1, 1}  -- White color
    titleLabel.font = 1           -- Bold font
    local titleDivide = notifBox:createDivider({})
    titleDivide.paddingAllSides = 15
   --Create new block for item list display
    local colorChange = 0
    -- -- List each looted item
    for name, stack in pairs(lootedItems) do --Get name, and stackSize for all lootedItems
        colorChange = colorChange + 1
        local lootList = notifBox:createBlock({})
        lootList.autoHeight = true
        lootList.autoWidth = true
        lootList.borderBottom = 5

        local lootLabel = lootList:createLabel({ text = name.." - "..tostring(stack) }) --Label is name - amount
        if colorChange % 2 == 0 then
            lootLabel.color = {0.8, 0.8, 0.8}  -- Light grey color
        else
            lootLabel.color = {.9, .9, .9}
        end
    end

    -- Update the layout and make the box visible
    notifBox:updateLayout() --updateLayout, no idea why but its required
    notifBox.visible = true --Make it display


    --Update visibility when opening menu
    local function updateVis()
        if notifBox then --Check if notifBox is loaded
            notifBox.visible = not tes3ui.menuMode() --Sets visiblilty to the inverse of menuMode, menuMode = true, visible = false
        end
    end

    local destroy = function()
        event.unregister("menuEnter", updateVis) --Unregister or else it crashes when opening menu after notifBox unloads
        event.unregister("menuExit", updateVis)
        notifBox:destroy()
    end

    -- Set a timer to make the notification disappear after 3 seconds
    event.register("menuEnter", updateVis)
    event.register("menuExit", updateVis)

    bs.timer{dur = 2, cb = destroy}

    return true
end


-- function common.createLootPopup(item)
--     -- Create the menu
--     local menu = tes3ui.createMenu{ id = tes3ui.registerID("CustomLootPopup"), fixedFrame = true }

--     -- Set the menu properties
--     menu.minWidth = 300
--     menu.minHeight = 100
--     menu.positionX = 150 -- Center the menu
--     menu.positionY = 50
--     menu.flowDirection = "top_to_bottom"

--     -- Add a label with the item's name
--     local label = menu:createLabel{ text = "You found: " .. item.name }
--     label.borderTop = 10
--     label.borderBottom = 10

--     -- Add a button to take the item
--     local takeButton = menu:createButton{ text = "Take" }
--     takeButton:register("mouseClick", function()
--         tes3.addItem{ reference = tes3.player, item = item, playSound = true }
--         tes3.messageBox{ message = "You took the item!" }
--         menu:destroy()
--         tes3ui.leaveMenuMode()
--     end)

--     -- Add a button to close the popup
--     local closeButton = menu:createButton{ text = "Close" }
--     closeButton:register("mouseClick", function()
--         menu:destroy()
--         tes3ui.leaveMenuMode()
--     end)

--     -- Update the UI
--     tes3ui.enterMenuMode(tes3ui.registerID("CustomLootPopup"))
--     menu:updateLayout()
-- end


return common