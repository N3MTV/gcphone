--====================================================================================
--  Function APP BANK
--====================================================================================

--[[
      Appeller SendNUIMessage({event = 'updateBankbalance', banking = xxxx})
      à la connection & à chaque changement du compte
--]]

-- ESX Implementation

local bank = 0
function setBankBalance (value)
      bank = value
      SendNUIMessage({event = 'updateBankbalance', banking = bank})
end

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(playerData)
      local accounts = playerData.accounts or {}
      for index, account in ipairs(accounts) do 
            if account.name == 'bank' then
                  setBankBalance(account.money)
                  break
            end
      end
end)

RegisterNetEvent('esx:setAccountMoney')
AddEventHandler('esx:setAccountMoney', function(account)
      if account.name == 'bank' then
            setBankBalance(account.money)
      end
end)
