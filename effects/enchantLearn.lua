local info = require("BeefStranger.StrangeMagic.common")
local bs = require("BeefStranger.functions")

local inspect = require("inspect").inspect --Wish I knew about this sooner
local log = info.log
local debug = log.debug
local learn = info.magic.learn
bs.debug(true)

local enchantable = {
    [tes3.objectType.armor] = true,
    [tes3.objectType.clothing] = true,
    [tes3.objectType.weapon] = true,
    [tes3.objectType.book] = true,
    [tes3.objectType.miscItem] = true
}

local function generateSpell(stack)
    ---Table so I can add all effects to spell.create
    local spellData = {
        id = string.format("%q", stack.id),
        name = string.format("(E) %s", stack.enchant.object.name),
    }
    ---Add effect min and max to the spellData table, does it in this format (effect or effect2-8)
    for i, effect in ipairs(stack.effect) do
        spellData["effect" .. (i == 1 and "" or i)] = effect.id--effect (if 1 then its just effect, if i is more than 1 than it gets added to effect (effect2))
        spellData["min" .. (i == 1 and "" or i)] = effect.min
        spellData["max" .. (i == 1 and "" or i)] = effect.max

        if stack.castType == 3 then --
            spellData["duration" .. (i == 1 and "" or i)] = 60 ---@type integer
        else
            spellData["duration" .. (i == 1 and "" or i)] = effect.duration ---@type integer
        end
    end
    ---spell creation
    local spell = bs.spell.create(spellData)

    ----adjusting cost
    if stack.castType == 3 then
        spell.magickaCost = math.clamp(bs.spell.calculateEffectCost(spell), 5, 300) ---Placeholder, min of 5 max of 300 for constantEffects
    else
        spell.magickaCost = math.clamp(bs.spell.calculateEffectCost(spell), 5, 150) ---Placeholder for other types min 5 max 150
    end
    return spell
end

---Make table of enchantable items that have an enchantment.
local function getEnchanted()
    local enchantedItems = {}
    local player = tes3.mobilePlayer
    if not player then return end

    for _, stack in pairs(player.object.inventory) do
        local item = stack.object

        if enchantable[item.objectType] and item.enchantment and item.name and not item.script then ---Only work on items that have an enchantment and are in the type table
            local effects = {}                                                  --Table to get all effects from enchant spell
            local totalCost = 0

            for i, effect in ipairs(item.enchantment.effects) do                --Still dont instinctively understand how to do this witout references
                if not effect.object or i > 8 then break end                    ---if theres no effect.object break the loop or if you hit 8 effects break
                table.insert(effects, {                                         --Insert effects id min max and object to effects table
                    id = effect.id,
                    min = effect.min,
                    max = effect.max,
                    cost = effect.cost,
                    object = effect.object
                })
                totalCost = totalCost + effect.cost
                -- log("%q - Effects - %s - %s",item.name, effect.object.name, effect.min)
            end

            table.insert(enchantedItems, { --Table of enchanted items,
                id = item.id,
                name = item.name,
                effect = effects,
                totalCost = totalCost,
                castType = item.enchantment.castType,
                enchant = item.enchantment.effects[1],
                enchantment = item.enchantment,
            })
            -- log("%s - %s - %s", item.name, enchantedItems.effect.min, item.enchantment.effects[1].cost)
        end
    end
    return enchantedItems
end

---Make the buttons for the messageMenu
--[[ local function enchantButtons()
    local enchantedItems = getEnchanted()
    local buttons = {}
    for _, stack in ipairs(enchantedItems) do
        local effect = stack.enchant
        table.insert(buttons, {

            text = string.format("%s - %s", stack.name, effect.object.name),
            callback = function()
                tes3.removeItem { reference = tes3.mobilePlayer, item = stack.id }
                tes3.addSpell({ reference = tes3.mobilePlayer, spell = generateSpell(stack) })
                tes3.playSound { sound = bs.sound.enchant_success, volume = .7 }
                tes3.playSound { sound = bs.bsSound.bashImpact, volume = 1, pitch = 1.5 }
            end
        })
    end
    return buttons
end ]]


local function knownEffect(item)
    -- local enchantTable = getEnchanted()
    local spells = tes3.getSpells{target = tes3.player}
    local known = 0

    -- for _, item in ipairs(enchantTable) do
        for _, effect in ipairs(item.effect) do
            for _, spell in ipairs(spells) do
                local hasEffect = spell:getFirstIndexOfEffect(effect.id)
                -- debug("%s", hasEffect)
                if hasEffect >= 0 then
                    known = 1
                    break
                end
            end
        end
    -- end
    if known == 1 then
        return "[Known] "
    else
        return ""
    end
    -- return known
end



