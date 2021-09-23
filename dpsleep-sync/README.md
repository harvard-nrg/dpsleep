DPSleep Pipeline Step #5 (sync - synchronizing the phone and actigraphy data)
=========

## Table of contents
1. [Requirements](#requirements)
2. [Installation](#installation)
3. [Usage examples](#usage-examples)

### Requirements

- You can run this step imediately after "dpsleep-act" step even without having the phone data

- The output is saved in processed/mtl5

- After this step, you should run dpsleep-qcact pipeline.


### Installation

To install dpsleep-sync on your system, run the following commands:
```bash
git clone git@github.com:harvard-nrg/dpsleep-sync.git 
cd sync
pip install -r requirements.txt
```

### Usage examples

```bash
# To generate reports under every subject's processed directory in PHOENIX
geneactiv_sync.py --data-type actigraphy --pipeline geneactiv_sync --data-dir GENERAL

# To generate reports for every subject and save them in ~/dp_test1 directory
geneactiv_sync.py --output-dir ~/dp_test1 --data-type actigraphy --pipeline geneactiv_sync --data-dir GENERAL
# or
geneactiv_sync.py --output-dir ~/dp_test1/ --data-type actigraphy --pipeline geneactiv_sync --data-dir GENERAL

# To generate reports for STUDY_A's subject B under ~/dp_test1 directory
geneactiv_sync.py --output-dir ~/dp_test1/ --study STUDY_A --subject B --data-type actigraphy --pipeline geneactiv_sync --data-dir GENERAL

# To generate reports for subject A and subject C in STUDY_PILOT under their processed folders
geneactiv_sync.py --study STUDY_PILOT --subject A C --data-type actigraphy --pipeline geneactiv_sync --data-dir GENERAL

# To generate reports for subject A and subject C in STUDY_PILOT under their processed folders
# Define the PHOENIX, consent and MATLAB directories 
geneactiv_sync.py --study STUDY_PILOT --phoenix-dir /data/PHOENIX --consent-dir /data/PHOENIX/GENERAL --mtl-dir MATLAB_DIRECTORY --subject A C --data-type actigraphy --pipeline geneactiv_sync --data-dir GENERAL

```

#### For more information, please run:
```bash
geneactiv_sync.py -h
```
