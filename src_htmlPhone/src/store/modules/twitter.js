import PhoneAPI from './../../PhoneAPI'
import Vue from 'vue'

const state = {
  twitterUsername: localStorage['gcphone_twitter_username'],
  twitterPassword: localStorage['gcphone_twitter_password'],
  twitterAvatarUrl: localStorage['gcphone_twitter_avatarUrl'],
  tweets: [],
  favoriteTweets: []
}

const getters = {
  twitterUsername: ({ twitterUsername }) => twitterUsername,
  twitterPassword: ({ twitterPassword }) => twitterPassword,
  twitterAvatarUrl: ({ twitterAvatarUrl }) => twitterAvatarUrl,
  tweets: ({ tweets }) => tweets,
  favoriteTweets: ({ favoriteTweets }) => favoriteTweets
}

const actions = {
  twitterCreateNewAccount (_, {username, password, avatarUrl}) {
    PhoneAPI.twitter_createAccount(username, password, avatarUrl)
  },
  twitterLogin ({ commit }, { username, password }) {
    localStorage['gcphone_twitter_username'] = username
    localStorage['gcphone_twitter_password'] = password
    commit('SET_TWITTER_LOGIN', { username, password })
  },
  twitterSetAvatar ({ state }, { avatarUrl }) {
    PhoneAPI.twitter_setAvatar(state.twitterUsername, state.twitterPassword, avatarUrl)
  },
  twitterPostTweet ({ state, commit }, { message }) {
    if (/^https?:\/\/.*\.(png|jpg|jpeg|gif)$/.test(message)) {
      PhoneAPI.twitter_postTweetImg(state.twitterUsername, state.twitterPassword, message)
    } else {
      PhoneAPI.twitter_postTweet(state.twitterUsername, state.twitterPassword, message)
    }
  },
  twitterToogleLike ({ state }, { tweetId }) {
    PhoneAPI.twitter_toggleLikeTweet(state.twitterUsername, state.twitterPassword, tweetId)
  },
  setInfoAccount ({ commit, dispatch }, data) {
    if (data.avatarUrl) {
      localStorage['gcphone_twitter_avatarUrl'] = data.avatarUrl
      commit('UPDATE_ACCOUNT_INFO', data)
    }
    if (data.username) {
      dispatch('twitterLogin', data)
    }
  },
  addTweet ({ commit, state }, tweet) {
    if (tweet.message && tweet.message.toLowerCase().indexOf(state.twitterUsername.toLowerCase()) !== -1) {
      Vue.notify({
        message: tweet.message,
        title: tweet.author + ' :',
        icon: 'twitter',
        sound: 'Twitter_Sound_Effect.ogg'
      })
    }
    commit('ADD_TWEET', { tweet })
  },
  fetchTweets ({ state }) {
    PhoneAPI.twitter_getTweets(state.twitterUsername, state.twitterPassword)
  },
  fetchFavoriteTweets ({ state }) {
    PhoneAPI.twitter_getFavoriteTweets(state.twitterUsername, state.twitterPassword)
  }
}

const mutations = {
  SET_TWITTER_LOGIN (state, { username, password }) {
    state.twitterUsername = username
    state.twitterPassword = password
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
  },
  UPDATE_ACCOUNT_INFO (state, { avatarUrl }) {
    state.twitterAvatarUrl = avatarUrl
  }
}

export default {
  state,
  getters,
  actions,
  mutations
}

if (process.env.NODE_ENV !== 'production') {
  state.tweets = [{
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
