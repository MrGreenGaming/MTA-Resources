Vue.use(Vuex)
const vuexStore = {
    state: {
        hideWindow: false,
        isLoggedIn: true,
        playerStats: [],
        vip: false,
        name: false,
        gc: 0,
        avatar: false,
        country: false,
        playerList: [],
        isLoading: true
    },

    getters: {
        country: state => {
            return state.country
        },
        isLoading: state => {
            return state.isLoading
        },
        isLoggedIn: state => {
            return state.isLoggedIn
        },
        vip: state => {
            return state.vip
        },
        playerList: state => {
            return state.playerList
        },
        playerStats: state => {
            return state.playerStats
        },
        gc: state => {
            return state.gc
        },
        name: state => {
            return state.name
        },
        avatar: state => {
            return state.avatar
        },
        hideWindow: state => {
            return state.hideWindow
        }
       
    },

    mutations: {
        // Make sure Lua tables are formatted properly
        removeData(state) {
            state.playerStats = []
            state.vip = false
            state.name = false
            state.gc = 0
            state.avatar = false
            state.playerList = []
        },
        setPlayerStats(state, string) {
            if (typeof string == 'string') {
                const statsObject = JSON.parse(string)
                if (typeof statsObject === 'object') {
                    state.playerStats = statsObject[0]
                }
            } else {
                state.playerStats = []
            }
            
        },
        setPlayerList(state, string) {
            if (typeof string === 'string') {
                const statsObject = JSON.parse(string)
                if (typeof statsObject === 'object') {
                    state.playerList = statsObject[0]
                } else {
                    state.playerList = []
                }
            } else {
                state.playerList = []
            }
        },
        setPlayerInfo(state, string) {
            if (typeof string == 'string') {
                const playerInfo = JSON.parse(string)
                if (typeof playerInfo === 'object') {
                    state.name = playerInfo[0].name || false
                    state.gc = playerInfo[0].gc || 0
                    state.vip = playerInfo[0].vip || false
                }
            } else {
                state.name = '- No Name -'
                state.gc = 0
                state.vip = false
            }
        },
        setPlayerAvatar(state, string) {
            if (string && typeof string === 'string') {
                state.avatar = string
            } else {
                state.avatar = false
            }
        },
        setLoggedIn(state, bool) {
            state.isLoggedIn = bool
        },
        setLoading(state, bool) {
            state.isLoading = bool && bool || false
        },
        setPlayerCountry(state, countryString) {
            const countryObj = JSON.parse(countryString)
            if (!countryObj || typeof countryObj !== 'object' ||!countryObj[0] || !countryObj[0].name || !countryObj[0].code) {
                state.country = false
                return
            }
            state.country = countryObj[0]
        }
        
    },
}
// Declare in window so it's usable by MTA
// window.VuexStore.commit('mutationName')
window.VuexStore = new Vuex.Store(vuexStore)
export default window.VuexStore

