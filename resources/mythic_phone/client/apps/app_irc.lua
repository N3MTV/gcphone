RegisterNetEvent("mythic_phone:client:IRCReset")
AddEventHandler("mythic_phone:client:IRCReset", function(channels)
  SendNUIMessage({event = 'irc_reset'})
end)

RegisterNetEvent("mythic_phone:client:IRCSetChannels")
AddEventHandler("mythic_phone:client:IRCSetChannels", function(channels)
  SendNUIMessage({event = 'irc_set_channels', channels = channels})
end)

RegisterNetEvent("mythic_phone:client:IRCReceive")
AddEventHandler("mythic_phone:client:IRCReceive", function(message)
  SendNUIMessage({event = 'irc_receive', message = message})
end)

RegisterNetEvent("mythic_phone:client:IRCChannel")
AddEventHandler("mythic_phone:client:IRCChannel", function(channel, messages)
  SendNUIMessage({event = 'irc_channel', messages = messages})
end)

RegisterNUICallback('irc_joinChannel', function(data, cb)
  TriggerServerEvent('mythic_phone:server:IRCJoinChannel', data.channel)
end)

RegisterNUICallback('irc_leaveChannel', function(data, cb)
  TriggerServerEvent('mythic_phone:server:IRCLeaveChannel', data.channel)
end)

RegisterNUICallback('irc_addMessage', function(data, cb)
  TriggerServerEvent('mythic_phone:server:IRCAddMessage', data.channel, data.message)
end)

RegisterNUICallback('irc_getChannel', function(data, cb)
  TriggerServerEvent('mythic_phone:server:IRCChannel', data.channel, data.joined)
end)
