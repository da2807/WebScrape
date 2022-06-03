### Upload data on _one drive business_ (see ```ipl_matchavailability.R``` under Cricket)

```
#if(!require(Microsoft365R)) install.packages("Microsoft365R")
library(AzureAuth)
library(Microsoft365R)

odb <- get_business_onedrive(tenant="edge10ltd")
#upload folder
foldername <- "ipl_squadavailability"
odb$upload_file(src = paste0("C:\\Users\\Aishwar\\Desktop\\Web Scraping\\",filename), dest = paste0("/",foldername,"/",filename))

```

### Schedule Script to run off a local computer (see ```schedulescript.R``` under Cricket)

``` 
#install.packages("taskscheduleR")
library(taskscheduleR)

taskscheduler_create(
  taskname = "matchavailability103.R",
  rscript = "C:\\Users\\Aishwar\\Desktop\\Web Scraping\\ipl_matchavailability.R",
  schedule = "ONCE",
  starttime = format(Sys.time() + 60, "%H:%M"),
  startdate = format(Sys.Date(), "%d/%m/%Y"),
  Rexe = file.path(Sys.getenv("R_HOME"),"bin","RScript.exe")
)

```