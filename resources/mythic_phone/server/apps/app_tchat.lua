function TchatGetMessageChannel (channel, cb)
  exports['ghmattimysql']:execute("SELECT * FROM phone_app_chat WHERE channel = @channel ORDER BY time DESC LIMIT 100", { 
      ['channel'] = channel
  }, cb)
end

function TchatAddMessage (channel, message)
  local Query = "INSERT INTO phone_app_chat (`channel`, `message`) VALUES(@channel, @message);"
  local Query2 = 'SELECT * from phone_app_chat WHERE `id` = @id;'
  local Parameters = {
    ['channel'] = channel,
    ['message'] = message
  }
  exports['ghmattimysql']:execute(Query, Parameters, function (id)
    exports['ghmattimysql']:execute(Query2, { ['id'] = id }, function (reponse)
      TriggerClientEvent('mythic_phone:client:tchat_receive', -1, reponse[1])
    end)
  end)
end


RegisterServerEvent('mythic_phone:server:tchat_channel')
AddEventHandler('mythic_phone:server:tchat_channel', function(channel)
  local sourcePlayer = tonumber(source)
  TchatGetMessageChannel(channel, function (messages)
    TriggerClientEvent('mythic_phone:client:tchat_channel', sourcePlayer, channel, messages)
  end)
end)

RegisterServerEvent('mythic_phone:server:tchat_addMessage')
AddEventHandler('mythic_phone:server:tchat_addMessage', function(channel, message)
  TchatAddMessage(channel, message)
end)