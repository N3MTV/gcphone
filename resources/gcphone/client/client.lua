--====================================================================================
-- #Author: Jonathan D @ Gannon
--====================================================================================
 
-- Configuration
local KeyToucheCloseEvent = {
  { code = 172, event = 'ArrowUp' },
  { code = 173, event = 'ArrowDown' },
  { code = 174, event = 'ArrowLeft' },
  { code = 175, event = 'ArrowRight' },
  { code = 176, event = 'Enter' },
  { code = 177, event = 'Backspace' },
}
local KeyOpenClose = 168
local menuIsOpen = false
local contacts = {}
local messages = {}
local myPhoneNumber = ''
local isDead = false
--====================================================================================
--  
--====================================================================================
 
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)
    if IsControlJustPressed(1, KeyOpenClose) then
      TooglePhone()
    end
    if menuIsOpen == true then
      for _, value in ipairs(KeyToucheCloseEvent) do
        if IsControlJustPressed(1, value.code) then
          SendNUIMessage({keyUp = value.event})
        end
      end
    end
  end
end)

 
--====================================================================================
--  Events
--====================================================================================
RegisterNetEvent("gcPhone:myPhoneNumber")
AddEventHandler("gcPhone:myPhoneNumber", function(_myPhoneNumber)
  myPhoneNumber = _myPhoneNumber
  SendNUIMessage({event = 'updateMyPhoneNumber', myPhoneNumber = myPhoneNumber})
end)

RegisterNetEvent("gcPhone:contactList")
AddEventHandler("gcPhone:contactList", function(_contacts)
  SendNUIMessage({event = 'updateContacts', contacts = _contacts})
  contacts = _contacts
end)

RegisterNetEvent("gcPhone:allMessage")
AddEventHandler("gcPhone:allMessage", function(allmessages)
  SendNUIMessage({event = 'updateMessages', messages = allmessages})
  messages = allmessages
end)

RegisterNetEvent("gcPhone:getBourse")
AddEventHandler("gcPhone:getBourse", function(bourse)
  SendNUIMessage({event = 'updateBourse', bourse = bourse})
end)

RegisterNetEvent("gcPhone:receiveMessage")
AddEventHandler("gcPhone:receiveMessage", function(message)
  -- SendNUIMessage({event = 'updateMessages', messages = messages})
  SendNUIMessage({event = 'newMessage', message = message})
  if message.owner == 0 then 
    SetNotificationTextEntry("STRING")
    AddTextComponentString('~o~Nouveau message')
    DrawNotification(false, false)
    PlaySound(-1, "Menu_Accept", "Phone_SoundSet_Default", 0, 0, 1)
    Citizen.Wait(300)
    PlaySound(-1, "Menu_Accept", "Phone_SoundSet_Default", 0, 0, 1)
    Citizen.Wait(300)
    PlaySound(-1, "Menu_Accept", "Phone_SoundSet_Default", 0, 0, 1)
  end
end)

RegisterNetEvent('banking:updateBalance')
AddEventHandler('banking:updateBalance', function(bank)
    SendNUIMessage({event = 'updateBankbalance', banking = bank})
end)
--====================================================================================
--  Function client | Contacts
--====================================================================================
function addContact(display, num) 
    TriggerServerEvent('gcPhone:addContact', display, num)
end

function deleteContact(num) 
    TriggerServerEvent('gcPhone:deleteContact', num)
end
--====================================================================================
--  Function client | Messages
--====================================================================================
function sendMessage(num, message)
  TriggerServerEvent('gcPhone:sendMessage', num, message)
end

function deleteMessage(msgId)
  TriggerServerEvent('gcPhone:deleteMessage', msgId)
  for k, v in ipairs(messages) do 
    if v.id == msgId then
      table.remove(messages, k)
      SendNUIMessage({event = 'updateMessages', messages = messages})
      return
    end
  end
end

function deleteMessageContact(num)
  TriggerServerEvent('gcPhone:deleteMessageNumber', num)
end

function deleteAllMessage()
  TriggerServerEvent('gcPhone:deleteAllMessage')
end

function setReadMessageNumber(num)
  TriggerServerEvent('gcPhone:setReadMessageNumber', num)
  for k, v in ipairs(messages) do 
    if v.transmitter == num then
      v.isRead = 1
    end
  end
end

function requestAllMessages()
  TriggerServerEvent('gcPhone:requestAllMessages')
end

function requestAllContact()
  TriggerServerEvent('gcPhone:requestAllContact')
end























--====================================================================================
--  Function client | Appels
--====================================================================================
local inCall = false
local aminCall = false

RegisterNetEvent("gcPhone:waitingCall")
AddEventHandler("gcPhone:waitingCall", function(infoCall)
  SendNUIMessage({event = 'waitingCall', infoCall = infoCall})
  if infoCall.transmitter_num == myPhoneNumber then
    aminCall = true
    ePhoneStartCall()
  end
end)

