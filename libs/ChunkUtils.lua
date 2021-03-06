if chunkUtilsG then
    return chunkUtilsG
end
local chunkUtils = {}

-- imports

local stringUtils = require("StringUtils")
local baseUtils = require("BaseUtils")
local constants = require("Constants")
local mapUtils = require("MapUtils")
local chunkPropertyUtils = require("ChunkPropertyUtils")

-- constants

local DEFINES_WIRE_TYPE_RED = defines.wire_type.red
local DEFINES_WIRE_TYPE_GREEN = defines.wire_type.green

local CHUNK_PASS_THRESHOLD = constants.CHUNK_PASS_THRESHOLD

local SENTINEL_IMPASSABLE_CHUNK = constants.SENTINEL_IMPASSABLE_CHUNK

local AI_STATE_ONSLAUGHT = constants.AI_STATE_ONSLAUGHT

local BASE_PHEROMONE = constants.BASE_PHEROMONE
local PLAYER_PHEROMONE = constants.PLAYER_PHEROMONE
local MOVEMENT_PHEROMONE = constants.MOVEMENT_PHEROMONE
local RESOURCE_PHEROMONE = constants.RESOURCE_PHEROMONE
local BUILDING_PHEROMONES = constants.BUILDING_PHEROMONES

local CHUNK_SIZE = constants.CHUNK_SIZE
local CHUNK_SIZE_DIVIDER = constants.CHUNK_SIZE_DIVIDER

local CHUNK_NORTH_SOUTH = constants.CHUNK_NORTH_SOUTH
local CHUNK_EAST_WEST = constants.CHUNK_EAST_WEST

local CHUNK_ALL_DIRECTIONS = constants.CHUNK_ALL_DIRECTIONS
local CHUNK_IMPASSABLE = constants.CHUNK_IMPASSABLE

local RESOURCE_NORMALIZER = constants.RESOURCE_NORMALIZER

local CHUNK_TICK = constants.CHUNK_TICK

-- imported functions

local isRampant = stringUtils.isRampant
local setNestCount = chunkPropertyUtils.setNestCount
local setPlayerBaseGenerator = chunkPropertyUtils.setPlayerBaseGenerator
local addPlayerBaseGenerator = chunkPropertyUtils.addPlayerBaseGenerator
local setResourceGenerator = chunkPropertyUtils.setResourceGenerator
local addResourceGenerator = chunkPropertyUtils.addResourceGenerator
local setWormCount = chunkPropertyUtils.setWormCount
local getPlayerBaseGenerator = chunkPropertyUtils.getPlayerBaseGenerator
local getNestCount = chunkPropertyUtils.getNestCount
local setRaidNestActiveness = chunkPropertyUtils.setRaidNestActiveness
local setNestActiveness = chunkPropertyUtils.setNestActiveness

local findNearbyBase = baseUtils.findNearbyBase
local createBase = baseUtils.createBase

local upgradeEntity = baseUtils.upgradeEntity

local setChunkBase = chunkPropertyUtils.setChunkBase
local setPassable = chunkPropertyUtils.setPassable
local setPathRating = chunkPropertyUtils.setPathRating

local getChunkByXY = mapUtils.getChunkByXY

local mFloor = math.floor

local mRandom = math.random

-- module code

local function getEntityOverlapChunks(map, entity)
    local boundingBox = entity.prototype.collision_box or entity.prototype.selection_box;
    local overlapArray = map.chunkOverlapArray

    overlapArray[1] = SENTINEL_IMPASSABLE_CHUNK --LeftTop
    overlapArray[2] = SENTINEL_IMPASSABLE_CHUNK --RightTop
    overlapArray[3] = SENTINEL_IMPASSABLE_CHUNK --LeftBottom
    overlapArray[4] = SENTINEL_IMPASSABLE_CHUNK --RightBottom

    if boundingBox then
        local center = entity.position
        local topXOffset
        local topYOffset

        local bottomXOffset
        local bottomYOffset

        topXOffset = boundingBox.left_top.x
        topYOffset = boundingBox.left_top.y
        bottomXOffset = boundingBox.right_bottom.x
        bottomYOffset = boundingBox.right_bottom.y

        local leftTopChunkX = mFloor((center.x + topXOffset) * CHUNK_SIZE_DIVIDER) * CHUNK_SIZE
        local leftTopChunkY = mFloor((center.y + topYOffset) * CHUNK_SIZE_DIVIDER) * CHUNK_SIZE

        local rightTopChunkX = mFloor((center.x + bottomXOffset) * CHUNK_SIZE_DIVIDER) * CHUNK_SIZE
        local leftBottomChunkY = mFloor((center.y + bottomYOffset) * CHUNK_SIZE_DIVIDER) * CHUNK_SIZE

        overlapArray[1] = getChunkByXY(map, leftTopChunkX, leftTopChunkY) -- LeftTop
        if (leftTopChunkX ~= rightTopChunkX) then
            overlapArray[2] = getChunkByXY(map, rightTopChunkX, leftTopChunkY) -- RightTop
        end
        if (leftTopChunkY ~= leftBottomChunkY) then
            overlapArray[3] = getChunkByXY(map, leftTopChunkX, leftBottomChunkY) -- LeftBottom
        end
        if (leftTopChunkX ~= rightTopChunkX) and (leftTopChunkY ~= leftBottomChunkY) then
            overlapArray[4] = getChunkByXY(map, rightTopChunkX, leftBottomChunkY) -- RightBottom
        end
    end
    return overlapArray
