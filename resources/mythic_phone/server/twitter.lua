--====================================================================================
-- #Author: Jonathan D @ Gannon
--====================================================================================

function TwitterGetTweets (accountId, cb)
  if accountId == nil then
    MySQL.Async.fetchAll('SELECT twitter_tweets.*, CONCAT_WS(\'\',characters.first_name , characters.last_name, characters.id) as author, twitter_accounts.avatar_url as authorIcon FROM twitter_tweets INNER JOIN twitter_accounts ON twitter_tweets.authorId = twitter_accounts.id INNER JOIN characters ON twitter_tweets.authorId = characters.id ORDER BY time DESC LIMIT 130',
    {}, cb)
  else
    MySQL.Async.fetchAll('SELECT twitter_tweets.*, CONCAT_WS(\'\',characters.first_name , characters.last_name, characters.id) as author, twitter_accounts.avatar_url as authorIcon, twitter_likes.id AS isLikes FROM twitter_tweets INNER JOIN twitter_accounts ON twitter_tweets.authorId = twitter_accounts.id LEFT JOIN twitter_likes  ON twitter_tweets.id = twitter_likes.tweetId AND twitter_likes.authorId = @accountId INNER JOIN characters ON twitter_tweets.authorId = characters.id ORDER BY time DESC LIMIT 130',
    { ['@accountId'] = accountId }, cb)
  end
end

function TwitterGetFavotireTweets (accountId, cb)
  if accountId == nil then
    MySQL.Async.fetchAll([===[
      SELECT twitter_tweets.*,
        CONCAT_WS('',characters.first_name , characters.last_name, characters.id) as author,
        twitter_accounts.avatar_url as authorIcon
      FROM twitter_tweets
        INNER JOIN twitter_accounts
          ON twitter_tweets.authorId = twitter_accounts.id
        INNER JOIN characters
          ON twitter_tweets.authorId = characters.id
      WHERE twitter_tweets.TIME > CURRENT_TIMESTAMP() - INTERVAL '15' DAY
      ORDER BY likes DESC, TIME DESC LIMIT 30
    ]===], {}, cb)
  else
    MySQL.Async.fetchAll([===[
      SELECT twitter_tweets.*,
        CONCAT_WS('',characters.first_name , characters.last_name, characters.id) as author,
        twitter_accounts.avatar_url as authorIcon,
        twitter_likes.id AS isLikes
      FROM twitter_tweets
        INNER JOIN twitter_accounts
          ON twitter_tweets.authorId = twitter_accounts.id
        INNER JOIN characters
          ON twitter_tweets.authorId = characters.id
        LEFT JOIN twitter_likes 
          ON twitter_tweets.id = twitter_likes.tweetId AND twitter_likes.authorId = @accountId
      WHERE twitter_tweets.TIME > CURRENT_TIMESTAMP() - INTERVAL '15' DAY
      ORDER BY likes DESC, TIME DESC LIMIT 30
    ]===], { ['@accountId'] = accountId }, cb)
  end
end

function getUser(id, cb)
  MySQL.Async.fetchScalar("SELECT avatar_url as authorIcon FROM twitter_accounts WHERE twitter_accounts.id = @id", {
    ['@id'] = id
  }, function (avatar)
    cb(avatar)
  end)
end

function TwitterPostTweet(char, message, cb)
  local cData = char.getCharData()
  getUser(cData.id, function (user)
    MySQL.Async.insert("INSERT INTO twitter_tweets (`authorId`, `message`) VALUES(@authorId, @message);", {
      ['@authorId'] = cData.id,
      ['@message'] = message
    }, function (id)
      MySQL.Async.fetchAll('SELECT * from twitter_tweets WHERE id = @id', {
        ['@id'] = id
      }, function (tweets)
        tweet = tweets[1]
        tweet['author'] = user.author
        tweet['authorIcon'] = user.authorIcon
        TriggerClientEvent('mythic_phone:client:twitter_newTweets', -1, tweet)
        TriggerEvent('mythic_phone:server:twitter_newTweets', char, tweet)
      end)
    end)
  end)
