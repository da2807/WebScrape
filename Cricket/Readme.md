## Extract Fixture List & Squad Availability

1 - ipl_fixture.R  
Grab season fixtures based on the year selected (default year = 2022). 

2 - ipl_matchavailability.R  
Grab Players available and benched on IPL match day and join with ipl_fixture list. Note for this to function, above is required to run to accomodate for date column. The 2 scripts however, can be made independent (default year = 2022). 

3 - InternationalFixtureList.R  
Script is done for the current year at the moment, however, can be expanded to bring fixture data for previous years.

4 - menssquadavailability.R  
Squad availability for current year international men games are brought in, however, can be expanded to bring data for previous years too. 

**Note:**  
View following example data frames to get a sense of the above scripts.

* IPL  
    + fixturedatav2.Rda
    + IPL2022SquadAvailability.Rda

* International 
    + IndiaMFixturelist2022v2.Rda
    + IndiaMSquadAvailabilityInternational.Rda


**Reference** 
[www.cricbuzz.com]

### Pipeline 
![Pipeline](C:\Users\Aishwar\Desktop\WebScrape\pipeline.png)


