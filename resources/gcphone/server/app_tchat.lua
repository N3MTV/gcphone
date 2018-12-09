function TchatGetMessageChannel (channel, cb)
    MySQL.Async.fetchAll("SELECT * FROM phone_app_chat WHERE channel = @channel ORDER BY time DESC LIMIT 100", { 
        ['@channel'] = channel
    }, cb)
end

function TchatAddMessage (channel, message)
  local id = MySQL.Sync.insert("INSERT INTO phone_app_chat (`channel`, `message`) VALUES (@channel, @message)", {
    ['@channel'] = channel,
    ['@message'] = message
  })

  local result = MySQL.Sync.fetchAll('SELECT * FROM phone_app_chat WHERE `id` = @id', {
    ['@id'] = id
  })

  TriggerClientEvent('gcPhone:tchat_receive', -1, result[1])
end


RegisterServerEvent('gcPhone:tchat_channel')
AddEventHandler('gcPhone:tchat_channel', function(channel)
  local sourcePlayer = tonumber(source)
  TchatGetMessageChannel(channel, function (messages)
    TriggerClientEvent('gcPhone:tchat_channel', sourcePlayer, channel, messages)
  end)
end)

RegisterServerEvent('gcPhone:tchat_addMessage')
AddEventHandler('gcPhone:tchat_addMessage', function(channel, message)
  TchatAddMessage(channel, message)
end)