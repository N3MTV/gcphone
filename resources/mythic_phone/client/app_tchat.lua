RegisterNetEvent("mythic_phone:client:tchat_receive")
AddEventHandler("mythic_phone:client:tchat_receive", function(message)
  SendNUIMessage({event = 'tchat_receive', message = message})
end)

RegisterNetEvent("mythic_phone:client:tchat_channel")
AddEventHandler("mythic_phone:client:tchat_channel", function(channel, messages)
  SendNUIMessage({event = 'tchat_channel', messages = messages})
end)

RegisterNUICallback('tchat_addMessage', function(data, cb)
  TriggerServerEvent('mythic_phone:server:tchat_addMessage', data.channel, data.message)
end)

RegisterNUICallback('tchat_getChannel', function(data, cb)
  TriggerServerEvent('mythic_phone:server:tchat_channel', data.channel)
end)
