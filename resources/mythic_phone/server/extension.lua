local PhoneNumbers        = {}

function notifyAlertSMS (number, alert, listSrc)
  if PhoneNumbers[number] ~= nil then
    local mess = 'From ' .. alert.numero  .. ' : ' .. alert.message
    if alert.coords ~= nil then
      mess = mess .. ' ' .. alert.coords.x .. ', ' .. alert.coords.y 
    end
    for k, _ in pairs(listSrc) do
      getPhoneNumber(tonumber(k), function (n)
        if n ~= nil then
          TriggerEvent('mythic_phone:server:_internalAddMessage', number, n, mess, 0, function (smsMess)
            TriggerClientEvent("mythic_phone:client:receiveMessage", tonumber(k), smsMess)
          end)
        end
      end)
    end
  end
end

AddEventHandler('mythic_phone:server:RegisterServiceNumber', function(number, type, sharePos, hasDispatch, hideNumber, hidePosIfAnon)
  print("^7[^8MYTHIC_PHONE ^7: ^8Service Number Register^7] " .. number .. ' => ' .. type)
	local hideNumber    = hideNumber    or false
	local hidePosIfAnon = hidePosIfAnon or false

	PhoneNumbers[number] = {
		type          = type,
    sources       = {},
    alerts        = {}
	}
end)


AddEventHandler('mythic_jobs:server:UpdateJob', function(source, job, lastJob)
  if PhoneNumbers[lastJob.base] ~= nil then
    TriggerEvent('mythic_phone_component:server:removeSource', lastJob.base, source)
  end

  if PhoneNumbers[job.base] ~= nil then
    TriggerEvent('mythic_phone_component:server:addSource', job.base, source)
  end
end)

AddEventHandler('mythic_phone_component:server:addSource', function(number, source)
	PhoneNumbers[number].sources[tostring(source)] = true
end)

AddEventHandler('mythic_phone_component:server:removeSource', function(number, source)
	PhoneNumbers[number].sources[tostring(source)] = nil
end)

RegisterServerEvent('mythic_phone:server:sendMessage')
AddEventHandler('mythic_phone:server:sendMessage', function(number, message)
    local sourcePlayer = tonumber(source)
    if PhoneNumbers[number] ~= nil then
      getPhoneNumber(source, function (phone) 
        notifyAlertSMS(number, {
          message = message,
          numero = phone,
        }, PhoneNumbers[number].sources)
      end)
    end
end)

RegisterServerEvent('mythic_phone_component:server:startCall')
AddEventHandler('mythic_phone_component:server:startCall', function (number, message, coords)
  local source = source
  if PhoneNumbers[number] ~= nil then
    getPhoneNumber(source, function (phone) 
      notifyAlertSMS(number, {
        message = message,
        coords = coords,
        numero = phone,
      }, PhoneNumbers[number].sources)
    end)
  else
    print("^7[^8MYTHIC_PHONE ^7: ^8Service Number Register^7] Call Attempted To A Non-Service Number - " .. number)
  end
end)

RegisterServerEvent('mythic_characters:server:CharacterSpawned')
AddEventHandler('mythic_characters:server:CharacterSpawned', function()
  local char = exports['mythic_base']:getPlayerFromId(source).getChar()
  local cData = char.getCharData()
  if PhoneNumbers[cData.job.base] ~= nil then
    TriggerEvent('mythic_phone_component:server:addSource', cData.job.base, source)
  end
end)


AddEventHandler('mythic_base:server:PlayerDropped', function(source)
  local char = exports['mythic_base']:getPlayerFromId(source).getChar()
  local cData = char.getCharData()
  if PhoneNumbers[cData.job.base] ~= nil then
    TriggerEvent('mythic_phone_component:server:removeSource', cData.job.base, source)
  end
end)


function getPhoneNumber (source, callback) 
  local char = exports['mythic_base']:getPlayerFromId(source).getChar()
  local cData = char.getCharData()

  callback(cData.phone)
end



RegisterServerEvent('esx_phone:send')
AddEventHandler('esx_phone:send', function(number, message, _, coords)
  local source = source
  if PhoneNumbers[number] ~= nil then
    getPhoneNumber(source, function (phone) 
      notifyAlertSMS(number, {
        message = message,
        coords = coords,
        numero = phone,
      }, PhoneNumbers[number].sources)
    end)
  else
    -- print('esx_phone:send | Appels sur un service non enregistre => numero : ' .. number)
  end
end)