DPSleep Pipeline Step #2 (frequency analysis)
=========

## Table of contents
1. [Requirements](#requirements)
2. [Installation](#installation)
2. [Usage examples](#usage-examples)

### Requirements
- To run the freq pipeline, make sure that you have time files saved in mtl1. To do so, you need to run the dpsleep-extract pipeline first.

- The output is saved as mtl2_YYYY_MM_DD.mat per day.

- After running this pipeline you should run dpsleep-act.

### Installation

To install dpsleep-freq on your system, run the following commands:
```bash
git clone git@github.com:harvard-nrg/dpsleep-freq.git 
cd freq
pip install -r requirements.txt
```

### Usage examples

```bash
# The default is that the pipeline runs for the "new" files. The --ext_mode can be [new, all, specific]. If "all" it runs for all the files in the subject folder. If "specific" the files after --ext_date argument is analyzed.

# To generate reports under every subject's processed directory in PHOENIX
geneactiv_freq.py --data-type actigraphy --pipeline geneactiv_freq --data-dir GENERAL

# To generate reports for every subject and save them in ~/dp_test1 directory
geneactiv_freq.py --output-dir ~/dp_test1 --data-type actigraphy --pipeline geneactiv_freq --data-dir GENERAL
# or
geneactiv_freq.py --output-dir ~/dp_test1/ --data-type actigraphy --pipeline geneactiv_freq --data-dir GENERAL

# To generate reports for STUDY_A's subject B under ~/dp_test1 directory
geneactiv_freq.py --output-dir ~/dp_test1/ --study STUDY_A --subject B --data-type actigraphy --pipeline geneactiv_freq --data-dir GENERAL

# To generate reports for subject A and subject C in STUDY_PILOT under their processed folders
geneactiv_freq.py --study STUDY_PILOT --subject A C --data-type actigraphy --pipeline geneactiv_freq --data-dir GENERAL

# To generate reports for subject A and subject C in STUDY_PILOT under their processed folders
# Define the PHOENIX, consent and MATLAB directories 
geneactiv_freq.py --study STUDY_PILOT --phoenix-dir /data/PHOENIX --consent-dir /data/PHOENIX/GENERAL --mtl-dir MATLAB_DIRECTORY --subject A C --data-type actigraphy --pipeline geneactiv_freq --data-dir GENERAL

# To generate reports for subject A and subject C in STUDY_PILOT under their processed folders
# Define the PHOENIX, consent and MATLAB directories 
# Define extract mode and date
geneactiv_freq.py --study STUDY_PILOT --phoenix-dir /data/PHOENIX --consent-dir /data/PHOENIX/GENERAL --mtl-dir MATLAB_DIRECTORY --subject A C --data-type actigraphy --pipeline geneactiv_freq --data-dir GENERAL --ext-mode specific --ext-date YYYY-MM-DD


```

#### For more information, please run:
```bash
geneactiv_freq.py -h
```
