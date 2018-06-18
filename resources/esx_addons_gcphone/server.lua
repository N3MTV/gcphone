
ESX                       = nil
local PhoneNumbers        = {}
local lastId              = 0

local SHOW_HUD_INFO = true
local SEND_SMS = true


-- PhoneNumbers = {
--   police = {
--     type  = "police",
--     sources = {
--       -- ['3'] = true
--     },
--     alerts = {}
--   }
-- }

TriggerEvent('esx:getSharedObject', function(obj)
  ESX = obj
end)

function getNewId()
  lastId = lastId + 1
  return lastId
end

function notifyAlert(number, alert) 
  if SHOW_HUD_INFO == false then
    return
  end
  if PhoneNumbers[number] ~= nil then
    for k,v in pairs(PhoneNumbers[number].sources) do
      TriggerClientEvent('esx_addons_gcphone:notifyAlert', tonumber(k), alert)
    end
  end
end

function notifyAlertSMS (number, alert)
  if SEND_SMS == false then
    return
  end
  if PhoneNumbers[number] ~= nil then
    for k,v in pairs(PhoneNumbers[number].sources) do
      getPhoneNumber(tonumber(k), function (n)
        TriggerEvent('gcPhone:_internalAddMessage', number, n, 'Alert (' .. alert.numero  .. '): ' .. alert.message, 0, function (smsMess)
          TriggerClientEvent("gcPhone:receiveMessage", tonumber(k), smsMess)
        end)
        if alert.coords ~= nil then
          TriggerEvent('gcPhone:_internalAddMessage', number, n, 'GPS: ' .. alert.coords.x .. ', ' .. alert.coords.y, 0, function (smsMess)
            TriggerClientEvent("gcPhone:receiveMessage", tonumber(k), smsMess)
          end)
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
    if PhoneNumbers[number].alerts[source] == nil then
      getPhoneNumber(source, function (phone) 
        local alert = {
          id = getNewId(),
          message = message,
          coords = coords,
          type = number,
          numero = phone,
          isAccept = 0,
          sources = {}
        }
        for k,v in pairs(PhoneNumbers[number].sources) do
          print('add ' .. k)
          alert.sources[k] = true
        end
        print('ADD alert to ' .. number)
        PhoneNumbers[number].alerts[source] = alert
        notifyAlert(number, alert)
        notifyAlertSMS(number, alert)
      end)
    else
      print('Double alert ? Maj à jour ?')
    end
  else
    print('Appels sur un service non enregistre => numero : ' .. number)
  end
end)




RegisterServerEvent('esx_addons_gcphone:acceptAlert')
AddEventHandler('esx_addons_gcphone:acceptAlert', function (type, alertId)
  print('esx_addons_gcphone:acceptAlert', type, alertId)
  local source = source
  if PhoneNumbers[type] ~= nil then
    print('esx_addons_gcphone:acceptAlert P1')
    for key, alert in pairs(PhoneNumbers[type].alerts) do
      print('alert check', alert.id)
      if alert.id == alertId then
        print('esx_addons_gcphone:acceptAlert P2')
        PhoneNumbers[type].alerts[key].isAccept = PhoneNumbers[type].alerts[key].isAccept + 1
        TriggerClientEvent('esx_addons_gcphone:showMessage', tonumber(key), 'Une unité de ' .. PhoneNumbers[type].type .. ' arrive')
        notifyAlert(type, PhoneNumbers[type].alerts[key])
        break
      end
    end
  end

end)

RegisterServerEvent('esx_addons_gcphone:refuseAlert')
AddEventHandler('esx_addons_gcphone:refuseAlert', function (type, alertId)
  local source = source
  if PhoneNumbers[type] ~= nil then
    for key, alert in pairs(PhoneNumbers[type].alerts) do
      if alert.id == alertId then
        print('esx_addons_gcphone:refuseAlert find')
        local allRefuse = true
        for k, src in pairs(PhoneNumbers[type].alerts[key].sources) do 
          print('source', src)
          if source == tonumber(k) then
            PhoneNumbers[type].alerts[key].sources[k] = false
          elseif src == true then
            allRefuse = false
          end
        end
        if allRefuse == true then
          if PhoneNumbers[type].alerts[key].isAccept == 0 then
            TriggerClientEvent('esx_addons_gcphone:showMessage', tonumber(key), 'Tout les unitee on ignoré l\'appels')
            for k, src in pairs(PhoneNumbers[type].alerts[key].sources) do 
              TriggerClientEvent('esx_addons_gcphone:showMessage', tonumber(k), 'Tout les unitee on ignoré l\'appels')
            end
          end
          PhoneNumbers[type].alerts[key] = nil
        end
        break
      end
    end
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
    TriggerEvent('esx_phone:removeSource', xPlayer.job.name, source)
  end

  for number, infoPhone in pairs(PhoneNumbers) do 
    print('-- num ' .. number)
    for ka, alerts in pairs(PhoneNumbers[number].alerts) do 
      if tonumber(ka) == source then
        print('remove alert user left the game')
        TriggerClientEvent('esx_addons_gcphone:removeAlert', -1, PhoneNumbers[number].alerts[ka].id)
        PhoneNumbers[number].alerts[ka] = nil
      else
        print('alert ka ' .. ka)
        PhoneNumbers[number].alerts[ka].sources[source] = nil
        local allCancel = true
        for k, src in pairs(PhoneNumbers[number].alerts[ka].sources) do 
          if src == true then
            allCancel = false
            break
          end
        end
        if allCancel == true then
          print('all cancel auto by disconnect', PhoneNumbers[number].alerts[ka].isAccept)
          if PhoneNumbers[number].alerts[ka].isAccept == 0 then
            TriggerClientEvent('esx_addons_gcphone:showMessage', tonumber(key), 'Tout les unitee on ignoré l\'appels')
            for k, src in pairs(PhoneNumbers[type].alerts[key].sources) do 
              TriggerClientEvent('esx_addons_gcphone:showMessage', tonumber(k), 'Tout les unitee on ignoré l\'appels')
            end
          end
          PhoneNumbers[number].alerts[ka] = nil
        end
      end
    end
  end
end)


function getPhoneNumber (source, callback) 
  print(ESX, source)
  local xPlayer = ESX.GetPlayerFromId(source)
  MySQL.Async.fetchAll('SELECT * FROM users WHERE identifier = @identifier',{
    ['@identifier'] = xPlayer.identifier
  }, function(result)
    callback(result[1].phone_number)
  end)
end