RegisterNetEvent("gcPhone:acceptCall")
AddEventHandler("gcPhone:acceptCall", function(infoCall)
  print('infoCall')
  print(json.encode(infoCall))
  if inCall == false then
    inCall = true
    NetworkSetVoiceChannel(infoCall.id + 1)
    NetworkSetTalkerProximity(0.0)
  end
  if aminCall == false then
    aminCall = true
    ePhoneStartCall()
  end
  SendNUIMessage({event = 'acceptCall', infoCall = infoCall})
end)

RegisterNetEvent("gcPhone:rejectCall")
AddEventHandler("gcPhone:rejectCall", function(infoCall)
  if inCall == true then
    inCall = false
    Citizen.InvokeNative(0xE036A705F989E049)
    NetworkSetTalkerProximity(2.5)
  end
  if aminCall == true then
    ePhoneStopCall()
  end
  SendNUIMessage({event = 'rejectCall', infoCall = infoCall})
end)


RegisterNetEvent("gcPhone:historiqueCall")
AddEventHandler("gcPhone:historiqueCall", function(historique)
  SendNUIMessage({event = 'historiqueCall', historique = historique})
end)

function startCall (phone_number)
  TriggerServerEvent('gcPhone:startCall', phone_number)
end

function acceptCall (infoCall)
  TriggerServerEvent('gcPhone:acceptCall', infoCall)
end

function rejectCall(infoCall)
  TriggerServerEvent('gcPhone:rejectCall', infoCall)
end

function ignoreCall(infoCall)
  TriggerServerEvent('gcPhone:ignoreCall', infoCall)
end

function requestHistoriqueCall() 
  TriggerServerEvent('gcPhone:getHistoriqueCall')
end

function appelsDeleteHistorique (num)
  TriggerServerEvent('gcPhone:appelsDeleteHistorique', num)
end

function appelsDeleteAllHistorique ()
  TriggerServerEvent('gcPhone:appelsDeleteAllHistorique')
end
  

--====================================================================================
--  Event - Appels
--====================================================================================

RegisterNUICallback('startCall', function (data, cb)
  startCall(data.numero)
  cb()
end)

RegisterNUICallback('acceptCall', function (data, cb)
  acceptCall(data.infoCall)
  cb()
end)

RegisterNUICallback('rejectCall', function (data, cb)
  rejectCall(data.infoCall)
  cb()
end)

RegisterNUICallback('ignoreCall', function (data, cb)
  ignoreCall(data.infoCall)
  cb()
end)

RegisterNUICallback('appelsDeleteHistorique', function (data, cb)
  appelsDeleteHistorique(data.numero)
  cb()
end)

RegisterNUICallback('appelsDeleteAllHistorique', function (data, cb)
  appelsDeleteAllHistorique(data.infoCall)
  cb()
end)






























































--====================================================================================
--  Gestion des evenements NUI
--==================================================================================== 
function tprint (t, s)
  for k, v in pairs(t) do
      local kfmt = '["' .. tostring(k) ..'"]'
      if type(k) ~= 'string' then
          kfmt = '[' .. k .. ']'
      end
      local vfmt = '"'.. tostring(v) ..'"'
      if type(v) == 'table' then
          tprint(v, (s or '')..kfmt)
      else
          if type(v) ~= 'string' then
              vfmt = tostring(v)
          end
          print(type(t)..(s or '')..kfmt..' = '..vfmt)
      end
  end
end
RegisterNUICallback('log', function(data, cb)
  -- print(data)
  -- tprint(data)
  cb()
end)
RegisterNUICallback('focus', function(data, cb)
  cb()
end)
RegisterNUICallback('blur', function(data, cb)
  cb()
end)
RegisterNUICallback('reponseText', function(data, cb)
  local limit = data.limit or 255
  local text = data.text or ''
  
  DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "", text, "", "", "", limit)
  while (UpdateOnscreenKeyboard() == 0) do
      DisableAllControlActions(0);
      Wait(0);
  end
  if (GetOnscreenKeyboardResult()) then
      text = GetOnscreenKeyboardResult()
  end
  cb(json.encode({text = text}))
end)
--====================================================================================
--  Event - Messages
--====================================================================================
RegisterNUICallback('getMessages', function(data, cb)
  cb(json.encode(messages))
end)
RegisterNUICallback('sendMessage', function(data, cb)
  if data.message == '%pos%' then
    local myPos = GetEntityCoords(GetPlayerPed(-1))
    data.message = 'GPS: ' .. myPos.x .. ', ' .. myPos.y
  end
  TriggerServerEvent('gcPhone:sendMessage', data.phoneNumber, data.message)
end)
RegisterNUICallback('deleteMessage', function(data, cb)
  deleteMessage(data.id)
  cb()
end)
RegisterNUICallback('deleteMessageNumber', function (data, cb)
  deleteMessageContact(data.number)
  cb()
end)
RegisterNUICallback('deleteAllMessage', function (data, cb)
  deleteAllMessage()
  cb()
end)
RegisterNUICallback('setReadMessageNumber', function (data, cb)
  setReadMessageNumber(data.number)
  cb()
end)
--====================================================================================
--  Event - Contacts
--====================================================================================
RegisterNUICallback('addContact', function(data, cb) 
  TriggerServerEvent('gcPhone:addContact', data.display, data.phoneNumber)
end)

