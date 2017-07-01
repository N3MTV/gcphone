--====================================================================================
-- #Author: Jonathan D @Gannon
--====================================================================================
require "resources/mysql-async/lib/MySQL"
require 'resources/gcphone/mysqltimestamp'
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
            if user.identifier == identifier then
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
        TriggerClientEvent("gcPhone:contactList", source, getContacts(identifier))
    end
end

RegisterServerEvent('gcPhone:addContact')
AddEventHandler('gcPhone:addContact', function(display, phoneNumber)
    local identifier = GetPlayerIdentifiers(source)[1]
    addContact(source, identifier, phoneNumber, display)
end)

RegisterServerEvent('gcPhone:updateContact')
AddEventHandler('gcPhone:updateContact', function(id, display, phoneNumber)
    local identifier = GetPlayerIdentifiers(source)[1]
    updateContact(source, identifier, id, phoneNumber, display)
end)

RegisterServerEvent('gcPhone:deleteContact')
AddEventHandler('gcPhone:deleteContact', function(id)
    local identifier = GetPlayerIdentifiers(source)[1]
    deleteContact(source, identifier, id)
end)

--====================================================================================
--  Messages
--====================================================================================
function getMessages(identifier)
    -- local result = MySQL.Sync.fetchAll("SELECT phone_messages.* FROM phone_messages LEFT JOIN users ON users.identifier = @identifier WHERE phone_messages.receiver = users.phone_number", {
    --     ['@identifier'] = identifier
    -- })
    -- -- A CHANGER !!!!!!!
    -- for k, v in ipairs(result) do  
    --     v.time = os.time(v.time) + math.floor(0) - 2*60*60
    -- end
    -- return result
    return MySQLQueryTimeStamp("SELECT phone_messages.* FROM phone_messages LEFT JOIN users ON users.identifier = @identifier WHERE phone_messages.receiver = users.phone_number", {
        ['@identifier'] = identifier
    })
end

function _internalAddMessage(transmitter, receiver, message, owner)
    -- print('ADD MESSAGE: ' .. transmitter .. receiver .. message .. owner)
    -- MySQL.Sync.execute("INSERT INTO phone_messages (`transmitter`, `receiver`,`message`, `isRead`,`owner`) VALUES(@transmitter, @receiver, @message, @isRead, @owner)", {
    --     ['@transmitter'] = transmitter,
    --     ['@receiver'] = receiver,
    --     ['@message'] = message,
    --     ['@isRead'] = owner,
    --     ['@owner'] = owner
    -- })
    Parameters = {
        ['@transmitter'] = transmitter,
        ['@receiver'] = receiver,
        ['@message'] = message,
        ['@isRead'] = owner,
        ['@owner'] = owner
    }
    local Query = "INSERT INTO phone_messages (`transmitter`, `receiver`,`message`, `isRead`,`owner`) VALUES(@transmitter, @receiver, @message, @isRead, @owner)"
    local Query2 = 'SELECT * from phone_messages WHERE `id` = (SELECT LAST_INSERT_ID())'
    local Connection = MySQL:createConnection()
    local Command = Connection.CreateCommand()
    Command.CommandText = Query
    if type(Parameters) == "table" then
        for Param in pairs(Parameters) do
            Command.Parameters.AddWithValue(Param, Parameters[Param])
        end
    end
    pcall(Command.ExecuteNonQuery)

    --phase2
    Command = Connection.CreateCommand()
    Command.CommandText = Query2
    local status, result = pcall(Command.ExecuteReader)
    return MySQL.Async.wrapQuery(
        function (Result)
            return Result
        end,
        Connection,
        Command.CommandText
    )(MyConvertResultToTable(result), nil)[1]
end

function addMessage(source, identifier, phone_number, message)
    local otherIdentifier = getIdentifierByPhoneNumber(phone_number)
    local myPhone = getNumberPhone(identifier)
    if otherIdentifier ~= nil then 
        local tomess = _internalAddMessage(myPhone, phone_number, message, 0)
        getSourceFromIdentifier(otherIdentifier, function (osou)
            if osou ~= nil then 
                -- TriggerClientEvent("gcPhone:allMessage", osou, getMessages(otherIdentifier))
                TriggerClientEvent("gcPhone:receiveMessage", osou, tomess)
            end
        end) 
    end
    local memess = _internalAddMessage(phone_number, myPhone, message, 1)
    -- TriggerClientEvent("gcPhone:allMessage", source, getMessages(identifier))
    TriggerClientEvent("gcPhone:receiveMessage", source, memess)

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
    local identifier = GetPlayerIdentifiers(source)[1]
    print(identifier)
    addMessage(source, identifier, phoneNumber, message)
end)

RegisterServerEvent('gcPhone:deleteMessage')
AddEventHandler('gcPhone:deleteMessage', function(msgId)
    deleteMessage(msgId)
end)

