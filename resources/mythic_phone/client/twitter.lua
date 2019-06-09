AddEventHandler('mythic_characters:client:CharacterSpawned', function()
  print("????")
  TriggerServerEvent('mythic_phone:server:twitter_login')
end)

RegisterNetEvent('mythic_characters:client:Logout')
AddEventHandler('mythic_characters:client:Logout', function()
  SendNUIMessage({event = 'twitter_logout'})
end)

RegisterNetEvent("mythic_phone:client:twitter_getTweets")
AddEventHandler("mythic_phone:client:twitter_getTweets", function(tweets)
  SendNUIMessage({event = 'twitter_tweets', tweets = tweets})
end)

RegisterNetEvent("mythic_phone:client:twitter_getFavoriteTweets")
AddEventHandler("mythic_phone:client:twitter_getFavoriteTweets", function(tweets)
  SendNUIMessage({event = 'twitter_favoritetweets', tweets = tweets})
end)

RegisterNetEvent("mythic_phone:client:twitter_newTweets")
AddEventHandler("mythic_phone:client:twitter_newTweets", function(tweet)
  SendNUIMessage({event = 'twitter_newTweet', tweet = tweet})
end)

RegisterNetEvent("mythic_phone:client:twitter_updateTweetLikes")
AddEventHandler("mythic_phone:client:twitter_updateTweetLikes", function(tweetId, likes)
  SendNUIMessage({event = 'twitter_updateTweetLikes', tweetId = tweetId, likes = likes})
end)

RegisterNetEvent("mythic_phone:client:twitter_setAccount")
AddEventHandler("mythic_phone:client:twitter_setAccount", function(username, avatarUrl)
  SendNUIMessage({event = 'twitter_setAccount', username = username, avatarUrl = avatarUrl})
end)

RegisterNetEvent("mythic_phone:client:twitter_createAccount")
AddEventHandler("mythic_phone:client:twitter_createAccount", function(account)
  SendNUIMessage({event = 'twitter_createAccount', account = account})
end)

RegisterNetEvent("mythic_phone:client:twitter_showError")
AddEventHandler("mythic_phone:client:twitter_showError", function(title, message)
  SendNUIMessage({event = 'twitter_showError', message = message, title = title})
end)

RegisterNetEvent("mythic_phone:client:twitter_showSuccess")
AddEventHandler("mythic_phone:client:twitter_showSuccess", function(title, message)
  SendNUIMessage({event = 'twitter_showSuccess', message = message, title = title})
end)

RegisterNetEvent("mythic_phone:client:twitter_setTweetLikes")
AddEventHandler("mythic_phone:client:twitter_setTweetLikes", function(tweetId, isLikes)
  SendNUIMessage({event = 'twitter_setTweetLikes', tweetId = tweetId, isLikes = isLikes})
end)

RegisterNUICallback('twitter_changePassword', function(data, cb)
  TriggerServerEvent('mythic_phone:server:twitter_changePassword', data.username)
end)

RegisterNUICallback('twitter_createAccount', function(data, cb)
  TriggerServerEvent('mythic_phone:server:twitter_createAccount', data.username, data.avatarUrl)
end)

RegisterNUICallback('twitter_getTweets', function(data, cb)
  TriggerServerEvent('mythic_phone:server:twitter_getTweets')
end)

RegisterNUICallback('twitter_getFavoriteTweets', function(data, cb)
  TriggerServerEvent('mythic_phone:server:twitter_getFavoriteTweets')
end)

RegisterNUICallback('twitter_postTweet', function(data, cb)
  TriggerServerEvent('mythic_phone:server:twitter_postTweets', data.message)
end)

RegisterNUICallback('twitter_toggleLikeTweet', function(data, cb)
  TriggerServerEvent('mythic_phone:server:twitter_toogleLikeTweet', data.tweetId)
end)

RegisterNUICallback('twitter_setAvatarUrl', function(data, cb)
  TriggerServerEvent('mythic_phone:server:twitter_setAvatarUrl', data.avatarUrl)
end)