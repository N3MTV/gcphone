import PhoneAPI from './../../PhoneAPI'
import Vue from 'vue'

const state = {
  twitterUsername: localStorage['gcphone_twitter_username'],
  twitterAvatarUrl: localStorage['gcphone_twitter_avatarUrl'],
  twitterNotification: localStorage['gcphone_twitter_notif'] ? parseInt(localStorage['gcphone_twitter_notif']) : 1,
  twitterNotificationSound: localStorage['gcphone_twitter_notif_sound'] !== 'false',
  tweets: [],
  favoriteTweets: []
}

const getters = {
  twitterUsername: ({ twitterUsername }) => twitterUsername,
  twitterAvatarUrl: ({ twitterAvatarUrl }) => twitterAvatarUrl,
  twitterNotification: ({ twitterNotification }) => twitterNotification,
  twitterNotificationSound: ({ twitterNotificationSound }) => twitterNotificationSound,
  tweets: ({ tweets }) => tweets,
  favoriteTweets: ({ favoriteTweets }) => favoriteTweets
}

const actions = {
  twitterLogout ({ commit }) {
    localStorage.removeItem('gcphone_twitter_username')
    localStorage.removeItem('gcphone_twitter_avatarUrl')
    commit('UPDATE_ACCOUNT', {
      username: undefined,
      avatarUrl: undefined
    })
  },
  twitterSetAvatar ({ state }, { avatarUrl }) {
    PhoneAPI.twitter_setAvatar(avatarUrl)
  },
  twitterPostTweet ({ state }, { message }) {
    if (/^https?:\/\/.*\.(png|jpg|jpeg|gif)$/.test(message)) {
      PhoneAPI.twitter_postTweetImg(message)
    } else {
      PhoneAPI.twitter_postTweet(message)
    }
  },
  twitterToogleLike ({ state }, { tweetId }) {
    PhoneAPI.twitter_toggleLikeTweet(tweetId)
  },
  setAccount ({ commit }, data) {
    localStorage['gcphone_twitter_username'] = data.username
    localStorage['gcphone_twitter_avatarUrl'] = data.avatarUrl
    commit('UPDATE_ACCOUNT', data)
  },
  addTweet ({ commit, state }, tweet) {
    let notif = state.twitterNotification === 2
    if (state.twitterNotification === 1) {
      notif = tweet.message && tweet.message.toLowerCase().indexOf(state.twitterUsername.toLowerCase()) !== -1
    }
    if (notif === true) {
      Vue.notify({
        message: tweet.message,
        title: tweet.author + ' :',
        icon: 'twitter',
        sound: state.twitterNotificationSound ? 'Twitter_Sound_Effect.ogg' : undefined
      })
    }
    commit('ADD_TWEET', { tweet })
  },
  fetchTweets ({ state }) {
    PhoneAPI.twitter_getTweets(state.twitterUsername)
  },
  fetchFavoriteTweets ({ state }) {
    PhoneAPI.twitter_getFavoriteTweets(state.twitterUsername)
  },
  setTwitterNotification ({ commit }, value) {
    localStorage['gcphone_twitter_notif'] = value
    commit('SET_TWITTER_NOTIFICATION', { notification: value })
  },
  setTwitterNotificationSound ({ commit }, value) {
    localStorage['gcphone_twitter_notif_sound'] = value
    commit('SET_TWITTER_NOTIFICATION_SOUND', { notificationSound: value })
  }
}

const mutations = {
  SET_TWITTER_NOTIFICATION (state, { notification }) {
    state.twitterNotification = notification
  },
  SET_TWITTER_NOTIFICATION_SOUND (state, { notificationSound }) {
    state.twitterNotificationSound = notificationSound
  },
  UPDATE_ACCOUNT (state, { username, avatarUrl }) {
    state.twitterUsername = username
    state.twitterAvatarUrl = avatarUrl
  },
  SET_TWEETS (state, { tweets }) {
    state.tweets = tweets
  },
  SET_FAVORITE_TWEETS (state, { tweets }) {
    state.favoriteTweets = tweets
  },
  ADD_TWEET (state, { tweet }) {
    state.tweets = [tweet, ...state.tweets]
  },
  UPDATE_TWEET_LIKE (state, { tweetId, likes }) {
    const tweetIndex = state.tweets.findIndex(t => t.id === tweetId)
    if (tweetIndex !== -1) {
      state.tweets[tweetIndex].likes = likes
    }
    const tweetIndexFav = state.favoriteTweets.findIndex(t => t.id === tweetId)
    if (tweetIndexFav !== -1) {
      state.favoriteTweets[tweetIndexFav].likes = likes
    }
  },
  UPDATE_TWEET_ISLIKE (state, { tweetId, isLikes }) {
    const tweetIndex = state.tweets.findIndex(t => t.id === tweetId)
    if (tweetIndex !== -1) {
      Vue.set(state.tweets[tweetIndex], 'isLikes', isLikes)
    }
    const tweetIndexFav = state.favoriteTweets.findIndex(t => t.id === tweetId)
    if (tweetIndexFav !== -1) {
      Vue.set(state.favoriteTweets[tweetIndexFav], 'isLikes', isLikes)
    }
  }
}

export default {
  state,
  getters,
  actions,
  mutations
}

if (process.env.NODE_ENV !== 'production') {
  state.favoriteTweets = [{
    id: 1,
    message: 'https://pbs.twimg.com/profile_images/702982240184107008/tUKxvkcs_400x400.jpg',
    author: 'Gannon',
    time: new Date(),
    likes: 3,
    isLikes: 60
  }, {
    id: 2,
    message: 'Borderlands 3 arrives on Xbox One, PS4, and PC on September 13, 2019! Tune in to the Gameplay Reveal Event on May 1st, where we’ll debut the first hands-on looks! Pre-order now to get the Gold Weapon Skins Pack! ➜ https://borderlands.com  ',
    author: 'Gearbox Official',
    authorIcon: 'https://pbs.twimg.com/profile_images/702982240184107008/tUKxvkcs_400x400.jpg',
    time: new Date(),
    likes: 65
  }, {
    id: 3,
    message: '',
    img: 'https://cdn.discordapp.com/attachments/563443658192322576/563473765569396746/samurai-background-hd-1920x1200-45462.jpg',
    author: 'Gannon',
    time: new Date()
  }, {
    id: 4,
    message: 'Super Message de la mort.',
    author: 'Gannon',
    authorIcon: 'https://pbs.twimg.com/profile_images/986085090684960768/AcD9lOLw_bigger.jpg',
    likes: 0,
    time: new Date()
  },
  {
    id: 5,
    message: 'Super Message de la mort.',
    author: 'Gannon',
    authorIcon: 'https://pbs.twimg.com/profile_images/986085090684960768/AcD9lOLw_bigger.jpg',
    likes: 0,
    time: new Date()
  },
  {
    id: 6,
    message: 'Super Message de la mort.',
    author: 'Gannon',
    authorIcon: 'https://pbs.twimg.com/profile_images/986085090684960768/AcD9lOLw_bigger.jpg',
    likes: 0,
    time: new Date()
  },
  {
    id: 7,
    message: 'Super Message de la mort.',
    author: 'Gannon',
    authorIcon: 'https://pbs.twimg.com/profile_images/986085090684960768/AcD9lOLw_bigger.jpg',
    likes: 0,
    time: new Date()
  },
  {
    id: 8,
    message: 'Super Message de la mort.',
    author: 'Gannon',
    authorIcon: 'https://pbs.twimg.com/profile_images/986085090684960768/AcD9lOLw_bigger.jpg',
    likes: 0,
    time: new Date()
  }]
}
