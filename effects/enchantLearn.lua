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
        id = string.format("%q", stack.id), --tostring(stack.id),
        name = string.format("(E) %s", stack.enchant.object.name),
    }
    ---Add effect min and max to the spellData table, does it in this format (effect or effect2-8)
    -- ---@param effect tes3effect
    for i, effect in ipairs(stack.effect) do ---@as tes3effect
        spellData["effect" .. (i == 1 and "" or i)] = effect.id--effect (if 1 then its just effect, if i is more than 1 than it gets added to effect (effect2))
        spellData["min" .. (i == 1 and "" or i)] = effect.min
        spellData["max" .. (i == 1 and "" or i)] = effect.max
        spellData["duration" .. (i == 1 and "" or i)] = (stack.castType == 3 and 60 or effect.duration) ---@type integer
        spellData["range" .. (i == 1 and "" or i)] = effect.rangeType
        spellData["radius" .. (i == 1 and "" or i)] = effect.radius
    end

    ---spell creation
    local spell = bs.spell.create(spellData)

    local spellCost = bs.spell.calculateEffectCost(spell)
    spell.magickaCost = (stack.castType == 3 and math.clamp(spellCost, 5, 300)) or math.clamp(spellCost, 5, 150)

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
                    object = effect.object,
                    radius = effect.radius,

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

---Player data initialization
local bsEnchant
event.register("loaded", function()
    -- Ensure tes3.player.data is initialized
    if not tes3.player.data then
        tes3.player.data = {}
    end

    -- Initialize bsEnchant if it doesn't exist
    tes3.player.data.bsEnchant = tes3.player.data.bsEnchant or {}
    bsEnchant = tes3.player.data.bsEnchant

    -- Initialize bsEnchant.know if it doesn't exist
    bsEnchant.know = bsEnchant.know or {}
    -- debug("%s", inspect(bsEnchant))
end)

