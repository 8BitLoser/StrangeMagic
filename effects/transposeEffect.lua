local bs = require("BeefStranger.functions")
local info = require("BeefStranger.StrangeMagic.common")
local config = require("BeefStranger.StrangeMagic.config")

local debug, trace = info.log.debug, info.log.trace
local transpose = info.magic.transpose --Experimenting with centralized effect list
local inspect = require("inspect").inspect

-- tes3.claimSpellEffectId("bsTranspose", transpose.id)
--Boolean Table of loose item objectTypes
local itemTypes = {
    [tes3.objectType.alchemy] = true,
    [tes3.objectType.apparatus] = true,
    [tes3.objectType.armor] = true,
    [tes3.objectType.book] = true,
    [tes3.objectType.clothing] = true,
    [tes3.objectType.miscItem] = true,
    [tes3.objectType.weapon] = true,
}
--Boolean Table of objects with an inventory
local hasInventory = {
    [tes3.objectType.container] = true,
    [tes3.objectType.creature] = true,
    [tes3.objectType.npc] = true,
}
--Table of types to loop over in cell
local iterateRefs = {
    tes3.objectType.alchemy,
    tes3.objectType.armor,
    tes3.objectType.book,
    tes3.objectType.clothing,
    tes3.objectType.container,
    tes3.objectType.creature,
    tes3.objectType.ingredient,
    tes3.objectType.miscItem,
    tes3.objectType.npc,
    tes3.objectType.weapon,
}
--Boolean Table of living beings
local being = {
    [tes3.objectType.creature] = true,
    [tes3.objectType.npc] = true,
}

----Need more experience with functions, so using a ton. Does make code look a bit nicer

local function refCheck(ref) ---@param ref tes3reference --Function to test lockNode, Locked, Trapped, NPC, isDead, Owner, Inventory
    --lockNode Check
    if ref.lockNode then
        if ref.lockNode.trap then
            trace("%s is trapped : skipping", ref.object.name)
            tes3.createVisualEffect({ lifespan = 2, reference = ref, magicEffectId = tes3.effect["fireDamage"], })
            return false
        elseif ref.lockNode.locked then
            trace("%s is locked : skipping", ref.object.name)
            return false
        end
        return true
    end

    --NPC and Creature living check
    if (ref.object.objectType == tes3.objectType.npc) or (ref.object.objectType == tes3.objectType.creature) then
        if ref.mobile.isDead then
            return true
        end
        trace("%s is not dead : skipping", ref.object.name)
        tes3.createVisualEffect({ lifespan = 2, reference = ref, magicEffectId = tes3.effect["fireDamage"], })
        return false
    end

    --Script Check
    if ref.object.script ~= nil then --false if object has script
        trace("%s has script : skipping", ref.object.name)
        tes3.createVisualEffect({ lifespan = 2, reference = ref, magicEffectId = tes3.effect["damageAttribute"], })
        return false
    end


    --Owner Check
    if tes3.getOwner({ reference = ref }) ~= nil and not tes3.hasOwnershipAccess({ target = ref }) then
        tes3.createVisualEffect({ lifespan = 2, reference = ref, magicEffectId = tes3.effect["drainSkill"], })
        return false
    end
    --Inventory check
    if hasInventory[ref.object.objectType] and #ref.object.inventory > 0 then
        if tes3.hasOwnershipAccess({ target = ref }) then
            trace("Has Access to %s", ref.object.name)
            return true
        end
        trace("%s has valid inventory", ref.object.name)
        return true
    end

    -- return true
end
--Table of items looted, for the notification
local looted = {}

local function addItem(ref) ---@param ref tes3reference Add item to player then delete it
    if itemTypes[ref.object.objectType] and (ref.deleted == false) and not ref.object.script then --If the item is in the list and not marked deleted
        if tes3.getOwner({ reference = ref }) ~= nil and not tes3.hasOwnershipAccess({ target = ref }) then
            bs.glowFX(ref, tes3.effect.fireDamage, 2)
            -- tes3.createVisualEffect({ lifespan = 2, reference = ref, magicEffectId = tes3.effect["fireDamage"], })
            debug("%s is owned/you dont have access", ref.object.name)
            return
        end

        if looted[ref.object.name] then --Checks if the item is already in the table
            looted[ref.object.name] = looted[ref.object.name] + ref.stackSize --Increase stack size by second item stack size
        else
            looted[ref.object.name] = ref.stackSize
        end


        -- local itemDetails = ref.object.name .. " - " .. tostring(ref.stackSize)

        if ref.object.name == "Gold" then                               --Gold piles dont work right, so i have to do this
            tes3.addItem({ reference = tes3.mobilePlayer, item = ref.object, count = ref.object.value })
            tes3.playSound{sound = bs.bsSound.fantasyUI5}
            debug("Looting Gold - %s", ref.object.value)
            -- info.createLootNotification("Gold - " .. tostring(ref.object.value))
            ref:delete()
        else --Add the item to the player, then delete the item
            -- table.insert(looted, ref.object.name, ref.stackSize)
            -- looted[ref.object.name] = ref.stackSize
            tes3.addItem({ reference = tes3.mobilePlayer, item = ref.object, count = ref.stackSize })
            tes3.playSound{sound = bs.bsSound.fantasyUI5}
            debug("Looting item - %s - %s", ref.object.name, ref.stackSize)

            ref:delete()
            -- return looted
        end
    end
    return looted
end

