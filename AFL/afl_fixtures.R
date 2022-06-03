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



matchstats <-
  data.frame(scores = scores,
             urls = urls,
             stringsAsFactors = FALSE)

x1<- matchstats%>%
  separate(urls,c("urls","ID"),sep="=")

roundno <- data.frame() 
default.url <-  "http://www.footywire.com/afl/footy/ft_match_statistics?mid="
for (i in x1$ID) {
  summinfo <- NULL
#  i=10545
#  print(i)                                                                                  #prints data as it runs so we don't wait till end
  sel.url      <-
    paste(default.url, i, sep = "")                                                         #paste forms the url, try a test case when i=2999 and run and see what happens                                                                     #in the same test case type htmlcode hit enter
  summinfo <- read_html(sel.url) %>%
    html_node(".lnorm") %>% html_text() %>% paste0(collapse = "") %>% data.frame()
  
  rename(summinfo,RoundNo = .)
    roundno  <- rbind(roundno,summinfo)
  #  if(i %% 9 == 0) {Sys.sleep(5)}
}

roundno <-rename(roundno, Roundno = .)
roundno2 <- as.character(unlist(roundno))

if (length(fix.dates) > length(urls)) {
  lengthdiff <- length(fix.dates) - length(urls)
  scores <- c(scores, rep("NA-NA", lengthdiff))
  urls <- c(urls, rep(NA, lengthdiff))
  roundno <- c(roundno2,rep(NA,lengthdiff))
  
}


matchfixtures <-
  data.frame(
    Team = team.names,
    Scores = scores,
    Date = fix.dates,
    Venue = venue,
#    roundno = roundno,
    year,
    urls = urls,
    stringsAsFactors = FALSE
  )



matchfixtures <- matchfixtures %>%
  separate(urls, c("urls", "ID"), sep = "=")
matchfixtures <- matchfixtures %>% separate(Team, c("Home","Away"), sep = "\nv")

# View(x2) another way to see what you have done
matchfixtures <- matchfixtures %>% separate(Scores, c("Home.Score", "Away.Score"), sep = "-")

matchfixtures <- matchfixtures %>%
  separate(roundno, c("Rd", "Venue", "Attendance"), sep = ",")

matchfixtures$Date <- word(matchfixtures$Date, 2, -1)

matchfixtures$Date <-
  as.Date(str_c(substr(matchfixtures$Date, 1, 6), ' ', matchfixtures$year), "%d %b %Y") 

matchfixtures <- matchfixtures %>%
  select(Home, Away, Home.Score, Away.Score, Date, Venue, ID, Rd)

end_time <- Sys.time()

print(end_time - start_time)