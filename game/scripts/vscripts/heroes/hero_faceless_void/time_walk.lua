--[[Author: Pizzalol
	Date: 21.09.2015.
	Prepares all the required information for movement]]
function TimeWalk( keys )
	local caster = keys.caster
	local caster_location = caster:GetAbsOrigin()
	local target_point = keys.target_points[1]
	local ability = keys.ability
	local modifier = keys.modifier

	-- Distance calculations
	local speed = ability:GetLevelSpecialValueFor("speed", (ability:GetLevel() - 1))
	local distance = (target_point - caster_location):Length2D()
	local direction = (target_point - caster_location):Normalized()
	local duration = distance/speed

	-- Saving the data in the ability
	ability.time_walk_distance = distance
	ability.time_walk_speed = speed * 1/30 -- 1/30 is how often the motion controller ticks
	ability.time_walk_direction = direction
	ability.time_walk_traveled_distance = 0

	-- Apply the slow aura and invlunerability modifier to the caster
	ability:ApplyDataDrivenModifier(caster, caster, modifier, {duration = duration})
end

--[[Author: Pizzalol
	Date: 21.09.2015.
	Moves the target until it has traveled the distance to the chosen point]]
function TimeWalkMotion( keys )
	local caster = keys.target
	local ability = keys.ability

	-- Move the caster while the distance traveled is less than the original distance upon cast
	if ability.time_walk_traveled_distance < ability.time_walk_distance then
		caster:SetAbsOrigin(caster:GetAbsOrigin() + ability.time_walk_direction * ability.time_walk_speed)
		ability.time_walk_traveled_distance = ability.time_walk_traveled_distance + ability.time_walk_speed
	else
		-- Remove the motion controller once the distance has been traveled
		caster:InterruptMotionControllers(false)
	end
end

--[[Author: YOLOSPAGHETTI
	Date: 14.01.2016
	Creates an array of all taken damage within last 2 seconds]]
function CalculateDamage( keys )
	local damage_taken = keys.DamageTaken
	local backtrack_time = keys.BacktrackTime
	
	-- Temporary damage array and index
	local temp = {}
	local temp_index = 0
	
	-- Global damage array and index
	local caster_index = 0
	if caster_damage == nil then
		caster_damage = {}
	end
	
	-- Sets the damage and game time values in the tempororary array, if caster was attacked within 2 seconds of current time
	-- Even indexes are damage values, odd are game times
	
	while caster_damage do
		if caster_damage[caster_index] == nil then
		break
		elseif Time() - caster_damage[caster_index+1] <= backtrack_time then
			temp[temp_index] = caster_damage[caster_index]
			temp[temp_index+1] = caster_damage[caster_index+1]
			temp_index = temp_index + 2
		end
		caster_index = caster_index + 2
	end
	
	-- Places most recent damage and current time in the temporary array
	temp[temp_index] = damage_taken
	temp[temp_index+1] = Time()
	
	-- Sets the global array as the temporary array
	caster_damage = temp
end

--[[Author: YOLOSPAGHETTI
	Date: 14.01.2016
	Removes all damage taken within 2 seconds of cast]]
function RemoveDamage ( keys )
	local caster = keys.caster
	local backtrack_time = keys.BacktrackTime
	local damage_sum = 0
	local caster_index = 0
	
	-- Sums damage over the last 2 seconds
	while caster_damage do
		if caster_damage[caster_index] == nil then
		break
		elseif Time() - caster_damage[caster_index+1] <= backtrack_time then
			damage_sum = damage_sum + caster_damage[caster_index]
		end
		caster_index = caster_index + 2
	end
	
	-- Adds damage to caster's current health
	caster:SetHealth(caster:GetHealth() + damage_sum)
end
