library(rvest)
library(dplyr)
library(reshape2)
library(tidyr)
library(tidyverse)
library(tibble)
library(lubridate)


#grab team name, default = india, change for other teamname and cricbuzz counter below, these should match as on cricbuzz. To see a full list of team name and counter
#run below code and update accordingly, default teamname = india & cricbuzzteamnumber = 2

#page_teams <- "https://www.cricbuzz.com/cricket-team"
#cricbuzz_teaminfo <- read_html(page_teams) %>%
#  html_nodes(".cb-team-item-text-inner") %>%
#  html_attr("href") %>% data.frame() %>%
#  separate(data = ., col = ., into = c("space","cricket-team","teamname", "cricbuzzcounter"), sep = "/") %>% 
#  select(teamname,cricbuzzcounter)


teamname <- "india"
cricbuzzteamnumber <- "2"


link <- paste0("https://www.cricbuzz.com/cricket-team/",teamname,"/",cricbuzzteamnumber,"/results")
page <- read_html(link)

#grab all sublinks with the link, these contain match and player level info
pageinfo <- page %>%
  html_nodes(".cb-text-complete") %>% html_attr("href") %>%
  paste("https://www.cricbuzz.com/", ., sep = "")


#substitute cricket-scores with live-cricket-scoreboard as this page sits within the sublinks of pageinfo
pagelinks <-
  gsub("cricket-scores", "live-cricket-scorecard", pageinfo)

#---temporary vars
df.squad_fix_details <- NULL

#df to store final values
final.df <- NULL

#fn to parse through fixture list, extract, playing XI, Bench for India and Opponent Teams
get_cast = function(pagelink) {
  page <- read_html(pagelink)

  f <- NULL                                                              
  p <- 1  
  Squad <- NULL
#Squad List
  Squad <- page %>%
    #   html_nodes(".schedule-date,ng-isolate-scope") %>%
    html_nodes(".cb-minfo-tm-nm") %>%
    html_text()
  
#tempvar to store team availability per match
  u <- as.character(unlist(Squad))

#iterate through the squad twice
  for (z in 1:2) {
    #z<-1
    TeamName <- u[p]
    PlayingXI <- u[p + 1]
    px1t1 <- str_trim(unlist(strsplit(PlayingXI, ",")))
    px1t1[1] <- str_trim(str_replace(px1t1[1], "Playing ", ""))
    px1t1 <- data.frame(px1t1)
    colnames(px1t1) <- "Names"
    px1t1$Availability <- "Playing"
    
    Bench <- u[p + 2]
    bencht1 <- str_trim(unlist(strsplit(Bench, ",")))
    bencht1[1] <- str_trim(str_replace(bencht1[1], "Bench ", ""))
    bencht1 <- data.frame(bencht1)
    colnames(bencht1) <- "Names"
    bencht1$Availability <- "Bench"
    t <- data.frame(TeamName, rbind(px1t1, bencht1))
    f <- rbind(f, t)
    p <- p + 3
  }

#grab fixture details such as date, time, win/loss, location  
  matchinfo <- page %>%
    #   html_nodes(".schedule-date,ng-isolate-scope") %>%
    html_nodes(".cb-text-complete , .cb-font-12 , .line-ht24") %>%
    html_text()
  df.matchinfo <-
    data.frame(as.character(matchinfo[3]),
               as.character(matchinfo[4]),
               as.character(matchinfo[5]))
  colnames(df.matchinfo) <-
    c("Series Description", "Match Details", "Result")
  
  df.squad_fix_details <- data.frame(f, df.matchinfo)
  
  return(df.squad_fix_details)
  
}

#run get cast through the entire fixture list, store result in final.df
for (i in 1:length(pagelinks)) {
  cast <- get_cast(pagelinks[i])
  final.df <- rbind(final.df, cast)
}


source("process_cricbuzz_squadavailability.R")

final.df_cleaned <- NULL
final.df_cleaned <- processcricbuzzsquadavailability(final.df)

#save(final.df, file = "O_AusMSquadAvailabilityInternational.Rda")
#save(final.df_cleaned, file = "P_AusMSquadAvailabilityInternational.Rda")









