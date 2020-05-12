		
local sx,sy = guiGetScreenSize()
local px,py = 1600,900
local x,y =  (sx/px), (sy/py)		

local inscape_value = 1
		
addEventHandler("onClientRender", root,
    function()
		showPlayerHudComponent("clock",false)
		showPlayerHudComponent("money",false)
		showPlayerHudComponent("health",false)
		showPlayerHudComponent("armour",false)
		showPlayerHudComponent("weapon",true) 
		showPlayerHudComponent("ammo",false)
		showPlayerHudComponent("wanted",false)
		
		
		if (not isPedDead ( getLocalPlayer() )) then
		
		
		local weaponType = getPedWeapon(localPlayer)
		local clip = getPedAmmoInClip (localPlayer, getPedWeaponSlot(localPlayer))
		local clip1 = getPedTotalAmmo (localPlayer, getPedWeaponSlot(localPlayer))	
		local playerHealth = getElementHealth ( getLocalPlayer() )
		local playerArmor = getPedArmor ( getLocalPlayer() )
		local playerMoney = getPlayerMoney ( getLocalPlayer() )		
		
		local weapon = getPedWeapon ( localPlayer, getPedWeaponSlot(localPlayer) )
		local clip_count = getWeaponProperty(weapon, "poor", "maximum_clip_ammo")
		
		if (clip_count == nil or clip_count == false) then
			clip_count = 1
		end
		
		local total_clips = 1
		
		if (clip1 > 0 and clip_count > 0) then
			total_clips = math.ceil(tonumber(clip1/clip_count))
		end
		
		if (playerHealth < 25) then
				if (inscape_value < playerHealth) then
					inscape_value = inscape_value + 2
				else
					inscape_value = inscape_value - 0.05
				end	
			else
			inscape_value = playerHealth
		end
		
        --dxDrawRectangle(x*1234, y*38, x*362, y*168, tocolor(255, 255, 255, 31), true)
		dxDrawRectangle(x*1372, y*65, x*205, y*30, tocolor(60, 60, 60, 255), true)
		dxDrawRectangle(x*1375, y*68, x*198/100*inscape_value, y*23, tocolor(215, 0, 0, 255), true)
        dxDrawRectangle(x*1375, y*68, x*198/100*playerHealth, y*23, tocolor(177, 0, 0, 255), true)
		
		dxDrawRectangle(x*1375, y*95.8, x*198, y*6, tocolor(60, 60, 60, 255), true)
        dxDrawRectangle(x*1375, y*95.8, x*198/100*playerArmor, y*6, tocolor(0, 60, 199, 138), true)
		
		dxDrawText(playerMoney.."$", x*1422, y*178, x*1572, y*195, tocolor(0, 0, 0, 255), 0.70, "bankgothic", "center", "center", false, false, true, false, false)
        dxDrawText(playerMoney.."$", x*1422, y*176, x*1572, y*193, tocolor(0, 0, 0, 255), 0.70, "bankgothic", "center", "center", false, false, true, false, false)
        dxDrawText(playerMoney.."$", x*1420, y*178, x*1570, y*195, tocolor(0, 0, 0, 255), 0.70, "bankgothic", "center", "center", false, false, true, false, false)
        dxDrawText(playerMoney.."$", x*1420, y*176, x*1570, y*193, tocolor(0, 0, 0, 255), 0.70, "bankgothic", "center", "center", false, false, true, false, false)
        dxDrawText(playerMoney.."$", x*1421, y*177, x*1571, y*194, tocolor(255, 255, 255, 255), 0.70, "bankgothic", "center", "center", false, false, true, false, false)
		dxDrawText(clip_count.."|"..clip.." ["..total_clips.."]", x*1275, y*218, x*1325, y*195, tocolor(0, 0, 0, 255), 0.70, "bankgothic", "center", "center", false, false, true, false, false)
        dxDrawText(clip_count.."|"..clip.." ["..total_clips.."]", x*1275, y*216, x*1325, y*193, tocolor(0, 0, 0, 255), 0.70, "bankgothic", "center", "center", false, false, true, false, false)
        dxDrawText(clip_count.."|"..clip.." ["..total_clips.."]", x*1273, y*218, x*1323, y*195, tocolor(0, 0, 0, 255), 0.70, "bankgothic", "center", "center", false, false, true, false, false)
        dxDrawText(clip_count.."|"..clip.." ["..total_clips.."]", x*1273, y*216, x*1323, y*193, tocolor(0, 0, 0, 255), 0.70, "bankgothic", "center", "center", false, false, true, false, false)
        dxDrawText(clip_count.."|"..clip.." ["..total_clips.."]", x*1274, y*217, x*1324, y*194, tocolor(255, 255, 255, 255), 0.70, "bankgothic", "center", "center", false, false, true, false, false)
        --dxDrawText(""..math.floor(tonumber(playerHealth)).."%", x*1431, y*85, x*1523, y*72, tocolor(255, 255, 255, 255), 1.10, "clear", "center", "center", false, false, true, false, false)
        --dxDrawText(""..math.floor(tonumber(playerArmor)).."%", x*1431, y*102, x*1523, y*140, tocolor(255, 255, 255, 255), 1.10, "clear", "center", "center", false, false, true, false, false)
		end
    end
)