end

local function scanPaths(chunk, surface, map)
    local pass = CHUNK_IMPASSABLE

    local x = chunk.x
    local y = chunk.y

    local filteredEntitiesCliffQuery = map.filteredEntitiesCliffQuery
    local filteredTilesPathQuery = map.filteredTilesPathQuery
    local count_entities_filtered = surface.count_entities_filtered
    local count_tiles_filtered = surface.count_tiles_filtered

    local passableNorthSouth = false
    local passableEastWest = false

    local topPosition = filteredEntitiesCliffQuery.area[1]
    local bottomPosition = filteredEntitiesCliffQuery.area[2]
    topPosition[2] = y
    bottomPosition[2] = y + 32

    for xi=x, x + 32 do
	topPosition[1] = xi
        bottomPosition[1] = xi + 1
	if (count_entities_filtered(filteredEntitiesCliffQuery) == 0) and
            (count_tiles_filtered(filteredTilesPathQuery) == 0)
        then
	    passableNorthSouth = true
	    break
	end
    end

    topPosition[1] = x
    bottomPosition[1] = x + 32

    for yi=y, y + 32 do
	topPosition[2] = yi
        bottomPosition[2] = yi + 1
	if (count_entities_filtered(filteredEntitiesCliffQuery) == 0) and
            (count_tiles_filtered(filteredTilesPathQuery) == 0)
        then
	    passableEastWest = true
	    break
	end
    end
    
    if passableEastWest and passableNorthSouth then
	pass = CHUNK_ALL_DIRECTIONS
    elseif passableEastWest then
	pass = CHUNK_EAST_WEST
    elseif passableNorthSouth then
	pass = CHUNK_NORTH_SOUTH
    end
    return pass
end

local function scorePlayerBuildings(surface, map)
    return (surface.count_entities_filtered(map.filteredEntitiesPlayerQuery50) * 50) +
        (surface.count_entities_filtered(map.filteredEntitiesPlayerQuery200) * 200) +
        (surface.count_entities_filtered(map.filteredEntitiesPlayerQuery1000) * 1000) +
        (surface.count_entities_filtered(map.filteredEntitiesPlayerQuery2000) * 2000) +
        (surface.count_entities_filtered(map.filteredEntitiesPlayerQuery3500) * 3500) +
        (surface.count_entities_filtered(map.filteredEntitiesPlayerQuery12000) * 12000)
end