local function transfer(ref) ---@param ref tes3reference Just a little function to transfer/play effect if refCheck true
    if refCheck(ref) then

        if hasInventory[ref.object.objectType] then
            ref.object.inventory:resolveLeveledItems(tes3.mobilePlayer)
            debug("has inventory")
            for _, stack in pairs(ref.object.inventory) do
                debug("%s", stack.object.name)

                if looted[stack.object.name] then --Checks if the item is already in the table
                    looted[stack.object.name] = looted[stack.object.name] + stack.count --Increase stack size by second item stack size
                else
                    looted[stack.object.name] = stack.count
                end
                
            end
        end
        ---------------------------------------------

        ---------------------------------------------

        trace("REFCHECK - %s", refCheck(ref))
        bs.glowFX(ref, transpose.id, 2)
        tes3.createVisualEffect({ lifespan = 2, reference = ref, magicEffectId = transpose.id, })
        trace("playing effect on %s",ref.object.name)
        tes3.transferInventory({from = ref, to = tes3.mobilePlayer})
        -- tes3.playSound{sound = bs.bsSound.fantasyUI5}
        bs.playSound(bs.bsSound.fantasyUI5)
        trace("transfering from %s",ref.object.name)


    end
    return looted
end


local function teleport(ref)---@param ref tes3reference Function to handle random teleporting of living beings
    local pos, iter, tpRand, newPos = ref.position:copy(), 0, 1500, nil --setup pos as the current ref pos, and set iter to 0
    local maxIter = 100
    repeat --Repeat below until certain condition is met
        newPos = pos:copy()
        newPos.x = pos.x + math.random(-tpRand, tpRand) --Randomize xyz by +-rand
        newPos.y = pos.y + math.random(-tpRand, tpRand)
        newPos.z = pos.z + math.random(0, tpRand/1.5) --dont want them going downwards, causes lots of iterations and maxing out
        local collision = tes3.testLineOfSight({ position1 = pos, position2 = newPos}) --Gets los, using to get pos not in a wall
        iter = iter + 1 --Just a counter
        -- debug("iteration %s", iter)
    until collision == true or iter >= maxIter --Repeat until a random point has been generated thats in los of ref, to stop them tp into walls

    ----debug("Ref pos %s, adjusted Pos %s", pos, newPos)

    if iter < 150 then --Only teleport if a valid collision pos was found within 175 tries
        tes3.playSound{sound = bs.bsSound.scifiBoom, reference = ref, volume = 2}
        tes3.positionCell({ reference = ref, position = newPos, cell = tes3.mobilePlayer.cell })

        -- tes3.positionCell({ reference = tes3.player, position = newPos, cell = tes3.mobilePlayer.cell })
    else
        debug("no safe pos found")
    end
end

--Transpose effect : Loot items from in radius of collision
---@param e tes3magicEffectCollisionEventData
local function onTranspose(e)
    -- local config = require("BeefStranger.StrangeMagic.config")
    if e.collision then
        -- debug("collision - %s", e.collision)
        -- debug("colliderRef - %s", e.collision.colliderRef)
        -- debug("collision - %s", e.collision.normal)
        -- tes3.playSound{sound = bs.bsSound.fantasyUI5}
        local closest = nil                                                           --Variable for storing the nearest item if nothing was in range
        local colRef, colPoint = e.collision.colliderRef, e.collision.point
        local collisionCell = colRef and colRef.cell or tes3.getCell { position = colPoint }
        -- debug("collisionCell = %s", collisionCell)

        for ref in collisionCell:iterateReferences(iterateRefs) do     --Set ref to every object in cell, that matches a type in iterateRefs table
            local distance = (e.collision.point:distance(ref.position) / 22.1)        --The distance between the collision point and the position of the iterated ref
            local range = math.max((bs.getEffect(e, transpose.id).radius + 1.5), 1.5) --Range is either the effect radius + 1.5 or 1.5, whatever is bigger
            local inRange = (distance <= range)                                       --Returns true if distance to ref is in range of the spell

            -- Note about range/radius, things can be hit in the visual radius but outside of the actual radius,
            -- not by much but it still happens. Most noticable at 0 radius, it will fail to impact items
            -- like 95% of the time. Setting a min value of 1.5 seems to help, and adding 1.5 makes it
            -- about equal with the visual radius of the effect. Otherwise things in the circle might not
            -- actually be hit even though visually it was.

            if inRange then
                transfer(ref)
                addItem(ref)

                if being[ref.object.objectType] and (ref.mobile.isDead == false) and ((config.combatOnly and ref.mobile.inCombat) or (not config.combatOnly)) then
                    teleport(ref)
                end
            end

            if not inRange then
                if distance <= 5 then
                    if closest == nil or distance < e.collision.point:distance(ref.position) / 22.1 then
                        closest = ref
                        transfer(closest)
                        addItem(closest)
                    end
                end
            end
        end

        if next(looted) then --Check if anything has been put in the looted table
            debug("%s", inspect(looted))
            info.createLootNotification(looted) --Create the loot UI
            looted = {} --Clear the table
        else
            -- debug("Nothing looted")
        end
    end
end

local function addEffects()
    local bsTranspose = bs.effect.create({
        id = transpose.id,
        name = "Transposistion",
        school = tes3.magicSchool["mysticism"],

        baseCost = 150,
        speed = 10,
        hitSound = bs.bsSound.fantasyUI5,
        -- castSound = bs.bsSound.magicImpact,
        areaSound = bs.bsSound.fantasyUI6,
        -- boltSound = bs.bsSound.magicImpact,


        allowSpellmaking = true,
        hasNoMagnitude = true,
        hasNoDuration = true,
        canCastSelf = false,
        onCollision = onTranspose
    })
end
event.register("magicEffectsResolved", addEffects)