end

function TwitterToogleLike(char, tweetId)
  local cData = char.getCharData()
  MySQL.Async.fetchAll('SELECT * FROM twitter_tweets WHERE id = @id', {
    ['@id'] = tweetId
  }, function (tweets)
    if (tweets[1] == nil) then return end
    local tweet = tweets[1]
    MySQL.Async.fetchAll('SELECT * FROM twitter_likes WHERE authorId = @authorId AND tweetId = @tweetId', {
      ['authorId'] = cData.id,
      ['tweetId'] = tweetId
    }, function (row) 
      if (row[1] == nil) then
        MySQL.Async.insert('INSERT INTO twitter_likes (`authorId`, `tweetId`) VALUES(@authorId, @tweetId)', {
          ['authorId'] = cData.id,
          ['tweetId'] = tweetId
        }, function (newrow)
          MySQL.Async.execute('UPDATE `twitter_tweets` SET `likes`= likes + 1 WHERE id = @id', {
            ['@id'] = tweet.id
          }, function ()
            TriggerClientEvent('mythic_phone:client:twitter_updateTweetLikes', -1, tweet.id, tweet.likes + 1)
            TriggerClientEvent('mythic_phone:client:twitter_setTweetLikes', cData.source, tweet.id, true)
            TriggerEvent('mythic_phone:server:twitter_updateTweetLikes', tweet.id, tweet.likes + 1)
          end)    
        end)
      else
        MySQL.Async.execute('DELETE FROM twitter_likes WHERE id = @id', {
          ['@id'] = row[1].id,
        }, function (newrow)
          MySQL.Async.execute('UPDATE `twitter_tweets` SET `likes`= likes - 1 WHERE id = @id', {
            ['@id'] = tweet.id
          }, function ()
            TriggerClientEvent('mythic_phone:client:twitter_updateTweetLikes', -1, tweet.id, tweet.likes - 1)
            TriggerClientEvent('mythic_phone:client:twitter_setTweetLikes', cData.source, tweet.id, false)
            TriggerEvent('mythic_phone:server:twitter_updateTweetLikes', tweet.id, tweet.likes - 1)
          end)
        end)
      end
    end)
  end)
end

function TwitterCreateAccount(id, avatarUrl, cb)
  MySQL.Async.insert('INSERT IGNORE INTO twitter_accounts (`id`, `avatar_url`) VALUES(@id, @avatarUrl)', {
    ['id'] = id,
    ['avatarUrl'] = avatarUrl
  }, cb)
end

-- ALTER TABLE `twitter_accounts`	CHANGE COLUMN `username` `username` VARCHAR(50) NOT NULL DEFAULT '0' COLLATE 'utf8_general_ci';

RegisterServerEvent('mythic_phone:server:twitter_login')
AddEventHandler('mythic_phone:server:twitter_login', function()
  local char = exports['mythic_base']:getPlayerFromId(source).getChar()
  local cData = char.getCharData()
  getUser(cData.id, function (user)
    if user == nil then
      TwitterCreateAccount(cData.id, 'https://pbs.twimg.com/profile_images/1114565338346078214/HZSe7qxC_400x400.jpg')
      getUser(cData.id, function (user2)
        TriggerClientEvent('mythic_notify:client:SendAlert', cData.source, { type = 'success', text = 'Logged Into Twitter'})
        TriggerClientEvent('mythic_phone:client:twitter_setAccount', cData.source, username, user2.authorIcon)
      end)
    else
      TriggerClientEvent('mythic_notify:client:SendAlert', cData.source, { type = 'success', text = 'Logged Into Twitter'})
      TriggerClientEvent('mythic_phone:client:twitter_setAccount', cData.source, username, user.authorIcon)
    end
  end)
end)

