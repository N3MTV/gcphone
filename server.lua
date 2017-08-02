--====================================================================================
-- #Author: Jonathan D @Gannon
--====================================================================================
--====================================================================================
--  
--====================================================================================


--====================================================================================
--  Utils
--====================================================================================

function getPhoneRandomNumber()
    return '0' .. math.random(600000000,699999999)
end

function getSourceFromIdentifier(identifier, cb)
    TriggerEvent("es:getPlayers", function(users)
        for k , user in pairs(users) do
            if user.getIdentifier() == identifier then
                cb(k)
                return
            end
        end
    end)
    cb(nil)
end
function getNumberPhone(identifier)
    local result = MySQL.Sync.fetchAll("SELECT users.phone_number FROM users WHERE users.identifier = @identifier", {
        ['@identifier'] = identifier
    })
    if result[1] ~= nil then
        return result[1].phone_number
    end
    return nil
end

function getIdentifierByPhoneNumber(phone_number)
    local result = MySQL.Sync.fetchAll("SELECT users.identifier FROM users WHERE users.phone_number = @phone_number", {
        ['@phone_number'] = phone_number
    })
    if result[1] ~= nil then
        return result[1].identifier
    end
    return nil
end
--====================================================================================
--  Contacts
--====================================================================================
function getContacts(identifier)
    local result = MySQL.Sync.fetchAll("SELECT phone_users_contacts.id, phone_users_contacts.number, phone_users_contacts.display FROM phone_users_contacts WHERE phone_users_contacts.identifier = @identifier", {
        ['@identifier'] = identifier
    })
    return result
end

function addContact(source, identifier, number, display)
    local sourcePlayer = tonumber(source)
    print(number .. ' ' ..  display)
    MySQL.Sync.execute("INSERT INTO phone_users_contacts (`identifier`, `number`,`display`) VALUES(@identifier, @number, @display)", {
        ['@identifier'] = identifier,
        ['@number'] = number,
        ['@display'] = display,
    })
    notifyContactChange(sourcePlayer, identifier)
end

function updateContact(source, identifier, id, number, display)
    local sourcePlayer = tonumber(source)
    MySQL.Sync.execute("UPDATE phone_users_contacts SET number = @number, display = @display WHERE id = @id", { 
        ['@number'] = number,
        ['@display'] = display,
        ['@id'] = id,
    })
    notifyContactChange(sourcePlayer, identifier)
end

function deleteContact(source, identifier, id)
    local sourcePlayer = tonumber(source)
    MySQL.Sync.execute("DELETE FROM phone_users_contacts WHERE `identifier` = @identifier AND `id` = @id", {
        ['@identifier'] = identifier,
        ['@id'] = id,
    })
    notifyContactChange(sourcePlayer, identifier)
end

function deleteAllContact(identifier)
    MySQL.Sync.execute("DELETE FROM phone_users_contacts WHERE `identifier` = @identifier", {
        ['@identifier'] = identifier
    })
end

function notifyContactChange(source, identifier)
    local sourcePlayer = tonumber(source)
    if sourcePlayer ~= nil then 
        TriggerClientEvent("gcPhone:contactList", sourcePlayer, getContacts(identifier))
    end
end

RegisterServerEvent('gcPhone:addContact')
AddEventHandler('gcPhone:addContact', function(display, phoneNumber)
    local sourcePlayer = tonumber(source)
    local identifier = GetPlayerIdentifiers(source)[1]
    addContact(sourcePlayer, identifier, phoneNumber, display)
end)

RegisterServerEvent('gcPhone:updateContact')
AddEventHandler('gcPhone:updateContact', function(id, display, phoneNumber)
    local sourcePlayer = tonumber(source)
    local identifier = GetPlayerIdentifiers(source)[1]
    updateContact(sourcePlayer, identifier, id, phoneNumber, display)
end)

RegisterServerEvent('gcPhone:deleteContact')
AddEventHandler('gcPhone:deleteContact', function(id)
    local sourcePlayer = tonumber(source)
    local identifier = GetPlayerIdentifiers(source)[1]
    deleteContact(sourcePlayer, identifier, id)
end)

--====================================================================================
--  Messages
--====================================================================================
function getMessages(identifier)
    local result = MySQL.Sync.fetchAll("SELECT phone_messages.* FROM phone_messages LEFT JOIN users ON users.identifier = @identifier WHERE phone_messages.receiver = users.phone_number", {
         ['@identifier'] = identifier
    })
    -- A CHANGER !!!!!!!
    --for k, v in ipairs(result) do  
        --v.time = os.time(v.time) + math.floor(0) - 2*60*60
    --end
    return result
    --return MySQLQueryTimeStamp("SELECT phone_messages.* FROM phone_messages LEFT JOIN users ON users.identifier = @identifier WHERE phone_messages.receiver = users.phone_number", {['@identifier'] = identifier})
