
library(tidyr)
library(stringr)
library(dplyr)
library(lubridate)


TeamName <- "India" ##Input team name


ProcessCricbuzzInternationalCricketFixture = function
(df = c(as.factor("Series Description"),
        as.factor("Match Details"),
        as.factor("Result")))
{
  finalfixturelist.df$TeamName <- as.character(TeamName)
  ##Removing Commentary Information
  finalfixturelist.df <- finalfixturelist.df %>%
    separate(`Series Description`, c("fixture", "commentary"), " - ")
  
  finalfixturelist.df <- finalfixturelist.df[-c(2)]
  
  ##Combining Columns to extract consistent format information
  finalfixturelist.df$combined <-
    str_c(finalfixturelist.df$fixture,
          ' ',
          finalfixturelist.df$`Match Details`)
  ##Extracting Format information from combined columns
  finalfixturelist.df <-
    mutate(finalfixturelist.df,
           CricketFormat =
             ifelse(
               grepl("Test", finalfixturelist.df$combined),
               "Test",
               ifelse(
                 grepl("ODI", finalfixturelist.df$combined),
                 "ODI",
                 ifelse(
                   grepl("T20", finalfixturelist.df$combined),
                   "T20",
                   "Warm-Up"
                 )
               )
             ))
  
  
  finalfixturelist.df <- suppressWarnings(finalfixturelist.df %>%
    separate(fixture, c("Match", "format"), ", "))
  
  
  
  finalfixturelist.df <- finalfixturelist.df[-c(2, 6)]
  
  finalfixturelist.df$Home_Away <-     c(ifelse(
    finalfixturelist.df$TeamName ==
    word(finalfixturelist.df$Match, 2, sep = fixed(" vs ")),
    "Away","Home"))

  finalfixturelist.df$Opponent <-     c(ifelse(
    finalfixturelist.df$TeamName ==
      word(finalfixturelist.df$Match, 2, sep = fixed(" vs ")),
      word(finalfixturelist.df$Match, 1, sep = fixed(" vs ")),
      word(finalfixturelist.df$Match, 2, sep = fixed(" vs "))  
    ))


  
  ##Extracting year and series information
  finalfixturelist.df <- finalfixturelist.df %>%
    rowwise() %>%
    separate(`Match Details`, c("Series", "Venue"), " Venue: ")
  
  finalfixturelist.df$Year <-
    str_sub(finalfixturelist.df$Series,-4,-1)
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
  
  finalfixturelist.df <-  suppressWarnings( finalfixturelist.df %>%
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
  
  ##Creating Result and Margin Columns
  
  finalfixturelist.df <- suppressWarnings (finalfixturelist.df %>%
    separate(Result, c("Result", "Margin"), " by "))
  
  finalfixturelist.df <-
    mutate(finalfixturelist.df, Result =
             ifelse(
               grepl("won", finalfixturelist.df$Result),
               "Win",
               ifelse(
                 grepl("Loss", finalfixturelist.df$Result),
                 "Loss",
                 ifelse(grepl("drawn", finalfixturelist.df$Result),
                        "Draw", NA)
               )
             ))
  
  ##Removing Unnecessary columns
  finalfixturelist.df <- finalfixturelist.df[-c(4, 5, 6)]
  
  return(finalfixturelist.df)
  
}

#View(ProcessCricbuzzInternationalCricketFixture(finalfixturelist.df))
