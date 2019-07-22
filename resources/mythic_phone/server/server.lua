--====================================================================================
-- #Author: Jonathan D @Gannon
-- #Version 2.0
--====================================================================================

math.randomseed(os.time()) 

--- Pour les numero du style XXX-XXXX
function getPhoneRandomNumber()
    local numBase0 = math.random(100,999)
    local numBase1 = math.random(0,9999)
    local num = string.format("%03d-%04d", numBase0, numBase1 )
	return num
end

--- Exemple pour les numero du style 06XXXXXXXX
-- function getPhoneRandomNumber()
--     return '0' .. math.random(600000000,699999999)
-- end

--====================================================================================
--  Utils
--====================================================================================
function getCharIDByPhoneNumber(phone_number) 
    local result = exports['ghmattimysql']:scalar("SELECT characters.id FROM characters WHERE characters.phone_number = @phone_number", {
        ['phone_number'] = phone_number
    })
    if result ~= nil then
        return result
    end
    return nil
end


function getPlayerID(source)
    local identifiers = GetPlayerIdentifiers(source)
    local player = getIdentifiant(identifiers)
    return player
end

function getIdentifiant(id)
    for _, v in ipairs(id) do
        return v
    end
end
--====================================================================================
--  Contacts
--====================================================================================
function getContacts(char)
    local cData = char.getCharData()
    local result = exports['ghmattimysql']:execute("SELECT * FROM phone_users_contacts WHERE phone_users_contacts.charid = @charid", {
        ['charid'] = cData.id
    })

    if result == nil then
        result = {}
    end

    return result
end

function addContact(char, number, display)
    local cData = char.getCharData()
    exports['ghmattimysql']:execute("INSERT INTO phone_users_contacts (`charid`, `number`,`display`) VALUES(@charid, @number, @display)", {
        ['charid'] = cData.id,
        ['number'] = number,
        ['display'] = display,
    },function()
        notifyContactChange(char)
    end)
end

function updateContact(char, id, number, display)
    exports['ghmattimysql']:execute("UPDATE phone_users_contacts SET number = @number, display = @display WHERE id = @id", { 
        ['number'] = number,
        ['display'] = display,
        ['id'] = id,
    },function()
        notifyContactChange(char)
    end)
end

function deleteContact(char, id)
    local cData = char.getCharData()
    exports['ghmattimysql']:execute("DELETE FROM phone_users_contacts WHERE `charid` = @charid AND `id` = @id", {
        ['charid'] = cData.id,
        ['id'] = id,
    })
    notifyContactChange(char)
end

function deleteAllContact(char)
    local cData = char.getCharData()
    exports['ghmattimysql']:execute("DELETE FROM phone_users_contacts WHERE `charid` = @charid", {
        ['charid'] = cData.id
    })
end

function notifyContactChange(char)
    local cData = char.getCharData()
    TriggerClientEvent("mythic_phone:client:contactList", cData.source, getContacts(char))
end

RegisterServerEvent('mythic_phone:server:addContact')
AddEventHandler('mythic_phone:server:addContact', function(display, phoneNumber)
    local char = exports['mythic_base']:getPlayerFromId(source).getChar()
    addContact(char, phoneNumber, display)
end)

RegisterServerEvent('mythic_phone:server:updateContact')
AddEventHandler('mythic_phone:server:updateContact', function(id, display, phoneNumber)
    local char = exports['mythic_base']:getPlayerFromId(source).getChar()
    updateContact(char, id, phoneNumber, display)
end)

RegisterServerEvent('mythic_phone:server:deleteContact')
AddEventHandler('mythic_phone:server:deleteContact', function(id)
    local char = exports['mythic_base']:getPlayerFromId(source).getChar()
    deleteContact(char, id)
end)

--====================================================================================
--  Messages
--====================================================================================
function getMessages(char)
    local cData = char.getCharData()
    local returned = false
    local messages = {}
    exports['ghmattimysql']:execute("SELECT * FROM phone_messages WHERE receiver = @number", {
         ['number'] = cData.phone
    }, function(msgs)
        if msgs ~= nil then
            messages = msgs
        end
        returned = true
    end)

    while not returned do
        Citizen.Wait(1)
    end

    return messages
    --return MySQLQueryTimeStamp("SELECT phone_messages.* FROM phone_messages LEFT JOIN characters ON characters.id = @charid WHERE phone_messages.receiver = characters.phone_number", {['charid'] = cData.id})
end

RegisterServerEvent('mythic_phone:server:_internalAddMessage')
AddEventHandler('mythic_phone:server:_internalAddMessage', function(transmitter, receiver, message, owner, cb)
    local msg = _internalAddMessage(transmitter, receiver, message, owner)
    cb(msg)
end)

