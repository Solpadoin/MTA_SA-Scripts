-----------------------------------------
----- REVISION CREATED BY SOLPADOIN -----
-----------------------------------------
--- *** HEAVY MODIFIED SCRIPT *** ---

--- ORIGINAL LOGIC DONE BY SLOTHMAN -> https://community.multitheftauto.com/index.php?p=resources&s=details&id=347 ---

myHostiles = { }
HelmetProtected = { 285, 287 }
resourceRoot = getResourceRootElement()

addCommandHandler("devmode",
    function()
        setDevelopmentMode(true)
    end
)

--FORCES ENTITIES TO MOVE ALONG AFTER THEIR hostiles_target PLAYER DIES
function playerdead ()
	setTimer ( Ent_release, 4000, 1 )
end
addEventHandler ( "onClientPlayerWasted", getLocalPlayer(), playerdead )

function Ent_release ()
	for k, ped in pairs( myHostiles ) do
		if (isElement(ped)) then
			if (getElementData (ped, "hostiles") == true) then
				setElementData ( ped, "hostiles_target", nil )
				setElementData ( ped, "hostiles_status", "idle" )
				table.remove(myHostiles,k)
			end
		end
	end
end

--REMOVES A hostiles FROM INFLUENCE AFTER ITS KILLED
function pedkilled ( killer, weapon, bodypart )
	if (getElementData (source, "hostiles") == true) and (getElementData (source, "hostiles_status") ~= "dead" ) then
		setElementData ( source, "hostiles_target", nil )
		setElementData ( source, "hostiles_status", "dead" )
	end
end
addEventHandler ( "onClientPedWasted", getRootElement(), pedkilled )

