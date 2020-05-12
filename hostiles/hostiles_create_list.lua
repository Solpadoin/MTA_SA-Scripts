-----------------------------------------
----- REVISION CREATED BY SOLPADOIN -----
-----------------------------------------
--- *** HEAVY MODIFIED SCRIPT *** ---

--- ORIGINAL Zombies LOGIC DONE BY SLOTHMAN -> https://community.multitheftauto.com/index.php?p=resources&s=details&id=347 ---

--- *** THIS FILE IS BLANK FILE TO CREATE YOUR CUSTOM HOSTILES *** ---






--- EN: Use this function if you want to init hostiles once per resource start. ---
--- RU: Используйте эту функцию, если хотите создать враждебного бота только один раз, при запуске ресурса. ---
function initFunction()
	--[[local player = getRandomPlayer ( )
	local x,y,z = getElementPosition(player)
	createHostilePed ( x, y, z + 2 )
	createHostilePed ( x, y, z + 3, 31 )
	createHostilePed ( x, y, z + 3, 30 )]]--
	
	
	-- to do --
end














---- DON'T EDIT THIS! ---
function main(startedResource)
	if startedResource == getThisResource() then
		setTimer ( initFunction, 1000, 1 )
	end
end
addEventHandler("onResourceStart", getRootElement(getThisResource()), main)