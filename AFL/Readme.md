## Extract AFL Data from footywire.com

* Scripts:  
    + afl_fixtures.R  
    generate fixture and results for the season selected. Note that season =2022 is hardcoded in the script to set up for auto schedule

    + aflgamedata.R  
    generate afl match stats 

    + AFLMatchstats_function.R  
    function to clean up afl fixture dataset

    + AFLPlayerStats_Function.R
    function to clean up afl playerstats dataset 


**Note:**  
View following example data frames to get a sense of the above scripts.  
    + Match Fixtures (2022_matchfixture.Rda)  
    + Player Stats (2022_aflplayerstats.Rda)

### References  

+ [Footywire] (https://www.footywire.com/afl/footy/ft_match_list) 

+ James Day, Robert Nguyen and Oscar Lane (2022). fitzRoy: Easily Scrape and Process AFL Data. R package version 1.1.0.
  https://CRAN.R-project.org/package=fitzRoy  

+ https://analysisofafl.netlify.app/data/2017-06-28-getting-afl-player-data/