function _internalAddMessage(transmitter, receiver, message, owner, cb)
    local msg = nil
    exports['ghmattimysql']:execute('INSERT INTO phone_messages (`transmitter`, `receiver`,`message`, `isRead`,`owner`) VALUES(@transmitter, @receiver, @message, @isRead, @owner)', {
        ['transmitter'] = transmitter,
        ['receiver'] = receiver,
        ['message'] = message,
        ['isRead'] = owner,
        ['owner'] = owner
    }, function(status)
        exports['ghmattimysql']:execute('SELECT * from phone_messages WHERE `id` = @id', {
            ['id'] = status.insertId
        }, function(stuff)
            msg = stuff[1]
        end)
    end)

    while msg == nil do
        Citizen.Wait(1)
    end

    return msg
end

function addMessage(char, phone_number, message)
    local cData = char.getCharData()
    local oCharId = getCharIDByPhoneNumber(phone_number)
    if oCharId ~= nil then 
        local tomess = _internalAddMessage(cData.phone, phone_number, message, 0)
        local oSrc = exports['mythic_base']:getPlayerFromCharId(oCharId)
        if tonumber(oSrc) ~= nil then 
            -- TriggerClientEvent("mythic_phone:client:allMessage", oSrc, getMessages(oCharId))
            TriggerClientEvent("mythic_phone:client:receiveMessage", tonumber(oSrc), tomess)
        end
    end
    local memess = _internalAddMessage(phone_number, cData.phone, message, 1)
    TriggerClientEvent("mythic_phone:client:receiveMessage", cData.source, memess)
end

function setReadMessageNumber(char, num)
    local cData = char.getCharData()
    exports['ghmattimysql']:execute("UPDATE phone_messages SET phone_messages.isRead = 1 WHERE phone_messages.receiver = @receiver AND phone_messages.transmitter = @transmitter", { 
        ['receiver'] = cData.phone,
        ['transmitter'] = num
    })
end

function deleteMessage(msgId)
    exports['ghmattimysql']:execute("DELETE FROM phone_messages WHERE `id` = @id", {
        ['id'] = msgId
    })
end

function deleteAllMessageFromPhoneNumber(char, phone_number)
    local cData = char.getCharData()
    exports['ghmattimysql']:execute("DELETE FROM phone_messages WHERE `receiver` = @mePhoneNumber and `transmitter` = @phone_number", {['mePhoneNumber'] = cData.phone, ['phone_number'] = phone_number})
end

function deleteAllMessage(char)
    local cData = char.getCharData()
    exports['ghmattimysql']:execute("DELETE FROM phone_messages WHERE `charid` = @charid", {
        ['charid'] = cData.id
    })
end

RegisterServerEvent('mythic_phone:server:sendMessage')
AddEventHandler('mythic_phone:server:sendMessage', function(phoneNumber, message)
    local char = exports['mythic_base']:getPlayerFromId(source).getChar()
    addMessage(char, phoneNumber, message)
end)

RegisterServerEvent('mythic_phone:server:deleteMessage')
AddEventHandler('mythic_phone:server:deleteMessage', function(msgId)
    deleteMessage(msgId)
end)

RegisterServerEvent('mythic_phone:server:deleteMessageNumber')
AddEventHandler('mythic_phone:server:deleteMessageNumber', function(number)
    local char = exports['mythic_base']:getPlayerFromId(source).getChar()
    deleteAllMessageFromPhoneNumber(char, number)
    -- TriggerClientEvent("mythic_phone:client:allMessage", source, getMessages(char))
end)

RegisterServerEvent('mythic_phone:server:deleteAllMessage')
AddEventHandler('mythic_phone:server:deleteAllMessage', function()
    local char = exports['mythic_base']:getPlayerFromId(source).getChar()
    deleteAllMessage(char)
end)

RegisterServerEvent('mythic_phone:server:setReadMessageNumber')
AddEventHandler('mythic_phone:server:setReadMessageNumber', function(num)
    local char = exports['mythic_base']:getPlayerFromId(source).getChar()
    setReadMessageNumber(char, num)
end)

RegisterServerEvent('mythic_phone:server:deleteALL')
AddEventHandler('mythic_phone:server:deleteALL', function()
    local char = exports['mythic_base']:getPlayerFromId(source).getChar()
    deleteAllMessage(char)
    deleteAllContact(char)
    appelsDeleteAllHistorique(char)
    TriggerClientEvent("mythic_phone:client:contactList", source, {})
    TriggerClientEvent("mythic_phone:client:allMessage", source, {})
    TriggerClientEvent("appelsDeleteAllHistorique", source, {})
end)

