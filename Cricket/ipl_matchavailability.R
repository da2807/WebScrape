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

#data for IPL is extracted year on year, for retrospective data, change year to go back in time.
year <- 2021
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

page <- read_html(link)

schedule_results <- page %>%
  html_nodes(".text-hvr-underline span , .ng-binding") %>% html_text() 

out <- data.frame(schedule_results)
out2 <- separate(data = out, col = schedule_results, into = c("Teams", "Match No"), sep = ",")
out3 <- separate(data = out2, col = Teams, into = c("Team1", "Team2"), sep = "vs")

# website has a counter for page, begin at 45886
#https://www.cricbuzz.com/live-cricket-scorecard/45886/csk-vs-kkr-1st-match-indian-premier-league-2022
#https://www.cricbuzz.com/live-cricket-scorecard/45891/dc-vs-mi-2nd-match-indian-premier-league-2022
#https://www.cricbuzz.com/live-cricket-scorecard/45896/pbks-vs-rcb-3rd-match-indian-premier-league-2022
#https://www.cricbuzz.com/live-cricket-scorecard/45901/gt-vs-lsg-4th-match-indian-premier-league-2022

#organising html url according to above, see out3 
out3$Team1caps <-sapply(str_extract_all(out3$Team1, "[A-Z]+"),paste0, collapse = "")
out3$Team2caps <-sapply(str_extract_all(out3$Team2, "[A-Z]+"),paste0, collapse = "")
out3$vs <- paste0(out3$Team1caps,"-vs-",out3$Team2caps)
out3 <- out3%>%
  mutate(matchno = str_replace_all(`Match No`," ","-"))
  

#ct <- 45886                           #website counter begin
out3<- out3[!(out3$Team1=="TBC "),]   #remove matches which haven't happened
k <- dim(out3)[1]                     #total matches to show availability
df<- NULL
df.squadavailable <- NULL
f<-NULL

resultlink<-page %>%
  html_nodes(".cb-text-complete") %>% html_attr("href") %>%
  paste("https://www.cricbuzz.com/", ., sep = "")

resultlink <-
  gsub("//cricket-scores/", "//live-cricket-scorecard/", resultlink)

resultlink <-
  gsub("//live-cricket-scores/", "//live-cricket-scorecard/", resultlink)

for (j in 1:length(resultlink)) {
    
  
#    print(out3$vs[j])
  
    p<-1                #parse through squad
                
    f<-NULL             #tempvar to store team availability per match
    
    
    
#    resultlink <-
#            paste0("https://www.cricbuzz.com/live-cricket-scorecard/",ct,"/",out3$vs[j],out3$matchno[j],"-indian-premier-league-2022")
                 
#print(resultlink)
#j<-3
    page <- read_html(resultlink[j])
                 
    Squad <- page %>%
              html_nodes(".cb-minfo-tm-nm") %>% html_text()
    
    Result <- page %>%
      html_nodes(".cb-text-complete") %>% html_text()
                 
    u <- as.character(unlist(Squad))
                 
                
                         for (z in 1:2){
                                         
                          #z<-1
                           TeamName <- u[p]
                                         PlayingXI <-u[p+1]
                                         px1t1 <- str_trim(unlist(strsplit(PlayingXI, ",")))
                                         px1t1[1] <- str_trim(str_replace(px1t1[1],"Playing ",""))
                                         px1t1 <- data.frame(px1t1)
                                         colnames(px1t1)<- "Names"
                                         px1t1$Availability<- "Playing"
                                         
                                         Bench <- u[p+2]
                                         bencht1 <- str_trim(unlist(strsplit(Bench, ",")))
                                         bencht1[1] <- str_trim(str_replace(bencht1[1],"Bench ",""))
                                         bencht1 <- data.frame(bencht1)
                                         colnames(bencht1)<- "Names"
                                         bencht1$Availability<- "Bench"
                                         t <- data.frame(TeamName,rbind(px1t1,bencht1))
                                         f<- rbind(f,t)
                                         p<- p + 3
                                       }

                ntimes <- as.character(replicate(dim(f)[1],out3$`Match No`[j]))
                f<- data.frame(f,ntimes,Result)
                df<-rbind(df,f)
        
#                ct <- ct + 5        #website counter

                }

df<- na.omit(df)

df$MatchIndex <- as.numeric(gsub(".*?([0-9]+).*", "\\1", df$ntimes))  
df$ntimesnospace <- gsub(" ", "", df$ntimes, fixed = TRUE)

#source("process_cricbuzz_ipl_squadavailability.R")

load("C:/Users/Aishwar/Desktop/Web Scraping/fixturedata2.Rda")
ipl_finalfixturelist_clean$MatchNonospace <- gsub(" ","",ipl_finalfixturelist_clean$MatchNo,fixed = TRUE)

dffinal<- left_join(df,ipl_finalfixturelist_clean, by = c("ntimesnospace" = "MatchNonospace"))
drop.cols <- c("MatchIndex.x", "MatchIndex.y","ntimesnospace", "ntimes")
dffinal <- dffinal %>% select(-all_of(drop.cols))

dffinal$Names <- gsub("\\(.*?)", "", dffinal$Names)

filename <- paste0("IPLSquadAvailability.csv")
write.csv(dffinal,paste0("C:\\Users\\Aishwar\\Desktop\\Web Scraping\\",filename))
print(dffinal$Year)

#one drive business
odb <- get_business_onedrive(tenant="edge10ltd")
#upload folder
foldername <- "ipl_squadavailability"
odb$upload_file(src = paste0("C:\\Users\\Aishwar\\Desktop\\Web Scraping\\",filename), dest = paste0("/",foldername,"/",filename))





















