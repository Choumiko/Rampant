-- imports

local acidBall = require("utils/AttackBall")
local biterUtils = require("utils/BiterUtils")
local swarmUtils = require("SwarmUtils")
package.path = "../libs/?.lua;" .. package.path
local constants = require("Constants")

-- constants

local neutral = {}

local NEUTRAL_UNIT_TIERS = constants.NEUTRAL_UNIT_TIERS
local NEUTRAL_UNIT_VARIATIONS = constants.NEUTRAL_UNIT_VARIATIONS

local NEUTRAL_NEST_TIERS = constants.NEUTRAL_NEST_TIERS
local NEUTRAL_NEST_VARIATIONS = constants.NEUTRAL_NEST_VARIATIONS

local NEUTRAL_WORM_TIERS = constants.NEUTRAL_WORM_TIERS
local NEUTRAL_WORM_VARIATIONS = constants.NEUTRAL_WORM_VARIATIONS

-- imported functions

local buildUnitSpawner = swarmUtils.buildUnitSpawner
local buildWorm = swarmUtils.buildWorm
local createAttackBall = acidBall.createAttackBall

local createRangedAttack = biterUtils.createRangedAttack

local createMeleeAttack = biterUtils.createMeleeAttack

local softSmoke = "the-soft-smoke-rampant"

local makeUnitAlienLootTable = biterUtils.makeUnitAlienLootTable
local makeSpawnerAlienLootTable = biterUtils.makeSpawnerAlienLootTable
local makeWormAlienLootTable = biterUtils.makeWormAlienLootTable

