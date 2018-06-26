
ESX                       = nil
local PhoneNumbers        = {}

-- PhoneNumbers = {
--   police = {
--     type  = "police",
--     sources = {
--        ['3'] = true
--     }
--   }
-- }

TriggerEvent('esx:getSharedObject', function(obj)
  ESX = obj
end)


function notifyAlertSMS (number, alert, listSrc)
  if PhoneNumbers[number] ~= nil then
    for k, _ in pairs(listSrc) do
      getPhoneNumber(tonumber(k), function (n)
        if n ~= nil then
          TriggerEvent('gcPhone:_internalAddMessage', number, n, 'De #' .. alert.numero  .. ' : ' .. alert.message, 0, function (smsMess)
            TriggerClientEvent("gcPhone:receiveMessage", tonumber(k), smsMess)
          end)
          if alert.coords ~= nil then
            TriggerEvent('gcPhone:_internalAddMessage', number, n, 'GPS: ' .. alert.coords.x .. ', ' .. alert.coords.y, 0, function (smsMess)
              TriggerClientEvent("gcPhone:receiveMessage", tonumber(k), smsMess)
            end)
          end
        end
      end)
    end
  end
end



AddEventHandler('esx_phone:registerNumber', function(number, type, sharePos, hasDispatch, hideNumber, hidePosIfAnon)
  print('==== Enregistrement du telephone ' .. number .. ' => ' .. type)
	local hideNumber    = hideNumber    or false
	local hidePosIfAnon = hidePosIfAnon or false

	PhoneNumbers[number] = {
		type          = type,
    sources       = {},
    alerts        = {}
	}
end)


AddEventHandler('esx:setJob', function(source, job, lastJob)
  if PhoneNumbers[lastJob.name] ~= nil then
    TriggerEvent('esx_addons_gcphone:removeSource', lastJob.name, source)
  end

  if PhoneNumbers[job.name] ~= nil then
    TriggerEvent('esx_addons_gcphone:addSource', job.name, source)
  end
end)

AddEventHandler('esx_addons_gcphone:addSource', function(number, source)
	PhoneNumbers[number].sources[tostring(source)] = true
end)

AddEventHandler('esx_addons_gcphone:removeSource', function(number, source)
	PhoneNumbers[number].sources[tostring(source)] = nil
end)


RegisterServerEvent('esx_addons_gcphone:startCall')
AddEventHandler('esx_addons_gcphone:startCall', function (number, message, coords)
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
    print('Appels sur un service non enregistre => numero : ' .. number)
  end
end)


AddEventHandler('esx:playerLoaded', function(source)

  local xPlayer = ESX.GetPlayerFromId(source)

  MySQL.Async.fetchAll('SELECT * FROM users WHERE identifier = @identifier',{
    ['@identifier'] = xPlayer.identifier
  }, function(result)

    local phoneNumber = result[1].phone_number
    xPlayer.set('phoneNumber', phoneNumber)

    if PhoneNumbers[xPlayer.job.name] ~= nil then
      TriggerEvent('esx_addons_gcphone:addSource', xPlayer.job.name, source)
    end
  end)

end)


AddEventHandler('esx:playerDropped', function(source)
  local source = source
  local xPlayer = ESX.GetPlayerFromId(source)
  if PhoneNumbers[xPlayer.job.name] ~= nil then
    TriggerEvent('esx_addons_gcphone:removeSource', xPlayer.job.name, source)
  end
end)


function getPhoneNumber (source, callback) 
  print('get phone to ' .. source)
  local xPlayer = ESX.GetPlayerFromId(source)
  if xPlayer == nil then
    print('esx_addons_gcphone. source null ???')
    callback(nil)
  end
  MySQL.Async.fetchAll('SELECT * FROM users WHERE identifier = @identifier',{
    ['@identifier'] = xPlayer.identifier
  }, function(result)
    callback(result[1].phone_number)
  end)
end

RegisterNetEvent("esx_ambulancejob:setDeathStatus")
AddEventHandler("esx_ambulancejob:setDeathStatus", function(dead)
  TriggerClientEvent("gcphone:isDead", source, dead)
end)