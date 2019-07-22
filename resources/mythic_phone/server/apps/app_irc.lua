RegisterServerEvent('mythic_characters:server:CharacterSpawned')
AddEventHandler('mythic_characters:server:CharacterSpawned', function(channel)
    local src = source
    local char = exports['mythic_base']:getPlayerFromId(src).getChar()
    TriggerClientEvent('mythic_phone:client:IRCReset', src)
    IRCGetChannels(char, function (channels)
        TriggerClientEvent('mythic_phone:client:IRCSetChannels', src, channels)
    end)
end)

function IRCGetChannels (char, cb)
    local cData = char.getCharData()
    exports['ghmattimysql']:execute("SELECT * FROM character_irc_channels WHERE charid = @charid ORDER BY channel DESC LIMIT 100", { 
        ['charid'] = cData.id
    }, cb)
end

function IRCJoinChannel (char, channel)
    local cData = char.getCharData()
    exports['ghmattimysql']:execute("INSERT INTO character_irc_channels (`charid`, `channel`) VALUES(@charid, @channel)", {
        ['charid'] = cData.id,
        ['channel'] = channel
    })
end

function IRCLeaveChannel (char, channel)
    local cData = char.getCharData()
    exports['ghmattimysql']:execute("DELETE FROM character_irc_channels WHERE charid = @charid AND channel = @channel", { 
        ['charid'] = cData.id,
        ['channel'] = channel
    })
end

function IRCGetMessageChannel (channel, cb)
    local src = source
    local char = exports['mythic_base']:getPlayerFromId(src).getChar()
    local cData = char.getCharData()
    local messages = {}
    exports['ghmattimysql']:scalar('SELECT joined FROM character_irc_channels WHERE charid = @charid and channel = @channel', { ['charid'] = cData.id, ['channel'] = channel}, function(joined)
        if joined == nil then
            joined = os.time()
        end
        exports['ghmattimysql']:execute("SELECT * FROM phone_irc WHERE channel = @channel AND UNIX_TIMESTAMP(TIME) >= @joined", { 
            ['channel'] = channel,
            ['joined'] = (joined / 1000)
        }, cb)
    end)
end
  
function IRCAddMessage (channel, message)
    local Query = "INSERT INTO phone_irc (`channel`, `message`) VALUES(@channel, @message);"
    local Query2 = 'SELECT * from phone_irc WHERE `id` = @id;'
    local Parameters = {
      ['channel'] = channel,
      ['message'] = message
    }
    exports['ghmattimysql']:execute(Query, Parameters, function (id)
      exports['ghmattimysql']:execute(Query2, { ['id'] = id.insertId }, function (reponse)
        TriggerClientEvent('mythic_phone:client:IRCReceive', -1, reponse[1])
      end)
    end)
end
  
RegisterServerEvent('mythic_phone:server:IRCGetChannels')
AddEventHandler('mythic_phone:server:IRCGetChannels', function(channel)
    local src = source
    local char = exports['mythic_base']:getPlayerFromId(src).getChar()
    IRCGetChannels(char, function (channels)
        print(json.encode(channels))
        TriggerClientEvent('mythic_phone:client:IRCSetChannels', src, channels)
    end)
end)
  
RegisterServerEvent('mythic_phone:server:IRCJoinChannel')
AddEventHandler('mythic_phone:server:IRCJoinChannel', function(channel)
    local src = source
    local char = exports['mythic_base']:getPlayerFromId(src).getChar()
    IRCJoinChannel(char, channel)
end)
  
RegisterServerEvent('mythic_phone:server:IRCLeaveChannel')
AddEventHandler('mythic_phone:server:IRCLeaveChannel', function(channel)
    local src = source
    local char = exports['mythic_base']:getPlayerFromId(src).getChar()
    IRCLeaveChannel(char, channel)
end)
  
RegisterServerEvent('mythic_phone:server:IRCChannel')
AddEventHandler('mythic_phone:server:IRCChannel', function(channel, joined)
    local sourcePlayer = tonumber(source)
    IRCGetMessageChannel(channel, function (messages)
        TriggerClientEvent('mythic_phone:client:IRCChannel', sourcePlayer, channel, messages)
    end)
end)
  
RegisterServerEvent('mythic_phone:server:IRCAddMessage')
AddEventHandler('mythic_phone:server:IRCAddMessage', function(channel, message)
    IRCAddMessage(channel, message)
end)