local function enchantMenu() --Learning UI, its not going well
    ---Also learning tables a bit more
    tes3.player.data.bsEnchant = tes3.player.data.bsEnchant or {} --Load bsEnchant table or if it doesnt exist create it
    local bsEnchant = tes3.player.data.bsEnchant --Handle for the table
    bsEnchant.know = bsEnchant.know or {} --Need to initialize tables like this, it gets the current table if it exists, and if it doesnt it creates an empty table

    local enchantTable = getEnchanted()
    local enchantMenuID = tes3ui.registerID("bsEnchantMenu") --Register the bsEnchantMenu id
    local width, height = tes3.getViewportSize() --Gets resolution of game window

    if tes3ui.findMenu("bsEnchantMenu") then
        tes3ui.findMenu("bsEnchantMenu"):destroy()
    end

    local enMenu = tes3ui.createMenu{id = enchantMenuID, fixedFrame = true} --Create the top most menu, if fixedFrame ~= true then the menu simply isnt there
    enMenu.minWidth = 400
    enMenu.minHeight = 200
    enMenu.positionX = 0.5 * (width - enMenu.minHeight) -- Center the menu vertically
    enMenu.positionY = 0.5 * (height - enMenu.minHeight) -- Center the menu vertically
    enMenu.flowDirection = "top_to_bottom"
    -------Aditions
    enMenu.paddingAllSides = 5
    enMenu.autoWidth = true
    enMenu.autoHeight = true
    -- enMenu.color = {0.251, 0.251, 0.216}

    local header = enMenu:createBlock()
    header.flowDirection = tes3.flowDirection.leftToRight
    header.autoHeight = true
    header.autoWidth = true
    header.paddingAllSides = 5
    local headerText = header:createLabel{ text = "Enchanted Items"}
    headerText.color = tes3ui.getPalette(tes3.palette.activePressedColor)
    header.borderBottom = 10
    header.font = 2
    header:createDivider({})

    -- local label = enMenu:createLabel{ text = "Enchanted Items "} --Makes the label to show at the top
    -- label.borderTop = 10    --Adds top and bottom space around the label to seperate it
    -- label.borderBottom = 10

    local destroy = function () enMenu:destroy() tes3ui.leaveMenuMode() end --A function to destroy and leaveMenuMode, otherwise it wouldnt close

    for _, item in ipairs(enchantTable) do --set 'item' to each item in the enchantTable table 
        local enchantID = item.enchant.object.id --ID of the items first enchantment
        local deconCount = bsEnchant[enchantID] or 0 --deconCount = value saved in bsEnchant or 0 if it doesnt exist
        local known = bsEnchant.know[enchantID] == true --Conditional check, if .know is false or nil know = false, if its true, know = true

        -- debug("before - %s", tostring(known)) 

        if deconCount < 5 then --Can use the spell 5 times to gain xp after enchant has been learned, means you have 6 total decons, but only 5 give xp
            ---Create the button for each item if it hasnt been decon 6 times, 
            local enItems = enMenu:createButton { text =  bs.sf("%s %s - %s", (known and "[Known ]" or ""), item.name, item.enchant.object.name)}
            -- local enItems = enMenu:createButton { text =  (known and "[Known] " or "").. item.name .. " - " .. item.enchant.object.name  }

            --Tooltip Creation
            enItems:register("help", function(e) --"help" is where you create a tooltip
                local tooltip = tes3ui.createTooltipMenu { item = item.id } --Actual tooltip creation on the item
                tooltip:createLabel { text = "Description: blahblahblah" } -- Add more detailed info

                if known then
                    tooltip:createLabel { text = bs.sf("Deconstructed : %s/5", deconCount) }
                end
            end)

            --What happens when you click on a button
            enItems:register("mouseClick", function() 
                if not known then --If object is not known then mark it known
                    bsEnchant.know[enchantID] = true --known will now be true for this enchant
                else
                    bsEnchant[enchantID] = deconCount + 1 --increment deconCount by one
                    tes3.mobilePlayer:exerciseSkill(tes3.skill.enchant, math.clamp(item.totalCost, 5, 75)) --give a clamped amount of xp
                end

                tes3.removeItem { reference = tes3.mobilePlayer, item = item.id }
                tes3.addSpell({ reference = tes3.mobilePlayer, spell = generateSpell(item) })
                tes3.playSound { sound = bs.sound.enchant_success, volume = .7 }
                tes3.playSound { sound = bs.bsSound.breakWood, volume = 1, pitch = 1.5 }

                destroy()
            end)
        end
    end
    -- Add a button to close the popup
    local footer = enMenu:createBlock()
    footer.autoHeight = true
    footer.autoWidth = true
    footer.borderTop = 25
    local closeButton = footer:createButton { text = "Close" }
    closeButton:register("mouseClick", destroy)

    tes3ui.enterMenuMode(enchantMenuID)
    enMenu:updateLayout()
end

bs.keyUp(";", enchantMenu)


