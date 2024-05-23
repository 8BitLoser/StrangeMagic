local bs = require("BeefStranger.functions")
local info = require("BeefStranger.StrangeMagic.common")

local debug = info.debug
local blink = info.magic.blink

--- Checks if the player can stand at the specified position
---@param position tes3vector3
---@return boolean
local function canStandAt(position)
    local halfHeight = tes3.player.object.boundingBox.max.z / 2
    local feetPosition = position + tes3vector3.new(0, 0, halfHeight)
    local headPosition = position - tes3vector3.new(0, 0, halfHeight)

    local rayTestFeet = tes3.rayTest{
        position = feetPosition,
        direction = tes3vector3.new(0, 0, -1),
        ignore = { tes3.player }
    }

    local rayTestHead = tes3.rayTest{
        position = headPosition,
        direction = tes3vector3.new(0, 0, 1),
        ignore = { tes3.player }
    }

    return not (rayTestFeet or rayTestHead)
end

--- Adjust the position until a valid spot is found
---@param position tes3vector3
---@return tes3vector3
local function findValidPosition(position)
    local stepSize = 50
    local maxAttempts = 20
    local attempts = 0

    while not canStandAt(position) and attempts < maxAttempts do
        debug("position attempt %s", attempts)
        position = position - tes3vector3.new(0, 0, stepSize)
        attempts = attempts + 1
    end

    return position
end


---@param e tes3magicEffectCollisionEventData
local function onCollision(e)
    if e.collision then
        debug("Collision")
        local ref = e.collision.colliderRef
        local point = e.collision.point
        -- local result = tes3.rayTest{
        --     position = point,
        --     direction = tes3vector3.new(0, 0, -1),
        --     ignore = {ref, tes3.player},
        --     returnNormal = true,
        --     useBackTriangles = false,
        --     -- root = e.terrainOnly and tes3.game.worldLandscapeRoot or nil,
        --     maxDistance = 500
        -- }

        local validPos = findValidPosition(point)
        debug("point %s - valid %s", point, e.collision.valid)
        tes3.positionCell{reference = tes3.player, position = point, forceCellChange = true, suppressFader = true}

    end
end


event.register(tes3.event.magicEffectsResolved, function ()
    bs.effect.create({
        name = blink.name,
        id = blink.id,
        school = blink.school,
        description = "Placeholder",

        baseCost = 1,
        speed = 8,

        allowEnchanting = true,
        allowSpellmaking = true,
        canCastSelf = true,
        canCastTarget = true,
        canCastTouch = true,

        onTick = nil,
        onCollision = onCollision
    })
end)
