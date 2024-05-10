local info = require("BeefStranger.StrangeMagic.common")
local bs = require("BeefStranger.functions")

bs.debug(true)

local log = info.log
local learn = info.learn

local enchantable = {

    -- tes3.objectType.armor,
    -- tes3.objectType.clothing,
    -- tes3.objectType.weapon,
    -- tes3.objectType.book,
    -- tes3.objectType.miscItem,

    [tes3.objectType.armor] = true,
    [tes3.objectType.clothing] = true,
    [tes3.objectType.weapon] = true,
    [tes3.objectType.book] = true,  -- Assuming books can be enchanted if they are scrolls or similar items.
    [tes3.objectType.miscItem] = true  -- Including this if there are specific miscellaneous items that can be enchanted.
}



-- local buttons = {
--     {
--         text =  "button 1",
--         callback = function ()
--         tes3.messageBox("Button 1 pressed")
--         end
--     },

--     {
--         text = "button 2",
--         callback = function ()
--             tes3.messageBox("Button 2 pressed")
--         end
--     }
-- }

local function createSpell(items)
    log:debug("name %s: id %s", tostring(items.name), items.id)
    local spell = bs.spell.create{
        id = '"'..items.id.. '"',
        name = items.name,
        effect = items.enchantment,
        min = 10,
       -- cost = , math.clamp? make min and max with bs.spell.calculate
    }
    return spell
end



local function getEnchanted()
    local enchantedItems = {}
    local player = tes3.mobilePlayer
    if not player then return end

    for _, stack in pairs(player.object.inventory) do
        local item = stack.object

        if enchantable[item.objectType] and item.enchantment and item.name then
            table.insert(enchantedItems, {id = item.id, name = item.name, enchantment = item.enchantment.effects[1].id})
            log:debug("%s - %s", item.name, item.enchantment.effects[1].id)
        end

    end
    return enchantedItems
end


local function enchantButtons()
    local enchantedItems = getEnchanted()
    local buttons = {}
    for _, eItem in ipairs(enchantedItems) do

        table.insert(buttons, {
            text = eItem.name .. " - " .. eItem.enchantment,
            callback = function()
                

                tes3.messageBox(eItem.name .. " - " .. eItem.enchantment)
                -- local spell = createSpell(enchantedItems)
                tes3.removeItem{reference = tes3.mobilePlayer, item = eItem.id}
                tes3.addSpell({ reference = tes3.mobilePlayer, spell = createSpell(eItem) })


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









        -- local player = tes3.mobilePlayer
        -- if not player then return end

        -- for _, stack in pairs(player.object.inventory) do
        --     local item = stack.object

        --     if enchantable[item.objectType] and item.enchantment then
        --         table.insert(enchantedItems, {id = item.id, enchantment = item.enchantment.id})
        --         log:debug("%s - %s", item.name, item.enchantment.id)
        --     end
        -- end
        -- return enchantedItems


        -- -- for i, item in ipairs(enchantable) do
        -- --     local equipped = tes3.getEquippedItem{
        -- --         actor = player,
        -- --         objectType = item,
        -- --     }





        -- --     if equipped --[[ and equipped.object.enchantment  ]]then
        -- --         -- log:debug("%s", equipped.object.name--[[ , equipped.object.enchantment ]])
        -- --     end
            
        -- -- end


        -- -- tes3ui.showMessageMenu{message = "Yo", buttons = buttons}
    end
end


---@param e tes3magicEffectTickEventData
local function onLearnTick(e)

     bs.onTick(e, function()
        local buttons = enchantButtons()

        tes3ui.showMessageMenu { message = "Enchanted Items", buttons = buttons }
    end)
end

local function addEffects()
    bs.effect.create({
        id = learn.id,
        name = "Learn Enchantment Effect",
        school = tes3.magicSchool["mysticism"],

        hitSound = bs.sound.WindBag,

        -- onCollision = onLearnCol,
        onTick = onLearnTick,
    })
end
event.register("magicEffectsResolved", addEffects)