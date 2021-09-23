DPSleep Pipeline Step #3 (act - activity scoring and sleep estimation)
=========

## Table of contents
1. [Requirements](#requirements)
2. [Installation](#installation)
2. [Usage examples](#usage-examples)

### Requirements

- Before this Step, make sure to run 'dpsleep-extract' and 'dpsleep-freq'. Folders mtl1 and mtl2 contain daily time data and minute-based frequency spectrum data files.

- This step performs the main analysis on the data that was explained with firgure 2 in the paper including:
    - Watch-off Remove
    - Activity Score Classification -> Outputs color-coded activity score daily map in mtl3 folder STUDY-SUB-geneactiv_mtl3p.png
    - Activity Level Classification  -> Outputs color-coded activity level daily map in mtl3 folder STUDY-SUB-geneactiv_mtl3act.png
    - Sleep and Nap Epochs Estimation -> Outputs Raw Sleep and Nap estimation in mtl3 folder STUDY-SUB-geneactiv_mtl3ss.png

- The output data is saved as a MATLAB file: STUDY-SUB-geneactiv_mtl3.mat

- After this step even if you don't have phone data, run dpsleep-sync. 



### Installation

To install dpsleep-act on your system, run the following commands:
```bash
git clone git@github.com:harvard-nrg/dpsleep-act.git 
cd act
pip install -r requirements.txt
```

### Usage examples

```bash
# To generate reports under every subject's processed directory in PHOENIX
geneactiv_act.py --data-type actigraphy --pipeline geneactiv_act --data-dir GENERAL

# To generate reports for every subject and save them in ~/dp_test1 directory
geneactiv_act.py --output-dir ~/dp_test1 --data-type actigraphy --pipeline geneactiv_act --data-dir GENERAL
# or
geneactiv_act.py --output-dir ~/dp_test1/ --data-type actigraphy --pipeline geneactiv_act --data-dir GENERAL

# To generate reports for STUDY_A's subject B under ~/dp_test1 directory
geneactiv_act.py --output-dir ~/dp_test1/ --study STUDY_A --subject B --data-type actigraphy --pipeline geneactiv_act --data-dir GENERAL

# To generate reports for subject A and subject C in STUDY_PILOT under their processed folders
geneactiv_act.py --study STUDY_PILOT --subject A C --data-type actigraphy --pipeline geneactiv_act --data-dir GENERAL

# To generate reports for subject A and subject C in STUDY_PILOT under their processed folders
# Define the PHOENIX, consent and MATLAB directories 
geneactiv_act.py --study STUDY_PILOT --phoenix-dir /data/PHOENIX --consent-dir /data/PHOENIX/GENERAL --mtl-dir MATLAB_DIRECTORY --subject A C --data-type actigraphy --pipeline geneactiv_act --data-dir GENERAL

```

#### For more information, please run:
```bash
geneactiv_act.py -h
```