RegisterServerEvent('gcPhone:deleteMessageNumber')
AddEventHandler('gcPhone:deleteMessageNumber', function(number)
    local identifier = GetPlayerIdentifiers(source)[1]
    deleteAllMessageFromPhoneNumber(identifier, number)
    TriggerClientEvent("gcPhone:allMessage", source, getMessages(identifier))
end)

RegisterServerEvent('gcPhone:deleteAllMessage')
AddEventHandler('gcPhone:deleteAllMessage', function()
    local identifier = GetPlayerIdentifiers(source)[1]
    deleteAllMessage(identifier)
    TriggerClientEvent("gcPhone:allMessage", source, getMessages(identifier))
end)

RegisterServerEvent('gcPhone:setReadMessageNumber')
AddEventHandler('gcPhone:setReadMessageNumber', function(num)
    local identifier = GetPlayerIdentifiers(source)[1]
    setReadMessageNumber(identifier, num)
end)

RegisterServerEvent('gcPhone:deleteALL')
AddEventHandler('gcPhone:deleteALL', function()
    local identifier = GetPlayerIdentifiers(source)[1]
    deleteAllMessage(identifier)
    deleteAllContact(identifier)
    TriggerClientEvent("gcPhone:contactList", source, {})
    TriggerClientEvent("gcPhone:allMessage", source, {})
end)
--====================================================================================
--  OnLoad
--====================================================================================
AddEventHandler('es:playerLoaded',function(source)
    local identifier = GetPlayerIdentifiers(source)[1]
    local myPhoneNumber = getNumberPhone(identifier)
    while myPhoneNumber == nil or myPhoneNumber == 0 do 
        local randomNumberPhone = getPhoneRandomNumber()
        print('TryPhone: ' .. randomNumberPhone)
        MySQL.Sync.execute("UPDATE users SET phone_number = @randomNumberPhone WHERE identifier = @identifier", { 
            ['@randomNumberPhone'] = randomNumberPhone,
            ['@identifier'] = identifier
        })
        myPhoneNumber = getNumberPhone(identifier)
    end
    TriggerClientEvent("gcPhone:myPhoneNumber", source, myPhoneNumber)
    TriggerClientEvent("gcPhone:contactList", source, getContacts(identifier))
    TriggerClientEvent("gcPhone:allMessage", source, getMessages(identifier))
end)

