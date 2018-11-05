# An Agent-Based Model for Evaluating the Waste Hypothesis
## Overview
This repo contains the NetLogo source code and R data analysis scripts for the study presented in the following paper:

[*Carleton, McAuley, Costopoulos, and Collard (In Prep) "An evolutionary agent-based model contradicts Dunnell’s waste hypothesis for cultural elaboration"*](https://osf.io/nrcgp/)

### Abstract
Ancient monuments represent a puzzle from the perspective of evolutionary theory. It is clear that they would have been energetically expensive to construct but they are not easy to explain in terms of reproductive success. In the late 1980s, Robert Dunnell argued that these and other cases of what he called cultural elaboration actually conferred a fitness advantage in highly variable environments. Here, we report a study in which we tested the key predictions of Dunnell’s hypothesis with an agent-based model. In the model, the agents inherited wasting behaviour and were subjected to selective pressure from a variable environment. The results we obtained run counter to the hypothesis. We found that the propensity for waste was strongly selected against by environmental variability. At the start of each experiment agents were likely to waste 50% of the time on average, but selection drove that rate down to around 10% and would have eliminated waste entirely if not for random mutations that produced wasting behaviour. This suggests that wasting does not provide an adaptive advantage in highly variable environments in the manner that Dunnell proposed.

## Software
The R scripts and NetLogo source file contained in this repository are intended for replication efforts and to improve the transparency of our research. They are, of course, provided without warranty or technical support. That said, questions about the code can be directed to Chris Carleton at w.ccarleton@gmail.com.

### NetLogo
Netlogo is a freely available Java-based program with a purpose-made programming language (i.e., a *Logo*) for defining agent-based models and running simulations.

To make use of the NetLogo source file, first download the latest version of [NetLogo](https://ccl.northwestern.edu/netlogo/download.shtml).

### R
There are several R scripts that were used for data analysis in our study. To make use of them, first download the latest version of [R](https://www.r-project.org/). Then, run the NetLogo ABM with the export option in the interface turned on. Once a simulation of the model completes, an R data file (with the extension .RData) will be stored in a folder of your choosing (again, an option in the NetLogo interface for the model). Change the path arguments in the R scripts to match your system—--in particular, change the path arguments in the ts_summaries.R script to the path ending in the folder containing the NetLogo .RData file(s). Then, open R, change to the appropriate working directory, and run:

```
library(fitdistrplus)
source("/PATH/TO/MLEFits.R")
source("/PATH/TO/cbindna.R")
source("/PATH/TO/ts_summaries.R")
```

You can also confirm our t-test results by calling the scripts, `pairwise_sd.R` and `pairwiset_mean_waste_prob.R`.
