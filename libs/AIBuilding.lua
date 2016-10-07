local aiBuilding = {}

-- imports

local constants = require("Constants")
local mapUtils = require("MapUtils")
local unitGroupUtils = require("UnitGroupUtils")
local neighborUtils = require("NeighborUtils")
package.path = "../?.lua;" .. package.path
local config = require("config")

-- constants

-- local SQUAD_GUARDING = constants.SQUAD_GUARDING
-- local SQUAD_BURROWING = constants.SQUAD_BURROWING

local PLAYER_BASE_PHEROMONE = constants.PLAYER_BASE_PHEROMONE
local PLAYER_PHEROMONE = constants.PLAYER_PHEROMONE
local PLAYER_DEFENSE_PHEROMONE = constants.PLAYER_DEFENSE_PHEROMONE
-- local ENEMY_BASE_PHEROMONE = constants.ENEMY_BASE_PHEROMONE
local DEATH_PHEROMONE = constants.DEATH_PHEROMONE

local AI_POINT_GENERATOR_AMOUNT = constants.AI_POINT_GENERATOR_AMOUNT
local AI_MAX_POINTS = constants.AI_MAX_POINTS

local ENEMY_BASE_GENERATOR = constants.ENEMY_BASE_GENERATOR

-- local AI_SCOUT_COST = constants.AI_SCOUT_COST
local AI_SQUAD_COST = constants.AI_SQUAD_COST
-- local AI_TUNNEL_COST = constants.AI_TUNNEL_COST

local AI_MAX_SQUAD_COUNT = constants.AI_MAX_SQUAD_COUNT

local HALF_CHUNK_SIZE = constants.HALF_CHUNK_SIZE
local CHUNK_SIZE = constants.CHUNK_SIZE

-- local MAGIC_MAXIMUM_NUMBER = constants.MAGIC_MAXIMUM_NUMBER

local NORTH_SOUTH_PASSABLE = constants.NORTH_SOUTH_PASSABLE
local EAST_WEST_PASSABLE = constants.EAST_WEST_PASSABLE

-- local COMMAND_GROUP = defines.command.group
-- local DISTRACTION_BY_DAMAGE = defines.distraction.by_damage

local CONFIG_USE_PLAYER_PROXIMITY = config.attackWaveGenerationUsePlayerProximity
local CONFIG_USE_PLAYER_BASE_PROXIMITY = config.attackWaveGenerationUsePlayerBaseProximity
local CONFIG_USE_PLAYER_DEFENSE_PROXIMITY = config.attackWaveGenerationUsePlayerDefenseProximity
local CONFIG_USE_POLLUTION_PROXIMITY = config.attackWaveGenerationUsePollution
local CONFIG_USE_THRESHOLD = config.attackWaveGenerationThreshold

-- imported functions

local getNeighborChunks = mapUtils.getNeighborChunks
local scoreNeighbors = neighborUtils.scoreNeighbors
local createSquad = unitGroupUtils.createSquad
local attackWaveScaling = config.attackWaveScaling

-- module code

local function attackWaveValidCandidate(chunk, surface)
    local total = 0;

    if CONFIG_USE_PLAYER_PROXIMITY then
	total = total + chunk[PLAYER_PHEROMONE]
    end
    if CONFIG_USE_PLAYER_BASE_PROXIMITY then
	total = total + chunk[PLAYER_BASE_PHEROMONE]
    end
    if CONFIG_USE_PLAYER_DEFENSE_PROXIMITY then
	total = total + chunk[PLAYER_DEFENSE_PHEROMONE]
    end
    if CONFIG_USE_POLLUTION_PROXIMITY then
	total = total + surface.get_pollution({chunk.pX, chunk.pY})
    end
    
    if (total >= CONFIG_USE_THRESHOLD) then
	return true
    else 
	return false
    end
end

local function scoreUnitGroupLocation(position, squad, neighborChunk, surface)
    local attackScore = surface.get_pollution(position) + neighborChunk[PLAYER_PHEROMONE] + neighborChunk[PLAYER_DEFENSE_PHEROMONE]  
    local avoidScore = neighborChunk[DEATH_PHEROMONE] 
    return attackScore - avoidScore
end

local function validUnitGroupLocation(x, chunk, neighborChunk)
    return neighborChunk[NORTH_SOUTH_PASSABLE] and neighborChunk[EAST_WEST_PASSABLE]
end

function aiBuilding.accumulatePoints(natives)
    if (natives.points < AI_MAX_POINTS) then
	natives.points = natives.points + math.floor(AI_POINT_GENERATOR_AMOUNT * math.random())
    end
end

function aiBuilding.removeScout(entity, natives)
    --[[
	local scouts = natives.scouts
	for i=1, #scouts do
	local scout = scouts[i]
	if (scout == entity) then
	tableRemove(scouts, i)
	return
	end
	end
    --]]
end

function aiBuilding.makeScouts(surface, natives, chunk, evolution_factor)
    --[[
	if (natives.points > AI_SCOUT_COST) then
	if (#global.natives.scouts < 5) and (math.random() < 0.05)  then -- TODO scaled with evolution factor
	local enemy = surface.find_nearest_enemy({ position = { x = chunk.pX + HALF_CHUNK_SIZE,
	y = chunk.pY + HALF_CHUNK_SIZE },
	max_distance = 100})
            
	if (enemy ~= nil) and enemy.valid and (enemy.type == "unit") then
	natives.points = natives.points - AI_SCOUT_COST
	global.natives.scouts[#global.natives.scouts+1] = enemy
	-- print(enemy, enemy.unit_number)
	end
	end
	end
    --]]
end

function aiBuilding.scouting(regionMap, natives)
    --[[
	local scouts = natives.scouts
	for i=1,#scouts do 
	local scout = scouts[i]
	if scout.valid then
	scout.set_command({type=defines.command.attack_area,
	destination={0,0},
	radius=32,
	distraction=defines.distraction.none})
	end
	end
    --]]
end



function aiBuilding.formSquads(regionMap, surface, natives, chunk, evolution_factor)
    if (natives.points > AI_SQUAD_COST) and (chunk[ENEMY_BASE_GENERATOR] ~= 0) and (#natives.squads < (AI_MAX_SQUAD_COUNT * evolution_factor)) then
	local valid = attackWaveValidCandidate(chunk, surface)
	if valid and (math.random() < 0.03) then
	    local squadPosition = {x=0, y=0}
	    local squadPath, squadScore = scoreNeighbors(chunk,
							 getNeighborChunks(regionMap, chunk.cX, chunk.cY),
							 validUnitGroupLocation,
							 scoreUnitGroupLocation,
							 nil,
							 surface,
							 squadPosition)
	    if (squadPath ~= nil) and (squadScore > 0) then
		squadPosition.x = squadPath.pX + HALF_CHUNK_SIZE
		squadPosition.y = squadPath.pY + HALF_CHUNK_SIZE
                
		local squad = createSquad(squadPosition, surface, natives)

		if (math.random() < 0.03) then
		    squad.rabid = true
		end
		
		local foundUnits = surface.set_multi_command({ command = { type = defines.command.group,
									   group = squad.group,
									   distraction = defines.distraction.none },
							       unit_count = attackWaveScaling(evolution_factor),
							       unit_search_distance = (CHUNK_SIZE * 2)})
		if (foundUnits > 0) then
		    natives.points = natives.points - AI_SQUAD_COST
		end
	    end
	end
    end
end

return aiBuilding