--====================================================================================
--  Gestion des appels
--====================================================================================
local CallsInProgress = {}
local PhoneFixeInfo = {}
local lastIndexCall = 10

function getHistoriqueCall (num)
    local result = exports['ghmattimysql']:execute("SELECT * FROM phone_calls WHERE owner = @num ORDER BY time DESC LIMIT 120", {
        ['num'] = num
    })
    return result
end

function sendHistoriqueCall (char)
    local cData = char.getCharData()
    local histo = getHistoriqueCall(cData.phone)
    TriggerClientEvent('mythic_phone:client:historiqueCall', cData.source, histo)
end

function saveCallRecord(appelInfo)     
    if appelInfo.extraData == nil or appelInfo.extraData.useNumber == nil then
        exports['ghmattimysql']:execute("INSERT INTO phone_calls (`owner`, `num`,`incoming`, `accepts`) VALUES(@owner, @num, @incoming, @accepts)", {
            ['owner'] = appelInfo.transmitter_num,
            ['num'] = appelInfo.receiver_num,
            ['incoming'] = 1,
            ['accepts'] = appelInfo.is_accepts
        }, function()
            local char = exports['mythic_base']:getPlayerFromId(appelInfo.transmitter_src).getChar()
            notifyNewAppelsHisto(char)
        end)
    end
    if appelInfo.is_valid == true then
        local num = appelInfo.transmitter_num
        if appelInfo.hidden == true then
            num = "Hidden #"
        end

        exports['ghmattimysql']:execute("INSERT INTO phone_calls (`owner`, `num`,`incoming`, `accepts`) VALUES(@owner, @num, @incoming, @accepts)", {
            ['owner'] = appelInfo.receiver_num,
            ['num'] = num,
            ['incoming'] = 0,
            ['accepts'] = appelInfo.is_accepts
        }, function()
            if appelInfo.receiver_src ~= nil then
                local char = exports['mythic_base']:getPlayerFromId(appelInfo.receiver_src).getChar()
                notifyNewAppelsHisto(char)
            end
        end)
    end
end

function notifyNewAppelsHisto (char) 
    sendHistoriqueCall(char)
end

RegisterServerEvent('mythic_phone:server:getHistoriqueCall')
AddEventHandler('mythic_phone:server:getHistoriqueCall', function()
    local char = exports['mythic_base']:getPlayerFromId(source).getChar()
    sendHistoriqueCall(char)
end)


RegisterServerEvent('mythic_phone:server:internal_startCall')
AddEventHandler('mythic_phone:server:internal_startCall', function(source, phone_number, rtcOffer, extraData)
    if FixePhone[phone_number] ~= nil then
        onCallFixePhone(source, phone_number, rtcOffer, extraData)
        return
    end
    
    local rtcOffer = rtcOffer
    if phone_number == nil or phone_number == '' then 
        print('BAD CALL NUMBER IS NIL')
        return
    end

    local hidden = string.sub(phone_number, 1, 1) == '#'
    if hidden == true then
        phone_number = string.sub(phone_number, 2)
    end

    local indexCall = lastIndexCall
    lastIndexCall = lastIndexCall + 1

    local char = exports['mythic_base']:getPlayerFromId(source).getChar()
    local cData = char.getCharData()
    local dSource = exports['mythic_base']:getPlayerFromCharId(getCharIDByPhoneNumber(phone_number))

    local is_valid = dSource ~= nil
    if dSource ~= nil then
        local dChar = exports['mythic_base']:getPlayerFromId(dSource).getChar()

        if dChar ~= nil then
            local dData = dChar.getCharData()

            local srcPhone = ''
            if extraData ~= nil and extraData.useNumber ~= nil then
                srcPhone = extraData.useNumber
            else
                srcPhone = cData.phone
            end

            CallsInProgress[indexCall] = {
                id = indexCall,
                transmitter_src = cData.source,
                transmitter_num = srcPhone,
                receiver_src = nil,
                receiver_num = phone_number,
                is_valid = dChar ~= nil,
                is_accepts = false,
                hidden = hidden,
                rtcOffer = rtcOffer,
                extraData = extraData
            }
        end
    end

    if is_valid == true then
        if dSource ~= nil then
            CallsInProgress[indexCall].receiver_src = dSource
            TriggerEvent('mythic_phone:server:addCall', CallsInProgress[indexCall])
            TriggerClientEvent('mythic_phone:client:waitingCall', cData.source, CallsInProgress[indexCall], true)
            TriggerClientEvent('mythic_phone:client:waitingCall', dSource, CallsInProgress[indexCall], false)
            return
        end
    end

    TriggerEvent('mythic_phone:server:addCall', CallsInProgress[indexCall])
    TriggerClientEvent('mythic_phone:client:waitingCall', cData.source, CallsInProgress[indexCall], true)
    TriggerClientEvent('mythic_phone:client:waitingCall', source, CallsInProgress[indexCall], false)
end)

