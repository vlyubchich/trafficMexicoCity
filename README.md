# Analysis of car accidents in Mexico City

These data and code support the results presented in (recommended citation):

Bailey S, Olivera-Villarroel SM, Lyubchich V (2020) 
Impacts of inclement weather on traffic accidents in Mexico City. 
In: Lyubchich V et al. (Eds) Evaluating Climate Change Impacts.


## Data

The data come come in two major chunks: hourly weather data from several weather stations 
and records of traffic accidents recpsub-hourly 
We load the raw weather data and pre-process by aggregating across stations using the script
**preprocessWeather.R**. The traffic data are loaded and preprocessed and other variables
(*holidays*, *year*, *weekday*, etc.) are created using the script **preprocessOther.R**.
For convenience, we also provide the ouputs of those scripts in the folder **dataderived**, 
so the user can go straight to the next step -- analysis.


## Analysis

