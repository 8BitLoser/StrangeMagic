local info = require("BeefStranger.StrangeMagic.common")
local bs = require("BeefStranger.functions")

local inspect = require("inspect").inspect --Wish I knew about this sooner
local log = info.debug
local learn = info.learn
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
    for i, effect in ipairs(items.effect)do
        spellData["effect"..(i == 1 and "" or i)] = effect.id --effect (if 1 then its just effect, if i is more than 1 than it gets added to effect (effect2))
        spellData["min"..(i == 1 and "" or i)] = effect.min
        spellData["max"..(i == 1 and "" or i)] = effect.max

        if items.castType == 3 then --
            spellData["duration"..(i == 1 and "" or i)] = 60 ---@type integer
        else
            spellData["duration"..(i == 1 and "" or i)] = effect.duration ---@type integer
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
            local effects = {} --Table to get all effects from enchant spell

            for i, effect in ipairs(item.enchantment.effects) do --Still dont instinctively understand how to do this witout references
                if not effect.object or i > 8 then break end ---if theres no effect.object break the loop or if you hit 8 effects break
                table.insert(effects, { --Insert effects id min max and object to effects table
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
            -- text = eItem.name .. " - " .. effect.object.name,
            callback = function()
                -- log(eItem.name .. " - " .. eItem.enchant.id.. " - "..effect.object.name)
                tes3.removeItem{reference = tes3.mobilePlayer, item = eItem.id}
                tes3.addSpell({ reference = tes3.mobilePlayer, spell = generateSpell(eItem) })
                tes3.playSound{sound = bs.sound.enchant_success, volume = .7}
                tes3.playSound{sound = bs.bsSound.bashImpact, volume = 1, pitch = 1.5}
            end
        })
    end
    return buttons
end

-- ---@param e tes3magicEffectCollisionEventData
-- local function onLearnCol(e)
--     if e.collision then
--         local buttons = enchantButtons()
--         tes3ui.showMessageMenu { message = "Enchanted Items", buttons = buttons }
--     end
-- end


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

local learnEffect

local function addEffects()

    -- bs.sound.addSound("bsSoundTest", bs.bsSound.magicImpact)

    -- local soundPath = "\\Bs\\bashImpact.wav"

    -- local sound = tes3.createObject{    
    --     id = "bsSoundTest",
    --     objectType = tes3.objectType.sound,
    --     filename = bs.bsSound.bashimpact,
    -- }
    -- if sound ~= nil then
    --     print(string.format("StrangeMagic: %s registered", sound))
    -- else
    --     print("Sound registered failed")
    -- end


    learnEffect = bs.effect.create({  
        id = learn.id,
        name = "Learn Enchantment Effect",
        school = tes3.magicSchool["mysticism"],

        baseCost = 2500,
        -- baseCost = bs.lerp(55, 5, 90, enchantSkill, false),

        hasNoDuration = true,
        hasNoMagnitude = true,
        canCastTarget = false,
        canCastTouch = false,


        -- onCollision = onLearnCol,
        onTick = onLearnTick,
    })
    return learnEffect
end
event.register("magicEffectsResolved", addEffects)

local function costAdjust()

end

event.register("loaded", costAdjust)



local function onKeyDownI()
    if not tes3.menuMode()then
        ---
        --- Idea for updating spells with updated baseCost
        ---tes3.getSpells(reference = tes3.player)
        ---
        ---for i, spells in pairs(tes3.getSpells) do
        ---
        ---     local hasLearn = spells:getFirstIndexOfEffect(info.learn.id)
        ---
        ---     if spells.effects[hasLearn] then
        ---         local spellCopy = spells:createCopy()
        ---         removeSpell spells
        ---         addSpell spellCopy
        ---
        ---
        ---
        ---
        tes3.playSound{sound = bs.bsSound.bashImpact}
        local enchantSkill = tes3.mobilePlayer.enchant.current
        local cost = bs.lerp(55, 5, 90, enchantSkill, false)
  

        log("Player enchant - %s - cost %s", enchantSkill, cost)

        local learnE = tes3.getMagicEffect(info.learn.id)
        if not learnE then return end

        log("BlearnE - %s", learnE.baseMagickaCost)

        learnE.baseMagickaCost = 100

        learnE.allowSpellmaking = true

        tes3.updateMagicGUI{reference = tes3.mobilePlayer, updateSpells = true}

        -- log("AlearnE - %s", learnE.baseMagickaCost)

        -- local enchantedItems = getEnchanted()
        -- if not enchantedItems then return end

        -- for _, eItem in ipairs(enchantedItems) do
        --     log("%s", inspect(enchantedItems))
        -- end
    end
end
event.register("keyDown", onKeyDownI, { filter = tes3.scanCode["i"] })