RegisterServerEvent('mythic_phone:server:startCall')
AddEventHandler('mythic_phone:server:startCall', function(phone_number, rtcOffer, extraData)
    TriggerEvent('mythic_phone:server:internal_startCall',source, phone_number, rtcOffer, extraData)
end)

RegisterServerEvent('mythic_phone:server:candidates')
AddEventHandler('mythic_phone:server:candidates', function (callId, candidates)
    if CallsInProgress[callId] ~= nil then
        local source = source
        local to = CallsInProgress[callId].transmitter_src
        if source == to then 
            to = CallsInProgress[callId].receiver_src
        end
        TriggerClientEvent('mythic_phone:client:candidates', to, candidates)
    end
end)


RegisterServerEvent('mythic_phone:server:acceptCall')
AddEventHandler('mythic_phone:server:acceptCall', function(infoCall, rtcAnswer)
    local id = infoCall.id
    if CallsInProgress[id] ~= nil then
        if PhoneFixeInfo[id] ~= nil then
            onAcceptFixePhone(source, infoCall, rtcAnswer)
            return
        end
        CallsInProgress[id].receiver_src = infoCall.receiver_src or CallsInProgress[id].receiver_src
        if CallsInProgress[id].transmitter_src ~= nil and CallsInProgress[id].receiver_src~= nil then
            CallsInProgress[id].is_accepts = true
            CallsInProgress[id].rtcAnswer = rtcAnswer
            TriggerClientEvent('mythic_phone:client:acceptCall', CallsInProgress[id].transmitter_src, CallsInProgress[id], true)
            TriggerClientEvent('mythic_phone:client:acceptCall', CallsInProgress[id].receiver_src, CallsInProgress[id], false)
            saveCallRecord(CallsInProgress[id])
        end
    end
end)




RegisterServerEvent('mythic_phone:server:rejectCall')
AddEventHandler('mythic_phone:server:rejectCall', function (infoCall)
    local id = infoCall.id
    if CallsInProgress[id] ~= nil then
        if PhoneFixeInfo[id] ~= nil then
            onRejectFixePhone(source, infoCall)
            return
        end

        if CallsInProgress[id].transmitter_src ~= nil then
            TriggerClientEvent('mythic_phone:client:rejectCall', CallsInProgress[id].transmitter_src, CallsInProgress[id])
        end

        if CallsInProgress[id].receiver_src ~= nil then
            TriggerClientEvent('mythic_phone:client:rejectCall', CallsInProgress[id].receiver_src, CallsInProgress[id])
        end

        if CallsInProgress[id].is_accepts == false then 
            saveCallRecord(CallsInProgress[id])
        end

        TriggerEvent('mythic_phone:server:removeCall', CallsInProgress)
        CallsInProgress[id] = nil
    end
end)

RegisterServerEvent('mythic_phone:server:appelsDeleteHistorique')
AddEventHandler('mythic_phone:server:appelsDeleteHistorique', function (numero)
    local char = exports['mythic_base']:getPlayerFromId(source).getChar()
    local cData = char.getCharData()
    exports['ghmattimysql']:execute("DELETE FROM phone_calls WHERE `owner` = @owner AND `num` = @num", {
        ['owner'] = cData.phone,
        ['num'] = numero
    })
end)

function appelsDeleteAllHistorique(char)
    local cData = char.getCharData()
    exports['ghmattimysql']:execute("DELETE FROM phone_calls WHERE `owner` = @owner", {
        ['owner'] = cData.phone
    })
end

RegisterServerEvent('mythic_phone:server:appelsDeleteAllHistorique')
AddEventHandler('mythic_phone:server:appelsDeleteAllHistorique', function ()
    local char = exports['mythic_base']:getPlayerFromId(source).getChar()
    appelsDeleteAllHistorique(char)
end)

