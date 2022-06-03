#if(!require(Microsoft365R)) install.packages("Microsoft365R")
#if(!require(AzureAuth)) install.packages("AzureAuth")
#if(!require(dplyr)) install.packages("dplyr")
#if(!require(rvest)) install.packages("rvest")
#if(!require(tidyverse)) install.packages("tidyverse")
#if(!require(tidyr)) install.packages("tidyr")
#if(!require(stringr)) install.packages("stringr")

library(stringr)
library(XML)
library(rvest)
library(tidyr)
library(dplyr)

start_time <- Sys.time()
#year <- as.integer(readline(prompt = "Enter Year: "))
year <- 2022
footywire_url <-
  paste0("http://www.footywire.com/afl/footy/ft_match_list?year=",
         year)
main.page <- read_html(footywire_url)

urls <-
  main.page %>%                                                             # get main page then we get Result links from main page
  html_nodes(".data:nth-child(5) a") %>%
  html_attr("href")                                                         # extract the urls
#head(urls)


scores<-main.page%>%                                                        
  html_nodes(".data:nth-child(5) a")%>%
  html_text() ## gets us the scores
#head(scores)

team.names<-main.page%>%
  html_nodes(".data:nth-child(2)")%>%
  html_text()
#head(team.names)

fix.dates<-main.page%>%
  html_nodes(".data:nth-child(1)")%>%
  html_text()
#head(fix.dates)

venue<-main.page%>%
  html_nodes(".data:nth-child(3)")%>%
  html_text()
#head(venue)

round<-main.page%>%
  html_nodes(".tbtitle")%>%
  html_text() %>% data.frame()
#head(round)



matchstats <-
  data.frame(scores = scores,
             urls = urls,
             stringsAsFactors = FALSE)
#head(matchstats)

x1<- matchstats%>%
  separate(urls,c("urls","ID"),sep="=")
#head(x1)

default.url <-  "http://www.footywire.com/afl/footy/ft_match_statistics?mid="
basic  <-  data.frame()
for (i in x1$ID) {
  #  i=10544
  print(i)                                                                                  #prints data as it runs so we don't wait till end
  sel.url      <-
    paste(default.url, i, sep = "")                                                         #paste forms the url, try a test case when i=2999 and run and see what happens
  htmlcode     <-
    readLines(sel.url)                                                                      #in the same test case type htmlcode hit enter
  summinfo <- read_html(sel.url) %>%
    html_node(".lnorm") %>% html_text() %>% paste0(collapse = "")
  export.table <-
    readHTMLTable(htmlcode)                                                                 #like the example before, gets all the tables
  top.table    <-
    as.data.frame(export.table[12])                                                         #12 is the top one
  top.table$team <- "home.team"
  bot.table    <-
    as.data.frame(export.table[16])                                                         # 16 is the bottom table
  bot.table$team <- "away.team"
  ind.table    <-
    rbind(top.table, bot.table)                                                             #rbind, binds the top table to the bottom table
  ind.table$RoundNo <- summinfo
  ind.table$MatchId <-
    rep(i, nrow(ind.table))                                                                 #this is adding a match ID which is the unique end of the url
  #  print(summary(ind.table))
  basic  <- rbind(basic, ind.table)
#  if(i %% 9 == 0) {Sys.sleep(5)}
}

basic2 <- basic %>%
  separate(RoundNo, c("Rd", "Venue", "Attendance"), sep = ",")
#print(basic)


if (length(fix.dates) > length(urls)) {
  lengthdiff <- length(fix.dates) - length(urls)
  scores <- c(scores, rep("NA-NA", lengthdiff))
  urls <- c(urls, rep(NA, lengthdiff))
  
}

matchstats <-
  data.frame(
    Team = team.names,
    Scores = scores,
    Date = fix.dates,
    Venue = venue,
 #   RoundNo = round,
    year,
    urls = urls,
    stringsAsFactors = FALSE
  )
#head(matchstats)

x1 <- matchstats %>%
  separate(urls, c("urls", "ID"), sep = "=")
# x1 lets you see what you have just done
x2 <- x1 %>% separate(Team, c("Home", "Away"), sep = "\nv")

# View(x2) another way to see what you have done
x3 <- x2 %>% separate(Scores, c("Home.Score", "Away.Score"), sep = "-")
#head(x2)



afl.stats <- left_join(basic2, x3, by = c("MatchId" = "ID"))

afl.stats_cleaned <- AFL_PlayerStatsFunction(afl.stats)

end_time <- Sys.time()


print(end_time - start_time)



