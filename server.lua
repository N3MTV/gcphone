--====================================================================================
-- #Author: Jonathan D @Gannon
--====================================================================================

-- AddEventHandler('onMySQLReady', function ()
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
    print(number .. ' ' ..  display)
    MySQL.Sync.execute("INSERT INTO phone_users_contacts (`identifier`, `number`,`display`) VALUES(@identifier, @number, @display)", {
        ['@identifier'] = identifier,
        ['@number'] = number,
        ['@display'] = display,
    })
    notifyContactChange(source, identifier)
end

function updateContact(source, identifier, id, number, display)
    MySQL.Sync.execute("UPDATE phone_users_contacts SET number = @number, display = @display WHERE id = @id", { 
        ['@number'] = number,
        ['@display'] = display,
        ['@id'] = id,
    })
    notifyContactChange(source, identifier)
end

function deleteContact(source, identifier, id)
    MySQL.Sync.execute("DELETE FROM phone_users_contacts WHERE `identifier` = @identifier AND `id` = @id", {
        ['@identifier'] = identifier,
        ['@id'] = id,
    })
    notifyContactChange(source, identifier)
end

function deleteAllContact(identifier)
    MySQL.Sync.execute("DELETE FROM phone_users_contacts WHERE `identifier` = @identifier", {
        ['@identifier'] = identifier
    })
end

function notifyContactChange(source, identifier)
    if source ~= nil then 
        TriggerClientEvent("gcphone:contactList", source, getContacts(identifier))
    end
end

RegisterServerEvent('gcphone:addContact')
AddEventHandler('gcphone:addContact', function(display, phoneNumber)
    local identifier = GetPlayerIdentifiers(source)[1]
    addContact(source, identifier, phoneNumber, display)
end)

RegisterServerEvent('gcphone:updateContact')
AddEventHandler('gcphone:updateContact', function(id, display, phoneNumber)
    local identifier = GetPlayerIdentifiers(source)[1]
    updateContact(source, identifier, id, phoneNumber, display)
end)

RegisterServerEvent('gcphone:deleteContact')
AddEventHandler('gcphone:deleteContact', function(id)
    local identifier = GetPlayerIdentifiers(source)[1]
    deleteContact(source, identifier, id)
end)

--====================================================================================
--  Messages
--====================================================================================
function getMessages(identifier)
    return MySQL.Sync.fetchAll("SELECT phone_messages.* FROM phone_messages LEFT JOIN users ON users.identifier = @identifier WHERE phone_messages.receiver = users.phone_number", {
        ['@identifier'] = identifier
    })
end

function _internalAddMessage(transmitter, receiver, message, owner)
	local Query = "INSERT INTO phone_messages (`transmitter`, `receiver`,`message`, `isRead`,`owner`) VALUES(@transmitter, @receiver, @message, @isRead, @owner);"
    local Query2 = 'SELECT * from phone_messages WHERE `id` = (SELECT LAST_INSERT_ID());'
	local Parameters = {
        ['@transmitter'] = transmitter,
        ['@receiver'] = receiver,
        ['@message'] = message,
        ['@isRead'] = owner,
        ['@owner'] = owner
    }
	return MySQL.Sync.fetchAll(Query .. Query2, Parameters)[1]
end

function addMessage(source, identifier, phone_number, message)
    local otherIdentifier = getIdentifierByPhoneNumber(phone_number)
    local myPhone = getNumberPhone(identifier)
    if otherIdentifier ~= nil then 
        local tomess = _internalAddMessage(myPhone, phone_number, message, 0)
        getSourceFromIdentifier(otherIdentifier, function (osou)
            if osou ~= nil then 
               TriggerClientEvent("gcphone:receiveMessage", osou, tomess)
            end
        end) 
    end
    local memess = _internalAddMessage(phone_number, myPhone, message, 1)
    TriggerClientEvent("gcphone:receiveMessage", source, memess)
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

RegisterServerEvent('gcphone:sendMessage')
AddEventHandler('gcphone:sendMessage', function(phoneNumber, message)
    local identifier = GetPlayerIdentifiers(source)[1]
    print(identifier)
    addMessage(source, identifier, phoneNumber, message)
end)

RegisterServerEvent('gcphone:deleteMessage')
AddEventHandler('gcphone:deleteMessage', function(msgId)
    deleteMessage(msgId)
end)

RegisterServerEvent('gcphone:deleteMessageNumber')
AddEventHandler('gcphone:deleteMessageNumber', function(number)
    local identifier = GetPlayerIdentifiers(source)[1]
    deleteAllMessageFromPhoneNumber(identifier, number)
    TriggerClientEvent("gcphone:allMessage", source, getMessages(identifier))
end)

RegisterServerEvent('gcphone:deleteAllMessage')
AddEventHandler('gcphone:deleteAllMessage', function()
    local identifier = GetPlayerIdentifiers(source)[1]
    deleteAllMessage(identifier)
    TriggerClientEvent("gcphone:allMessage", source, getMessages(identifier))
end)

RegisterServerEvent('gcphone:setReadMessageNumber')
AddEventHandler('gcphone:setReadMessageNumber', function(num)
    local identifier = GetPlayerIdentifiers(source)[1]
    setReadMessageNumber(identifier, num)
end)

RegisterServerEvent('gcphone:deleteALL')
AddEventHandler('gcphone:deleteALL', function()
    local source = source
    local identifier = GetPlayerIdentifiers(source)[1]
    deleteAllMessage(identifier)
    deleteAllContact(identifier)
    TriggerClientEvent("gcphone:contactList", source, {})
    TriggerClientEvent("gcphone:allMessage", source, {})
end)

RegisterServerEvent('gcPhone:internalSendMessage')
AddEventHandler('gcPhone:internalSendMessage', function(identifier, from, message)
    local phone = getNumberPhone(identifier)
    if phone ~= nil then 
        local mess = _internalAddMessage(from, phone, message, 0)
        getSourceFromIdentifier(identifier, function (osou)
            if osou ~= nil then 
                TriggerClientEvent("gcPhone:receiveMessage", osou, mess)
            end
        end) 
    end
end)
--====================================================================================
--  OnLoad
--====================================================================================
RegisterServerEvent('hardcap:playerActivated')
AddEventHandler('hardcap:playerActivated',function()
	local source = source
    local identifier = GetPlayerIdentifiers(source)[1]
    local myPhoneNumber = getNumberPhone(identifier)
    while myPhoneNumber == nil or myPhoneNumber == 0 do 
        local randomNumberPhone = getPhoneRandomNumber()
        MySQL.Sync.execute("UPDATE users SET phone_number = @randomNumberPhone WHERE identifier = @identifier", { 
            ['@randomNumberPhone'] = randomNumberPhone,
            ['@identifier'] = identifier
        })
        myPhoneNumber = getNumberPhone(identifier)
    end
    TriggerClientEvent("gcphone:myPhoneNumber", source, myPhoneNumber)
    TriggerClientEvent("gcphone:contactList", source, getContacts(identifier))
    TriggerClientEvent("gcphone:allMessage", source, getMessages(identifier))
end)


-- Just For reload
RegisterServerEvent('gcphone:allUpdate')
AddEventHandler('gcphone:allUpdate', function()
    local source = source
    local identifier = GetPlayerIdentifiers(source)[1]
    local mess = getMessages(identifier)
    TriggerClientEvent("gcphone:myPhoneNumber", source, getNumberPhone(identifier))
    TriggerClientEvent("gcphone:allMessage", source, getMessages(identifier))
    TriggerClientEvent("gcphone:contactList", source, getContacts(identifier))  
end)

print('')
print('')
print('                  /((((((\\\\\\\\')
print('          =======((((((((((\\\\\\\\\\')
print('               ((           \\\\\\\\\\\\\\')
print('               ( (*    _/      \\\\\\\\\\\\\\')
print('                 \\    /  \\      \\\\\\\\\\\\________________')
print('                  |  |   |       </                  ((\\\\\\\\')
print('                  o_|   /        /                      \\ \\\\\\\\    \\\\\\\\\\\\\\')
print('                       |  ._    (                        \\ \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\')
print('                       | /                       /       /    \\\\\\\\\\\\\\     \\\\')
print('               .______/\\/     /                 /       /         \\\\\\')
print('              / __.____/    _/         ________(       /\\')
print('             / / / ________/\\`---------\'         \\     /  \\_')
print('            / /  \\ \\                             \\   \\ \\_  \\')
print('           ( <    \\ \\                             >  /    \\ \\')
print('            \\/      \\\\_                          / /       > )')
print('                     \\_|                        / /       / /')
print('                                              _//       _//')
print('                                             /_|       /_|')
print('')
print('')

-- MySQLReady
-- end)