--====================================================================================
--  OnLoad
--====================================================================================
RegisterServerEvent('mythic_characters:server:CharacterSpawned')
AddEventHandler('mythic_characters:server:CharacterSpawned',function()
    local src = source
    local char = exports['mythic_base']:getPlayerFromId(src).getChar()
    local cData = char.getCharData()
    TriggerClientEvent("mythic_phone:client:myPhoneNumber", src, cData.phone)
    TriggerClientEvent("mythic_phone:client:contactList", src, getContacts(char))
    TriggerClientEvent("mythic_phone:client:allMessage", src, getMessages(char))
end)

-- Just For reload
RegisterServerEvent('mythic_phone:server:allUpdate')
AddEventHandler('mythic_phone:server:allUpdate', function()
    local src = source
    local char = exports['mythic_base']:getPlayerFromId(src).getChar()
    local cData = char.getCharData()
    TriggerClientEvent("mythic_phone:client:myPhoneNumber", src, cData.phone)
    TriggerClientEvent("mythic_phone:client:contactList", src, getContacts(char))
    TriggerClientEvent("mythic_phone:client:allMessage", src, getMessages(char))
    TriggerClientEvent('mythic_phone:client:getBourse', src, getBourse())
    sendHistoriqueCall(char)
end)

--====================================================================================
--  App bourse
--====================================================================================
function getBourse()
    --  Format
    --  Array 
    --    Object
    --      -- libelle type String    | Nom
    --      -- price type number      | Prix actuelle
    --      -- difference type number | Evolution 
    -- 
    -- local result = exports['ghmattimysql']:execute("SELECT * FROM `recolt` LEFT JOIN `items` ON items.`id` = recolt.`treated_id` WHERE fluctuation = 1 ORDER BY price DESC",{})
    local result = {
        {
            libelle = 'Google',
            price = 125.2,
            difference =  -12.1
        },
        {
            libelle = 'Microsoft',
            price = 132.2,
            difference = 3.1
        },
        {
            libelle = 'Amazon',
            price = 120,
            difference = 0
        }
    }
    return result
end

function onCallFixePhone (source, phone_number, rtcOffer, extraData)
    local indexCall = lastIndexCall
    lastIndexCall = lastIndexCall + 1

    local hidden = string.sub(phone_number, 1, 1) == '#'
    if hidden == true then
        phone_number = string.sub(phone_number, 2)
    end

    local char = exports['mythic_base']:getPlayerFromId(source).getChar()
    local cData = char.getCharData()

    local srcPhone = ''
    if extraData ~= nil and extraData.useNumber ~= nil then
        srcPhone = extraData.useNumber
    else
        srcPhone = cData.phone
    end

    CallsInProgress[indexCall] = {
        id = indexCall,
        transmitter_src = cData.source,
        transmitter_num = cData.phone,
        receiver_src = nil,
        receiver_num = phone_number,
        is_valid = false,
        is_accepts = false,
        hidden = hidden,
        rtcOffer = rtcOffer,
        extraData = extraData,
        coords = FixePhone[phone_number].coords
    }
    
    PhoneFixeInfo[indexCall] = CallsInProgress[indexCall]

    TriggerClientEvent('mythic_phone:client:notifyFixePhoneChange', -1, PhoneFixeInfo)
    TriggerClientEvent('mythic_phone:client:waitingCall', cData.source, CallsInProgress[indexCall], true)
end



function onAcceptFixePhone(source, infoCall, rtcAnswer)
    local id = infoCall.id
    
    CallsInProgress[id].receiver_src = source
    if CallsInProgress[id].transmitter_src ~= nil and CallsInProgress[id].receiver_src ~= nil then
        CallsInProgress[id].is_accepts = true
        CallsInProgress[id].forceSaveAfter = true
        CallsInProgress[id].rtcAnswer = rtcAnswer
        PhoneFixeInfo[id] = nil
        TriggerClientEvent('mythic_phone:client:notifyFixePhoneChange', -1, PhoneFixeInfo)
        TriggerClientEvent('mythic_phone:client:acceptCall', CallsInProgress[id].transmitter_src, CallsInProgress[id], true)
        TriggerClientEvent('mythic_phone:client:acceptCall', CallsInProgress[id].receiver_src, CallsInProgress[id], false)
        saveCallRecord(CallsInProgress[id])
    end
end

function onRejectFixePhone(source, infoCall, rtcAnswer)
    local id = infoCall.id
    PhoneFixeInfo[id] = nil
    TriggerClientEvent('mythic_phone:client:notifyFixePhoneChange', -1, PhoneFixeInfo)
    TriggerClientEvent('mythic_phone:client:rejectCall', CallsInProgress[id].transmitter_src, CallsInProgress[id])
    if CallsInProgress[id].is_accepts == false then
        saveCallRecord(CallsInProgress[id])
    end
    CallsInProgress[id] = nil
    
end