--THIS CHECKS ALL ZOMBIES EVERY SECOND TO SEE IF THEY ARE IN SIGHT
function zombie_check ()
	if (getElementData (getLocalPlayer (), "hostiles") ~= true) and ( isPedDead ( getLocalPlayer () ) == false ) then
		local zombies = getElementsByType ( "ped",getRootElement(),true )
		local Px,Py,Pz = getElementPosition( getLocalPlayer () )
		if isPedDucked ( getLocalPlayer ()) then
			local Pz = Pz-1
		end		
		for theKey,theZomb in ipairs(zombies) do
			if (isElement(theZomb)) then
				local Zx,Zy,Zz = getElementPosition( theZomb )
				if (getDistanceBetweenPoints3D(Px, Py, Pz, Zx, Zy, Zz) < 45 ) then
					if (getElementData (theZomb, "hostiles") == true) then
						if ( getElementData ( theZomb, "hostiles_status" ) == "idle" ) then --CHECKS IF AN IDLE hostiles IS IN SIGHT
							local isclear = isLineOfSightClear (Px, Py, Pz+1, Zx, Zy, Zz +1, true, false, false, true, false, false, false) 
							if (isclear == true) then
								setElementData ( theZomb, "hostiles_status", "chasing" )
								setElementData ( theZomb, "hostiles_target", getLocalPlayer() )
								table.insert( myHostiles, theZomb ) --ADDS hostiles TO PLAYERS COLLECTION
								table.remove( zombies, theKey)
								zombieradiusalert (theZomb)
							end
						elseif (getElementData(theZomb,"hostiles_status") == "chasing") and (getElementData(theZomb,"hostiles_target") == nil) then --CHECKS IF AN AGGRESSIVE LOST hostiles IS IN SIGHT
							local isclear = isLineOfSightClear (Px, Py, Pz+1, Zx, Zy, Zz +1, true, false, false, true, false, false, false) 
							if (isclear == true) then
								setElementData ( theZomb, "hostiles_target", getLocalPlayer() )
								isthere = "no"
								for k, ped in pairs( myHostiles ) do
									if ped == theZomb then
										isthere = "yes"
									end
								end
								if isthere == "no" then
									table.insert( myHostiles, theZomb ) --ADDS THE WAYWARD hostiles TO THE PLAYERS COLLECTION
									table.remove( zombies, theKey)
								end
							end
						elseif ( getElementData ( theZomb, "hostiles_target" ) == getLocalPlayer() ) then --CHECKS IF AN ALREADY AGGRESSIVE hostiles IS IN SIGHT
							local isclear = isLineOfSightClear (Px, Py, Pz+1, Zx, Zy, Zz +1, true, false, false, true, false, false, false) 
							if (isclear == false) then --IF YOUR hostiles LOST YOU, MAKES IT REMEMBER YOUR LAST COORDS
								setElementData ( theZomb, "hostiles_target", nil )
								triggerServerEvent ("onHostieLostPlayer", theZomb, oldPx, oldPy, oldPz)
							end
						end
					end
				end
			end
		end
	--this second half is for checking peds and zombies
	
		local nonzombies = getElementsByType ( "ped",getRootElement(),true )
		for theKey,theZomb in ipairs(zombies) do
			if (isElement(theZomb)) then
				if (getElementData (theZomb, "hostiles") == true) then
					local Zx,Zy,Zz = getElementPosition( theZomb )
					for theKey,theNonZomb in ipairs(nonzombies) do
						if (getElementData (theNonZomb, "hostiles") ~= true) then -- if the ped isnt a hostiles
							local Px,Py,Pz = getElementPosition( theNonZomb )
							if (getDistanceBetweenPoints3D(Px, Py, Pz, Zx, Zy, Zz) < 45 ) then
								local isclear = isLineOfSightClear (Px, Py, Pz+1, Zx, Zy, Zz +1, true, false, false, true, false, false, false ) 
								if (isclear == true) and ( getElementHealth ( theNonZomb ) > 0) then
									if ( getElementData ( theZomb, "hostiles_status" ) == "idle" ) then --CHECKS IF AN IDLE hostiles IS IN SIGHT
										triggerServerEvent ("onHostieLostPlayer", theZomb, Px, Py, Pz)									
										setElementData ( theZomb, "hostiles_status", "chasing" )
										setElementData ( theZomb, "hostiles_target", theNonZomb )
										zombieradiusalert (theZomb)
									elseif ( getElementData ( theZomb, "hostiles_status" ) == "chasing" ) and ( getElementData ( theZomb, "hostiles_target" ) == nil) then
										triggerServerEvent ("onHostieLostPlayer", theZomb, Px, Py, Pz)
										setElementData ( theZomb, "hostiles_target", theNonZomb )									
									end
								end					
							end		
							if ( getElementData ( theZomb, "hostiles_target" ) == theNonZomb ) then --CHECKS IF AN ALREADY AGGRESSIVE hostiles IS IN SIGHT OF THE PED
								local Px,Py,Pz = getElementPosition( theNonZomb )
								if (getDistanceBetweenPoints3D(Px, Py, Pz, Zx, Zy, Zz) < 45 ) then
									local isclear = isLineOfSightClear (Px, Py, Pz+1, Zx, Zy, Zz+1, true, false, false, true, false, false, false) 
									if (isclear == false) then --IF YOUR hostiles LOST THE PED, MAKES IT REMEMBER the peds LAST COORDS
										triggerServerEvent ("onHostieLostPlayer", theZomb, Px, Py, Pz)							
										setElementData ( theZomb, "hostiles_target", nil )
									end
								end
							end
						end
					end
				end
			end
		end
	end
	for k, ped in pairs( myHostiles ) do
		if (isElement(ped) == false) then
			table.remove( myHostiles, k)
		end
	end
	oldPx,oldPy,oldPz = getElementPosition( getLocalPlayer () )
end


--INITAL SETUP

function clientsetupstarter(startedresource)
	if startedresource == getThisResource() then
		setTimer ( clientsetup, 1234, 1)
		MainClientTimer1 = setTimer ( zombie_check, 1000, 0)  --STARTS THE TIMER TO CHECK FOR ZOMBIES
	end
end
addEventHandler("onClientResourceStart", getRootElement(), clientsetupstarter)

function clientsetup()
	--oldPx,oldPy,oldPz = getElementPosition( getLocalPlayer () )
	---throatcol = createColSphere ( 0, 0, 0, .3)
	
--ALL ZOMBIES STFU
	local zombies = getElementsByType ( "ped" )
	for theKey,theZomb in ipairs(zombies) do
		if (isElement(theZomb)) then
			if (getElementData (theZomb, "hostiles") == true) then
				setPedVoice(theZomb, "PED_TYPE_DISABLED")
			end
		end
	end
	
