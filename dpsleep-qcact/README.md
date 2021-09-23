DPSleep Pipeline Step #6 (qcact - build the Quality Control pdf file)
=========

## Table of contents
1. [Requirements](#requirements)
2. [Installation](#installation)
3. [Usage examples](#usage-examples)

### Requirements
- Before this step, make sure to run "dpsleep-sync", "dpsleep-act", and all previous steps. Input to this pipeline is from mtl3 and mtl5

- Output is saved in mtl6 as a pdf file

- After this step, run dpsleep-upact

### Installation

To install dpsleep-qcact pipeline on your system, run the following commands:
```bash
git clone git@github.com:harvard-nrg/dpsleep-qcact.git 
cd qcact
pip install -r requirements.txt
```

### Usage examples

```bash
# To generate reports under every subject's processed directory in PHOENIX
geneactiv_qcact.py --data-type actigraphy --pipeline geneactiv_qcact --data-dir GENERAL

# To generate reports for every subject and save them in ~/dp_test1 directory
geneactiv_qcact.py --output-dir ~/dp_test1 --data-type actigraphy --pipeline geneactiv_qcact --data-dir GENERAL
# or
geneactiv_qcact.py --output-dir ~/dp_test1/ --data-type actigraphy --pipeline geneactiv_qcact --data-dir GENERAL

# To generate reports for STUDY_A's subject B under ~/dp_test1 directory
geneactiv_qcact.py --output-dir ~/dp_test1/ --study STUDY_A --subject B --data-type actigraphy --pipeline geneactiv_qcact --data-dir GENERAL

# To generate reports for subject A and subject C in STUDY_PILOT under their processed folders
geneactiv_qcact.py --study STUDY_PILOT --subject A C --data-type actigraphy --pipeline geneactiv_qcact --data-dir GENERAL


# To generate reports for subject A and subject C in STUDY_PILOT under their processed folders
# Define the PHOENIX, consent and MATLAB directories 
geneactiv_qcact.py --study STUDY_PILOT --phoenix-dir /data/PHOENIX --consent-dir /data/PHOENIX/GENERAL --mtl-dir MATLAB_DIRECTORY --subject A C --data-type actigraphy --pipeline geneactiv_qcact --data-dir GENERAL
```

#### For more information, please run:
```bash
geneactiv_qcact.py -h
```
