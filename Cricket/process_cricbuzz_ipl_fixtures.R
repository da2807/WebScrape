


library(tidyr)
library(stringr)
library(dplyr)
library(lubridate)

IplFixtureFunction = function(df = c(as.factor("Series Description"),
                                     as.factor("Match Details"),
                                     as.factor("Result"))) {
  ##Adding format columns
  finalfixturelist.df$Format <-
    c("T20")
  
  ##Removing Commentary Information
  finalfixturelist.df <- finalfixturelist.df %>%
    separate(`Series Description`, c("fixture", "commentary"), " - ")
  
  finalfixturelist.df <- finalfixturelist.df[-c(2)]
  
  ##Separating Match and Match number
  finalfixturelist.df <- finalfixturelist.df %>%
    separate(`fixture`, c("Match", "MatchNo"), ", ")
  
  ##Separating Teams
  finalfixturelist.df <- finalfixturelist.df %>%
    separate(`Match`, c("Home Team", "Away Team"), "vs")
  
  ##Separating Result and Margin
  finalfixturelist.df <- finalfixturelist.df %>%
    separate(`Result`, c("Winner", "Margin"), "won by")
  
  ##Extracting year and series information
  
  finalfixturelist.df <- finalfixturelist.df %>%
    rowwise() %>%
    separate(`Match Details`, c("Series", "Venue"), " Venue: ")
  
  finalfixturelist.df$Year <-
    str_sub(finalfixturelist.df$Series, -4, -1)
  finalfixturelist.df$Series <-
    gsub("Series: ", "", as.character(finalfixturelist.df$Series))
  finalfixturelist.df$Series <-
    str_sub(finalfixturelist.df$Series,
            1,
            nchar(finalfixturelist.df$Series) - 5)
  
  finalfixturelist.df <- finalfixturelist.df %>%
    rowwise() %>%
    separate(`Venue`, c("Venue", "DateTime"), " Date & Time: ")
  
  
  
  
  ##Extracting dates by splitting string, filling Nulls and converting to date
  finalfixturelist.df <-   finalfixturelist.df %>%
    separate(`DateTime`, c("Date", "Time"), ",")
  
  finalfixturelist.df <-   suppressWarnings(finalfixturelist.df %>%
    separate(`Date`, c("Start Date", "End Date"), "-"))
  
  finalfixturelist.df <- finalfixturelist.df %>%
    mutate(
      `End Date` = `End Date`
      %>% is.na
      %>% ifelse(
        finalfixturelist.df$`Start Date`,
        finalfixturelist.df$`End Date`
      )
    )
  
  ##Converting string start and end dates to type date
  
  finalfixturelist.df$StartDate <-
    as.Date(str_c(
      finalfixturelist.df$`Start Date`,
      ' ',
      finalfixturelist.df$Year
    ),
    "%b %d %Y")
  finalfixturelist.df$EndDate <-
    as.Date(str_c(
      finalfixturelist.df$`End Date`,
      ' ',
      finalfixturelist.df$Year
    ),
    "%b %d %Y")
  
  ##Number of days scheduled (Primarily for tests) + 1 added to count end date
  
  finalfixturelist.df$No_Of_Days <-
    
    interval(finalfixturelist.df$StartDate,
             finalfixturelist.df$EndDate) %/% days(1)  +  1
  
  finalfixturelist.df$MatchIndex <-
    c(as.numeric(rownames(finalfixturelist.df)))
  
  ##Removing Unnecessary columns
  finalfixturelist.df <- finalfixturelist.df[-c(6, 7, 8)]
  
  return(finalfixturelist.df)
  
}

#View(IplFixtureFunction(finalfixturelist.df))



