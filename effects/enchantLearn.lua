local info = require("BeefStranger.StrangeMagic.common")
local bs = require("BeefStranger.functions")

local inspect = require("inspect").inspect --Wish I knew about this sooner
local log = info.debug
local learn = info.magic.learn
bs.debug(true)

local enchantable = {
    [tes3.objectType.armor] = true,
    [tes3.objectType.clothing] = true,
    [tes3.objectType.weapon] = true,
    [tes3.objectType.book] = true,
    [tes3.objectType.miscItem] = true
}

local function generateSpell(items)
    ---Table so I can add all effects to spell.create
    local spellData = {
        id = string.format("%q", items.id),
        name = string.format("(E) %s", items.enchant.object.name),
    }
    ---Add effect min and max to the spellData table, does it in this format (effect or effect2-8)
    for i, effect in ipairs(items.effect) do
        spellData["effect" .. (i == 1 and "" or i)] = effect.id--effect (if 1 then its just effect, if i is more than 1 than it gets added to effect (effect2))
        spellData["min" .. (i == 1 and "" or i)] = effect.min
        spellData["max" .. (i == 1 and "" or i)] = effect.max

        if items.castType == 3 then --
            spellData["duration" .. (i == 1 and "" or i)] = 60 ---@type integer
        else
            spellData["duration" .. (i == 1 and "" or i)] = effect.duration ---@type integer
        end
    end
    ---spell creation
    local spell = bs.spell.create(spellData)

    ----adjusting cost
    if items.castType == 3 then
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

        if enchantable[item.objectType] and item.enchantment and item.name then ---Only work on items that have an enchantment and are in the type table
            local effects = {}                                                  --Table to get all effects from enchant spell

            for i, effect in ipairs(item.enchantment.effects) do                --Still dont instinctively understand how to do this witout references
                if not effect.object or i > 8 then break end                    ---if theres no effect.object break the loop or if you hit 8 effects break
                table.insert(effects, {                                         --Insert effects id min max and object to effects table
                    id = effect.id,
                    min = effect.min,
                    max = effect.max,
                    object = effect.object
                })
                -- log("%q - Effects - %s - %s",item.name, effect.object.name, effect.min)
            end

            table.insert(enchantedItems, { --Table of enchanted items,
                id = item.id,
                name = item.name,
                effect = effects,
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
local function enchantButtons()
    local enchantedItems = getEnchanted()
    local buttons = {}
    for _, eItem in ipairs(enchantedItems) do
        local effect = eItem.enchant
        table.insert(buttons, {

            text = string.format("%s - %s", eItem.name, effect.object.name),
            callback = function()
                tes3.removeItem { reference = tes3.mobilePlayer, item = eItem.id }
                tes3.addSpell({ reference = tes3.mobilePlayer, spell = generateSpell(eItem) })
                tes3.playSound { sound = bs.sound.enchant_success, volume = .7 }
                tes3.playSound { sound = bs.bsSound.bashImpact, volume = 1, pitch = 1.5 }
            end
        })
    end
    return buttons
end

---@param e tes3magicEffectTickEventData
local function onLearnTick(e)
    local messageMenu = tes3ui.findMenu(tes3ui.registerID("MenuMessage")) ---Codium says this is a more efficient way of handling menus, not sure i see the point, but figured i'd try it out
    if messageMenu then
        local buttons = enchantButtons()
        messageMenu:destroyChildren()
        messageMenu:destroy()
        tes3ui.showMessageMenu { message = "Enchanted Items", buttons = buttons, cancels = true }
    else
        bs.onTick(e, function()
            local buttons = enchantButtons()
            tes3ui.showMessageMenu { message = "Enchanted Items", buttons = buttons, cancels = true }
        end)
    end
end

local function addEffects()
    bs.effect.create({
        id = learn.id,
        name = "Deconstruct Enchantment",
        school = tes3.magicSchool["mysticism"],
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
            tes3.getObject(learn.spellName).magickaCost = bs.lerp(100, 5, 90, tes3.mobilePlayer.enchant.current, false)
            tes3.addSpell({ reference = tes3.mobilePlayer, spell = learn.spellName })
            bs.refreshSpell(tes3.player, learn.spellName)
        end
    end
end
event.register(tes3.event.charGenFinished, charGenFinishedCallback)


local function onKeyDownI()
    if not tes3.menuMode() then
        -- tes3.mobilePlayer:exerciseSkill(tes3.skill.enchant, 100)
        -- log("%s", inspect(tes3.mobilePlayer.object.class.majorSkills))
        -- local major = tes3.mobilePlayer.object.class.majorSkills
        -- -- inspect(tes3.mobilePlayer.object.class.majorSkills)

        -- for _, skill in ipairs(tes3.mobilePlayer.object.class.minorSkills) do
        --     if skill == tes3.skill.enchant then
        --         log("enchant is minor skill")
        --     else
        --         log("enchant is not minor skill")
            -- end
        -- end

    end
end
event.register("keyDown", onKeyDownI, { filter = tes3.scanCode["i"] })