RegisterNUICallback('updateContact', function(data, cb)
  TriggerServerEvent('gcPhone:updateContact', data.id, data.display, data.phoneNumber)
end)

RegisterNUICallback('deleteContact', function(data, cb)
  TriggerServerEvent('gcPhone:deleteContact', data.id)
end)

RegisterNUICallback('getContacts', function(data, cb)
  cb(json.encode(contacts))
end)

RegisterNUICallback('setGPS', function(data, cb)
  SetNewWaypoint(tonumber(data.x), tonumber(data.y))
  cb()
end)
RegisterNUICallback('callEvent', function(data, cb)
  if data.data ~= nil then 
    TriggerEvent(data.eventName, data.data)
  else
    TriggerEvent(data.eventName)
  end
  cb()
end)

RegisterNUICallback('deleteALL', function(data, cb)
  TriggerServerEvent('gcPhone:deleteALL')
  cb()
end)

function TooglePhone() 
  menuIsOpen = not menuIsOpen
  SendNUIMessage({show = menuIsOpen})
  if menuIsOpen == true then 
    ePhoneInAnim()
  else
    ePhoneOutAnim()
  end
end

RegisterNUICallback('takePhoto', function(data, cb)
  menuIsOpen = false
  SendNUIMessage({show = false})
  cb()
  TriggerEvent('camera:open')
end)

RegisterNUICallback('closePhone', function(data, cb)
  menuIsOpen = false
  SendNUIMessage({show = false})
  ePhoneOutAnim()
  cb()
end)

AddEventHandler('onClientResourceStart', function(res)
    --ClearPedTasksImmediately(GetPlayerPed(-1))
    DoScreenFadeIn(300)
    if res == "gcphone" then
        print('Reload Info')
        TriggerServerEvent('gcPhone:allUpdate')
    end
end)


----------------------------------
---------- GESTION APPEL ---------
----------------------------------

local confirmed = 0
local teldest = ""

RegisterNetEvent('callService')
AddEventHandler("callService", function(arg)
    DisplayOnscreenKeyboard(true, "FMMC_KEY_TIP8", "", "", "", "", "", 50)
	teldest = arg
	confirmed = 1
end)

Citizen.CreateThread(function()
	while true do
		Wait(0)
		if confirmed == 1 then
			if UpdateOnscreenKeyboard() == 3 then
				confirmed = 0
			elseif UpdateOnscreenKeyboard() == 1 then
				local txt = GetOnscreenKeyboardResult()
				if string.len(txt) > 0 then
					msg = txt
					confirmed = 2
				else
					TriggerEvent('hud:NotifColor',"Votre message est vide",6)
					confirmed = 0
				end
			elseif UpdateOnscreenKeyboard() == 2 then
				confirmed = 0
			end
		end
		if confirmed == 2 then
            if teldest == "police" then
                TriggerEvent("es_freeroam:notify", "CHAR_CALL911", 1, "911", false, "911 Prévenu!")
                local plyPos = GetEntityCoords(GetPlayerPed(-1), true)
                TriggerServerEvent("call:makeCall", "police", {x=plyPos.x,y=plyPos.y,z=plyPos.z},msg)
            elseif teldest == "mecano" then
                TriggerEvent("es_freeroam:notify", "CHAR_CARSITE2", 1, "Garagiste", false, "Garagiste prévenu!")
                local plyPos = GetEntityCoords(GetPlayerPed(-1), true)
                TriggerServerEvent("call:makeCall", "depanneur", {x=plyPos.x,y=plyPos.y,z=plyPos.z},msg)
            elseif teldest == "taxi" then
                TriggerEvent("es_freeroam:notify", "CHAR_TAXI", 1, "Taxi", false, "Taxi prévenu!")
                local plyPos = GetEntityCoords(GetPlayerPed(-1), true)
                TriggerServerEvent("call:makeCall", "taxi", {x=plyPos.x,y=plyPos.y,z=plyPos.z},msg)
            elseif teldest == "ambulance" then
                TriggerEvent("es_freeroam:notify", "CHAR_PLANESITE", 1, "Urgence", false, "Ambulancier prévenu!")
                local plyPos = GetEntityCoords(GetPlayerPed(-1), true)
                TriggerServerEvent("call:makeCall", "medic", {x=plyPos.x,y=plyPos.y,z=plyPos.z},msg)
            elseif teldest == "journaliste" then
                TriggerEvent("es_freeroam:notify", "CHAR_LIFEINVADER", 1, "LifeInvader", false, "Journaliste prévenu!")
                local plyPos = GetEntityCoords(GetPlayerPed(-1), true)
                TriggerServerEvent("call:makeCall", "journaliste", {x=plyPos.x,y=plyPos.y,z=plyPos.z},msg)
            else
                TriggerEvent('hud:NotifColor',"Erreur de destinataire",6)
            end
			confirmed = 0
		end
	end
end)

