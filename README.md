# Rampant Tactics
Factorio Mod - Improves the enemies tactics by using potential fields/pheromones allowing probing of defenses, retreats, and player hunting  

# Forum Post

https://forums.factorio.com/viewtopic.php?f=94&t=31445  

# Notes

0.14.10 factorio version fixed more pathing issues  
0.14.4 factorio version fixed some issues with unit groups commands  

There will be a slight pause the first time this is started up due to indexing all the chunks that have been generated.  

MP should be working  

# Features

Tactical Retreats - these will take place when a unit group is in a chunk that has reached a death threshold  
Unit Group Merging  - if multiple unit groups retreat at the same time there is a chance the groups will merge  
Unit Group Forming - any chunks with spawners in it that is covered by a pollution, player, player base, or player defense pheromone clouds will form groups based on the evolution factor  
Probing Behavior Against Defenses - unit groups will attempt to avoid chunks that are soaked in death  
Player Hunting  - unit groups will track the player based on there emitted pheromone cloud  
Pathfinding - unit groups will use potential fields to perform only single step pathfinding allowing for efficient and dynamic pathing  

# Planned Features

Tunneling Biters  
Fire Biters  
Suicide Biters  
infesting Biters  
Base Expansion  

# Version History

0.14.3 - slightly lowered Rampant attack wave frequency  
	Altered attack wave size to ramp up slower  
	Added configuration options for:  
		attack wave generation area  
		attack wave threshold  
		attack wave size  
		turn off rampant attack waves  

0.14.2 - adjusted unit retreat group size threshold   
	adjusted squad attack pattern (https://forums.factorio.com/viewtopic.php?f=94&t=31445&start=20#p203861)  
	Fixed migration issue   

0.14.1 - fixed ai created bases not being counted in logic   
	Optimization to offset ai created bases scanning   

0.13.3 = 0.14.3   

0.13.2 = 0.14.2   

0.13.1 - backported 0.14 factorio version to 0.13 factorio version   

0.0.8 - fixed retreat oscillations (https://forums.factorio.com/viewtopic.php?f=94&t=31445&start=10#p198750)   
	added scaling for kamikaze attack (https://forums.factorio.com/viewtopic.php?f=94&t=31445&start=10#p199401)   
	increased squad size max from 125 to 150, (larger waves)   

0.0.6 - some speed improvements   
	MP is working (https://github.com/veden/Rampant/issues/1)   

0.0.5 - fix for nil chunk in ai attack (https://mods.factorio.com/mods/Veden/Rampant/discussion/2512)   
	checks for main surface (https://forums.factorio.com/viewtopic.php?f=94&t=31445&p=198228#p198563)   
	updated info with forum homepage   
        
0.0.4 - initial release   
