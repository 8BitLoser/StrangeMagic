local bs = require("BeefStranger.functions")
local common = {}

bs.createLog("StrangeMagic")

common.log = bs.getLog("StrangeMagic")
common.debug = common.log.debug

---Log for common
local log = common.log

function common.requireHelper(filePath)
    -----------
    local basePath = "Data Files/mwse/mods/"
    local modPath = "BeefStranger.StrangeMagic.effects"

    local path = basePath..modPath:gsub("%.", "/") .. "/"
-----------------

    log.debug("filePath %s", path)
    for file in lfs.dir(filePath) do
        local fileName = file:match("(.+)%.lua$")
        if fileName then
            log.debug(modPath..".".. fileName)
            dofile("BeefStranger.StrangeMagic.effects." .. fileName)
        end
    end
end

function common.imports()
    common.requireHelper("Data Files/MWSE/mods/BeefStranger/StrangeMagic/effects/")
end

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
    },
    speed = {
        name = "speedForce",
        id = 23337,
        spellName = "Fleet Feet",
        spellId = "speedSpell",
        school = tes3.magicSchool["restoration"]
    }

}

local magic = common.magic

function common.distributeSpells()
    for key, spellInfo in pairs(magic) do
        if spellInfo.seller and not tes3.hasSpell{reference = spellInfo.seller, spell = spellInfo.spellId} then
            -- log:debug("%s has %s", spellInfo.seller, spellInfo.spellId)
            -- break

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

-- ---Get if player already has spell and grant xp instead
-- local function generateSpell(stack)
--     ---Table so I can add all effects to spell.create
--     local spellData = {
--         id = string.format("%q", stack.id),
--         name = string.format("(E) %s", stack.enchant.object.name),
--     }
--     ---Add effect min and max to the spellData table, does it in this format (effect or effect2-8)
--     for i, effect in ipairs(stack.effect) do
--         spellData["effect" .. (i == 1 and "" or i)] = effect.id--effect (if 1 then its just effect, if i is more than 1 than it gets added to effect (effect2))
--         spellData["min" .. (i == 1 and "" or i)] = effect.min
--         spellData["max" .. (i == 1 and "" or i)] = effect.max

--         if stack.castType == 3 then --
--             spellData["duration" .. (i == 1 and "" or i)] = 60 ---@type integer
--         else
--             spellData["duration" .. (i == 1 and "" or i)] = effect.duration ---@type integer
--         end
--     end
--     ---spell creation
--     local spell = bs.spell.create(spellData)

--     ----adjusting cost
--     if stack.castType == 3 then
--         spell.magickaCost = math.clamp(bs.spell.calculateEffectCost(spell), 5, 300) ---Placeholder, min of 5 max of 300 for constantEffects
--     else
--         spell.magickaCost = math.clamp(bs.spell.calculateEffectCost(spell), 5, 150) ---Placeholder for other types min 5 max 150
--     end
--     return spell
-- end


-- function common.enchantMenu(enchantTable)
--     local enchantMenuID = tes3ui.registerID("bsEnchantMenu")
--     local width, height = tes3.getViewportSize()

--     local enMenu = tes3ui.createMenu{id = enchantMenuID, fixedFrame = true}
--     enMenu.minWidth = 300
--     enMenu.minHeight = 100
--     enMenu.positionX = 0.5 * (width - enMenu.minHeight) -- Center the menu vertically
--     enMenu.positionY = 0.5 * (height - enMenu.minHeight) -- Center the menu vertically
--     enMenu.flowDirection = "top_to_bottom"

--     local label = enMenu:createLabel{ text = "Enchanted Items "}
--     label.borderTop = 10
--     label.borderBottom = 10

--     local destroy = function () enMenu:destroy() tes3ui.leaveMenuMode() end

--     for index, item in ipairs(enchantTable) do
--         local enItems = enMenu:createButton{text = item.name .. " - ".. item.enchant.object.name}
--         enItems:register("help", function(e)
--             local tooltip = tes3ui.createTooltipMenu{item = item.id}
--             tooltip:createLabel{text = "Test ToolTip"}
--         end)
--         enItems:register("mouseClick", function ()
--             tes3.removeItem { reference = tes3.mobilePlayer, item = item.id }
--             tes3.addSpell({ reference = tes3.mobilePlayer, spell = generateSpell(item) })
--             tes3.playSound { sound = bs.sound.enchant_success, volume = .7 }
--             tes3.playSound { sound = bs.bsSound.breakWood, volume = 1, pitch = 1.5 }

--             destroy()
--         end)
--     end




-- -------------------------------placeholder
--     local takeButton = enMenu:createButton{ text = "Take" }
--     takeButton:register("mouseClick", function()
--         tes3.messageBox{ message = "You took the item!" }
--         destroy()
--     end)

--     -- Add a button to close the popup
--     local closeButton = enMenu:createButton{ text = "Close" }
--     closeButton:register("mouseClick", destroy)

--     tes3ui.enterMenuMode(enchantMenuID)
--     enMenu:updateLayout()

-- end




function common.createLootPopup(item)
    -- Create the menu
    local menu = tes3ui.createMenu{ id = tes3ui.registerID("CustomLootPopup"), fixedFrame = true }

    -- Set the menu properties
    menu.minWidth = 300
    menu.minHeight = 100
    menu.positionX = 150 -- Center the menu
    menu.positionY = 50
    menu.flowDirection = "top_to_bottom"

    -- Add a label with the item's name
    local label = menu:createLabel{ text = "You found: " .. item.name }
    label.borderTop = 10
    label.borderBottom = 10

    -- Add a button to take the item
    local takeButton = menu:createButton{ text = "Take" }
    takeButton:register("mouseClick", function()
        tes3.addItem{ reference = tes3.player, item = item, playSound = true }
        tes3.messageBox{ message = "You took the item!" }
        menu:destroy()
        tes3ui.leaveMenuMode()
    end)

    -- Add a button to close the popup
    local closeButton = menu:createButton{ text = "Close" }
    closeButton:register("mouseClick", function()
        menu:destroy()
        tes3ui.leaveMenuMode()
    end)

    -- Update the UI
    tes3ui.enterMenuMode(tes3ui.registerID("CustomLootPopup"))
    menu:updateLayout()
end


return common