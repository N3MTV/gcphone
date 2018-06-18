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


local alerts           = {}
local currentAlert     = 1
ESX                    = nil


-- alerts = {
--   {
--     id = 500,
--     message = 'Help',
--     coords = { x = 132, y = -42},
--     phone = '366-888',
--     isAccept = 0
--   },
--   {
--     id = 45674,
--     message = 'Help2',
--     coords = { x = 132, y = -42},
--     phone = '366-888',
--     isAccept = 1
--   },
--   {
--     id = 45,
--     message = 'Help3',
--     coords = { x = 132, y = -42},
--     phone = '366-888',
--     isAccept = 3
--   }
-- }

-- Citizen.CreateThread(function ()
  --   Citizen.Wait(1000)
  --   TriggerServerEvent('esx_addons_gcphone:startCall', 'police', 'lol', {
  --     x = 13,
  --     y = 254,
  --     z = 0
  --   })
  
  -- end)

function removeAlert (alertId) 
  for k, v in ipairs(alerts) do
    if v.id == alertId then
      if currentAlert >= k then
        currentAlert = math.max(1, currentAlert - 1)
      end
      table.remove(alerts, k)
      break
    end
  end
end

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)



RegisterNetEvent('esx_addons_gcphone:notifyAlert')
AddEventHandler('esx_addons_gcphone:notifyAlert', function(alert)
  local find = false
  for key, calert in ipairs(alerts) do 
    if alert.id == calert.id then
      find = true
      alerts[key] = alert
      break
    end
  end
  if find == false then
    table.insert(alerts, alert)
  end
end)


RegisterNetEvent('esx_addons_gcphone:setPhoneNumberSource')
AddEventHandler('esx_addons_gcphone:setPhoneNumberSource', function(phoneNumber, source)
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

	TriggerServerEvent('esx_addons_gcphone:send', phoneNumber, data.message, data.anonyme, {
		x = coords.x,
		y = coords.y,
		z = coords.z
	})
	
	SendNUIMessage({
		showMessageEditor = false
	})

	ESX.ShowNotification(_U('message_sent'))
end)



RegisterNetEvent('esx_addons_gcphone:showMessage')
AddEventHandler('esx_addons_gcphone:showMessage', function (message)
  ESX.ShowNotification(message)
end)



Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10)
    if #alerts ~= 0 then
      local alert = alerts[currentAlert]
      DrawRect(0.12, 0.10, 0.2, 0.16, 0, 0, 0, 178)

      SetTextFont(0)
      SetTextScale(0.0, 0.35)
      SetTextCentre(true)
      SetTextDropShadow(0, 0, 0, 0, 0)
      SetTextEdge(0, 0, 0, 0, 0)
      SetTextColour(255, 255, 255, 255)
      SetTextEntry("STRING")
      if alert.isAccept == 0 then
        AddTextComponentString('~o~Appels en cours')
      else
        AddTextComponentString('~g~Appels en cours')
      end
      DrawText(0.12, 0.02)


      SetTextFont(0)
      SetTextScale(0.0, 0.24)
      SetTextCentre(false)
      SetTextDropShadow(0, 0, 0, 0, 0)
      SetTextEdge(0, 0, 0, 0, 0)
      SetTextColour(255, 255, 255, 255)
      SetTextEntry("STRING")
      AddTextComponentString('~r~' .. currentAlert .. ' / ~r~' .. #alerts)
      DrawText(0.025, 0.02)


      SetTextFont(0)
      SetTextScale(0.0, 0.24)
      SetTextCentre(false)
      SetTextDropShadow(0, 0, 0, 0, 0)
      SetTextEdge(0, 0, 0, 0, 0)
      SetTextColour(255, 255, 255, 255)
      SetTextEntry("STRING")
      AddTextComponentString(alert.isAccept .. ' unité')
      DrawText(0.195, 0.02)

      SetTextFont(0)
      SetTextScale(0.0, 0.24)
      SetTextCentre(false)
      SetTextDropShadow(0, 0, 0, 0, 0)
      SetTextEdge(0, 0, 0, 0, 0)
      SetTextColour(255, 255, 255, 255)
      SetTextEntry("STRING")
      AddTextComponentString('Appuyez sur ~g~X~s~ pour prendre l\'appel ou ~r~N~s~ pour le refuser')
      DrawText(0.025, 0.16)

      if alert.message ~= nil then
        local message = alert.message
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

      if alert.coords ~= nil then
        SetTextFont(0)
        SetTextScale(0.0, 0.24)
        SetTextCentre(true)
        SetTextDropShadow(0, 0, 0, 0, 0)
        SetTextEdge(0, 0, 0, 0, 0)
        SetTextColour(255, 255, 255, 255)
        SetTextEntry("STRING")
        AddTextComponentString('~g~Position: ~b~' .. math.floor(alert.coords.x) .. ' ' .. math.floor(alert.coords.y))
        DrawText(0.07, 0.14)
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

      if alert.numero ~= nil then
        SetTextFont(0)
        SetTextScale(0.0, 0.24)
        SetTextCentre(true)
        SetTextDropShadow(0, 0, 0, 0, 0)
        SetTextEdge(0, 0, 0, 0, 0)
        SetTextColour(255, 255, 255, 255)
        SetTextEntry("STRING")
        AddTextComponentString('~g~Numero: ~b~' .. alert.numero)
        DrawText(0.17, 0.14)
      else 
        SetTextFont(0)
        SetTextScale(0.0, 0.24)
        SetTextCentre(true)
        SetTextDropShadow(0, 0, 0, 0, 0)
        SetTextEdge(0, 0, 0, 0, 0)
        SetTextColour(255, 255, 255, 255)
        SetTextEntry("STRING")
        AddTextComponentString('~o~Numero inconnu')
        DrawText(0.17, 0.14)
      end

      if GetLastInputMethod(2) then 
        if IsControlJustPressed(1, Keys['RIGHT']) then
          currentAlert = ((currentAlert) % #alerts) + 1
        elseif IsControlJustPressed(1, Keys['LEFT']) then
          currentAlert = ((currentAlert + #alerts - 2) % #alerts) + 1
        elseif IsControlJustPressed(1, Keys['X']) then
          TriggerServerEvent('esx_addons_gcphone:acceptAlert', alert.type, alert.id)
          if alert.coords ~= nil then
            SetNewWaypoint(alert.coords.x, alert.coords.y)
          end
        elseif IsControlJustPressed(1, Keys["N"]) then
          TriggerServerEvent('esx_addons_gcphone:refuseAlert', alert.type, alert.id)
          removeAlert(alert.id)
        end

      end

		end
	end
end)



RegisterNetEvent('esx_addons_gcphone:call')
AddEventHandler('esx_addons_gcphone:call', function(data)
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
    TriggerServerEvent('esx_addons_gcphone:startCall', number, message, {
      x = coords.x,
      y = coords.y,
      z = coords.z
    })
  end
end)
