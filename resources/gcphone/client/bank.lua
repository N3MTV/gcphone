--====================================================================================
--  Function APP BANK
--====================================================================================

local bank = 0
function setBankBalance (value)
      bank = value
      SendNUIMessage({event = 'updateBankbalance', banking = bank})
end

RegisterNetEvent('mythic_phone:client:SetupBankApp')
AddEventHandler('mythic_phone:client:SetupBankApp', function(cData)
      setBankBalance(cData.bank)
end)

RegisterNetEvent('mythic_base:client:SetBankMoney')
AddEventHandler('mythic_base:client:SetBankMoney', function(cData)
      setBankBalance(cData.bank)
end)

RegisterNetEvent("mythic_base:client:AddBankBalance")
AddEventHandler("mythic_base:client:AddBankBalance", function(amount)
      setBankBalance(bank + amount)
end)

RegisterNetEvent("mythic_base:client:RemoveBankBalance")
AddEventHandler("mythic_base:client:RemoveBankBalance", function(amount)
      setBankBalance(bank - amount)
end)