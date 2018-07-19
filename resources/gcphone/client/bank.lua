--====================================================================================
--  Function APP BANK
--====================================================================================

--[[
      Appeller SendNUIMessage({event = 'updateBankbalance', banking = xxxx})
      à la connection & à chaque changement du compte
--]]

-- FOR ESX

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(playerData)
      local accounts = playerData.accounts or {}
      for index, account in ipairs(accounts) do 
            if account.name == 'bank' then
                  SendNUIMessage({event = 'updateBankbalance', banking = account.money})
                  break
            end
      end
end)

RegisterNetEvent('esx:setAccountMoney')
AddEventHandler('esx:setAccountMoney', function(account)
      if account.name == 'bank' then
            SendNUIMessage({event = 'updateBankbalance', banking = account.money})
      end
end)



--- Piste

-- local bank = 0
-- RegisterNetEvent('es:displayBank')
-- AddEventHandler('es:displayBank', function(a)
--   print('BANK ', a)
-- 	SendNUIMessage({event = 'updateBankbalance', banking = a})
-- end)

-- RegisterNetEvent("es:addedBank")
-- AddEventHandler("es:addedBank", function(m, native)
--   bank = bank + m
--   SendNUIMessage({event = 'updateBankbalance', banking = a})
-- end)

-- RegisterNetEvent("es:removedBank")
-- AddEventHandler("es:removedBank", function(m, native, current)
--   bank = bank - m
--   SendNUIMessage({event = 'updateBankbalance', banking = a})
-- end)

-- RegisterNetEvent('banking:updateBalance')
-- AddEventHandler('banking:updateBalance', function(bank)
--     SendNUIMessage({event = 'updateBankbalance', banking = bank})
-- end)

-- RegisterNetEvent('esx:setAccountMoney')
-- AddEventHandler('esx:setAccountMoney', function(account)
--   if account.name == 'bank' then
--     SendNUIMessage({event = 'updateBankbalance', banking = account.money})
--   end 
-- end)