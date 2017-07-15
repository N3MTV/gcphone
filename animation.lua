-- @author https://github.com/EmmanuelVlad/ephone

local inAnim = "cellphone_text_in"
local outAnim = "cellphone_text_out"
local outInCallAnim = "cellphone_call_out"
local callAnim = "cellphone_call_listen_base"
local idleAnim = "cellphone_text_read_base"

local phoneProp = 0
local phoneModel = "prop_npc_phone_02"

--------------------------------------------------------------------------------
--
--								FUNCTIONS
--
--------------------------------------------------------------------------------
function newPhoneProp()
	local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1), true))
	RequestModel(phoneModel)
	while not HasModelLoaded(phoneModel) do
		Citizen.Wait(100)
	end
	return CreateObject(phoneModel, 1.0, 1.0, 1.0, 1, 1, 0)
end

function ePhoneInAnim()
	if IsPlayerDead(PlayerId()) then
		return
	end
	local bone = GetPedBoneIndex(GetPlayerPed(-1), 28422)
	local dict = "cellphone@"
	if IsPedInAnyVehicle(GetPlayerPed(-1), false) then
		dict = dict .. "in_car@ds"
	end

	RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		Citizen.Wait(100)
	end

	TaskPlayAnim(GetPlayerPed(-1), dict, inAnim, 4.0, -1, -1, 50, 0, false, false, false)
	Citizen.Wait(157)
	phoneProp = newPhoneProp()
	AttachEntityToEntity(phoneProp, GetPlayerPed(-1), bone, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1, 1, 0, 0, 2, 1)
end

-- function ePhoneIdleAnim()
-- 	if IsPlayerDead(PlayerId()) then
-- 		return
-- 	end
-- 	local dict = "cellphone@"
-- 	if IsPedInAnyVehicle(GetPlayerPed(-1), false) then
-- 		dict = dict .. "in_car@ds"
-- 	end
-- 	RequestAnimDict(dict)
-- 	while not HasAnimDictLoaded(dict) do
-- 		Citizen.Wait(100)
-- 	end
-- 	TaskPlayAnim(GetPlayerPed(-1), dict, idleAnim, 1.0, -1, -1, 50, 0, false, false, false)
-- end

function ePhoneOutAnim()
	if IsPlayerDead(PlayerId()) then
		return
	end
	local dict = "cellphone@"
	if IsPedInAnyVehicle(GetPlayerPed(-1), false) then
		dict = dict .. "in_car@ds"
	end

	RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		Citizen.Wait(1)
	end
	if GetCurrentPedWeapon == 1 then
		ClearPedSecondaryTask(GetPlayerPed(-1))
		return
	end
	if inCall then
		StopAnimTask(GetPlayerPed(-1), dict, callAnim, 1.0)
		TaskPlayAnim(GetPlayerPed(-1), dict, outAnim, 5.0, -1, -1, 50, 0, false, false, false)
		inCall = false
	elseif not inCall then
		StopAnimTask(GetPlayerPed(-1), dict, inAnim, 1.0)
		TaskPlayAnim(GetPlayerPed(-1), dict, outAnim, 5.0, -1, -1, 50, 0, false, false, false)
	end
	Citizen.Wait(700)
	DeleteEntity(phoneProp)
	Citizen.Wait(500)
	StopAnimTask(GetPlayerPed(-1), dict, outAnim, 1.0)
end

-- function ePhoneCallAnim()
-- 	if IsPlayerDead(PlayerId()) then
-- 		return
-- 	end
-- 	local dict = "cellphone@"

-- 	RequestAnimDict(dict)
-- 	while not HasAnimDictLoaded(dict) do
-- 		Citizen.Wait(1)
-- 	end
-- 	StopAnimTask(GetPlayerPed(-1), "cellphone@", inAnim, 1.0)
-- 	TaskPlayAnim(GetPlayerPed(-1), dict, callAnim, 3.0, -1, -1, 50, 0, false, false, false)
-- end

-- function ePhoneSelfieAnim()
-- 	if IsPlayerDead(PlayerId()) then
-- 		return
-- 	end
-- 	local dict = "cellphone@self"
-- 	local anim = "selfie"

-- 	RequestAnimDict(dict)
-- 	while not HasAnimDictLoaded(dict) do
-- 		Citizen.Wait(1)
-- 	end
-- 	TaskPlayAnim(GetPlayerPed(-1), dict, outAnim, 1.0, -1, -1, 49, 0, false, false, false)
-- end