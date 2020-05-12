-----------------------------------------
----- REVISION CREATED BY SOLPADOIN -----
-----------------------------------------
--- *** HEAVY MODIFIED SCRIPT *** ---

--- ORIGINAL Zombies LOGIC DONE BY SLOTHMAN -> https://community.multitheftauto.com/index.php?p=resources&s=details&id=347 ---

resourceName = getResourceName ( getThisResource() )
HostilesLimit = get(resourceName..".MaxHostiles") -- HOW MANY ENTITIES SHOULD EXIST AT MAXIMUM?
HostilesStreaming = get(resourceName..".StreamMethod") -- 1 to constantly stream zombies, 0 to only allow zombies to spawn via createZombie function, 2 to only allow spawning at set spawnpoints
IsOnlyGangSkins = get(resourceName..".IsOnlyGangSkins")
IsOnlyPoliceSkins = get(resourceName..".IsOnlyPoliceSkins")
IsWeaponDroppable = get(resourceName..".IsWeaponDroppable")
getDifficultLevel = get(resourceName..".getDifficultLevel")

outputChatBox(getDifficultLevel, root)

function array_concat(...)
    local t = {}

    for i = 1, arg.n do
        local array = arg[i]
        if (type(array) == "table") then
            for j = 1, #array do
                t[#t+1] = array[j]
            end
        else
            t[#t+1] = array
        end
    end

    return t
end

if (IsOnlyGangSkins == "true" or IsOnlyGangSkins == true) then
	HostilesPedSkins = { 105, 106, 107, 102, 103, 104, 108, 109, 110, 114, 115, 116, 173, 174, 175 } 
	
	if (IsOnlyPoliceSkins == "true" or IsOnlyPoliceSkins == true) then
		HostilesPedSkins = array_concat(HostilesPedSkins, { 265, 266, 267, 280, 281 })
	end
elseif (IsOnlyPoliceSkins == "true" or IsOnlyPoliceSkins == true) then
	HostilesPedSkins = { 265, 266, 267, 280, 281 }
else
	HostilesPedSkins = { 13,22,56,67,68,69,70,92,97,105,107,108,126,127,128,152,162,167,188,195,206,209,212,229,230,258,264,277,280 }
end

--HostilesPedSkins = {7,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,43,44,45,36,37,38,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,66,67,68,69,70,71,72,73,75,76,77,78,79,80,81,82,83,85,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,112,113,114,115,116,117,118,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,150,151,152,153,154,155,156,157,158,159,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207,209,210,211,212,213,214,215,216,217,218,219,229,230,231,232,233,234,235,236,237,238,239,240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255,256,257,258,259,260,261,262,263,264,275,276,277,278,279,280,281,282,283,284,286,288 }

HostilesSpeed = get(resourceName.."Speed")

if HostilesStreaming > 2 then
	HostilesStreaming = 1
end

MinMoney = tonumber(get(resourceName..".MinMoney"))
MaxMoney = tonumber(get(resourceName..".MaxMoney"))

if HostilesSpeed == 0 then --super slow zombies (goofy looking)
	chaseanim = "WALK_drunk"
	checkspeed = 2000
elseif HostilesSpeed == 1 then -- normal speed
	chaseanim = "run_old"
	checkspeed = 1000
elseif HostilesSpeed == 2 then -- rocket zombies (possibly stressful on server)
	chaseanim = "Run_Wuzi"
	checkspeed = 680
else -- defaults back to normal
	chaseanim = "run_old"
	checkspeed = 1000
end

resourceRoot = getResourceRootElement()
moancount =0
moanlimit = 3
everyZombie = { }

local maxZPerPlayer = 5

--IDLE BEHAVIOUR OF A hostiles
function Zomb_Idle (ped)
	if isElement(ped) then
		if ( getElementData ( ped, "hostiles_status" ) == "idle" ) and ( isPedDead ( ped ) == false ) and (getElementData (ped, "hostiles") == true) then
			local action = math.random( 1, 6 )
			if action < 4 then -- walk a random direction
				local rdmangle = math.random( 1, 359 )
				setPedRotation( ped, rdmangle )
				setPedAnimation ( ped, "PED", "Player_Sneak", -1, true, true, true)
				setTimer ( Zomb_Idle, 7000, 1, ped )
			elseif action == 4 then -- get on the ground
				setPedAnimation ( ped, "MEDIC", "cpr", -1, false, true, true)
				setTimer ( Zomb_Idle, 4000, 1, ped )
			elseif action == 5 then -- stand still doing nothing
				setPedAnimation ( ped )
				setTimer ( Zomb_Idle, 4000, 1, ped )
			end
		end
	end
end

--BEHAVIOUR WHILE CHASING PLAYERS
function Zomb_chase (ped, Zx, Zy, Zz )
	if isElement(ped) then
		if (getElementData ( ped, "hostiles_status" ) == "chasing") and (getElementData (ped, "hostiles") == true) then
			local x, y, z = getElementPosition( ped )
			if (getElementData ( ped, "hostiles_target" ) == nil) and getElementData ( ped, "Tx" ) ~= false then			
				local Px = getElementData ( ped, "Tx" )
				local Py = getElementData ( ped, "Ty" )
				local Pz = getElementData ( ped, "Tz" )
				local Pdistance = (getDistanceBetweenPoints3D( Px, Py, Pz, x, y, z ))
				if (Pdistance < 1.5 ) then
					setTimer ( function (ped) if ( isElement ( ped ) ) then setElementData ( ped, "hostiles_status", "idle" ) end end, 2000, 1, ped )
				end
			end
			local distance = (getDistanceBetweenPoints3D( x, y, z, Zx, Zy, Zz ))			
			if (distance < 150 ) then -- IF THE PED HASNT MOVED
				if (getElementData ( ped, "hostiles_target" ) == nil) then
					local giveup = math.random( 1, 15 )
					if giveup == 1 then
						setElementData ( ped, "hostiles_status", "idle" )
					else
						local action = math.random( 1, 5 )
						if action == 4 then
							setPedAnimation ( ped )
							triggerClientEvent ( "Hostiles_Punch", getRootElement(), ped )
							setTimer ( function (ped) if ( isElement ( ped ) ) then setPedAnimation ( ped, "ped", chaseanim, -1, true, true, true ) end end, 800, 1, ped )
							setTimer ( Zomb_chase, 1000, 1, ped, x, y, z )
						elseif action == 5 then
							setPedAnimation ( ped )
							triggerClientEvent ( "Hostiles_Jump", getRootElement(), ped )
							setTimer ( Zomb_chase, 1500, 1, ped, x, y, z )
						end
					end
				else 
					local Ptarget = (getElementData ( ped, "hostiles_target" ))
					if isElement(Ptarget) then
						local Px, Py, Pz = getElementPosition( Ptarget )
						local Pdistance = (getDistanceBetweenPoints3D( Px, Py, Pz, Zx, Zy, Zz ))
						if (Pdistance < 120 ) then -- ATTACK A PLAYER IF THEY ARE CLOSE
							if ( isPedDead ( Ptarget ) ) then --EAT A DEAD PLAYER
								setPedAnimation ( ped )
								setPedAnimation ( ped, "MEDIC", "cpr", -1, false, true, false)
								setTimer ( function (ped) if ( isElement ( ped ) ) then setElementData ( ped, "hostiles_status", "idle" ) end end, 10000, 1, ped )
								setTimer ( function (ped) if ( isElement ( ped ) ) then setPedRotation ( ped, getPedRotation(ped)-180) end end, 10000, 1, ped )
								zmoan(ped)
							else
								local action = math.random( 1, 12 )
								if action == -1 or action == -2 then
									setPedAnimation ( ped)
									triggerClientEvent ( "Hostiles_Jump", getRootElement(), ped )
									setTimer ( Zomb_chase, 100, 1, ped, x, y, z )
								else
									setPedAnimation ( ped)
									triggerClientEvent ( "Hostiles_Punch", getRootElement(), ped, Ptarget )
									setTimer ( function (ped) if ( isElement ( ped ) ) then setPedAnimation ( ped, "ped", chaseanim, -1, true, true, true ) end end, 800, 1, ped )
									setTimer ( Zomb_chase, 800, 1, ped, x, y, z )
								end
							end
						else
							if ( isPedDead (Ptarget) ) then
							setTimer ( function (ped) if ( isElement ( ped ) ) then setElementData ( ped, "hostiles_status", "idle" ) end end, 2000, 1, ped )
							setTimer ( function (ped) if ( isElement ( ped ) ) then setPedRotation ( ped, getPedRotation(ped)-180) end end, 1800, 1, ped )
							else
								local action = math.random( 1, 10 )
								if action < 10 then
									setPedAnimation ( ped)
									triggerClientEvent ( "Hostiles_Punch", getRootElement(), ped )
									setTimer ( function (ped) if ( isElement ( ped ) ) then setPedAnimation ( ped, "ped", chaseanim, -1, true, true, true ) end end, 800, 1, ped )
									setTimer ( Zomb_chase, 2000, 1, ped, x, y, z )
								elseif action == 10 then
									setPedAnimation ( ped)
									triggerClientEvent ( "Hostiles_Jump", getRootElement(), ped )
									setTimer ( Zomb_chase, 2000, 1, ped, x, y, z )
								end
							end
						end
					else
						setElementData ( ped, "hostiles_status", "idle" )
					end
				end
			else
				setPedAnimation ( ped, "ped", chaseanim, -1, true, true, true) --KEEP WALKING
				setTimer ( Zomb_chase, checkspeed, 1, ped, x, y, z ) --CHECK AGAIN
			end
		end
	end
end

--SET THE DIRECTION OF THE hostiles
function setangle ()
	for theKey,ped in ipairs(everyZombie) do
		if isElement(ped) then
			if ( getElementData ( ped, "hostiles_status" ) == "chasing" ) then
				local x
				local y
				local z
				local px
				local py
				local pz
				if ( getElementData ( ped, "hostiles_target" ) ~= nil ) then
					local ptarget = getElementData ( ped, "hostiles_target" )
					if isElement(ptarget) then
						x, y, z = getElementPosition( ptarget )
						px, py, pz = getElementPosition( ped )
					else
						setElementData ( ped, "hostiles_status", "idle" )
						x, y, z = getElementPosition( ped )
						px, py, pz = getElementPosition( ped )
					end
					zombangle = ( 360 - math.deg ( math.atan2 ( ( x - px ), ( y - py ) ) ) ) % 360 --MAGIC SPELL TO MAKE PEDS LOOK AT YOU
					setPedRotation( ped, zombangle )
				elseif ( getElementData ( ped, "hostiles_target" ) == nil ) and (getElementData ( ped, "Tx" ) ~= false) then --IF THE PED IS AFTER THE PLAYERS LAST KNOWN WHEREABOUTS
					x = getElementData ( ped, "Tx" )
					y = getElementData ( ped, "Ty" )
					z = getElementData ( ped, "Tz" )
					px, py, pz = getElementPosition( ped )
					zombangle = ( 360 - math.deg ( math.atan2 ( ( x - px ), ( y - py ) ) ) ) % 360 --MAGIC SPELL TO MAKE PEDS LOOK AT YOU
					setPedRotation( ped, zombangle )
				end
			end
		end
	end
end

--SETS THE hostiles ACTIVITY WHEN hostiles_status CHANGES
addEventHandler ( "onElementDataChange", getRootElement(),
function ( dataName )
	if getElementType ( source ) == "ped" and dataName == "hostiles_status" then
		if (getElementData (source, "hostiles") == true) then
			if ( isPedDead ( source ) == false ) then
				if (getElementData ( source, "hostiles_status" ) ==  "chasing" ) then
					local Zx, Zy, Zz = getElementPosition( source )
					setTimer ( Zomb_chase, 1000, 1, source, Zx, Zy, Zz )
					local newtarget = (getElementData ( source, "hostiles_target" ))
					if isElement (newtarget) then
						if getElementType ( newtarget ) == "player" then
							setElementSyncer ( source, newtarget )
						end
					end
					zmoan(source)
				elseif (getElementData ( source, "hostiles_status" ) ==  "idle" ) then
					setTimer ( Zomb_Idle, 1000, 1, source)
				elseif (getElementData ( source, "hostiles_status" ) ==  "throatslashing" ) then
					local tx,ty,tz = getElementPosition( source )
					local ptarget = getElementData ( source, "hostiles_target" )
					if isElement(ptarget) then
						local vx,vy,vz = getElementPosition( ptarget )
						local zombdistance = (getDistanceBetweenPoints3D (tx, ty, tz, vx, vy, vz))
						if (zombdistance < .8) then
							zmoan(source)
							setPedAnimation ( source, "knife", "KILL_Knife_Player", -1, false, false, true)
							setPedAnimation ( ptarget, "knife", "KILL_Knife_Ped_Damage", -1, false, false, true)
							setTimer ( Playerthroatbitten, 2300, 1, ptarget, source) 
							setTimer ( function (source) if ( isElement ( source ) ) then setElementData ( source, "hostiles_status", "idle" ) end end, 5000, 1, source )
						else
							setElementData ( source, "hostiles_status", "idle" )
						end
					else
						setElementData ( source, "hostiles_status", "idle" )
					end
				end
			elseif (getElementData ( source, "hostiles_status" ) ==  "dead" ) then
				setTimer ( Zomb_delete, 10000, 1, source)
			end
		end
	end
end)

--RESOURCE START/INITIAL SETUP
function outbreak(startedResource)
	--newZombieLimit = get("" .. getResourceName(startedResource) .. ".Zlimit")
	newZombieLimit = HostilesLimit
	if newZombieLimit ~= false then
		if newZombieLimit > HostilesLimit then 
			newZombieLimit = HostilesLimit
		end
	else
		newZombieLimit = HostilesLimit
	end
	WoodTimer = setTimer ( WoodSetup, 2000, 1) -- CHECKS FOR BARRIERS
	if startedResource == getThisResource() then
	
		call(getResourceFromName("scoreboard"), "scoreboardAddColumn", "PVE kills") --ADDS TO SCOREBOARD
		call(getResourceFromName("scoreboard"), "scoreboardAddColumn", "PVP kills") --ADDS TO SCOREBOARD
		
		local allplayers = getElementsByType ( "player" )
		for pKey,thep in ipairs(allplayers) do
			setElementData ( thep, "dangercount", 0 )
		end	
		local alivePlayers = getAlivePlayers ()
		for playerKey, playerValue in ipairs(alivePlayers) do
			setElementData ( playerValue, "alreadyspawned", true  )
		end
		if HostilesSpeed == 2 then
			MainTimer1 = setTimer ( setangle, 200, 0) -- KEEPS ZOMBIES FACING THE RIGHT DIRECTION (fast)
		else
			MainTimer1 = setTimer ( setangle, 400, 0) -- KEEPS ZOMBIES FACING THE RIGHT DIRECTION
		end
		MainTimer3 = setTimer ( clearFarZombies, 3000, 0) --KEEPS ALL THE ZOMBIES CLOSE TO PLAYERS	
		if HostilesStreaming == 1 then
			MainTimer2 = setTimer ( SpawnZombie, 2500, 0 ) --Spawns zombies in random locations
		elseif HostilesStreaming == 2 then
			MainTimer2 = setTimer ( SpawnpointZombie, 2500, 0 ) --spawns zombies in hostiles spawnpoints
		end
	end
end
addEventHandler("onResourceStart", getRootElement(), outbreak)

function player_Connect()
	setElementData ( source, "dangercount", 0 )
end
addEventHandler ( "onPlayerConnect", getRootElement(), player_Connect )

function WoodSetup()
	local allcols = getElementsByType ( "colshape" ) --clears off old wood cols
	for colKey, colValue in ipairs(allcols) do
		if ( getElementData ( colValue, "purpose" ) == "zombiewood" ) then
			destroyElement(colValue)
		end
	end	
	local allobjects = getElementsByType ( "object" ) --SETS UP ALL THE WOOD BARRIERS
	for objectKey, objectValue in ipairs(allobjects) do
		if ( getElementData ( objectValue, "purpose" ) == "zombiewood" ) then
			setElementDimension ( objectValue, 26 )
			local x,y,z = getElementPosition( objectValue )
			local thecol = createColSphere ( x, y, z, 1.6 )
			setElementData ( thecol, "purpose", "zombiewood" )
			setElementParent ( thecol, objectValue )
		end
	end	
end

function ReduceMoancount()
	moancount = moancount-1
end

function zmoan(hostiles)
	if moancount < moanlimit then
		moancount = moancount+1
		--local randnum = math.random( 1, 10 )
		--triggerClientEvent ( "Hostie_Moan", getRootElement(), hostiles, randnum )
		setTimer ( ReduceMoancount, 800, 1 )
	end
end

--CLEARS A DEAD hostiles
function Zomb_delete (ped)
	if isElement(ped) then
		if (getElementData (ped, "hostiles") == true) then
			for theKey,thePed in ipairs(everyZombie) do
				if ped == thePed then
					table.remove( everyZombie, theKey )
					break
				end
			end
			destroyElement ( ped )
		end
	end
end

--HEADSHOTS
addEvent( "headboom", true )
function Zheadhit ( ped,attacker, weapon, bodypart)
	if (getElementData (ped, "hostiles") == true) then
		killPed ( ped, attacker, weapon, bodypart )
		setPedHeadless  ( ped, true )
	end
end
addEventHandler( "headboom", getRootElement(), Zheadhit )

--TORSO HIT
addEvent( "torsoboom", true )
function torso_entity_hit ( ped,attacker, weapon, bodypart)
	if (getElementData (ped, "hostiles") == true) then
		if (getDifficultLevel == "Easy") then
			killPed ( ped, attacker, weapon, bodypart )
		end
	end
end
addEventHandler( "torsoboom", getRootElement(), torso_entity_hit )

--KILL FROM hostiles ATTACK
addEvent( "hostie_playereaten", true )
function KnifeAttacked ( player, attacker, weapon, bodypart)
    killPed ( player, attacker, weapon, bodypart )
end
addEventHandler( "hostie_playereaten", getRootElement(), KnifeAttacked )

--CHECKS FOR hostiles GRABBING FROM BEHIND
function Playerthroatbitten ( player, attacker)
	local Zx, Zy, Zz = getElementPosition( attacker )
	local Px, Py, Pz = getElementPosition( player )
	local distance = (getDistanceBetweenPoints3D( Px, Py, Pz, Zx, Zy, Zz ))
	if (distance < 1) then
		killPed ( player, attacker, weapon, bodypart )
	else
		setPedAnimation (player)
	end
end

--ADJUSTS PLAYERS hostiles KILL SCORE
function deanimated( ammo, attacker, weapon, bodypart )
	if (attacker) then
		if (getElementType ( attacker ) == "player") and (getElementType ( source ) == "ped") then
			if (getElementData (source, "hostiles") == true) then
				local oldZcount = getElementData ( attacker, "PVE kills" )
				if oldZcount ~= false then
					setElementData ( attacker, "PVE kills", oldZcount + 1  )
					triggerEvent ( "onZombieWasted", source, attacker, weapon, bodypart )
					givePlayerMoney ( attacker, math.random(MinMoney, MaxMoney) )

					if (IsWeaponDroppable == true or IsWeaponDroppable == "true") then
						local x, y, z = getElementPosition ( source ) 
						local currentweapon = getPedWeapon ( source )
						createPickup ( x, y, z, 2, currentweapon, -1, getPedTotalAmmo ( source ) )
					end
				else
					setElementData ( attacker, "PVE kills", 1  )
					triggerEvent ( "onZombieWasted", source, attacker, weapon, bodypart )				
				end	
			else
				local oldZcount = getElementData ( attacker, "PVP kills" )
				if oldZcount ~= false then
					setElementData ( attacker, "PVP kills", oldZcount + 1  )
					triggerEvent ( "onZombieWasted", source, attacker, weapon, bodypart )
				else
					setElementData ( attacker, "PVP kills", 1  )
					triggerEvent ( "onZombieWasted", source, attacker, weapon, bodypart )				
				end	
			end
		end
	end
end
addEventHandler("onPedWasted", resourceRoot, deanimated)

--STUFF TO ALLOW PLAYERS TO PLACE BOARDS
function boarditup( player, key, keyState )
	local rightspot = 0
	local allcols = getElementsByType ( "radararea" )
	local Bx, By, Bz = getElementPosition( player )
	
	for ColKey,theCol in ipairs(allcols) do
		if (getElementData ( theCol, "hostilesProof" ) == true ) or (getElementData ( theCol, "zombieProof" ) == true ) then
			if (isInsideRadarArea ( theCol, Bx, By )) then
				local rightcol = theCol
				local Cx, Cy, Cz = getElementPosition( rightcol )
				woodangle = ( 360 - math.deg ( math.atan2 ( ( Cx - Bx ), ( Cy - By ) ) ) ) % 360
				setPedRotation( player, woodangle )
				setPedAnimation(player, "riot", "RIOT_PUNCHES", 3000, true, true, true )
				local wx, wy, wz = getElementPosition( player )
				setTimer( doneboarding, 2000, 1, player, rightcol, wx, wy, wz )
			end
		end
	end
end
addCommandHandler ( "construct", boarditup )
	
function doneboarding(player, rightcol, wx, wy, wz)
	setPedAnimation(player)
	local newx, newy, newz = getElementPosition( player )
	local distance = (getDistanceBetweenPoints3D( wx, wy, wz, newx, newy, newz ))			
	if (distance < .7 ) then
		newwood = getElementParent ( rightcol )
		setElementDimension ( newwood, 0 )
		setTimer( setElementDimension, 50, 1, newwood, 0)
	end
end

--SPAWN hostiles (now can be cancelled!)


z_weapon_table = {22, 23, 25, 31}
addEvent( "onHostilesSpawn", true )
function RanSpawn_Z ( gx, gy, gz, rot)
	local safezone = 0
	local allradars = getElementsByType("radararea")
	for theKey,theradar in ipairs(allradars) do
		if getElementData(theradar, "hostilesProof") == true or getElementData(theradar, "zombieProof") == true  then
			if isInsideRadarArea ( theradar, gx, gy ) then
				safezone = 1
			end
		end
	end
	if safezone == 0 then
		if table.getn ( everyZombie ) < newZombieLimit then
			if not rot then
				rot = math.random (1,359)
			end
			randomZskin = math.random ( 1, table.getn ( HostilesPedSkins ) )			
			local zomb = createPed( tonumber( HostilesPedSkins[randomZskin] ), gx, gy, gz )
			if zomb ~= false then
				setElementData ( zomb, "hostiles", true  )
				giveWeapon ( zomb, z_weapon_table[math.random(1, 4)], 60, true )
				table.insert( everyZombie, zomb )	
				setTimer ( function (zomb, rot) if ( isElement ( zomb ) ) then setPedRotation ( zomb, rot ) end end, 500, 1, zomb, rot )
				setTimer ( function (zomb) if ( isElement ( zomb ) ) then setPedAnimation ( zomb, "ped", chaseanim, -1, true, true, true ) end end, 1000, 1, zomb )
				setTimer ( function (zomb) if ( isElement ( zomb ) ) then setElementData ( zomb, "hostiles_status", "idle" ) end end, 2000, 1, zomb )
				triggerClientEvent ( "Hostiles_STFU", getRootElement(), zomb )
			end
		end
	end
end
addEventHandler( "onHostilesSpawn", getRootElement(), RanSpawn_Z )


--SPAWNS ZOMBIES RANDOMLY NEAR PLAYERS
function SpawnZombie ()
	local pacecount = 0
	while pacecount < 1 do	--4 ZOMBIES AT A TIME TO PREVENT FPS DROP
		if (table.getn( everyZombie )+pacecount < newZombieLimit ) and (HostilesStreaming == 1) then	
			local xcoord = 0
			local ycoord = 0
			local xdirection = math.random(1,2)
			if xdirection == 1 then
				xcoord = math.random(15,40)
			else
				xcoord = math.random(-40,-15)
			end
			local ydirection = math.random(1,2)
			if ydirection == 1 then
				ycoord = math.random(15,40)
			else
				ycoord = math.random(-40,-15)
			end
			local liveplayers = getAlivePlayers ()
			if (table.getn( liveplayers ) > 0 ) then
				local lowestcount = 999
				local lowestguy = nil
				for PKey,thePlayer in ipairs(liveplayers) do
					if isElement(thePlayer) then
						if (getElementData (thePlayer, "dangercount")) and (getElementData(thePlayer, "hostilesProof") ~= true or getElementData(thePlayer, "zombieProof") ~= true) and (getElementData(thePlayer, "alreadyspawned" ) == true) then
							if (getElementData (thePlayer, "dangercount") < lowestcount)  then
								local safezone = 0
								local gx, gy, gz = getElementPosition( thePlayer )
								local allradars = getElementsByType("radararea")
								for theKey,theradar in ipairs(allradars) do
									if getElementData(theradar, "hostilesProof") == true or getElementData(theradar, "zombieProof") == true then
										if isInsideRadarArea ( theradar, gx, gy ) then
											safezone = 1
										end
									end
								end
								if safezone == 0 then
									lowestguy = thePlayer
									lowestcount = getElementData (thePlayer, "dangercount")
								end
							end
						end
					end
				end
				pacecount = pacecount+1
				if isElement(lowestguy) then
					triggerClientEvent ( "Spawn_Placement", lowestguy, ycoord, xcoord )
				else
					pacecount = pacecount+1
				end
			else
				pacecount = pacecount+1
			end
		else
			pacecount = pacecount+1
		end
	end
end

--SPAWNS ZOMBIES IN SPAWNPOINTS NEAR PLAYERS
function SpawnpointZombie ()
	local pacecount = 0
	while pacecount < 6 do	--5 ZOMBIES AT A TIME TO PREVENT FPS DROP
		if (table.getn( everyZombie )+pacecount < newZombieLimit ) and (HostilesStreaming == 2) then	
			local liveplayers = getAlivePlayers ()
			if (table.getn( liveplayers ) > 0 ) then
				local lowestcount = 99999
				local lowestguy = nil
				for PKey,thePlayer in ipairs(liveplayers) do --THIS PART GETS THE PLAYER WITH THE LEAST ZOMBIES ATTACKING
					if (getElementData (thePlayer, "dangercount")) and ((getElementData(thePlayer, "hostilesProof") ~= true) or (getElementData(thePlayer, "zombieProof") ~= true)) then
						if (getElementData (thePlayer, "dangercount") < lowestcount) then
							lowestguy = thePlayer
							lowestcount = getElementData (thePlayer, "dangercount")
						end
					end
				end
				if isElement(lowestguy) then
					local zombiespawns = { }
					local possiblezombies = getElementsByType ( "Zombie_spawn" )
					local Px, Py, Pz = getElementPosition( lowestguy )
					for ZombKey,theZomb in ipairs(possiblezombies) do
						local Zx, Zy, Zz = getElementPosition( theZomb )
						local distance = (getDistanceBetweenPoints3D( Px, Py, Pz, Zx, Zy, Zz ))
						if (distance < 8) then
							table.remove( possiblezombies, ZombKey) --IF SPAWN IS TOO CLOSE TO ANY PLAYER
						end
					end
					local Px, Py, Pz = getElementPosition( lowestguy )
					for ZombKey2,theZomb2 in ipairs(possiblezombies) do
						local Zx, Zy, Zz = getElementPosition( theZomb2 )
						local distance = (getDistanceBetweenPoints3D( Px, Py, Pz, Zx, Zy, Zz ))
						if (distance < 60) then --AS LONG AS THE SPAWN IS CLOSE ENOUGH TO A PLAYER
							table.insert( zombiespawns, theZomb2 )
						end
					end
					if (table.getn( zombiespawns ) >0 ) then--IF THE LOWEST PLAYER HAS ANY CLOSE SPAWNS,USE ONE
						local random = math.random ( 1, table.getn ( zombiespawns ) )
						local posX = getElementData(zombiespawns[random], "posX") 
						local posY = getElementData(zombiespawns[random], "posY") 
						local posZ = getElementData(zombiespawns[random], "posZ")
						local rot = getElementData(zombiespawns[random], "rotZ")
						pacecount = pacecount+1
						triggerEvent ( "hostiles_status",zombiespawns[random], posX, posY, posZ, rot )			
					else--IF THE LOWEST PLAYERS DOESNT HAVE ANY SPAWNS, THEN SEE IF ANYONE HAS ANY
						local zombiespawns = { }
						local possiblezombies = getElementsByType ( "Zombie_spawn" )
						local allplayers = getAlivePlayers ()
						for theKey,thePlayer in ipairs(allplayers) do
							local Px, Py, Pz = getElementPosition( thePlayer )
							for ZombKey,theZomb in ipairs(possiblezombies) do
								local Zx, Zy, Zz = getElementPosition( theZomb )
								local distance = (getDistanceBetweenPoints3D( Px, Py, Pz, Zx, Zy, Zz ))
								if (distance < 8) then
									table.remove( possiblezombies, ZombKey) --IF SPAWN IS TOO CLOSE TO ANY PLAYER
								end
							end
						end
						for theKey,thePlayer in ipairs(allplayers) do
							local Px, Py, Pz = getElementPosition( thePlayer )
							for ZombKey2,theZomb2 in ipairs(possiblezombies) do
								local Zx, Zy, Zz = getElementPosition( theZomb2 )
								local distance = (getDistanceBetweenPoints3D( Px, Py, Pz, Zx, Zy, Zz ))
								if (distance < 60) then --AS LONG AS THE SPAWN IS CLOSE ENOUGH TO A PLAYER
									table.insert( zombiespawns, theZomb2 )
								end
							end
						end
						if (table.getn( zombiespawns ) >1 ) then
							local random = math.random ( 1, table.getn ( zombiespawns ) )
							local posX = getElementData(zombiespawns[random], "posX") 
							local posY = getElementData(zombiespawns[random], "posY") 
							local posZ = getElementData(zombiespawns[random], "posZ")
							local rot = getElementData(zombiespawns[random], "rotZ")
							pacecount = pacecount+1
							triggerEvent ( "hostiles_status",zombiespawns[random], posX, posY, posZ, rot )			
						else
							pacecount = pacecount+1
						end
					end
				else
					pacecount = pacecount+1
				end
			else
				pacecount = pacecount+1
			end
		else
			pacecount = pacecount+1
		end
	end
end

--DELETES ZOMBIES THAT ARE TOO FAR FROM ANY PLAYERS TO KEEP THEM MORE CONCENTRATED WHILE STREAMING ZOMBIES
function clearFarZombies ()
	if newZombieLimit ~= false then
		local toofarzombies = { }
		local allplayers = getElementsByType ( "player" )
		for ZombKey,theZomb in ipairs(everyZombie) do
			if isElement(theZomb) then
				if (getElementData (theZomb, "hostiles") == true) then
					far = 1
					local Zx, Zy, Zz = getElementPosition( theZomb )
					for theKey,thePlayer in ipairs(allplayers) do
						local Px, Py, Pz = getElementPosition( thePlayer )
						local distance = (getDistanceBetweenPoints3D( Px, Py, Pz, Zx, Zy, Zz ))
						if (distance < 75) then
							far = 0
						end
					end
					if far == 1 then
						table.insert( toofarzombies, theZomb )
					end
				end
			else
				table.remove( everyZombie, ZombKey )
			end
		end
		if (table.getn( toofarzombies ) >1 ) then
			for ZombKey,theZomb in ipairs(toofarzombies) do
				if (getElementData (theZomb, "hostiles") == true) and  ( getElementData ( theZomb, "forcedtoexist" ) ~= true) then
					Zomb_delete (theZomb)
				end
			end
		end
	end
end

-- DESTROYS UP TO 13 ZOMBIES THAT ARE IDLE WHEN A PLAYER SPAWNS (TO FORCE NEW ZOMBIES TO SPAWN NEAR THE NEW GUY)
function player_Spawn ()
	if HostilesStreaming == 1 or HostilesStreaming == 2 then
		local relocatecount = 0
		for ZombKey,theZomb in ipairs(everyZombie) do
			if relocatecount < 14 then
				if ( getElementData ( theZomb, "forcedtoexist" ) ~= true) then
					if ( getElementData ( theZomb, "hostiles_status" ) == "idle" ) and ( isPedDead ( theZomb ) == false ) and (getElementData (theZomb, "hostiles") == true) then
						relocatecount = relocatecount+1
						Zomb_delete (theZomb)
					end
				end
			end
		end
	end
	if ( getElementData ( source, "alreadyspawned" ) ~= true) then
		setElementData ( source, "alreadyspawned", true  )
	end
end
addEventHandler ( "onPlayerSpawn", getRootElement(), player_Spawn )

---EXPORTED FUNCTIONS!!!!!!!!!!!!!!
function createHostilePed ( x, y, z, weapon, rot, skin, interior, dimension )
	if (table.getn( everyZombie ) < newZombieLimit ) then
	--this part handles the args
		if not x then return false end
		if not y then return false end
		if not z then return false end
		if not weapon then
			weapon = 6
		end
		if not rot then
			rot = math.random (1,359)
		end
		if not skin then
			randomZskin = math.random ( 1, table.getn ( HostilesPedSkins ) )			
			skin = HostilesPedSkins[randomZskin]
		end
		if not interior then interior = 0 end
		if not dimension then dimension = 0 end
	--this part spawns the ped
		local zomb = createPed (tonumber(skin),tonumber(x),tonumber(y),tonumber(z))--spawns the ped
	--if successful, this part applies the hostiles settings/args
		if (zomb ~= false) then
			setTimer ( setElementInterior, 100, 1, zomb, tonumber(interior)) --sets interior
			setTimer ( setElementDimension, 100, 1, zomb, tonumber(dimension)) --sets dimension
			setElementData ( zomb, "hostiles", true  )
			setElementData ( zomb, "forcedtoexist", true  )
			setTimer ( function (zomb, rot) if ( isElement ( zomb ) ) then setPedRotation ( zomb, rot ) end end, 500, 1, zomb, rot )
			setTimer ( function (zomb) if ( isElement ( zomb ) ) then setElementData ( zomb, "hostiles_status", "idle" ) end end, 2000, 1, zomb )
			setTimer ( function (zomb) if ( isElement ( zomb ) ) then setElementData ( zomb, "forcedtoexist", true ) end end, 1000, 1, zomb )
			setTimer ( function (zomb) if ( isElement ( zomb ) ) then table.insert( everyZombie, zomb ) end end, 1000, 1, zomb )
			triggerClientEvent ( "Hostiles_STFU", getRootElement(), zomb )
			giveWeapon(zomb, weapon, 60, true)
			return zomb --returns the hostiles element
		else
			return false --returns false if there was a problem
		end
	else
		return false --returns false if there was a problem
	end
end

--check if a ped is a hostiles or not
function isPedHostile(ped)
	if (isElement(ped)) then
		if (getElementData (ped, "hostiles") == true) then
			return true
		else
			return false
		end
	else
		return false
	end
end

addEvent( "onHostieLostPlayer", true )
function ZombieTargetCoords ( x,y,z )
	setElementData ( source, "Tx", x, false )
	setElementData ( source, "Ty", y, false )
	setElementData ( source, "Tz", z, false )
end
addEventHandler( "onHostieLostPlayer", getRootElement(), ZombieTargetCoords )


function storePlayerAccData ( quitType )
	 local playeraccount = getPlayerAccount ( source )
     if ( playeraccount ) and not isGuestAccount ( playeraccount ) then -- if the player is logged in
        local playermoney = getPlayerMoney ( source ) -- get the player money
        setAccountData ( playeraccount, "playeracc.money", playermoney ) -- save it in his account
		
		local pve_kills = getElementData(source, "PVE kills") or 0
		local pvp_kills = getElementData(source, "PVP kills") or 0
		
		setAccountData ( playeraccount, "playeracc.pve_kills", pve_kills ) -- save it in his account
		setAccountData ( playeraccount, "playeracc.pvp_kills", pvp_kills ) -- save it in his account
     end
end
addEventHandler ( "onPlayerQuit", root, storePlayerAccData )


function onPlayerLoginData (_, playeraccount )
      if ( playeraccount ) then
            local playermoney = getAccountData ( playeraccount, "playeracc.money" ) or 0
			local pve_kills =   getAccountData ( playeraccount, "playeracc.pve_kills" ) or 0
			local pvp_kills =   getAccountData ( playeraccount, "playeracc.pvp_kills" ) or 0
						
            if ( playermoney ) then
                setPlayerMoney ( source, playermoney )
				setElementData ( source, "PVE kills", pve_kills)
				setElementData ( source, "PVP kills", pvp_kills)
            end
      end
end
addEventHandler ( "onPlayerLogin", root, onPlayerLoginData )