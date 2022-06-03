IPLSquadAvailability = function(dffinal = c(as.factor("TeamName"),
                                         as.factor("Names"),
                                         as.character("Availability"),
                                         as.factor("ntimes"),
                                         as.factor("MatchIndex"),
                                         #as.factor("Match Centre"),
                                         as.character("Date"),
                                         as.character("Time (IST)"),
                                         as.character("Venue")
                                         
                                         
)){

dffinal<- df
#Making Names consistent
dffinal$Names<-gsub("\\(.*?)", "", dffinal$Names)


#3Splitting match information into teams
dffinal <- dffinal %>%
  separate(`Match Centre`, c("Home Team", "Away Team"), " vs ")

#splitting and joining string date and then converting to date 
dffinal<- dffinal %>%
  separate(`Date`, c("Date", "Year"), ", ")

dffinal$Date <-
  as.Date(str_c(dffinal$Date, ' ', dffinal$Year),
          "%B %d %Y")
##Adding series, format columns
dffinal$Series <-
  c("IPL"
  )
dffinal$Format <-
  c("T20"
  )
#Making teamnames consistent
dffinal$TeamName <-
  gsub("Squad", "", as.character(dffinal$TeamName))
##Removing unnecessary columns
dffinal <- dffinal[-c(4, 10)]
return(dffinal)

}
#View(IPLSquadAvailability(dffinal))
