RatingsFetcher = {}

function RatingsFetcher.requestAll()
    dbQuery(function(qh)
        local res = dbPoll(qh, 0)
        if res then
            AllMapsRatings.receiveRatingsFromDatabase(res)
        end
    end, Database.getConnection(), 'SELECT `mapresourcename`, sum(case when `rating`= 1 then 1 else 0 end) AS likes, sum(case when `rating`= 0 then 1 else 0 end) AS dislikes FROM `mapratings` GROUP BY `mapresourcename')
end

function RatingsFetcher.request()
    local resname = getResourceName(exports.mapmanager:getRunningGamemodeMap())
    iprint("requesting current map", resname)
    if not resname then outputDebugString("No running map to fetch") return end
    dbQuery(function(qh)
        local res = dbPoll(qh, 0)
        iprint("Request res", res)
        if res then
            CurrentMapRatings.receiveRatingsFromDatabase(resname, res)
        end
    end, Database.getConnection(), 'SELECT `forumid`, `rating` FROM `mapratings` WHERE `mapresourcename` = ?', resname)
end