end

local MessagesToAdd = {}

AddEventHandler('playerDropped', function()
    local sourcePlayer = tonumber(source)
    if source ~= nil then
        for k,v in pairs(MessagesToAdd)do
            if MessagesToAdd[k] ~= nil then
                MySQL.Sync.execute("INSERT INTO phone_messages (`transmitter`, `receiver`, `message`, `time`, `isRead`, `owner`) VALUES(@transmitter, @receiver, @message, @time, @isRead, @owner)", {
                    ['@transmitter'] = MessagesToAdd[k].transmitter,
                    ['@receiver'] = MessagesToAdd[k].receiver,
                    ['@message'] = MessagesToAdd[k].message,
                    ['@time'] = MessagesToAdd[k].time,
                    ['@isRead'] = MessagesToAdd[k].owner,
                    ['@owner'] = MessagesToAdd[k].owner
                })
            end
        end
    end
end)

local function updatePlayerMessages()
    SetTimeout(6000000, function()
        for k,v in pairs(MessagesToAdd)do
            if MessagesToAdd[k] ~= nil then
                MySQL.Sync.execute("INSERT INTO phone_messages (`transmitter`, `receiver`, `message`, `time`, `isRead`, `owner`) VALUES(@transmitter, @receiver, @message, @time, @isRead, @owner)", {
                    ['@transmitter'] = MessagesToAdd[k].transmitter,
                    ['@receiver'] = MessagesToAdd[k].receiver,
                    ['@message'] = MessagesToAdd[k].message,
                    ['@time'] = MessagesToAdd[k].time,
                    ['@isRead'] = MessagesToAdd[k].owner,
                    ['@owner'] = MessagesToAdd[k].owner
                })
            end
        end
        updatePlayerMessages()
    end)
end
updatePlayerMessages()

local lastmessage = {
    transmitter = 0,
    receiver = 0,
    message = 0,
    time = 0,
    isRead = 0,
    owner = 0,
}

function _internalAddMessage(transmitter, receiver, message, owner)
    print('ADD MESSAGE: ' .. transmitter .. receiver .. message .. owner)
    local tstamp = os.date("*t", os.time())
    local time = os.date(tstamp.year .. "-" .. tstamp.month .. "-" .. tstamp.day .. " " .. tstamp.hour .. ":" .. tstamp.min .. ":" .. tstamp.sec)
    table.insert(MessagesToAdd, {transmitter,receiver,message,isRead,owner})
    lastmessage.transmitter = transmitter
    lastmessage.receiver = receiver
    lastmessage.message = message
    lastmessage.time = time
    lastmessage.isRead = owner
    lastmessage.owner = owner
    return lastmessage
end

function addMessage(source, identifier, phone_number, message)
    local sourcePlayer = tonumber(source)
    local otherIdentifier = getIdentifierByPhoneNumber(phone_number)
    local myPhone = getNumberPhone(identifier)
    if otherIdentifier ~= nil then 
        local tomess = _internalAddMessage(myPhone, phone_number, message, 0)
        getSourceFromIdentifier(otherIdentifier, function (osou)
            if tonumber(osou) ~= nil then 
                -- TriggerClientEvent("gcPhone:allMessage", osou, getMessages(otherIdentifier))
                TriggerClientEvent("gcPhone:receiveMessage", tonumber(osou), tomess)
            end
        end) 
    end
    local memess = _internalAddMessage(phone_number, myPhone, message, 1)
    -- TriggerClientEvent("gcPhone:allMessage", source, getMessages(identifier))
    TriggerClientEvent("gcPhone:receiveMessage", sourcePlayer, memess)

end

function setReadMessageNumber(identifier, num)
    local mePhoneNumber = getNumberPhone(identifier)
    MySQL.Sync.execute("UPDATE phone_messages SET phone_messages.isRead = 1 WHERE phone_messages.receiver = @receiver AND phone_messages.transmitter = @transmitter", { 
        ['@receiver'] = mePhoneNumber,
        ['@transmitter'] = num
    })
end

function deleteMessage(msgId)
    MySQL.Sync.execute("DELETE FROM phone_messages WHERE `id` = @id", {
        ['@id'] = msgId
    })
