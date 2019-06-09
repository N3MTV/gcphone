AddEventHandler('mythic_characters:client:CharacterSpawned', function()
  print("????")
  TriggerServerEvent('gcPhone:twitter_login')
end)

RegisterNetEvent('mythic_characters:client:Logout')
AddEventHandler('mythic_characters:client:Logout', function()
  SendNUIMessage({event = 'twitter_logout'})
end)

RegisterNetEvent("gcPhone:twitter_getTweets")
AddEventHandler("gcPhone:twitter_getTweets", function(tweets)
  SendNUIMessage({event = 'twitter_tweets', tweets = tweets})
end)

RegisterNetEvent("gcPhone:twitter_getFavoriteTweets")
AddEventHandler("gcPhone:twitter_getFavoriteTweets", function(tweets)
  SendNUIMessage({event = 'twitter_favoritetweets', tweets = tweets})
end)

RegisterNetEvent("gcPhone:twitter_newTweets")
AddEventHandler("gcPhone:twitter_newTweets", function(tweet)
  SendNUIMessage({event = 'twitter_newTweet', tweet = tweet})
end)

RegisterNetEvent("gcPhone:twitter_updateTweetLikes")
AddEventHandler("gcPhone:twitter_updateTweetLikes", function(tweetId, likes)
  SendNUIMessage({event = 'twitter_updateTweetLikes', tweetId = tweetId, likes = likes})
end)

RegisterNetEvent("gcPhone:twitter_setAccount")
AddEventHandler("gcPhone:twitter_setAccount", function(username, password, avatarUrl)
  SendNUIMessage({event = 'twitter_setAccount', username = username, password = password, avatarUrl = avatarUrl})
end)

RegisterNetEvent("gcPhone:twitter_createAccount")
AddEventHandler("gcPhone:twitter_createAccount", function(account)
  SendNUIMessage({event = 'twitter_createAccount', account = account})
end)

RegisterNetEvent("gcPhone:twitter_showError")
AddEventHandler("gcPhone:twitter_showError", function(title, message)
  SendNUIMessage({event = 'twitter_showError', message = message, title = title})
end)

RegisterNetEvent("gcPhone:twitter_showSuccess")
AddEventHandler("gcPhone:twitter_showSuccess", function(title, message)
  SendNUIMessage({event = 'twitter_showSuccess', message = message, title = title})
end)

RegisterNetEvent("gcPhone:twitter_setTweetLikes")
AddEventHandler("gcPhone:twitter_setTweetLikes", function(tweetId, isLikes)
  SendNUIMessage({event = 'twitter_setTweetLikes', tweetId = tweetId, isLikes = isLikes})
end)

RegisterNUICallback('twitter_changePassword', function(data, cb)
  TriggerServerEvent('gcPhone:twitter_changePassword', data.username)
end)

RegisterNUICallback('twitter_createAccount', function(data, cb)
  TriggerServerEvent('gcPhone:twitter_createAccount', data.username, data.avatarUrl)
end)

RegisterNUICallback('twitter_getTweets', function(data, cb)
  TriggerServerEvent('gcPhone:twitter_getTweets')
end)

RegisterNUICallback('twitter_getFavoriteTweets', function(data, cb)
  TriggerServerEvent('gcPhone:twitter_getFavoriteTweets')
end)

RegisterNUICallback('twitter_postTweet', function(data, cb)
  TriggerServerEvent('gcPhone:twitter_postTweets', data.message)
end)

RegisterNUICallback('twitter_toggleLikeTweet', function(data, cb)
  TriggerServerEvent('gcPhone:twitter_toogleLikeTweet', data.tweetId)
end)

RegisterNUICallback('twitter_setAvatarUrl', function(data, cb)
  TriggerServerEvent('gcPhone:twitter_setAvatarUrl', data.avatarUrl)
end)