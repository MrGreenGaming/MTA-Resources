Vue.use(Vuex)
const vuexStore = {
    state: {
        isLoggedIn: true,
        monthlyTopsAmount: 500,
        playerTops: [],
        playerStats: [],
        topTimeMaps: [],
        vip: false,
        name: false,
        gc: 0,
        avatar: false,
        country: false,
        playerList: [],
        isLoading: true,
        dialogChosenPlayer: false
    },

    getters: {
        monthlyTopsAmount: state => {
            return state.monthlyTopsAmount
        },
        playerTops: state => {
            return state.playerTops
        },
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
        topTimeMaps: state => {
            return state.topTimeMaps
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
        dialogChosenPlayer: state => {
            return state.dialogChosenPlayer
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
            state.topTimeMaps = []
            state.dialogChosenPlayer = false
        },
        setPlayerStats(state, string) {
            if (typeof string == 'string') {
                const statsObject = JSON.parse(string)
                if (typeof statsObject === 'object') {
                    state.playerStats = statsObject[0]
                }
            } else {
                state.playerStats = []
                state.country = false
                state.vip = false
                state.gc = false
                state.name = false
                state.avatar = false

            }
            
        },
        setTopTimeMaps(state, string) {
            if (typeof string === 'string') {
                const statsObject = JSON.parse(string)
                if (typeof statsObject === 'object') {
                    state.topTimeMaps = statsObject[0]
                } else {
                    state.topTimeMaps = []
                }
            } else {
                state.topTimeMaps = []
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
        setPlayerTops(state, string) {
            if (typeof string !== 'string') {
                state.playerTops = []
                return
            }
            const tops = JSON.parse(string)
            if (!tops || typeof tops !== 'object' || !tops[0] ) {
                state.playerTops = []
                return
            }
            state.playerTops = tops[0]
        },
        setMonthlyTopAmount(state, amount) {
            state.monthlyTopsAmount = typeof amount === 'number' && amount || 0
        },
        setLoggedIn(state, bool) {
            state.isLoggedIn = bool
        },
        setLoading(state, bool) {
            state.isLoading = bool && bool || false
        },
        setDialogChosenPlayer(state, value) {
            state.dialogChosenPlayer = value || false
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