end

function deleteAllMessageFromPhoneNumber(identifier, phone_number)
    local mePhoneNumber = getNumberPhone(identifier)
    MySQL.Sync.execute("DELETE FROM phone_messages WHERE `receiver` = @mePhoneNumber and `transmitter` = @phone_number", {
        ['@mePhoneNumber'] = mePhoneNumber,
        ['@phone_number'] = phone_number
    })
end

function deleteAllMessage(identifier)
    local mePhoneNumber = getNumberPhone(identifier)
    MySQL.Sync.execute("DELETE FROM phone_messages WHERE `receiver` = @mePhoneNumber", {
        ['@mePhoneNumber'] = mePhoneNumber
    })
end

RegisterServerEvent('gcPhone:sendMessage')
AddEventHandler('gcPhone:sendMessage', function(phoneNumber, message)
    local sourcePlayer = tonumber(source)
    local identifier = GetPlayerIdentifiers(source)[1]
    print(identifier)
    addMessage(sourcePlayer, identifier, phoneNumber, message)
end)

RegisterServerEvent('gcPhone:deleteMessage')
AddEventHandler('gcPhone:deleteMessage', function(msgId)
    deleteMessage(msgId)
end)

RegisterServerEvent('gcPhone:deleteMessageNumber')
AddEventHandler('gcPhone:deleteMessageNumber', function(number)
    local sourcePlayer = tonumber(source)
    local identifier = GetPlayerIdentifiers(source)[1]
    deleteAllMessageFromPhoneNumber(identifier, number)
    TriggerClientEvent("gcPhone:allMessage", sourcePlayer, getMessages(identifier))
end)

RegisterServerEvent('gcPhone:deleteAllMessage')
AddEventHandler('gcPhone:deleteAllMessage', function()
    local sourcePlayer = tonumber(source)
    local identifier = GetPlayerIdentifiers(source)[1]
    deleteAllMessage(identifier)
    TriggerClientEvent("gcPhone:allMessage", sourcePlayer, getMessages(identifier))
end)

RegisterServerEvent('gcPhone:setReadMessageNumber')
AddEventHandler('gcPhone:setReadMessageNumber', function(num)
    local identifier = GetPlayerIdentifiers(source)[1]
    setReadMessageNumber(identifier, num)
end)

RegisterServerEvent('gcPhone:deleteALL')
AddEventHandler('gcPhone:deleteALL', function()
    local sourcePlayer = tonumber(source)
    local identifier = GetPlayerIdentifiers(source)[1]
    deleteAllMessage(identifier)
    deleteAllContact(identifier)
    TriggerClientEvent("gcPhone:contactList", sourcePlayer, {})
    TriggerClientEvent("gcPhone:allMessage", sourcePlayer, {})
end)
--====================================================================================
--  OnLoad
--====================================================================================
AddEventHandler('es:playerLoaded',function(source)
    local sourcePlayer = tonumber(source)
    local identifier = GetPlayerIdentifiers(sourcePlayer)[1]
    local myPhoneNumber = getNumberPhone(identifier)
    print(myPhoneNumber)
    while myPhoneNumber == nil or tonumber(myPhoneNumber) == 0 do 
        local randomNumberPhone = getPhoneRandomNumber()
        print('TryPhone: ' .. randomNumberPhone)
        MySQL.Sync.execute("UPDATE users SET phone_number = @randomNumberPhone WHERE identifier = @identifier", { 
            ['@randomNumberPhone'] = randomNumberPhone,
            ['@identifier'] = identifier
        })
        myPhoneNumber = getNumberPhone(identifier)
    end
    print(myPhoneNumber)
    TriggerClientEvent("gcPhone:myPhoneNumber", sourcePlayer, myPhoneNumber)
    TriggerClientEvent("gcPhone:contactList", sourcePlayer, getContacts(identifier))
    TriggerClientEvent("gcPhone:allMessage", sourcePlayer, getMessages(identifier))
end)

-- Just For reload
RegisterServerEvent('gcPhone:allUpdate')
AddEventHandler('gcPhone:allUpdate', function()
    local sourcePlayer = tonumber(source)
    local identifier = GetPlayerIdentifiers(source)[1]
    TriggerClientEvent("gcPhone:myPhoneNumber", sourcePlayer, getNumberPhone(identifier))
    TriggerClientEvent("gcPhone:contactList", sourcePlayer, getContacts(identifier))
    TriggerClientEvent("gcPhone:allMessage", sourcePlayer, getMessages(identifier))
end)
