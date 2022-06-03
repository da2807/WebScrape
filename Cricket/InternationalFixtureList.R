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
library(rvest)
library(dplyr)
library(reshape2)
library(tidyr)
library(tidyverse)
library(tibble)

# fun to get fixture list from each web url
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

#grab team name, default = india, change for other teamname and cricbuzz counter below, these should match as on cricbuzz. To see a full list of team name and counter
#run below code and update accordingly, default teamname = india & cricbuzzteamnumber = 2
#page_teams <- "https://www.cricbuzz.com/cricket-team"
cricbuzz_teaminfo <- read_html(page_teams) %>%
  html_nodes(".cb-team-item-text-inner") %>%
  html_attr("href") %>% data.frame() %>%
  separate(data = ., col = ., into = c("space","cricket-team","teamname", "cricbuzzcounter"), sep = "/") %>% 
  select(teamname,cricbuzzcounter)

teamname <- "india"
cricbuzzteamnumber <- "2"


#grab schedule where matches have happened
finalfixturelist.df <- NULL
link <- paste0("https://www.cricbuzz.com/cricket-team/",teamname,"/",cricbuzzteamnumber,"/results")
page <- read_html(link)

pageinfo <- page %>%
  html_nodes(".cb-text-complete") %>% html_attr("href") %>%
  paste("https://www.cricbuzz.com/", ., sep = "")

pagelinks <-
  gsub("cricket-scores", "live-cricket-scorecard", pageinfo)


for (i in 1:length(pagelinks)){
  cast <- get_cast(pagelinks[i])
  finalfixturelist.df <- rbind(finalfixturelist.df, cast)
}


#grab future list 
link <- paste0("https://www.cricbuzz.com/cricket-team/",teamname,"/",cricbuzzteamnumber,"/schedule")
page <- read_html(link)
pagelinks2 <- page %>%
  html_nodes("#series-matches .cb-ovr-flo") %>% html_nodes("a") %>% 
  html_attr("href") %>%
  paste("https://www.cricbuzz.com/", ., sep = "")

for (i in 1:length(pagelinks2)){
  cast <- get_cast(pagelinks2[i])
  finalfixturelist.df <- rbind(finalfixturelist.df, cast)
}


source("process_cricbuzz_m_internationalfixtures.R")

finalfixturelist_cleaned <- ProcessCricbuzzInternationalCricketFixture(finalfixturelist.df)


save(finalfixturelist.df, file = "IndiaMFixturelist2022.Rda")