RegisterServerEvent('mythic_phone:server:twitter_getTweets')
AddEventHandler('mythic_phone:server:twitter_getTweets', function()
  local char = exports['mythic_base']:getPlayerFromId(source).getChar()
  local cData = char.getCharData()
  TwitterGetTweets(cData.id, function (tweets)
    TriggerClientEvent('mythic_phone:client:twitter_getTweets', cData.source, tweets)
  end)
end)

RegisterServerEvent('mythic_phone:server:twitter_getFavoriteTweets')
AddEventHandler('mythic_phone:server:twitter_getFavoriteTweets', function()
  local char = exports['mythic_base']:getPlayerFromId(source).getChar()
  local cData = char.getCharData()
  TwitterGetFavotireTweets(cData.id, function (tweets)
    TriggerClientEvent('mythic_phone:client:twitter_getFavoriteTweets', cData.source, tweets)
  end)
end)

RegisterServerEvent('mythic_phone:server:twitter_postTweets')
AddEventHandler('mythic_phone:server:twitter_postTweets', function(message)
  local char = exports['mythic_base']:getPlayerFromId(source).getChar()
  TwitterPostTweet(char, message)
end)

RegisterServerEvent('mythic_phone:server:twitter_toogleLikeTweet')
AddEventHandler('mythic_phone:server:twitter_toogleLikeTweet', function(tweetId)
  local char = exports['mythic_base']:getPlayerFromId(source).getChar()
  TwitterToogleLike(char, tweetId)
end)


RegisterServerEvent('mythic_phone:server:twitter_setAvatarUrl')
AddEventHandler('mythic_phone:server:twitter_setAvatarUrl', function(avatarUrl)
  local char = exports['mythic_base']:getPlayerFromId(source).getChar()
  local cData = char.getCharData()
  MySQL.Async.execute("UPDATE `twitter_accounts` SET `avatar_url`= @avatarUrl WHERE twitter_accounts.id = @id", {
    ['@id'] = cData.id,
    ['@avatarUrl'] = avatarUrl
  }, function (result)
    if (result == 1) then
      local un = cData.firstName .. cData.lastName .. cData.id 

      TriggerClientEvent('mythic_phone:client:twitter_setAccount', cData.source, un, avatarUrl)
      TriggerClientEvent('mythic_notify:client:SendAlert', cData.source, { type = 'success', text = 'Twitter Avatar Updated'})
    else
      TriggerClientEvent('mythic_notify:client:SendAlert', cData.source, { type = 'error', text = 'Something Is Wrong, You\'re Not Logged In'})
    end
  end)
end)


--[[
  Discord WebHook
  set discord_webhook 'https//....' in config.cfg
--]]
AddEventHandler('mythic_phone:server:twitter_newTweets', function (char, tweet)
  local cData = char.getCharData()
  local discord_webhook = GetConvar('discord_webhook', '')
  if discord_webhook == '' then
    return
  end
  local headers = {
    ['Content-Type'] = 'application/json'
  }
  local data = {
    ["username"] = tweet.author,
    ["embeds"] = {{
      ["thumbnail"] = {
        ["url"] = tweet.authorIcon
      },
      ["color"] = 1942002,
      ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ", tweet.time / 1000 )
    }}
  }
  local isHttp = string.sub(tweet.message, 0, 7) == 'http://' or string.sub(tweet.message, 0, 8) == 'https://'
  local ext = string.sub(tweet.message, -4)
  local isImg = ext == '.png' or ext == '.pjg' or ext == '.gif' or string.sub(tweet.message, -5) == '.jpeg'
  if (isHttp and isImg) and true then
    data['embeds'][1]['image'] = { ['url'] = tweet.message }
  else
    data['embeds'][1]['description'] = tweet.message
  end
  PerformHttpRequest(discord_webhook, function(err, text, headers) end, 'POST', json.encode(data), headers)
end)