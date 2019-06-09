RegisterNetEvent('mythic_phone:client:call')
AddEventHandler('mythic_phone:client:call', function(data)
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
    TriggerServerEvent('mythic_phone_component:server:startCall', number, message, {
      x = coords.x,
      y = coords.y,
      z = coords.z
    })
  end
end)
