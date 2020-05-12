---- ORIGINAL RESOURCE -> https://community.multitheftauto.com/?p=resources&s=details&id=18102 ----
---  MODIFIED BY SOLPADOIN  ---

local shader = dxCreateShader([[
	Texture smoke;
	float r = 0.0, g = 0.0, b = 0.0;

	sampler SmokeSampler = sampler_state { Texture = smoke; };
	
	float4 PixelShaderFunction(float2 coords : TEXCOORD0) : COLOR0 {
		float4 color = tex2D(SmokeSampler, coords);
		color.r = r;
		color.g = g;
		color.b = b;
		return color;
	}
	
	technique Technique1 {
		pass Pass1 {
			PixelShader = compile ps_2_0 PixelShaderFunction();
		}
	}
]])

local smoke = dxCreateTexture("files/smoke.png")
dxSetShaderValue(shader, "smoke", smoke)
engineApplyShaderToWorldTexture(shader, "collisionsmoke")
engineApplyShaderToWorldTexture(shader, "bullethitsmoke")

function setSmokeToTeamColor()
	local theVehicle = getPedOccupiedVehicle( source )
	
	if theVehicle then
		local team = getPlayerTeam ( source )
		
		if team then
			local r, g, b = getTeamColor ( team )
			if r and g and b then
				dxSetShaderValue(shader, "r", math.max(0, math.min(255, r)) / 255)
				dxSetShaderValue(shader, "g", math.max(0, math.min(255, g)) / 255)
				dxSetShaderValue(shader, "b", math.max(0, math.min(255, b)) / 255)
			end
		else
			dxSetShaderValue(shader, "r", math.max(0, math.min(255, 0)) / 255)
			dxSetShaderValue(shader, "g", math.max(0, math.min(255, 0)) / 255)
			dxSetShaderValue(shader, "b", math.max(0, math.min(255, 0)) / 255)
		end	
	end
end
addEventHandler("onClientPlayerVehicleEnter", getRootElement(), setSmokeToTeamColor)

--[[
addCommandHandler("smokecolor", function(cmd, r, g, b)
	local r, g, b = tonumber(r), tonumber(g), tonumber(b)
	if not r or not g or not b then return outputChatBox(("USE: /%s <red: 0-255> <green: 0-255> <blue: 0-255>"):format(cmd)) end

	dxSetShaderValue(shader, "r", math.max(0, math.min(255, r)) / 255)
	dxSetShaderValue(shader, "g", math.max(0, math.min(255, g)) / 255)
	dxSetShaderValue(shader, "b", math.max(0, math.min(255, b)) / 255)

	outputChatBox("Smoke color changed!", r, g, b)
end)
]]--