local function enchantMenu() --Learning UI, its not going well
    ---Also learning tables a bit more

    local enchantTable = getEnchanted()
    local enchantMenuID = tes3ui.registerID("bsEnchantMenu") --Register the bsEnchantMenu id
    local width, height = tes3.getViewportSize() --Gets resolution of game window

    if tes3ui.findMenu("bsEnchantMenu") then
        tes3ui.findMenu("bsEnchantMenu"):destroy()
    end

    ----------------------------------------------------------------------------------------------------
    ---`Menu Creation`
    ----------------------------------------------------------------------------------------------------
    ---contentPath = "menu_thin_border.NIF"
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

    ----------------------------------------------------------------------------------------------------
    ---`Header`
    ----------------------------------------------------------------------------------------------------
    local header = enMenu:createBlock{id = "Header"}
    header.flowDirection = tes3.flowDirection.leftToRight
    header.autoHeight = true
    header.autoWidth = true
    -- header.paddingAllSides = 5
    header.paddingLeft = 10
    header.paddingBottom = 2
    local headerText = header:createLabel{ id = "Header Text", text = "Enchanted Items"}
    headerText.color = tes3ui.getPalette(tes3.palette.activePressedColor)
    header.borderBottom = 10
    header.font = 2
    -- header:createDivider({id = "Divider"})
    -- header:createThinBorder({id = "ThinBorder"})

    local headerDivider = enMenu:createDivider{id = "Header Divider"}
    headerDivider.autoHeight = true
    headerDivider.autoWidth = true
    headerDivider.borderBottom = 20

    ----------------------------------------------------------------------------------------------------
    ---`Buttons`
    ----------------------------------------------------------------------------------------------------
    local buttons = headerDivider:createBlock{id = "buttons"}
    buttons.flowDirection = tes3.flowDirection.topToBottom
    buttons.autoHeight = true
    buttons.autoWidth = true
    buttons.borderTop = 10

    local destroy = function () enMenu:destroy() tes3ui.leaveMenuMode() end --A function to destroy and leaveMenuMode, otherwise it wouldnt close

    for _, item in ipairs(enchantTable) do --set 'item' to each item in the enchantTable table 
        local enchantID = tostring(item.enchant.object.id) --ID of the items first enchantment|Had to do tostring, because sometimes it would randomly be a string and somethimes it was randomly a number
        local deconCount = bsEnchant[enchantID] or 0 --deconCount = value saved in bsEnchant or 0 if it doesnt exist
        local known = bsEnchant.know[enchantID] == true --Conditional check, if .know is false or nil know = false, if its true, know = true

        -- local border = enMenu:createThinBorder({name = "Items"})
        -- border.autoHeight = true
        -- border.autoWidth = true
        -- local buttons = border:createBlock()

        -- debug("in loop %s", inspect(bsEnchant))
        -- debug("before - %s", tostring(known)) 

        if deconCount < 5 then --Can use the spell 5 times to gain xp after enchant has been learned, means you have 6 total decons, but only 5 give xp
            ---Create the button for each item if it hasnt been decon 6 times,

            local enItems = buttons:createButton { id = "Buttons" ,text =  bs.sf("%s %s - %s", (known and "[Known ]" or ""), item.name, item.enchant.object.name)}
            -- local enItems = enMenu:createButton { text =  (known and "[Known] " or "").. item.name .. " - " .. item.enchant.object.name  }

            --Tooltip Creation
            enItems:register("help", function(e) --"help" is where you create a tooltip, and other non pause ui
                local tooltip = tes3ui.createTooltipMenu {id = "Tooltip", item = item.id } --Actual tooltip creation on the item
                if not known then
                    tooltip:createLabel { text = "Enchantment not known" } -- Add more detailed info
                end
                

                if known then
                    tooltip:createLabel{ text = "Deconstructed"}
                    -- tooltip.paddingTop = 15
                    local fillbar = tooltip:createFillBar{ id = "fillbar", current = deconCount, max = 5}
                    fillbar.widget.fillColor = {0.129, 0.522, 0.941}
                    -- tooltip.paddingBottom = 15
                    -- tooltip:createLabel { text = bs.sf("Deconstructed : %s/5", deconCount) }
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

                tes3.removeItem { reference = tes3.mobilePlayer, item = item.id } --Destroy item
                bs.addSpell(tes3.mobilePlayer, generateSpell(item))
                -- tes3.addSpell({ reference = tes3.mobilePlayer, spell = generateSpell(item) }) --Generate Spell from enchant
                bs.playSound(bs.sound.enchant_success, .7)
                bs.playSound(bs.bsSound.breakWood, 1, 1.5)
                -- tes3.playSound { sound = bs.sound.enchant_success, volume = .7 }
                -- tes3.playSound { sound = bs.bsSound.breakWood, volume = 1, pitch = 1.5 }

                destroy()
            end)
        end
    end
    ----------------------------------------------------------------------------------------------------
    ---`Footer`
    ----------------------------------------------------------------------------------------------------
    local footer = enMenu:createBlock({id = "Footer"})
    footer.autoHeight = true
    footer.autoWidth = true
    footer.borderTop = 35
    local closeButton = footer:createButton { id = "Close Button",text = "Close" }
    closeButton:register("mouseClick", destroy)

    tes3ui.enterMenuMode(enchantMenuID)
    enMenu:updateLayout()
end
-------------------------Debug----------------------------------


bs.keyUp(";", enchantMenu)
----------------------------------------------------------------
---@param e tes3magicEffectTickEventData
local function onLearnTick(e)
    bs.onTick(e, function()
        enchantMenu()
    end)
end

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
            -- tes3.addSpell({ reference = tes3.mobilePlayer, spell = learn.spellName })
            bs.addSpell(tes3.mobilePlayer, learn.spellName)
            bs.refreshSpell(tes3.player, learn.spellName)
        end
    end
end
event.register(tes3.event.charGenFinished, charGenFinishedCallback)
