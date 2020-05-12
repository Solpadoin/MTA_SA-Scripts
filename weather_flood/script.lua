local WEATHER_RAIN = 8
local WATER_INCREMENT = 0.001
local MAX_WATER_LEVEL = 0.005
local MAX_WAVE_HEIGHT = 2
local MIN_WAVE_HEIGHT = 0.1

function restoreWeather()
	setRainLevel (0)
	setWeather (0)
	setWaterLevel (0)
	setWaveHeight (0)
end

function clamp(value, minimal, maximal)
	if (value <= minimal) then
		value = minimal
	elseif (value >= maximal) then
		value = maximal
	end
	
	return value
end

function addWaveHeight(height)
	local oldHeight = getWaveHeight()
	local height = tonumber ( height )
	setWaveHeight ( clamp(oldHeight + height, MIN_WAVE_HEIGHT, MAX_WAVE_HEIGHT) )
end

function interpolateBetween(value, minimal, maximal)
	if (value < minimal) then
		value = minimal
	elseif (value > maximal) then
		value = maximal
	end
	
	local center = ((minimal + maximal)/2)
	local value_central = (value + center)/10 -- * math.random(0.1, 0.5)
	return value_central
end

setTimer(function ()
	local weather_id = getWeather()
	
	if (weather_id == WEATHER_RAIN) then
		setRainLevel ( 2 )
		else
		setRainLevel ( 0 )
	end
	
	local rain_level = getRainLevel( )
	
	if (rain_level) then
		if (rain_level >= 1) then
			local x,y,z = getElementPosition(getLocalPlayer())
			local water_level = getWaterLevel ( x,y,z )
			
			if (water_level) then
				if (water_level < MAX_WATER_LEVEL) then
					setWaterLevel ( water_level + WATER_INCREMENT )
					else
					restoreWeather()
				end
			else
				--setWaterLevel ( water_level + WATER_INCREMENT )
			end
		end
		addWaveHeight(interpolateBetween(getWaveHeight(), MIN_WAVE_HEIGHT, MAX_WAVE_HEIGHT))
	end
end, 60000, 0)