--[[ local function processEnchantedItems(callback)
    local enchantedItems = getEnchanted()
    for _, stack in ipairs(enchantedItems) do
        callback(stack)
    end
end

local function enchantButtons()
    local buttons = {}
    processEnchantedItems(function(stack)
        local effect = stack.enchant
        table.insert(buttons, {
            text = string.format("%s - %s", stack.name, effect.object.name),
            callback = function()
                tes3.removeItem { reference = tes3.mobilePlayer, item = stack.id }
                tes3.addSpell({ reference = tes3.mobilePlayer, spell = generateSpell(stack) })
                tes3.playSound { sound = bs.sound.enchant_success, volume = .7 }
                tes3.playSound { sound = bs.bsSound.bashImpact, volume = 1, pitch = 1.5 }
            end
        })
    end)
    return buttons
end
 ]]

---@param e tes3magicEffectTickEventData
local function onLearnTick(e)



    -- local messageMenu = tes3ui.findMenu(tes3ui.registerID("MenuMessage")) ---Codium says this is a more efficient way of handling menus, not sure i see the point, but figured i'd try it out
    -- if messageMenu then
    --     local buttons = enchantButtons()
    --     messageMenu:destroyChildren()
    --     messageMenu:destroy()
    --     tes3ui.showMessageMenu { message = "Enchanted Items", buttons = buttons, cancels = true }
    -- else
        bs.onTick(e, function()
            enchantMenu()
            -- tes3ui.showMessageMenu { message = "Enchanted Items", buttons = buttons, cancels = true }
        end)
    end
-- end

local function addEffects()
    bs.effect.create({
        id = learn.id,
        name = "Deconstruct Enchantment",
        school = learn.school,
        description = "Learn how to cast the Enchantment as a spell, at the cost of the enchanted item.",

        baseCost = 10,

        hasNoDuration = true,
        hasNoMagnitude = true,
        canCastTarget = false,
        canCastTouch = false,

        -- onCollision = onLearnCol,
        onTick = onLearnTick,
    })
end
event.register("magicEffectsResolved", addEffects)

local function costAdjustment(e) --- @param e skillRaisedEventData
    if e.skill == tes3.skill.enchant then
        local spells = tes3.getSpells { target = tes3.player, spellType = 0 }
        local enchantSkill = tes3.mobilePlayer.enchant.current
        for _, spell in ipairs(spells) do --First time I worked out a for loop with no reference!
            local hasEffect = spell:getFirstIndexOfEffect(learn.id)
            if hasEffect >= 0 then
                spell.magickaCost = bs.lerp(100, 5, 90, enchantSkill, false)
                bs.refreshSpell(tes3.player, spell.id)
            end
        end
    end
end
event.register(tes3.event.skillRaised, costAdjustment)

--- @param e charGenFinishedEventData
local function charGenFinishedCallback(e)
    for _, skill in ipairs(tes3.mobilePlayer.object.class.majorSkills) do
        if skill == tes3.skill.enchant and tes3.skill.mysticism then
            log("enchant is major skill")
            tes3.getObject(learn.spellId).magickaCost = bs.lerp(100, 5, 90, tes3.mobilePlayer.enchant.current, false)
            tes3.addSpell({ reference = tes3.mobilePlayer, spell = learn.spellName })
            bs.refreshSpell(tes3.player, learn.spellName)
        end
    end
end
event.register(tes3.event.charGenFinished, charGenFinishedCallback)


-- bs.keyUp("n", function ()
--     local enchantTable = getEnchanted()
--     local spells = tes3.getSpells{target = tes3.player}

--     for _, spell in ipairs(spells) do
        
--         for _, item in ipairs(enchantTable) do
--             local hasEffect = spell:getFirstIndexOfEffect(item.effect.id)
--             debug("%s", hasEffect)
--             -- knownCheck(item)
--         end
--     end


--     -- debug("%s",inspect(enchantTable))

--     -- enchantMenu(--[[ enchantTable ]])
-- end)






-- bs.keyUp("n", function ()
--     local enchantTable = getEnchanted()
--     local spells = tes3.getSpells{target = tes3.player}

--     for _, item in ipairs(enchantTable) do ---sigh| loop through every item in enchantTable
--         local effectKnown = false   ---initialize 
--         for _, effect in ipairs(item.effect) do --loop through all effects in enchantTable.effects
--             for _, spell in ipairs(spells) do --Loop through all spells on player
--                 local hasEffect = spell:getFirstIndexOfEffect(effect.id) ---set hasEffect to the result of the check
--                 if hasEffect >= 0 then
--                     effectKnown = true
--                     debug("Effect %s from item %s is already known", effect.object.name, item.name)
--                     break
--                 end
--             end
--             if effectKnown then
--                 break
--             end
--         end
--         if not effectKnown then
--             debug("No matching effect found for item %s", item.name)
--         end
--     end
-- end)