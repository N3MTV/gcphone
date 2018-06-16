local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}


local CurrentInfoCall            = nil
ESX                              = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)


RegisterNetEvent('esx_phone:stopDispatch')
AddEventHandler('esx_phone:stopDispatch', function(callId, reason)
	if CurrentInfoCall ~= nil and CurrentInfoCall.id == callId  then
		CurrentInfoCall = nil
	end
end)

RegisterNetEvent('esx_phone:setPhoneNumberSource')
AddEventHandler('esx_phone:setPhoneNumberSource', function(phoneNumber, source)
	if source == -1 then
		PhoneNumberSources[phoneNumber] = nil
	else
		PhoneNumberSources[phoneNumber] = source
	end
end)

RegisterNUICallback('setGPS', function(data)
	SetNewWaypoint(data.x,  data.y)
	ESX.ShowNotification(_U('gps_position'))
end)

RegisterNUICallback('send', function(data)
	local phoneNumber = data.number
	local playerPed   = GetPlayerPed(-1)
	local coords      = GetEntityCoords(playerPed)

	if tonumber(phoneNumber) ~= nil then
		phoneNumber = tonumber(phoneNumber)
	end

	TriggerServerEvent('esx_phone:send', phoneNumber, data.message, data.anonyme, {
		x = coords.x,
		y = coords.y,
		z = coords.z
	})
	
	SendNUIMessage({
		showMessageEditor = false
	})

	ESX.ShowNotification(_U('message_sent'))
end)


RegisterNetEvent('esx_addons_gcphone:alert')
AddEventHandler('esx_addons_gcphone:alert', function (callInfo)
  print('CurrentInfoCall', callInfo)
  print('sx_addons_gcphone:alert', json.encode(callInfo))
  if CurrentInfoCall == nil then
    print('set CurrentInfoCall')
    CurrentInfoCall = callInfo
  end
end)

-- CurrentInfoCall = {
--   extraData = {
--     id = 0,
--     message = "Ewemple de message Ewemple de message Ewemple de message Ewemple de message Ewemple de message ",
--     coords = {
--       x = 20.1234564,
--       y = 20.12,
--       z = 564.12
--     }
--   }
-- }
-- Key controls
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10)
		
		if CurrentInfoCall ~= nil then
      DrawRect(0.12, 0.10, 0.2, 0.16, 0, 0, 0, 178)
      SetTextFont(0)
      SetTextScale(0.0, 0.35)
      SetTextCentre(true)
      SetTextDropShadow(0, 0, 0, 0, 0)
      SetTextEdge(0, 0, 0, 0, 0)
      SetTextColour(255, 255, 255, 255)
      SetTextEntry("STRING")
      AddTextComponentString('~b~Appels en cours')
      DrawText(0.12, 0.02)

      SetTextFont(0)
      SetTextScale(0.0, 0.24)
      SetTextCentre(false)
      SetTextDropShadow(0, 0, 0, 0, 0)
      SetTextEdge(0, 0, 0, 0, 0)
      SetTextColour(255, 255, 255, 255)
      SetTextEntry("STRING")
      AddTextComponentString('Appuyez sur ~g~X~s~ pour prendre l\'appel ou ~r~N~s~ pour le refuser')
      DrawText(0.025, 0.16)

      if CurrentInfoCall.extraData ~= nill and CurrentInfoCall.extraData.message ~= nil then
        local message = CurrentInfoCall.extraData.message
        local sh = 0.045
        while #message ~= 0 do
          message2 = string.sub(message, 0, 50)
          message2 = message2:gsub("^%s*(.-)%s*$", "%1")
          message = string.sub(message, 51)
          SetTextFont(0)
          SetTextScale(0.0, 0.30)
          SetTextCentre(false)
          SetTextDropShadow(0, 0, 0, 0, 0)
          SetTextEdge(0, 0, 0, 0, 0)
          SetTextColour(255, 255, 255, 255)
          SetTextEntry("STRING")
          AddTextComponentString(message2)
          DrawText(0.025, sh)
          sh = sh + 0.018
        end
      else
        SetTextFont(0)
        SetTextScale(0.0, 0.30)
        SetTextCentre(true)
        SetTextDropShadow(0, 0, 0, 0, 0)
        SetTextEdge(0, 0, 0, 0, 0)
        SetTextColour(255, 255, 255, 255)
        SetTextEntry("STRING")
        AddTextComponentString("~o~Aucun message")
        DrawText(0.12, 0.08)
      end

      if CurrentInfoCall.extraData ~= nill and CurrentInfoCall.extraData.coords ~= nil then
        SetTextFont(0)
        SetTextScale(0.0, 0.24)
        SetTextCentre(true)
        SetTextDropShadow(0, 0, 0, 0, 0)
        SetTextEdge(0, 0, 0, 0, 0)
        SetTextColour(255, 255, 255, 255)
        SetTextEntry("STRING")
        AddTextComponentString('~g~Position: ~b~' .. math.floor(CurrentInfoCall.extraData.coords.x) .. ' ' .. math.floor(CurrentInfoCall.extraData.coords.y))
        DrawText(0.12, 0.14)
      else
        SetTextFont(0)
        SetTextScale(0.0, 0.24)
        SetTextCentre(true)
        SetTextDropShadow(0, 0, 0, 0, 0)
        SetTextEdge(0, 0, 0, 0, 0)
        SetTextColour(255, 255, 255, 255)
        SetTextEntry("STRING")
        AddTextComponentString('~o~Position inconnu')
        DrawText(0.12, 0.14)
      end

      if GetLastInputMethod(2) then 
        if IsControlPressed(0, Keys['X']) then
          TriggerServerEvent('esx_phone:acceptCall', CurrentInfoCall, nil)
          TriggerServerEvent('esx_phone:stopDispatch', CurrentInfoCall.id)
          if CurrentInfoCall.extraData ~= nill and CurrentInfoCall.extraData.coords ~= nil then
            SetNewWaypoint(CurrentInfoCall.extraData.coords.x,  CurrentInfoCall.extraData.coords.y)
          end
          CurrentInfoCall = nil
        elseif IsControlPressed(0, Keys["N"]) then
          CurrentInfoCall = nil
        end

      end

		end
	end
end)



RegisterNetEvent('esx_addons_gcphone:call')
AddEventHandler('esx_addons_gcphone:call', function(data)
  print('envent:')
  local playerPed   = GetPlayerPed(-1)
  local coords      = GetEntityCoords(playerPed)
  local message     = data.message
  local number      = data.number
  if message == nil then
    DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "", "", "", "", "", 200)
    while (UpdateOnscreenKeyboard() == 0) do
      DisableAllControlActions(0);
      Wait(0);
    end
    if (GetOnscreenKeyboardResult()) then
      message =  GetOnscreenKeyboardResult()
    end
  end
  if message ~= nil and message ~= "" then
    TriggerServerEvent('esx_addons_gcphone:startCall', number, nil, message, {
      x = coords.x,
      y = coords.y,
      z = coords.z
    })
  end
end)

