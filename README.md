# Pedal Poll / Sondo Vélo 2021-2024 analysis

This repo contains the code and documentation for analysis of the 2022-2024 Pedal Poll / Sondo Vélo data. 

A preprint of 2021-2024 analysis paper can be found [here](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=5331432).

The 2021 results can be found [here](https://velocanadabikes.org/pedalpoll/pedal-poll-sondo-velo-2021-results/) and the associated academic paper is [here](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=4000804).

## Cleaning and analysis steps:

### Data

This repository contains all raw data from Pedal Poll used in the analysis. The following external datasets are also required to reproduce the analysis:
1. Pedal Poll 2021 cleaned data. In all scripts this data is loaded directly from the online version, which can be found [here](https://velocanadabikes.org/wp-content/uploads/2022/Pedal%20Poll%202021%20Data%20UPLOAD.csv).
2. Spatial Access Measures: a database of accessibility to destinations produced by Statistics Canada. The file can be found [here](https://www150.statcan.gc.ca/n1/pub/27-26-0001/2023001/sam-msa-eng.zip).
3. 2021 census dissemination block boundary file: this is used to assign count locations to dissemination blocks to match with Spatial Access Measures data. The file can be found [here](https://www12.statcan.gc.ca/census-recensement/2021/geo/sip-pis/boundary-limites/files-fichiers/ldb_000a21a_e.zip).

Index of files:
- `20XX_data_dictionary.csv`: data dictionary for cleaned data files produced from `data_cleaning_2022.ipynb` and `data_cleaning.ipynb`. Because the 2022 data is formatted like the 2021 data and has a different format from 2023 and 2024, there are two data dictionaries. 
- `20XX_hand_count.csv`: paper count data from 2022, 2023, and 2024.
- `20240916_153200.csv`: raw CounterPoint app data from 2023, downloaded with [this query](https://superset.counterpointapp.org/superset/explore/p/Nk5eQpXYOZR/).
- `20250624_142657.csv`: raw CounterPoint app data from 2024, downloaded with [this query](https://superset.counterpointapp.org/superset/dashboard/p/Bb80wKA0kl3/).
- `CounterPoint Data Explorer - Bicycle Demographics Submission Data_Page 1_Table.csv`: raw CounterPoint app data from 2022, downloaded with the now-replaced CounterPoint data explorer.
- `Official Count Locations IDs.csv`: list of official 2021 focus community count sites, used only to preferentially label grouped CounterPoint IDs where possible.
- `counterpoint_official_sites_multiyear_counts-CanBICS-v2_sheet1.csv`: unique counterpoints classified after 2023 count.
- `PP_CounterPoints_Cycle_Facilities_FULL_02JAN2025.csv`: list of unique CounterPoints and classified Can-BICS infrastructure in each count year.
- `brampton_2023_paper.csv`: additional 2023 paper count data from Brampton.
- `cma_population_2021.csv`: uPsed to determine community population sizes for Discussion. Processed file created from 2021 census data downloaded on 2025-03-03 from https://www12.statcan.gc.ca/census-recensement/2021/dp-pd/prof/index.cfm?Lang=E
- `hand_count_2022_unique_counterpoints_filled.csv`: 2022 paper count data with CounterPoint IDs manually filled in where possible.

### Scripts

The following scripts run in this order reproduce the analysis and figures for the [paper](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=5331432).

1. `data_cleaning_2022.ipynb` and `data_cleaning.ipynb`: scripts to clean data for 2022 and 2023/2024.
2. `counterpoint_location_grouping.ipynb`: group CounterPoint pins within 100 m to better compare counts over multiple years.
3. `Can-BICS_classification.ipynb`: sort CounterPoint locations for classification by hand with Can-BICS.
4. `analysis_processing.ipynb`: load all years of cleaned datasets and group counts by count session, calculate bikes per hour.
5. `regression_model.ipynb`: add Spatial Access Measures data and process data for regression model.
6. `regression.R`: run regression model and calculate confidence intervals.
7. `paper_figures.ipynb`: produce figures and tables for paper.
