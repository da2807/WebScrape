#if(!require(Microsoft365R)) install.packages("Microsoft365R")
#if(!require(AzureAuth)) install.packages("AzureAuth")
#if(!require(dplyr)) install.packages("dplyr")
#if(!require(rvest)) install.packages("rvest")
#if(!require(tidyverse)) install.packages("tidyverse")
#if(!require(tidyr)) install.packages("tidyr")

library(rvest)
library(dplyr)
library(reshape2)
library(tidyr)
library(tidyverse)
library(tibble)
library(AzureAuth)
library(Microsoft365R)
library(lubridate)

#data for IPL is extracted year on year, for retrospective data, change var year below. 
year <- 2022
archive_link <- paste0("https://www.cricbuzz.com/cricket-scorecard-archives/",year)
page_ind <- read_html(archive_link) %>%
  html_nodes(".cb-schdl") %>% html_nodes("a") %>%
  html_attr("href") %>% data.frame() %>% 
  separate(data = ., col = ., into = c("space","cricket-team","cricbuzzcounter","tournament","matches"), sep = "/") %>% 
  filter(str_detect(tournament, "indian-premier-league")) %>%
select(cricbuzzcounter,tournament)

# Grab IPL match source link
link <- paste0("https://www.cricbuzz.com/cricket-series/",page_ind[1],"/indian-premier-league-",year,"/matches")
page <- read_html(link)

finalfixturelist.df <- NULL

pageinfo <- page %>%
  html_nodes(".cb-text-complete") %>% html_attr("href") %>%
  paste("https://www.cricbuzz.com/", ., sep = "")

pagelinks <-
  gsub("//cricket-scores/", "//live-cricket-scorecard/", pageinfo)

get_cast <- function(pagelinks){
  #grab fixture details such as date, time, win/loss, location  
  matchinfo <- pagelinks %>% read_html() %>%
    html_nodes(".cb-text-complete , .cb-font-12 , .line-ht24") %>%
    html_text()
  df.matchinfo <-
    data.frame(as.character(matchinfo[3]),
               as.character(matchinfo[4]),
               as.character(matchinfo[5]))
  colnames(df.matchinfo) <-
    c("Series Description", "Match Details", "Result")
  return(df.matchinfo)
  
}

for (i in 1:length(pagelinks)) {
  cast <- get_cast(pagelinks[i])
  finalfixturelist.df <- rbind(finalfixturelist.df, cast)
}

source("process_cricbuzz_ipl_fixtures.R")

ipl_finalfixturelist_clean <- IplFixtureFunction(finalfixturelist.df)

save(ipl_finalfixturelist_clean,file="fixturedata2.Rda")