-- Just For reload
RegisterServerEvent('gcPhone:allUpdate')
AddEventHandler('gcPhone:allUpdate', function()
    local identifier = GetPlayerIdentifiers(source)[1]
    TriggerClientEvent("gcPhone:myPhoneNumber", source, getNumberPhone(identifier))
    TriggerClientEvent("gcPhone:contactList", source, getContacts(identifier))
    TriggerClientEvent("gcPhone:allMessage", source, getMessages(identifier))
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
print('             / / / ________/\`---------\'         \\     /  \\_')
print('            / /  \\ \\                             \\   \\ \\_  \\')
print('           ( <    \\ \\                             >  /    \\ \\')
print('            \\/      \\\\_                          / /       > )')
print('                     \\_|                        / /       / /')
print('                                              _//       _//')
print('                                             /_|       /_|')
print('')
print('')

-- local Transaction = MySQL.Sync.beginTransaction()
-- MySQL.Sync.execute("INSERT INTO phone_messages (`transmitter`, `receiver`,`message`, `isRead`,`owner`) VALUES(@transmitter, @receiver, @message, @isRead, @owner)", {
--     ['@transmitter'] = 'Inconnu',
--     ['@receiver'] = '06',
--     ['@message'] = 'Je sais qui tu est',
--     ['@isRead'] = 0,
--     ['@owner'] = 0
-- }, Transaction)

-- MySQL.Sync.fetchScalar('SELECT LAST_INSERT_ID()', nil, Transaction)
-- local result = MySQL.Sync.commitTransaction(Transaction)
-- print('result: ' .. json.encode(result))



-- function wrapQueryNoClose(next, Connection, Message, Transformer)
--     Transformer = Transformer or function (Result) return Result end
--     local Stopwatch = clr.System.Diagnostics.Stopwatch()
--     Stopwatch.Start()

--     return function (Result, Error)
--         if Error ~= nil then
--             Logger:Error(Error.ToString())

--             -- if Connection then
--             --     Connection.Close()
--             --     Connection.Dispose()
--             -- end

--             return nil
--         end

--         local ConnectionId = -1;

--         Result = Transformer(Result)

--         -- if Connection then
--         --     ConnectionId = Connection.ServerThread
--         --     Connection.Close()
--         --     Connection.Dispose()
--         -- end

--         Stopwatch.Stop()
        
--         next(Result)

--         return Result
--     end
-- end

-- function MySQLInsertMessage(Parameters) 
--     local Query = "INSERT INTO phone_messages (`transmitter`, `receiver`,`message`, `isRead`,`owner`) VALUES(@transmitter, @receiver, @message, @isRead, @owner)"
--     local Query2 = 'SELECT * from phone_messages WHERE `id` = (SELECT LAST_INSERT_ID())'
--     local Connection = MySQL:createConnection()
--     local Command = Connection.CreateCommand()
--     Command.CommandText = Query
--     if type(Parameters) == "table" then
--         for Param in pairs(Parameters) do
--             Command.Parameters.AddWithValue(Param, Parameters[Param])
--         end
--     end
--     pcall(Command.ExecuteNonQuery)

--     --phase2
--     Command = Connection.CreateCommand()
--     Command.CommandText = Query2
--     local status, result = pcall(Command.ExecuteReader)
--     return MySQL.Async.wrapQuery(
--         function (Result)
--             return Result
--         end,
--         Connection,
--         Command.CommandText
--     )(MyConvertResultToTable(result), nil)
-- end


-- local result = MySQLInsertMessage({
--         ['@transmitter'] = 'Inconnu',
--         ['@receiver'] = '06',
--         ['@message'] = 'Je sais qui tu est',
--         ['@isRead'] = 0,
--         ['@owner'] = 0
--     })
-- print('result: ' .. json.encode(result))
-- local mess = MySQL.Sync.fetchAll('SELECT * from phone_messages WHERE `id` = (SELECT LAST_INSERT_ID())', {})
-- print('result: ' .. json.encode(mess))
-- for _, v in pairs(data) do 
--     for key, vv in pairs(v) do 
--         print(key .. ' -> ' .. vv)
--     end
--     print('----')
-- end

-- local query = "INSERT INTO phone_messages (`transmitter`, `receiver`,`message`, `isRead`,`owner`) VALUES(@transmitter, @receiver, @message, @isRead, @owner)"
-- local params = {
--         ['@transmitter'] = '00',
--         ['@receiver'] = '00',
--         ['@message'] = '00',
--         ['@isRead'] = 1,
--         ['@owner'] = 1
--     }
-- local insert = MySQL.Sync.execute(, )
-- print('TTTTTTTTTTTTTTTT')
-- print(insert)



-- local Command = MySQL.Utils.CreateCommand(query, params)
-- --return MySQL.Sync.wrapQuery(Command.ExecuteReader, connection, Command.CommandText, MySQL.Utils.ConvertResultToTable)
-- local asyncWrapper = MySQL.Async.wrapQuery(
--     function (Result)
--         return Result
--     end,
--     Command.Connection,
--     Command.CommandText
-- )
-- local status, result = pcall(Command.ExecuteReader)
-- local r = asyncWrapper(ConvertObjectTimeStamp(result), nil)
-- local identifier = 'steam:1100001013c8633'
-- local data = nil
-- data = MySQLQueryTimeStamp("SELECT phone_messages.* FROM phone_messages LEFT JOIN users ON users.identifier = @identifier WHERE phone_messages.receiver = users.phone_number", {
--         ['@identifier'] = identifier
--     })
-- print('DATA')

-- for _, v in pairs(data) do 
--     for key, vv in pairs(v) do 
--         print(key .. ' -> ' .. vv)
--     end
--     print('----')
-- end

-- data = MySQL.Sync.fetchAll("SELECT phone_messages.* FROM phone_messages LEFT JOIN users ON users.identifier = @identifier WHERE phone_messages.receiver = users.phone_number", {
--         ['@identifier'] = identifier
--     })
-- print('DATA')
-- for _, v in pairs(data) do 
--     for key, vv in pairs(v) do 
--         print(key .. ' -> ' .. vv)
--     end
--     print('----')
-- end
-- Debug
----[[
-- local identifier = 'steam:1100001013c8633'
-- local myPhoneNumber = '0693854121'
-- local otherPhoneNumber = '0645122261'
-- local fakePhoneNumber = '0633308300'


-- print('Check Number')
-- print('myPhoneNumber Exist ? : ' .. getIdentifierByPhoneNumber(myPhoneNumber))
-- print('otherPhoneNumber Exist ? : ' .. getIdentifierByPhoneNumber(otherPhoneNumber))
-- print('fakePhoneNumber Exist ? : ' .. getIdentifierByPhoneNumber(fakePhoneNumber))
-- print('')

-- print('Phone number: ' .. getNumberPhone(identifier))

-- print('')
-- print('Contacts')
-- local listContacts = getContacts(identifier)
-- for _, v in ipairs(listContacts) do 
--     print(v.display .. ' => ' .. v.number)
-- end

-- print('')
-- print('Messages')
-- local mesasges = getMessages(identifier)
-- print(#mesasges)
-- for _, v in pairs(mesasges) do 
--     for key, vv in pairs(v) do 
--         print(key .. ' -> ' .. vv)
--     end
--     print('----')
-- end

-- addMessage(identifier, otherPhoneNumber, 'Test002')
-- addMessage(identifier, fakePhoneNumber, 'Test002')

-- deleteAllMessageFromPhoneNumber(identifier, otherIdentifier)
-- deleteAllMessage(identifier)
--]] -- END DEBUG & Teste

