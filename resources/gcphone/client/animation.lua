-- @author https://github.com/EmmanuelVlad/ephone

local inAnim = "cellphone_text_in"
local outAnim = "cellphone_text_out"
local textToCall = "cellphone_text_to_call"
local CallToText = "cellphone_call_to_text"

local phoneProp = 0
local phoneModel = "prop_amb_phone"
local lastAnim = nil
--------------------------------------------------------------------------------
--
--								FUNCTIONS
--
--------------------------------------------------------------------------------


function ePhoneInAnim()
	print('ePhoneInAnim')
	if IsPlayerDead(PlayerId()) then
		return
	end
	local bone = GetPedBoneIndex(GetPlayerPed(-1), 28422)
	local dict = "cellphone@"
	if IsPedInAnyVehicle(GetPlayerPed(-1), false) then
		dict = dict .. "in_car@ds"
	end

	loadAnimDict(dict)

	TaskPlayAnim(GetPlayerPed(-1), dict, inAnim, 4.0, -1, -1, 50, 0, false, false, false)
	lastAnim = inAnim
	Citizen.Wait(157)
	phoneProp = newPhoneProp()
	AttachEntityToEntity(phoneProp, GetPlayerPed(-1), bone, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1, 1, 0, 0, 2, 1)
end


function ePhoneStartCall () 
	print('ePhoneStartCall before', lastAnim)
	if lastAnim ~= inAnim and lastAnim ~= CallToText then
		return
	end
	print('ePhoneStartCall')
	local dict = "cellphone@"
	if IsPedInAnyVehicle(GetPlayerPed(-1), false) then
		dict = dict .. "in_car@ds"
	end
	loadAnimDict(dict)
	StopAnimTask(GetPlayerPed(-1), dict, lastAnim, 1.0)
	TaskPlayAnim(GetPlayerPed(-1), dict, textToCall, 3.0, -1, -1, 50, 0, false, false, false)
	lastAnim = textToCall
end


function ePhoneStopCall () 
	if lastAnim ~= textToCall then
		return
	end
	print('ePhoneStopCall')
	local dict = "cellphone@"
	if IsPedInAnyVehicle(GetPlayerPed(-1), false) then
		dict = dict .. "in_car@ds"
	end
	loadAnimDict(dict)
	StopAnimTask(GetPlayerPed(-1), dict, lastAnim, 1.0)
	TaskPlayAnim(GetPlayerPed(-1), dict, CallToText, 3.0, -1, -1, 50, 0, false, false, false)
	lastAnim = CallToText
end


function ePhoneOutAnim()
	print('ePhoneOutAnim')
	if IsPlayerDead(PlayerId()) then
		return
	end
	local dict = "cellphone@"
	if IsPedInAnyVehicle(GetPlayerPed(-1), false) then
		dict = dict .. "in_car@ds"
	end

	loadAnimDict(dict)

	StopAnimTask(GetPlayerPed(-1), dict, lastAnim, 1.0)
	TaskPlayAnim(GetPlayerPed(-1), dict, outAnim, 5.0, 1, -1, 50, 0, false, false, false)
	Citizen.Wait(1000)

	StopAnimTask(GetPlayerPed(-1), dict, outAnim, 1.0)
	lastAnim = nil

	-- Workaround to delete entity...
	Citizen.InvokeNative(0xAE3CBE5BF394C9C9 , Citizen.PointerValueIntInitialized(phoneProp))
end



function loadAnimDict(dict)
	RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		Citizen.Wait(1)
	end
end

function newPhoneProp()
	RequestModel(phoneModel)
	while not HasModelLoaded(phoneModel) do
		Citizen.Wait(1)
	end
	local phoneEntity = CreateObject(phoneModel, 1.0, 1.0, 1.0, 1, 1, 0)
	SetEntityAsMissionEntity(phoneEntity)
	return phoneEntity
end