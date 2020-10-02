local ALL_MAPS_RATINGS_REFETCH_TIME = 10 * 60 * 1000

function init()
    -- Connect to database
    if not Database.connect() then
        cancelEvent("Could not connect to database")
        return
    end


    addEvent("onRaceStateChanging")
    addEventHandler("onRaceStateChanging", root, function(state) if state == "NoMap" then CurrentMapRatings.clear() end end)

    addEvent("onMapStarting")
    addEventHandler("onMapStarting", root, RatingsFetcher.requestCurrent)

    AllMapsRatings.requestRatings()
    setTimer(AllMapsRatings.requestRatings, ALL_MAPS_RATINGS_REFETCH_TIME, 0)
end
addEventHandler("onResourceStart", resourceRoot, init)
