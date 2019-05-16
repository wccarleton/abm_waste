# An Agent-Based Model for Evaluating the Waste Hypothesis
## Overview
This repo contains the NetLogo source code and R data analysis scripts for the study presented in the following paper:

*Carleton, McAuley, Costopoulos, and Collard "Agent-based model experiments refute Dunnell’s adaptive waste explanation for cultural elaboration".*

### Abstract
Ancient monuments represent a puzzle from the perspective of evolutionary theory. It is obvious that their construction would have been costly in terms of energy, but it is not clear how they would have enhanced reproductive success. In the late 1980s, the prominent US archaeologist Robert Dunnell proposed a solution to this conundrum. He argued that wasting energy on monuments and other forms of what he dubbed “cultural elaboration” would have conferred a selective advantage in highly variable environments. In the present paper, we report a study in which we used an agent-based model to test the core prediction of Dunnell’s hypothesis. In the model, the agents inherited a propensity to waste and were subjected to selection in low and high variability environments. The results we obtained do not support the hypothesis. We found that the propensity to waste was subject to strong negative selection regardless of the level of environmental variability. At the start of each simulation run, agents wasted 50% of the time on average, but selection drove that rate down by more than a third after the first generation, ultimately settling at 5-7% on average. This casts serious doubt on the ability of Dunnell’s hypothesis to explain instances of cultural elaboration in the archaeological record.

## Software
The R scripts and NetLogo source file contained in this repository are intended for replication efforts and to improve the transparency of our research. They are, of course, provided without warranty or technical support. That said, questions about the code can be directed to Chris Carleton at ccarleton@protonmail.com.

### NetLogo
Netlogo is a freely available Java-based program with a purpose-made programming language (i.e., a *Logo*) for defining agent-based models and running simulations.

To make use of the NetLogo source file, first download the latest version of [NetLogo](https://ccl.northwestern.edu/netlogo/download.shtml).

### R
This model relies on tight integration with R. Thus, you may need to download the latest version of [R](https://www.r-project.org/), and follow [these instructions](https://ccl.northwestern.edu/netlogo/docs/r.html) to use NetLogo's R extension. As per the instructions, you will need to install an R package that provides support for Java. Also note that data may not be exported properly if simulations are run in parallel.

R is used to produce a time series of virtual "climate change" and for exporting simulation results. To export results, run the NetLogo ABM with the export option in the interface turned on. Once a simulation of the model completes, an R data file (with the extension .RData) will be stored in a folder of your choosing (again, an option in the NetLogo interface for the model). Change the path arguments in the R scripts to match your system—--in particular, change the path arguments in the ts_summaries.R script to the path ending in the folder containing the NetLogo .RData file(s).

There are also several R scripts that were used for data analysis in our study. To replicate our analyses, open R, change to the appropriate working directory, and run:

```
source("/PATH/TO/neutral_means.R")
source("/PATH/TO/waste_means.R")
source("/PATH/TO/agent_ages.R")
source("/PATH/TO/dsd_waste.R")
source("/PATH/TO/selectdiff_waste.R")
```

Then run any of the R scripts in the /Plotting folder of this repo. One of the scripts therein will require that the "LapacesDemon" package is loaded because it depends on the dhalfnorm function (half-normal distribution). Another half-normal distribution function would work as well, but the relevant plotting script (halfnorm_selection.R) may require editing to account for different function arguments. 

Note that paths in these scripts may need to be changed depending on your directory tree and the location of the your ABM results. You may also need to edit the scripts to account for different numbers of experiments---we ran 6 experiments for the paper cited above and the R scripts in this repo are all tailored to that protocol.