function neutral.addFaction()

    local biterLoot = makeUnitAlienLootTable(nil)
    local spawnerLoot = makeSpawnerAlienLootTable(nil)
    local wormLoot = makeWormAlienLootTable(nil)

    -- neutral biters
    buildUnitSpawner(
	{
	    unit = {
		name = "neutral-biter",

		loot = biterLoot,
		attributes = {
		    explosion = "blood-explosion-small"
		},
		attack = {},
		resistances = {},

		type = "biter",
		tint1 = {r=0.56, g=0.46, b=0.42, a=0.65},
		tint2 = {r=1, g=0.63, b=0, a=0.4}
	    },

	    unitSpawner = {
		name = "neutral-biter-nest",

		loot = spawnerLoot,
		attributes = {},	    
		resistances = {},
		tint = {r=0.56, g=0.46, b=0.42, a=0.65}
	    }
	},

	{
	    unit = {

		{		
		    type = "attack",
		    name = "damage",
		    [1] = 7,
		    [2] = 15,
		    [3] = 22.5,
		    [4] = 35,
		    [5] = 45,
		    [6] = 60,
		    [7] = 75,
		    [8] = 90,
		    [9] = 150,
		    [10] = 200
		},

		{
		    type = "resistance",
		    name = "physical",
		    decrease = {
			[1] = 0,
			[2] = 0,
			[3] = 4,
			[4] = 5,
			[5] = 6,
			[6] = 8,
			[7] = 10,
			[8] = 12,
			[9] = 14,
			[10] = 15
		    },
		    percent = {
			[1] = 0,
			[2] = 0,
			[3] = 0,
			[4] = 10,
			[5] = 12,
			[6] = 12,
			[7] = 13,
			[8] = 13,
			[9] = 14,
			[10] = 15
		    }
		},
		
		{
		    type = "resistance",
		    name = "explosion",
		    decrease = {
			[1] = 0,
			[2] = 0,
			[3] = 0,
			[4] = 0,
			[5] = 0,
			[6] = 0,
			[7] = 10,
			[8] = 12,
			[9] = 14,
			[10] = 15
		    },
		    percent = {
			[1] = 0,
			[2] = 0,
			[3] = 0,
			[4] = 10,
			[5] = 12,
			[6] = 12,
			[7] = 13,
			[8] = 13,
			[9] = 14,
			[10] = 15
		    }
		},

		
	    },
	    
	    unitSpawner = {

		{		
		    type = "attribute",
		    name = "evolutionRequirement",
		    [1] = 0,
		    [2] = 0.12,
		    [3] = 0.22,
		    [4] = 0.32,
		    [5] = 0.42,
		    [6] = 0.52,
		    [7] = 0.62,
		    [8] = 0.72,
		    [9] = 0.82,
		    [10] = 0.92
		},
		
		{
		    type = "resistance",
		    name = "physical",
		    decrease = {
			[1] = 2,
			[2] = 2,
			[3] = 4,
			[4] = 4,
			[5] = 6,
			[6] = 6,
			[7] = 10,
			[8] = 12,
			[9] = 12,
			[10] = 14
		    },
		    percent = {
			[1] = 15,
			[2] = 15,
			[3] = 17,
			[4] = 17,
			[5] = 18,
			[6] = 18,
			[7] = 19,
			[8] = 19,
			[9] = 20,
			[10] = 20
		    }
		},

		{
		    type = "resistance",
		    name = "explosion",
		    decrease = {
			[1] = 5,
			[2] = 5,
			[3] = 6,
			[4] = 6,
			[5] = 7,
			[6] = 7,
			[7] = 8,
			[8] = 8,
			[9] = 9,
			[10] = 9
		    },
		    percent = {
			[1] = 15,
			[2] = 15,
			[3] = 17,
			[4] = 17,
			[5] = 18,
			[6] = 18,
			[7] = 19,
			[8] = 19,
			[9] = 20,
			[10] = 20
		    }
		},

		{
		    type = "resistance",
		    name = "fire",
		    decrease = {
			[1] = 3,
			[2] = 3,
			[3] = 4,
			[4] = 4,
			[5] = 6,
			[6] = 6,
			[7] = 6,
			[8] = 6,
			[9] = 7,
			[10] = 7
		    },
		    percent = {
			[1] = 60,
			[2] = 60,
			[3] = 62,
			[4] = 62,
			[5] = 63,
			[6] = 63,
			[7] = 64,
			[8] = 64,
			[9] = 65,
			[10] = 65
		    }
		}
	    }
	},

	createMeleeAttack,

	{
	    unit = NEUTRAL_UNIT_VARIATIONS,
	    unitSpawner = NEUTRAL_NEST_VARIATIONS
	},

	{
	    unit = NEUTRAL_UNIT_TIERS,
	    unitSpawner = NEUTRAL_NEST_TIERS
	}
    )

    -- neutral spitters
    buildUnitSpawner(
	{
	    unit = {
		name = "neutral-spitter",

		loot = biterLoot,
		attributes = {
		    explosion = "blood-explosion-small"
		},
		attack = {
		    type = "projectile",
		    directionOnly = true,
		    softSmokeName = softSmoke
		},
		resistances = {},

		type = "spitter",
		attackName = "neutral-spitter",
		tint = {r=0.56, g=0.46, b=0.42, a=1},
		pTint = {r=0, g=1, b=1, a=0.5},
		sTint = {r=0, g=1, b=1, a=0.5}
	    },

	    unitSpawner = {
		name = "neutral-spitter-nest",

		loot = spawnerLoot,
		attributes = {},
		resistances = {},
		
		tint = {r=0.99, g=0.09, b=0.09, a=1}
	    }
	},

	{
	    unit = {

		{		
		    type = "attack",
		    name = "damage",
		    [1] = 4,
		    [2] = 9,
		    [3] = 14,
		    [4] = 23,
		    [5] = 30,
		    [6] = 37,
		    [7] = 45,
		    [8] = 57,
		    [9] = 70,
		    [10] = 80
		},
			
		{
		    type = "resistance",
		    name = "explosion",
		    percent = {
			[1] = 0,
			[2] = 0,
			[3] = 10,
			[4] = 10,
			[5] = 20,
			[6] = 20,
			[7] = 30,
			[8] = 30,
			[9] = 40,
			[10] = 40
		    }
		},

		{
		    type = "attack",
		    name = "range",
		    [1] = 13,
		    [2] = 13,
		    [3] = 14,
		    [4] = 14,
		    [5] = 15,
		    [6] = 15,
		    [7] = 16,
		    [8] = 16,
		    [9] = 17,
		    [10] = 17
		},

		{
		    type = "attack",
		    name = "radius",
		    [1] = 1.2,
		    [2] = 1.3,
		    [3] = 1.4,
		    [4] = 1.5,
		    [5] = 1.6,
		    [6] = 1.7,
		    [7] = 1.8,
		    [8] = 1.9,
		    [9] = 2.0,
		    [10] = 2.5
		}

	    },
	    
	    unitSpawner = {

		{
		    type = "resistance",
		    name = "physical",
		    decrease = {
			[1] = 2,
			[2] = 2,
			[3] = 4,
			[4] = 4,
			[5] = 6,
			[6] = 6,
			[7] = 10,
			[8] = 12,
			[9] = 12,
			[10] = 14
		    },
		    percent = {
			[1] = 15,
			[2] = 15,
			[3] = 17,
			[4] = 17,
			[5] = 18,
			[6] = 18,
			[7] = 19,
			[8] = 19,
			[9] = 20,
			[10] = 20
		    }
		},

		{
		    type = "resistance",
		    name = "explosion",
		    decrease = {
			[1] = 5,
			[2] = 5,
			[3] = 6,
			[4] = 6,
			[5] = 7,
			[6] = 7,
			[7] = 8,
			[8] = 8,
			[9] = 9,
			[10] = 9
		    },
		    percent = {
			[1] = 15,
			[2] = 15,
			[3] = 17,
			[4] = 17,
			[5] = 18,
			[6] = 18,
			[7] = 19,
			[8] = 19,
			[9] = 20,
			[10] = 20
		    }
		},
		{
		    type = "resistance",
		    name = "fire",
		    decrease = {
			[1] = 3,
			[2] = 3,
			[3] = 4,
			[4] = 4,
			[5] = 6,
			[6] = 6,
			[7] = 6,
			[8] = 6,
			[9] = 7,
			[10] = 7
		    },
		    percent = {
			[1] = 60,
			[2] = 60,
			[3] = 62,
			[4] = 62,
			[5] = 63,
			[6] = 63,
			[7] = 64,
			[8] = 64,
			[9] = 65,
			[10] = 65
		    }
		}	    
	    }
	},

	function (attributes)
	    return createRangedAttack(attributes,
				      createAttackBall(attributes),
				      spitterattackanimation(attributes.scale,
							     attributes.tint))
	end,
	
	{
	    unit = NEUTRAL_UNIT_VARIATIONS,
	    unitSpawner = NEUTRAL_NEST_VARIATIONS
	},

	{
	    unit = NEUTRAL_UNIT_TIERS,
	    unitSpawner = NEUTRAL_NEST_TIERS
	}
    )

    -- neutral worms
    buildWorm(
	{
	    name = "neutral-worm",

	    loot = wormLoot,	    
	    attributes = {},
	    attack = {
		type = "projectile",
		softSmokeName = softSmoke
	    },
	    resistances = {},

	    attackName = "neutral-worm",
	    tint = {r=0.56, g=0.46, b=0.42, a=0.65},
	    pTint = {r=0, g=1, b=1, a=0.5},
	    sTint = {r=0, g=1, b=1, a=0.5}
	},

	{

	    {    
		type = "attack",
		name = "damage",
		[1] = 12,
		[2] = 20,
		[3] = 25,
		[4] = 30,
		[5] = 35,
		[6] = 40,
		[7] = 50,
		[8] = 60,
		[9] = 70,
		[10] = 80
	    },
	    
	    {
		type = "resistance",
		name = "physical",
		decrease = {
		    [1] = 0,
		    [2] = 0,
		    [3] = 5,
		    [4] = 5,
		    [5] = 8,
		    [6] = 8,
		    [7] = 10,
		    [8] = 10,
		    [9] = 12,
		    [10] = 12
		}
	    },

	    {
		type = "resistance",
		name = "explosion",
		decrease = {
		    [1] = 0,
		    [2] = 0,
		    [3] = 5,
		    [4] = 5,
		    [5] = 8,
		    [6] = 8,
		    [7] = 10,
		    [8] = 10,
		    [9] = 12,
		    [10] = 12
		},
		percent = {
		    [1] = 0,
		    [2] = 0,
		    [3] = 10,
		    [4] = 10,
		    [5] = 20,
		    [6] = 20,
		    [7] = 30,
		    [8] = 30,
		    [9] = 40,
		    [10] = 40
		}
	    },

	    {
		type = "resistance",
		name = "fire",
		decrease = {
		    [1] = 3,
		    [2] = 3,
		    [3] = 4,
		    [4] = 4,
		    [5] = 6,
		    [6] = 6,
		    [7] = 6,
		    [8] = 6,
		    [9] = 7,
		    [10] = 7
		},
		percent = {
		    [1] = 70,
		    [2] = 70,
		    [3] = 72,
		    [4] = 72,
		    [5] = 73,
		    [6] = 73,
		    [7] = 74,
		    [8] = 74,
		    [9] = 75,
		    [10] = 75
		}
	    },

	    {
		type = "attack",
		name = "radius",
		[1] = 1.5,
		[2] = 1.6,
		[3] = 1.7,
		[4] = 1.8,
		[5] = 1.9,
		[6] = 2.0,
		[7] = 2.2,
		[8] = 2.3,
		[9] = 2.5,
		[10] = 3.0
	    }
	},

	function (attributes)
	    return createRangedAttack(attributes,
				      createAttackBall(attributes))
	end,

	NEUTRAL_WORM_VARIATIONS,
	NEUTRAL_WORM_TIERS
    )
end


return neutral
