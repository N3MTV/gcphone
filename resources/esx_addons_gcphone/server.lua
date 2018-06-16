ESX                       = nil
local DisptachRequestId   = 0
local PhoneNumbers        = {}
local inService           = {}

-- PhoneNumbers = {
--   police = {
--     sources = { 2 }
--   }
-- }

RegisterServerEvent('gcPhone:addCall')
AddEventHandler('gcPhone:addCall', function (AppelsInfo)
  local phoneNumber = AppelsInfo.receiver_num
  if PhoneNumbers[phoneNumber] ~= nil then
    for k,v in pairs(PhoneNumbers[phoneNumber].sources) do
      TriggerClientEvent('esx_addons_gcphone:alert', tonumber(k), AppelsInfo)
    end
  end
end)

TriggerEvent('esx:getSharedObject', function(obj)
  ESX = obj
end)

function GetDistpatchRequestId()

  local requestId = DisptachRequestId

  if DisptachRequestId < 65535 then
    DisptachRequestId = DisptachRequestId + 1
  else
    DisptachRequestId = 0
  end

  return requestId

end

AddEventHandler('esx_phone:getDistpatchRequestId', function(cb)
  cb(GetDistpatchRequestId())
end)



RegisterServerEvent('esx_phone:stopDispatch')
AddEventHandler('esx_phone:stopDispatch', function(infoCallId)
  TriggerClientEvent('esx_phone:stopDispatch', -1, infoCallId)
end)



AddEventHandler('esx:setJob', function(source, job, lastJob)
  if PhoneNumbers[lastJob.name] ~= nil then
    TriggerEvent('esx_phone:removeSource', lastJob.name, source)
  end

  if PhoneNumbers[job.name] ~= nil then
    TriggerEvent('esx_phone:addSource', job.name, source)
  end
end)

AddEventHandler('esx_phone:addSource', function(number, source)
	PhoneNumbers[number].sources[tostring(source)] = true
end)

AddEventHandler('esx_phone:removeSource', function(number, source)
	PhoneNumbers[number].sources[tostring(source)] = nil
end)


AddEventHandler('esx_phone:registerNumber', function(number, type, sharePos, hasDispatch, hideNumber, hidePosIfAnon)
  print('==== Enregistrement du telephone ' .. number)
	local hideNumber    = hideNumber    or false
	local hidePosIfAnon = hidePosIfAnon or false

	PhoneNumbers[number] = {
		type          = type,
		sharePos      = sharePos,
		hasDispatch   = (hasDispatch or false),
		hideNumber    = hideNumber,
		hidePosIfAnon = hidePosIfAnon,
		sources       = {}
	}
end)

RegisterServerEvent('esx_addons_gcphone:startCall')
AddEventHandler('esx_addons_gcphone:startCall', function (number, rtcOffert, message, coords)
  local number = number
  local rtcOffert = rtcOffert
  local extraData = {
    message = message,
    coords = coords
  }
  TriggerEvent('gcPhone:internal_startCall', source, number, rtcOffert, extraData)
end)


RegisterServerEvent('esx_phone:acceptCall')
AddEventHandler('esx_phone:acceptCall', function (infoCall, answser)
    local source = source
    infoCall.receiver_src = source
    TriggerEvent('gcPhone:acceptCall', infoCall, answser)
end)

RegisterServerEvent('gcPhone:rejectCall')
AddEventHandler('gcPhone:rejectCall', function (infoCall)
  TriggerClientEvent('esx_phone:stopDispatch', -1, infoCall.id)
end)



AddEventHandler('esx:playerLoaded', function(source)

  local xPlayer = ESX.GetPlayerFromId(source)

  MySQL.Async.fetchAll('SELECT * FROM users WHERE identifier = @identifier',{
    ['@identifier'] = xPlayer.identifier
  }, function(result)

    local phoneNumber = result[1].phone_number
    xPlayer.set('phoneNumber', phoneNumber)

    if PhoneNumbers[xPlayer.job.name] ~= nil then
      TriggerEvent('esx_phone:addSource', xPlayer.job.name, source)
    end
  end)

end)