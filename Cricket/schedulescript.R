#install.packages("taskscheduleR")
library(taskscheduleR)

#install.packages("miniUI")
#install.packages("shiny")
#install.packages("shinyFiles")
#
#library(miniUI)
#library(shiny)
#library(shinyFiles)


#The script below is meant to run only "once" but the frequency can be adapted, e.g. "DAILY", "MONTHLY" etc. 

taskscheduler_create(
  taskname = "matchavailability103.R",
  rscript = "C:\\Users\\Aishwar\\Desktop\\Web Scraping\\ipl_matchavailability.R",
  schedule = "ONCE",
  starttime = format(Sys.time() + 60, "%H:%M"),
  startdate = format(Sys.Date(), "%d/%m/%Y"),
  Rexe = file.path(Sys.getenv("R_HOME"),"bin","RScript.exe")
)