--SKIN REPLACEMENTS
--[[
	local skin = engineLoadTXD ( "skins/13.txd" ) --bleedin eyes 31 by Slothman
	engineImportTXD ( skin, 13 )
	local skin = engineLoadTXD ( "skins/22.txd" ) -- slashed 12 by Wall-E
	engineImportTXD ( skin, 22 )	
	local skin = engineLoadTXD ( "skins/56.txd" ) --young and blue by Slothman
	engineImportTXD ( skin, 56 )
	local skin = engineLoadTXD ( "skins/67.txd" ) -- slit r* employee
	engineImportTXD ( skin, 67 )
	local skin = engineLoadTXD ( "skins/68.txd" ) -- shredded preist by Deixell
	engineImportTXD ( skin, 68 )
	local skin = engineLoadTXD ( "skins/69.txd" ) --bleedin eyes in denim by Capitanazop
	engineImportTXD ( skin, 69 )
	local skin = engineLoadTXD ( "skins/70.txd" ) --ultra gory scientist by 50p
	engineImportTXD ( skin, 70 )
	local skin = engineLoadTXD ( "skins/84.txd" ) --guitar wolf (nonzombie) by Slothman
	engineImportTXD ( skin, 84 )
	local skin = engineLoadTXD ( "skins/92.txd" ) -- peeled flesh by xbost
	engineImportTXD ( skin, 92 )
	local skin = engineLoadTXD ( "skins/97.txd" ) -- easterboy by Slothman
	engineImportTXD ( skin, 97 )
	local skin = engineLoadTXD ( "skins/105.txd" ) --Scarred Grove Gangster by Wall-E
	engineImportTXD ( skin, 105 )
	local skin = engineLoadTXD ( "skins/107.txd" ) --ripped and slashed grove by Wall-E
	engineImportTXD ( skin, 107 )
	local skin = engineLoadTXD ( "skins/108.txd" ) -- skeleton thug by Deixell
	engineImportTXD ( skin, 108 )
	local skin = engineLoadTXD ( "skins/111.txd" ) --Frank West from dead rising (nonzombie) by Slothman
	engineImportTXD ( skin, 111 )
	local skin = engineLoadTXD ( "skins/126.txd" ) -- bullet ridden wiseguy by Slothman
	engineImportTXD ( skin, 126 )
	local skin = engineLoadTXD ( "skins/127.txd" ) --flyboy from dawn of the dead by Slothman
	engineImportTXD ( skin, 127 )
	local skin = engineLoadTXD ( "skins/128.txd" ) --holy native by Slothman
	engineImportTXD ( skin, 128 )
	local skin = engineLoadTXD ( "skins/152.txd" ) --bitten schoolgirl by Slothman
	engineImportTXD ( skin, 152 )
	local skin = engineLoadTXD ( "skins/162.txd" ) --shirtless redneck by Slothman
	engineImportTXD ( skin, 162 )
	local skin = engineLoadTXD ( "skins/167.txd" ) --dead chickenman by 50p
	engineImportTXD ( skin, 167 )
	local skin = engineLoadTXD ( "skins/188.txd" ) --burnt greenshirt by Slothman
	engineImportTXD ( skin, 188 )
	local skin = engineLoadTXD ( "skins/192.txd" ) --Alice from resident evil (nonzombie) by Slothman
	engineImportTXD ( skin, 192 )
	local skin = engineLoadTXD ( "skins/195.txd" ) --bloody ex by Slothman
	engineImportTXD ( skin, 195 )
	local skin = engineLoadTXD ( "skins/206.txd" ) -- faceless hostiles by Slothman
	engineImportTXD ( skin, 206 )
	local skin = engineLoadTXD ( "skins/209.txd" ) --Noodle vendor by 50p
	engineImportTXD ( skin, 209 )
	local skin = engineLoadTXD ( "skins/212.txd" ) --brainy hobo by Slothman
	engineImportTXD ( skin, 212 )
	local skin = engineLoadTXD ( "skins/229.txd" ) --infected tourist by Slothman
	engineImportTXD ( skin, 229 )
	local skin = engineLoadTXD ( "skins/230.txd" ) --will work for brains hobo by Slothman
	engineImportTXD ( skin, 230 )
	local skin = engineLoadTXD ( "skins/258.txd" ) --bloody sided suburbanite by Slothman
	engineImportTXD ( skin, 258 )
	local skin = engineLoadTXD ( "skins/264.txd" ) --scary clown by 50p
	engineImportTXD ( skin, 264 )
	local skin = engineLoadTXD ( "skins/274.txd" ) --Ash Williams (nonzombie) by Slothman
	engineImportTXD ( skin, 274 )
	local skin = engineLoadTXD ( "skins/277.txd" ) -- gutted firefighter by Wall-E
	engineImportTXD ( skin, 277 )
	local skin = engineLoadTXD ( "skins/280.txd" ) --infected cop by Lordy
	engineImportTXD ( skin, 280 )
	local skin = engineLoadTXD ( "skins/287.txd" ) --torn army by Deixell
	engineImportTXD ( skin, 287 )
	
	--]]
