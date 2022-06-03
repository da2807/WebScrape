
AFL_matchStatsfunction = function(matchstats) {
##Separating Teams
#matchstats <-matchstats %>%
#  separate(`Team`, c("Home", "Away"), "v")
#
###Separating Scores
#matchstats <- matchstats %>%
#  separate(`Scores`, c("Home.Score", "Away.Score"), "-")

#Cleaning date column in right format
matchstats$Date <- word(matchstats$Date, 2, -1)

matchstats$Date <-
 as.Date(str_c(substr(matchstats$Date, 1, 6), ' ', matchstats$year), "%d %b %Y") 

##Fetching MatchId
matchstats$MatchId <- as.character(str_sub(matchstats$urls, -5, -1))

##Separating Scores
matchstats <- matchstats %>%
  separate(`urls`, c("urls", "MatchId"), "=")


matchstats <- matchstats %>% 
  inner_join(afl.stats, by = "MatchId") %>% 
  select(Home.x, Away.x, Home.Score.x, Away.Score.x, Date.x, Venue.x, urls.x, MatchId, Rd)

matchstats <- distinct(matchstats)
return(matchstats)
}

#AFL_matchStatsfunction(matchstats)





