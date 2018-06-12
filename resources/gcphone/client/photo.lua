-- @author ??? Maybe Charli FeverRP

phone = false
phoneId = 0

RegisterNetEvent('camera:open')
AddEventHandler('camera:open', function()
    TriggerEvent('es:setMoneyDisplay',0)
    TriggerEvent('es:setBankDisplay',0)
    TriggerEvent('es:setFoodDisplay',0)
    
    CreateMobilePhone(1)
	CellCamActivate(true, true)
	phone = true
    ePhoneOut()
    local Button = {
        {'~INPUT_PHONE~',"Retourner"},
        {'~INPUT_CELLPHONE_CANCEL~',"Ranger"}
    }
    TriggerEvent('hud:SetButton',Button, 0)
end)

frontCam = false

function CellFrontCamActivate(activate)
	return Citizen.InvokeNative(0x2491A93618B7D838, activate)
end

Citizen.CreateThread(function()
DestroyMobilePhone()
	while true do
		Citizen.Wait(0)
				
		if IsControlJustPressed(1, 177) and phone == true then -- CLOSE PHONE
			DestroyMobilePhone()
			phone = false
            TriggerEvent('es:setMoneyDisplay',100)
            TriggerEvent('es:setBankDisplay',100)
            TriggerEvent('es:setFoodDisplay',100)
			CellCamActivate(false, false)
			if firstTime == true then 
				firstTime = false 
				Citizen.Wait(2500)
				displayDoneMission = true
			end
		end
		
		if IsControlJustPressed(1, 27) and phone == true then -- SELFIE MODE
			frontCam = not frontCam
			CellFrontCamActivate(frontCam)
		end
			
		if phone == true then
            TriggerEvent('hud:RenderButton') 
			HideHudComponentThisFrame(7)
			HideHudComponentThisFrame(8)
			HideHudComponentThisFrame(9)
			HideHudComponentThisFrame(6)
			HideHudComponentThisFrame(19)
			HideHudAndRadarThisFrame()
		end
			
		ren = GetMobilePhoneRenderId()
		SetTextRenderId(ren)
		
		-- Everything rendered inside here will appear on your phone.
		
		SetTextRenderId(1) -- NOTE: 1 is default
	end
end)