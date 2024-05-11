local info = require("BeefStranger.StrangeMagic.common")
local bs = require("BeefStranger.functions")

bs.debug(true)

local log = info.log
local learn = info.learn

local enchantable = {
    [tes3.objectType.armor] = true,
    [tes3.objectType.clothing] = true,
    [tes3.objectType.weapon] = true,
    [tes3.objectType.book] = true, 
    [tes3.objectType.miscItem] = true
}

local function createSpell(items) ----Need to make spell with every effect not just first
    log:debug("name %s: id %s", tostring(items.name), items.id)
    ---Table so I can add all effects to spell.create
    local spellData = {
        id = '"'..items.id.. '"',
        name = "(E) "..items.enchant.object.name,
    }
    ---Add effect min and max to the spellData table, does it in this format (effect or effect2-8)
    for i, effect in ipairs(items.effect)do
        spellData["effect"..(i == 1 and "" or i)] = effect.id --effect (if 1 then its just effect, if i is more than 1 than it gets added to effect (effect2))
        spellData["min"..(i == 1 and "" or i)] = effect.min
        spellData["max"..(i == 1 and "" or i)] = effect.max
        spellData["duration"..(i == 1 and "" or i)] = effect.duration
    end

    local spell = bs.spell.create(spellData)
    ---Update spell cost
    spell.magickaCost = math.clamp(bs.spell.calculateEffectCost(spell), 5, 100)
    -- local spell = bs.spell.create{
    --     id = '"'..items.id.. '"',
    --     name = "(E) "..items.enchant.object.name,
    --     effect = items.enchantment,
    --     min = 10, --Needs to be set by enchantment
    --    -- cost = , math.clamp? make min and max with bs.spell.calculate
    -- }
    -- spell.magickaCost = math.clamp(bs.spell.calculateEffectCost(spell), 5, 100)
    -- -- log:debug("createSpell - %s", items.enchantment.)
    return spell
end

---Make table of enchantable items that have an enchantment.
local function getEnchanted()
    local enchantedItems = {}
    local player = tes3.mobilePlayer
    if not player then return end

    for _, stack in pairs(player.object.inventory) do
        local item = stack.object

        if enchantable[item.objectType] and item.enchantment and item.name then ---Only work on items that have an enchantment and are in the type table
            local effects = {} --Table to get all effects from enchant spell

            for i, effect in ipairs(item.enchantment.effects) do --Still dont instinctively understand how to do this witout references
                if not effect.object or i > 8 then break end ---if theres no effect.object break the loop or if you hit 8 effects break
                table.insert(effects, { --Insert effects id min max and object to effects table
                    id = effect.id,
                    min = effect.min,
                    max = effect.max,
                    object = effect.object
                })
                log:debug("%q - Effects - %s - %s",item.name, effect.object.name, effect.min)
            end

            table.insert(enchantedItems, { --Table of enchanted items, 
                id = item.id,
                name = item.name,
                effect = effects,
                enchant = item.enchantment.effects[1],
                enchantment = item.enchantment.effects[1].id,
            })
            -- log:debug("%s - %s - %s", item.name, enchantedItems.effect.min, item.enchantment.effects[1].cost)
        end

    end
    return enchantedItems
end

---Make the buttons for the messageMenu
local function enchantButtons()
    local enchantedItems = getEnchanted() 
    local buttons = {}
    for _, eItem in ipairs(enchantedItems) do
        local effect = eItem.enchant
        table.insert(buttons, {
            text = eItem.name .. " - " .. effect.object.name,
            callback = function()

                log:debug(eItem.name .. " - " .. eItem.enchantment.. " - "..effect.object.name)
                tes3.messageBox(eItem.name .. " - " .. eItem.enchantment.. " - ".. effect.object.name)
                tes3.removeItem{reference = tes3.mobilePlayer, item = eItem.id}
                tes3.addSpell({ reference = tes3.mobilePlayer, spell = createSpell(eItem) })
                tes3.playSound{sound = bs.sound.enchant_success}
                tes3.playSound{sound = bs.sound.Pack, volume = 0.8, pitch = 1.5}

            end
        })
    end
    return buttons
end

---@param e tes3magicEffectCollisionEventData
local function onLearnCol(e)
    if e.collision then
        local buttons = enchantButtons()
        tes3ui.showMessageMenu { message = "Enchanted Items", buttons = buttons }
    end
end


---@param e tes3magicEffectTickEventData
local function onLearnTick(e)

     bs.onTick(e, function()
        local buttons = enchantButtons()

        tes3ui.showMessageMenu { message = "Enchanted Items", buttons = buttons, cancels = true }
    end)
end

local function addEffects()
    bs.effect.create({
        id = learn.id,
        name = "Learn Enchantment Effect",
        school = tes3.magicSchool["mysticism"],

        -- hitSound = bs.sound.WindBag,

        -- onCollision = onLearnCol,
        onTick = onLearnTick,
    })
end
event.register("magicEffectsResolved", addEffects)


local function onKeyDownI()
    if not tes3.menuMode()then
        local enchanted = getEnchanted()

        for _, eItem in ipairs(enchanted) do
            log:debug("%s, %s, %s", eItem.enchant.object.name, eItem.enchant.min, eItem.enchant.max)
        end

    end
end
event.register("keyDown", onKeyDownI, { filter = tes3.scanCode["i"] })