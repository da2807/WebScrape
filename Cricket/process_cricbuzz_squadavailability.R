

#
#
# library(tidyr)
# library(stringr)
# library(dplyr)
# library(lubridate)




processcricbuzzsquadavailability = function(df = c(
  as.factor("TeamName"),
  as.factor("Names"),
  as.character("Availability"),
  as.factor("Series.Description"),
  as.factor("Match.Details"),
  as.factor("Result")
)) {
  ##Removing Commentary Information
  final.df <- final.df %>%
    separate(`Series.Description`, c("fixture", "commentary"), " - ")
  
  final.df <- final.df[-c(5)]
  
  ##Combining Columns to extract consistent format information
  final.df$combined <-
    str_c(final.df$fixture,
          ' ',
          final.df$`Match Details`)
  ##Extracting Format information from combined columns
  final.df <-
    mutate(final.df, CricketFormat =
             ifelse(
               grepl("Test", final.df$combined),
               "Test",
               ifelse(
                 grepl("ODI", final.df$combined),
                 "ODI",
                 ifelse(grepl("T20", final.df$combined), "T20", "Warm-Up")
               )
             ))
  
  final.df <- final.df %>%
    separate(fixture, c("Match", "format"), ", ")
  
  final.df <- final.df[-c(5, 8)]
  
  ##Creating Result and Margin Columns
  
  final.df <- suppressWarnings(final.df %>%
                                 separate(Result, c("Result", "Margin"), " by "))
  
  
  
  final.df <- mutate(final.df, Result =
                       ifelse(
                         grepl("drawn", final.df$Result),
                         "Draw",
                         ifelse(
                           substr(final.df$TeamName, 1, 5) == substr(final.df$Result, 1, 5),
                           "Win",
                           ifelse(
                             substr(final.df$TeamName, 1, 5) != substr(final.df$Result, 1, 5),
                             "Loss",
                             NA
                           )
                         )
                       ))
  
  
  final.df <- final.df %>%
    separate(Match, c("Team 1", "Team 2"), " vs ")
  
  #Splitting Match to Provide opponent
  
  final.df$Opponent <- c(ifelse(
    substr(final.df$TeamName, 1, 5) == substr(final.df$`Team 1`, 1, 5),
    final.df$`Team 2`,
    final.df$`Team 1`
  ))
  
  
  
  
  ##Extracting year and series information
  final.df <- final.df %>%
    rowwise() %>%
    separate(`Match.Details`, c("Series", "Venue"), " Venue: ")
  
  final.df$Year <-
    str_sub(final.df$Series, -4, -1)
  final.df$Series <-
    gsub("Series: ", "", as.character(final.df$Series))
  final.df$Series <-
    str_sub(final.df$Series,
            1,
            nchar(final.df$Series) - 5)
  
  final.df <- final.df %>%
    rowwise() %>%
    separate(`Venue`, c("Venue", "DateTime"), " Date & Time: ")
  
  
  
  ##Extracting dates by splitting string, filling Nulls and converting to date
  final.df <- final.df %>%
    rowwise() %>%
    separate(`DateTime`, c("Date", "Time"), ",")
  
  final.df <-   suppressWarnings(final.df %>%
                                   separate(`Date`, c("Start Date", "End Date"), "-"))
  
  final.df <- final.df %>%
    mutate(`End Date` = `End Date`
           %>% is.na
           %>% ifelse(final.df$`Start Date`,
                      final.df$`End Date`))
  
  ##Converting string start and end dates to type date
  
  final.df$StartDate <-
    as.Date(str_c(final.df$`Start Date`, ' ', final.df$Year),
            "%b %d %Y")
  final.df$EndDate <-
    as.Date(str_c(final.df$`End Date`, ' ', final.df$Year),
            "%b %d %Y")
  
  ##Number of days scheduled (Primarily for tests) + 1 added to count end date
  
  final.df$No_Of_Days <-
    
    interval(final.df$StartDate,
             final.df$EndDate) %/% days(1)  +  1
  
  
  #Making Names consistent
  final.df$Names <- gsub("\\(.*?)", "", final.df$Names)
  
  
  #Making teamnames consistent
  final.df$TeamName <-
    gsub("Squad", "", as.character(final.df$TeamName))
  
  ##Removing Unnecessary columns
  final.df <- final.df[-c(4, 5, 8, 9, 10)]
  
  
  return(final.df)
}


#View(processcricbuzzsquadavailability(final.df))