function chunkUtils.initialScan(chunk, natives, surface, map, tick, evolutionFactor, rebuilding)
    local passScore = 1 - (surface.count_tiles_filtered(map.filteredTilesQuery) * 0.0009765625)

    if (passScore >= CHUNK_PASS_THRESHOLD) then
	local pass = scanPaths(chunk, surface, map)

	local playerObjects = scorePlayerBuildings(surface, map)
        
        local nests = surface.find_entities_filtered(map.filteredEntitiesUnitSpawnereQuery)

	if ((playerObjects > 0) or (#nests > 0)) and (pass == CHUNK_IMPASSABLE) then
	    pass = CHUNK_ALL_DIRECTIONS
	end

        if (pass ~= CHUNK_IMPASSABLE) then
            local worms = surface.find_entities_filtered(map.filteredEntitiesWormQuery)
            local resources = surface.count_entities_filtered(map.countResourcesQuery) * RESOURCE_NORMALIZER

            if natives.newEnemies and ((#nests > 0) or (#worms > 0)) then
                local nestCount = 0
                local wormCount = 0
                local base = findNearbyBase(map, chunk, natives)
                if base then
                    setChunkBase(map, chunk, base)
                else
                    base = createBase(map, natives, evolutionFactor, chunk, tick, rebuilding)
                end
                local alignment = base.alignment

                for _, unit in pairs(surface.find_entities_filtered(map.filteredEntitiesUnitQuery)) do                    
                    if (unit.valid) then
                        unit.destroy()
                    end
                end
                
                if (#nests > 0) then
                    for i = 1, #nests do
                        if rebuilding then
                            if not isRampant(nests[i].name) then
                                if upgradeEntity(nests[i], surface, alignment[mRandom(#alignment)], natives, evolutionFactor) then
                                    nestCount = nestCount + 1
                                end
                            else
                                nestCount = nestCount + 1
                            end
                        else
                            if upgradeEntity(nests[i], surface, alignment[mRandom(#alignment)], natives, evolutionFactor) then
                                nestCount = nestCount + 1
                            end
                        end
                    end
                end
                if (#worms > 0) then
                    for i = 1, #worms do
                        if rebuilding then
                            if not isRampant(worms[i].name) then
                                if upgradeEntity(worms[i], surface, alignment[mRandom(#alignment)], natives, evolutionFactor) then
                                    wormCount = wormCount + 1
                                end
                            else
                                wormCount = wormCount + 1
                            end
                        else
                            if upgradeEntity(worms[i], surface, alignment[mRandom(#alignment)], natives, evolutionFactor) then
                                wormCount = wormCount + 1
                            end
                        end
                    end
                end
                setNestCount(map, chunk, nestCount)
                setWormCount(map, chunk, wormCount)
            else
                setNestCount(map, chunk, #nests)
                setWormCount(map, chunk, #worms)
            end

            setPlayerBaseGenerator(map, chunk, playerObjects)
            setResourceGenerator(map, chunk, resources)

            setPassable(map, chunk, pass)
            setPathRating(map, chunk, passScore)

            return chunk
        end
    end

    return SENTINEL_IMPASSABLE_CHUNK
end

function chunkUtils.chunkPassScan(chunk, surface, map)
    local passScore = 1 - (surface.count_tiles_filtered(map.filteredTilesQuery) * 0.0009765625)

    if (passScore >= CHUNK_PASS_THRESHOLD) then
	local pass = scanPaths(chunk, surface, map)

	local playerObjects = getPlayerBaseGenerator(map, chunk)

	local nests = getNestCount(map, chunk)

	if ((playerObjects > 0) or (nests > 0)) and (pass == CHUNK_IMPASSABLE) then
	    pass = CHUNK_ALL_DIRECTIONS
	end

	setPassable(map, chunk, pass)
	setPathRating(map, chunk, passScore)

	return chunk
    end

    return SENTINEL_IMPASSABLE_CHUNK
end

function chunkUtils.mapScanChunk(chunk, surface, map)
    local playerObjects = scorePlayerBuildings(surface, map)
    setPlayerBaseGenerator(map, chunk, playerObjects)
    local resources = surface.count_entities_filtered(map.countResourcesQuery) * RESOURCE_NORMALIZER
    setResourceGenerator(map, chunk, resources)
    local nests = surface.count_entities_filtered(map.filteredEntitiesUnitSpawnereQuery)
    setNestCount(map, chunk, nests)
    local worms = surface.count_entities_filtered(map.filteredEntitiesWormQuery)
    setWormCount(map, chunk, worms)
end

function chunkUtils.entityForPassScan(map, entity)
    local overlapArray = getEntityOverlapChunks(map, entity)

    for i=1,#overlapArray do
        local chunk = overlapArray[i]
        if (chunk ~= SENTINEL_IMPASSABLE_CHUNK) then
            map.chunkToPassScan[chunk] = true
        end
    end
end

function chunkUtils.createChunk(topX, topY)
    local chunk = {
	x = topX,
	y = topY
    }
    chunk[MOVEMENT_PHEROMONE] = 0
    chunk[BASE_PHEROMONE] = 0
    chunk[PLAYER_PHEROMONE] = 0
    chunk[RESOURCE_PHEROMONE] = 0
    chunk[CHUNK_TICK] = 0

    return chunk
end

function chunkUtils.colorChunk(x, y, tileType, surface)
    local tiles = {}
    for xi=x+5, x + 27 do
	for yi=y+5, y + 27 do
	    tiles[#tiles+1] = {name=tileType, position={xi, yi}}
	end
    end
    surface.set_tiles(tiles, false)
end

function chunkUtils.registerEnemyBaseStructure(map, entity, base)
    local entityType = entity.type
    if ((entityType == "unit-spawner") or (entityType == "turret")) and (entity.force.name == "enemy") then
	local overlapArray = getEntityOverlapChunks(map, entity)

        local lookup
        if (entityType == "unit-spawner") then
            lookup = map.chunkToNests
        elseif (entityType == "turret") then
            lookup = map.chunkToWorms
        end      

        for i=1,#overlapArray do
            local chunk = overlapArray[i]
            if (chunk ~= SENTINEL_IMPASSABLE_CHUNK) then
                lookup[chunk] = (lookup[chunk] or 0) + 1
                setChunkBase(map, chunk, base)
            end
        end
    end

    return entity
end

function chunkUtils.unregisterEnemyBaseStructure(map, entity)
    local entityType = entity.type
    if ((entityType == "unit-spawner") or (entityType == "turret")) and (entity.force.name == "enemy") then
	local overlapArray = getEntityOverlapChunks(map, entity)

        local mainLookup
        local secondaryLookup
        if (entityType == "unit-spawner") then
            mainLookup = map.chunkToNests
            secondaryLookup = map.chunkToWorms
        elseif (entity.type == "turret") then
            mainLookup = map.chunkToWorms
            secondaryLookup = map.chunkToNests            
        end

        for i=1,#overlapArray do
            local chunk = overlapArray[i]
            if (chunk ~= SENTINEL_IMPASSABLE_CHUNK) then
                local count = mainLookup[chunk]
                if count then
                    if (count <= 1) then
                        if (entityType == "unit-spawner") then
                            setRaidNestActiveness(map, chunk, 0)
                            setNestActiveness(map, chunk, 0)
                        end
                        mainLookup[chunk] = nil
                        if not secondaryLookup[chunk] then
                            setChunkBase(map, chunk, nil)
                        end
                    else
                        mainLookup[chunk] = count - 1
                    end
                end
            end
        end
        
    end
end

function chunkUtils.accountPlayerEntity(map, entity, natives, addObject, creditNatives)

    if (BUILDING_PHEROMONES[entity.type] ~= nil) and (entity.force.name ~= "enemy") then
        local entityValue = BUILDING_PHEROMONES[entity.type]

        local overlapArray = getEntityOverlapChunks(map, entity)
        if not addObject then
            if creditNatives then
                if (natives.state == AI_STATE_ONSLAUGHT) then
                    natives.points = natives.points + entityValue
                else
                    natives.points = natives.points + (entityValue * 0.12)
                end
            end
            entityValue = -entityValue
        end

        for i=1,#overlapArray do
            local chunk = overlapArray[i]
            if (chunk ~= SENTINEL_IMPASSABLE_CHUNK) then
                addPlayerBaseGenerator(map, chunk, entityValue)
            end
        end
    end
    return entity
end

function chunkUtils.unregisterResource(entity, map)
    if entity.prototype.infinite_resource then
        return
    end
    local overlapArray = getEntityOverlapChunks(map, entity)

    for i=1,#overlapArray do
        local chunk = overlapArray[i]
        if (chunk ~= SENTINEL_IMPASSABLE_CHUNK) then
            addResourceGenerator(map, chunk, -RESOURCE_NORMALIZER)
        end
    end        
end


function chunkUtils.makeImmortalEntity(surface, entity)
    local repairPosition = entity.position
    local repairName = entity.name
    local repairForce = entity.force
    local repairDirection = entity.direction

    local wires
    if (entity.type == "electric-pole") then
        wires = entity.neighbours
    end
    entity.destroy()
    local newEntity = surface.create_entity({position=repairPosition,
                                             name=repairName,
                                             direction=repairDirection,
                                             force=repairForce})
    if wires then
        for _,v in pairs(wires.copper) do
            if (v.valid) then
                newEntity.connect_neighbour(v);
            end
        end
        for _,v in pairs(wires.red) do
            if (v.valid) then
                newEntity.connect_neighbour({wire = DEFINES_WIRE_TYPE_RED, target_entity = v});
            end
        end
        for _,v in pairs(wires.green) do
            if (v.valid) then
                newEntity.connect_neighbour({wire = DEFINES_WIRE_TYPE_GREEN, target_entity = v});
            end
        end
    end

    newEntity.destructible = false
end

chunkUtilsG = chunkUtils
return chunkUtils
