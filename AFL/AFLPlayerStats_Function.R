
AFL_PlayerStatsFunction = function(afl.stats){
#Removing Null from column names
names(afl.stats) = gsub(pattern= "NULL.", replacement = "", x = names(afl.stats))

#Cleaning date column in right format
afl.stats$Date <- word(afl.stats$Date, 2, -1)

afl.stats$Date <-
  as.Date(str_c(substr(afl.stats$Date, 1, 6), ' ', afl.stats$year), "%d %b %Y") 

##Removing Unnecessary columns
afl.stats <- afl.stats[-c(29)]
return(afl.stats)
}

#AFL_PlayerStatsFunction(afl.stats)