end

--UPDATES PLAYERS COUNT OF AGGRESIVE ZOMBIES
addEventHandler ( "onClientElementDataChange", getRootElement(),
function ( dataName )
	if getElementType ( source ) == "ped" and dataName == "hostiles_status" then
		local thestatus = (getElementData ( source, "hostiles_status" ))
		if (thestatus == "idle") or (thestatus == "dead") then		
			for k, ped in pairs( myHostiles ) do
				if ped == source and (getElementData (ped, "hostiles") == true) then
					setElementData ( ped, "hostiles_target", nil )
					table.remove( myHostiles, k)
					setElementData ( getLocalPlayer(), "dangercount", tonumber(table.getn( myHostiles )) )
				end
			end
		end
	end
end )

--MAKES A AIM TO THE hostiles_target
addEvent( "Hostiles_Jump", true )
function Zjump ( ped )
	if (isElement(ped)) then
		setPedControlState( ped, "aim_weapon", true )
		setTimer ( function (ped) if ( isElement ( ped ) ) then setPedControlState ( ped, "aim_weapon", false) end end, 5000, 1, ped )
	end
end
addEventHandler( "Hostiles_Jump", getRootElement(), Zjump )

--MAKES A SHOOT WITH RECOIL SIMULATION
addEvent( "Hostiles_Punch", true )
function Zpunch ( ped, Ptarget )
	if (isElement(ped)) then
		if (isElement(Ptarget)) then
			local x,y,z = getElementPosition(Ptarget)
			setPedAimTarget ( ped, x + math.random(-0.35, 0.35), y + math.random(-0.35, 0.35), z + math.random(0.35, 0.6)) --- simulate recoil --- 
		end
		
		if (getPedControlState ( ped, "fire") == true) then
			return end
		
		setPedControlState( ped, "fire", true )
		setTimer ( function (ped) if ( isElement ( ped ) ) then setPedControlState ( ped, "fire", false) end end, 600, 1, ped )
	end
end
addEventHandler( "Hostiles_Punch", getRootElement(), Zpunch )

--MAKES A STFU
addEvent( "Hostiles_STFU", true )
function Zstfu ( ped )
	if (isElement(ped)) then
		setPedVoice(ped, "PED_TYPE_DISABLED")
	end
end
addEventHandler( "Hostiles_STFU", getRootElement(), Zstfu )

