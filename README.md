# Analysis of car accidents in Mexico City

These data and code support the results presented in (recommended citation):

Bailey S, Olivera-Villarroel SM, Lyubchich V (2020) 
Impacts of inclement weather on traffic accidents in Mexico City.
Ch 14 in V Lyubchich et al. (eds.) *Evaluating Climate Change Impacts*, p 307--324. Boca Raton, FL: CRC Press.  
https://doi.org/10.1201/9781351190831-14


## Data

The data come in two major parts: hourly weather data from several weather stations 
and records of traffic accidents, where times of the accidents are usually rounded to the 
nearest 5 minutes. All source data files are in the folder **dataraw**. 
The scripts for data pre-processing:

* **preprocessWeather.R** to load the raw weather data and aggregate across stations;
* **preprocessOther.R** to load and pre-process traffic data and to create other variables
(*holiday*, *year*, *weekday*, etc.);
* **preprocessBoth.R** to merge the traffic and weather data in two major tables (hourly and daily).

For convenience, the outputs of these scripts are already provided in the folder **dataderived**, 
so the user can go straight to the next step -- analysis.


## Analysis

The analysis is written in a knitr file **MexAnalysis.Rnw** and is structured into sections
corresponding to sections of the chapter cited above. For convenience, 
the compiled output **MexAnalysis.PDF** is also provided.


## Citation

Bibtex entry for the book chapter:

```
@incollection{Bailey:etal:2020:impacts,
   author = {Bailey, S and Olivera-Villarroel, S M and Lyubchich, V},
   title = {Impacts of inclement weather on traffic accidents in {Mexico City}},
   booktitle = {Evaluating Climate Change Impacts},
   editor = {Lyubchich, V and Gel, Y R and Kilbourne, K H and Miller, T J and Newlands, N K and Smith, A B},
   pages = {307--324},
   year = {2020},
   address = {Boca Raton, FL, USA},
   publisher = {CRC Press}
}
```

The data and code release:

```
@software{lyubchich_3723688,
  author = {Lyubchich, V and Bailey, S and Olivera-Villarroel, S M},
  title = {{github.com/vlyubchich/trafficMexicoCity: Analysis of car accidents in Mexico City}},
  year = 2020,
  publisher = {Zenodo},
  version = {v1.0},
  doi = {10.5281/zenodo.3723688},
  url = {https://doi.org/10.5281/zenodo.3723688}
}
```
