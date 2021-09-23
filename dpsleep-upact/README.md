DPSleep Pipeline Step #7 (upact - Update Sleep Parameters after QC)
=========

## Table of contents
1. [Requirements](#requirements)
2. [Installation](#installation)
3. [Usage examples](#usage-examples)

### Requirements
- Make sure to run the "dpsleep-qcact" pipeline before this step
- Run this step after doing Quality Control on "dpsleep-qcact" results and saving the .csv file with adding "_qcd" to the name
- The output is saved as a .csv file in mtl7 with all sleep parameters

### Installation

To install dpsleep-upact on your system, run the following commands:
```bash
git clone git@github.com:harvard-nrg/dpsleep-upact.git 
cd upact
pip install -r requirements.txt
```

### Usage examples

```bash
# To generate reports under every subject's processed directory in PHOENIX
geneactiv_upact.py --data-type actigraphy --pipeline geneactiv_upact --data-dir GENERAL

# To generate reports for every subject and save them in ~/dp_test1 directory
geneactiv_upact.py --output-dir ~/dp_test1 --data-type actigraphy --pipeline geneactiv_upact --data-dir GENERAL
# or
geneactiv_upact.py --output-dir ~/dp_test1/ --data-type actigraphy --pipeline geneactiv_upact --data-dir GENERAL

# To generate reports for STUDY_A's subject B under ~/dp_test1 directory
geneactiv_upact.py --output-dir ~/dp_test1/ --study STUDY_A --subject B --data-type actigraphy --pipeline geneactiv_upact --data-dir GENERAL

# To generate reports for subject A and subject C in STUDY_PILOT under their processed folders
geneactiv_upact.py --study STUDY_PILOT --subject A C --data-type actigraphy --pipeline geneactiv_upact --data-dir GENERAL

# To generate reports for subject A and subject C in STUDY_PILOT under their processed folders
# Define the PHOENIX, consent and MATLAB directories 
geneactiv_upact.py --study STUDY_PILOT --phoenix-dir /data/PHOENIX --consent-dir /data/PHOENIX/GENERAL --mtl-dir MATLAB_DIRECTORY --subject A C --data-type actigraphy --pipeline geneactiv_upact --data-dir GENERAL
```

#### For more information, please run:
```bash
geneactiv_upact.py -h
```
