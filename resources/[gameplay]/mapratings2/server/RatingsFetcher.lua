RatingFetcher = {}

function RatingsFetcher.requestAll()
    dbQuery(Database.getConnection(), function(qh)
        local res = dbPoll(qh)
        if res then
            AllMapsRatings.receiveRatingsFromDatabase(res)
        end
    end, 'SELECT `mapresourcename`, sum(case when `rating`= 1 then 1 else 0 end) AS likes, sum(case when `rating`= 0 then 1 else 0 end) AS dislikes FROM `mapratings` GROUP BY `mapresourcename')
end

function RatingsFetcher.requestCurrent()
    local resname = getResourceName(exports.mapmanager:getRunningGamemodeMap())
    if not resname then error("No running map to fetch") return end
    dbQuery(Database.getConnection(), function(qh)
        local res = dbPoll(qh, 0)
        if res then
            CurrentMapRatings.receiveRatingsFromDatabase(resname, res)
        end
    end, 'SELECT `forumid`, `rating` FROM `mapratings` WHERE `mapresourcename` = ?', resname)
end

