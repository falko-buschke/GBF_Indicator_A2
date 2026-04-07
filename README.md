## Reporting on the extent of natural ecosystems under the Kunming-Montreal Global Biodiversity Framework
Code and data to replicate the analyses presented in the unpublished manuscript:

* Buschke, F.T. *et al.* (In preparation) Reporting on the extent of natural ecosystems under the Kunming-Montreal Global Biodiversity Framework.

 Accurate as of 04 April 2026. For enquiries, contact `falko.buschke@gmail.com`

 ## Repository structure
 The repository is made up of two code-scripts, two datasets, and a folder with outputs.

 ### Code-scripts
 #### Google Earth Engine processing scripts
 The file `GEE_Script.js` includes the scripts necessary to calcalate the proportion of natural land in each country of the world. Natural land call on the [SBTN Natural Lands Map](https://landcarbonlab.org/data/natural-lands-map/). Earth Engine Asset: `WRI/SBTN/naturalLands/v1_1/2020`

Country boundaries are based on [FAO Global Administrative Unit Layers (GAUL)](https://www.fao.org/hih-geospatial-platform/news/detail/now-available--the-global-administrative-unit-layers-(gaul)-dataset---2024-edition/en). Earth Engine Asset: `FAO/GAUL_SIMPLIFIED_500m/2015/level0`

#### R scripts
A single R-script `ReplicateAnalyses.R` can be used to replicate the anlyses in the manuscript. This includes a script to reproduce all 4 figures, as well as the unity-line regression analysis. 

All outputs are saved to the directory `Figures`.

### Data files
This repository relies on two input datasets:

* `Indicator A2.csv` - a spreadsheet developed by manually screening Parties' 7^th^ National Reports to the Convention on Biological Diversity (CBD), available from the [CBD Online Reprting Tool (ORT)](https://ort.cbd.int/national-reports/nr7). Data are up-to-date as of 31 March 2026.
* `WRI_data.csv` - A cleaned summary spreadsheet for the total extent of natural land in each country. This is the output from the Earth Engine script `GEE_Script.js`, but is augemented to include country ISO3 codes.

### Figures Directory

This directory include examples of the Figures produced as an output from the R-script `ReplicateAnalyses.R'.

#### Figure 1
<img src="https://github.com/falko-buschke/GBF_Indicator_A2/blob/main/Figures/Figure1.png" alt="Fig1" width="600"/>

#### Figure 2
<img src="https://github.com/falko-buschke/GBF_Indicator_A2/blob/main/Figures/Figure2.png" alt="Fig2" width="600"/>

#### Figure 3
<img src="https://github.com/falko-buschke/GBF_Indicator_A2/blob/main/Figures/Figure3.png" alt="Fig3" width="600"/>

#### Figure 4
<img src="https://github.com/falko-buschke/GBF_Indicator_A2/blob/main/Figures/Figure4.png" alt="Fig4" width="600"/>
 