--MAKES A MOAN --- NO MUSIC LICENCE :-(
addEvent( "Hostie_Moan", true )
function Zmoan ( ped, randnum )
	if (isElement(ped)) then
		--local Zx,Zy,Zz = getElementPosition( ped )
		--local sound = playSound3D("sounds/mgroan"..randnum..".ogg", Zx, Zy, Zz, false)
		--setSoundMaxDistance(sound, 20)
	end
end
addEventHandler( "Hostie_Moan", getRootElement(), Zmoan )

--HEADSHOTS TO ALL BUT IGNORE HELMETED--
function zombiedamaged ( attacker, weapon, bodypart )
	if getElementType ( source ) == "ped" then
		if (getElementData (source, "hostiles") == true) then
			if ( bodypart == 9 ) then
				helmeted = "no"
				local zskin = getElementModel ( source )
				for k, skin in pairs( HelmetProtected ) do
					if skin == zskin then
						helmeted = "yes"
					end
				end
				if helmeted == "no" then
					triggerServerEvent ("headboom", source, source, attacker, weapon, bodypart )
				end
			end
			
			if ( bodypart == 3 ) then
				triggerServerEvent ("torsoboom", source, source, attacker, weapon, bodypart )
			end
		end
	end
end
addEventHandler ( "onClientPedDamage", getRootElement(), zombiedamaged )

function zombiedkilled(killer, weapon, bodypart)
	if getElementType ( source ) == "ped" then
		if (getElementData (source, "hostiles") == true) then
			setElementCollisionsEnabled(source, false)
		end
	end
end
addEventHandler ( "onClientPedWasted", getRootElement(), zombiedkilled )

--CAUSES MORE DAMAGE TO PLAYER WHEN ATTACKED BY A hostiles
function zombieattack ( attacker, weapon, bodypart )
	if (attacker) then
		if getElementType ( attacker ) == "ped" then
			if (getElementData (attacker, "hostiles") == true) then
				local playerHealth = getElementHealth ( source )
				if playerHealth > 10 then
					--local player_score = 1000000 -- getElementData(source, "PVE kills") or 0
					--setElementHealth ( source, playerHealth + (math.random(0.002, 0.005) * player_score) )
				else
					triggerServerEvent ("hostie_playereaten", source, source, attacker, weapon, bodypart )
				end
			end
		end
	end
end
addEventHandler ( "onClientPlayerDamage", getLocalPlayer(), zombieattack )

--avoid friendlyfire
function cancelPedDamage ( attacker )
	if attacker and isElement(attacker) then
		if (getElementType ( attacker ) == "player" and getElementType ( source ) == "player") then
			if (getTeamName (getPlayerTeam(attacker)) == getTeamName (getPlayerTeam(source))) then
				cancelEvent()
			end
		end
	end
end
addEventHandler ( "onClientPedDamage", getRootElement(), cancelPedDamage )

--ZOMBIES ATTACK FROM BEHIND AND GUI STUFF
function movethroatcol ()
	local screenWidth, screenHeight = guiGetScreenSize()
	local dcount = tostring(table.getn( myHostiles ))
	dxDrawText( dcount, screenWidth-40, screenHeight -50, screenWidth, screenHeight, tocolor ( 0, 0, 0, 255 ), 1.44, "pricedown" )
	dxDrawText( dcount, screenWidth-42, screenHeight -52, screenWidth, screenHeight, tocolor ( 255, 255, 255, 255 ), 1.4, "pricedown" )
	
	if isElement(throatcol) then
		local playerrot = getPedRotation ( getLocalPlayer () )
		local radRot = math.rad ( playerrot )
		local radius = 1
		local px,py,pz = getElementPosition( getLocalPlayer () )
		local tx = px + radius * math.sin(radRot)
		local ty = py + -(radius) * math.cos(radRot)
		local tz = pz
		setElementPosition ( throatcol, tx, ty, tz )
	end
end
addEventHandler ( "onClientRender", getRootElement(), movethroatcol )

function choketheplayer ( theElement, matchingDimension )
	if getElementType ( theElement ) == "ped" and ( isPedDead ( getLocalPlayer () ) == false ) then
        if ( getElementData ( theElement, "hostiles_target" ) == getLocalPlayer () ) and (getElementData (theElement, "hostiles") == true) then
			local px,py,pz = getElementPosition( getLocalPlayer () )
			setTimer ( checkplayermoved, 600, 1, theElement, px, py, pz)
		end
    end
end
addEventHandler ( "onClientColShapeHit", getRootElement(), choketheplayer )

function checkplayermoved (zomb, px, py, pz)
	if (isElement(zomb)) then
		local nx,ny,nz = getElementPosition( getLocalPlayer () )
		local distance = (getDistanceBetweenPoints3D (px, py, pz, nx, ny, nz))
		if (distance < .7) and ( isPedDead ( getLocalPlayer () ) == false ) then
			setElementData ( zomb, "hostiles_status", "throatslashing" )
		end
	end
end

--ALERTS ANY IDLE ZOMBIES WITHIN A RADIUS OF 10 WHEN GUNSHOTS OCCUR OR OTHER ZOMBIES GET ALERTED
function zombieradiusalert (theElement)
	local Px,Py,Pz = getElementPosition( theElement )
	local zombies = getElementsByType ( "ped" )
	for theKey,theZomb in ipairs(zombies) do
		if (isElement(theZomb)) then
			if (getElementData (theZomb, "hostiles") == true) then
				if ( getElementData ( theZomb, "hostiles_status" ) == "idle" ) then
					local Zx,Zy,Zz = getElementPosition( theZomb )
					local distance = (getDistanceBetweenPoints3D (Px, Py, Pz, Zx, Zy, Zz))
					if (distance < 10) and ( isPedDead ( getLocalPlayer () ) == false ) then
						isthere = "no"
						for k, ped in pairs( myHostiles ) do
							if ped == theZomb then
								isthere = "yes"
							end
						end
						if isthere == "no" and (getElementData (getLocalPlayer (), "hostiles") ~= true) then
							if (getElementType ( theElement ) == "ped") then
								local isclear = isLineOfSightClear (Px, Py, Pz, Zx, Zy, Zz, true, false, false, true, false, false, false) 
								if (isclear == true) then
									setElementData ( theZomb, "hostiles_status", "chasing" )
									setElementData ( theZomb, "hostiles_target", getLocalPlayer () )
									table.insert( myHostiles, theZomb ) --ADDS hostiles TO PLAYERS COLLECTION
								end
							else
								setElementData ( theZomb, "hostiles_status", "chasing" )
								setElementData ( theZomb, "hostiles_target", getLocalPlayer () )
								table.insert( myHostiles, theZomb ) --ADDS hostiles TO PLAYERS COLLECTION
							end
						end
					end
				end
			end
		end
	end
end

function shootingnoise ( weapon, ammo, ammoInClip, hitX, hitY, hitZ, hitElement)
	if alertspacer ~= 1 then
		if (weapon == 9) then
			alertspacer = 1
			setTimer ( resetalertspacer, 5000, 1 )
			zombieradiusalert(getLocalPlayer ())
		elseif (weapon > 21) and (weapon ~= 23) then
			alertspacer = 1
			setTimer ( resetalertspacer, 5000, 1 )
			zombieradiusalert(getLocalPlayer ())
		end
	end
	if hitElement then
		if (getElementType ( hitElement ) == "ped") then
			if (getElementData (hitElement, "hostiles") == true) then			
				isthere = "no"
				for k, ped in pairs( myHostiles ) do
					if ped == hitElement then
						isthere = "yes"
					end
				end
				if isthere == "no" and (getElementData (getLocalPlayer (), "hostiles") ~= true) then
					setElementData ( hitElement, "hostiles_status", "chasing" )
					setElementData ( hitElement, "hostiles_target", getLocalPlayer () )
					table.insert( myHostiles, hitElement ) --ADDS hostiles TO PLAYERS COLLECTION
					zombieradiusalert (hitElement)
				end
			end
		end
	end
end
addEventHandler ( "onClientPlayerWeaponFire", getLocalPlayer (), shootingnoise )

function resetalertspacer ()
	alertspacer = nil
end

function choketheplayer ( theElement, matchingDimension )
	if getElementType ( theElement ) == "ped" and ( isPedDead ( getLocalPlayer () ) == false ) and (getElementData (theElement , "hostiles") == true) then
        if ( getElementData ( theElement, "hostiles_target" ) == getLocalPlayer () ) then
			local px,py,pz = getElementPosition( getLocalPlayer () )
			setTimer ( checkplayermoved, 600, 1, theElement, px, py, pz)
		end
    end
end

addEvent( "Spawn_Placement", true )
function Spawn_Place(xcoord, ycoord)
	local x,y,z = getElementPosition( getLocalPlayer() )
	local posx = x+xcoord
	local posy = y+ycoord
	local gz = getGroundPosition ( posx, posy, z+500 )
	triggerServerEvent ("onHostilesSpawn", getLocalPlayer(), posx, posy, gz+1 )
end
addEventHandler("Spawn_Placement", getRootElement(), Spawn_Place)