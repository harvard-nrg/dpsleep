# DPSleep Modules

There are six DPLocate modules. They are run in tandem. Their dependencies are:

* MATLAB >= 2017a
* Python >= 3.6
* pandas

# Installation

* Make sure you have the stated MATLAB and Python

* Install Python packages:

      pip install -r requirements.txt

* Finally, clone this repository:

      git clone https://github.com/dptools/dpsleep.git
    
  Individual module scripts are `dpsleep/dpsleep-*/*py`. Learn more about them below.

# DPSleep-extract: Step 1 extract the raw data

## Table of contents

1. [Requirements](#requirements)
2. [Usage](#usage)

## Requirements

- The Raw data is saved as a `.csv` or `.csv.gz` file with the following naming 
  format

```text
STUDTY_left wrist_WATCHID_YYYY-MM-DD hh-mm-ss.csv.gz
```

- The Data has the following format:
    - 100 rows of metadata
    - Actigraphy data from row 101 with the following columns:

```text
YYYY-MM-DD hh:mm:ss:mmm|accel_x(g)|accel_y(g)|accel_z(g)|light(lux)|button(0-1)|temperature(deg.C)
```

- The output directory can be edited. The default is `./processed/mtl1` and the 
  files are saved as `mtl1_YYYY_MM_DD.csv` and `mtl1_YYYY_MM_DD.mat`

- This step is the longest part of the pipeline and it can take hours per 
  subject. Running that in parallel for different subjects of a study is 
  recommended to reduce the execution time.

- After this step run dpsleep-freq pipeline

## Usage

The default is that the pipeline runs for the `new` files. The `--ext_mode` can 
be `[ new, all, specific ]`. If `all`, it runs for all the files in the subject 
folder. If `specific` the files after `--ext_date` argument is analyzed.

```bash
# To generate reports under every subject's processed directory in PHOENIX
geneactiv_extract.py --data-type actigraphy --pipeline geneactiv_extract --data-dir GENERAL

# To generate reports for every subject and save them in ~/dp_test1 directory
geneactiv_extract.py --output-dir ~/dp_test1 --data-type actigraphy --pipeline geneactiv_extract --data-dir GENERAL
# or
geneactiv_extract.py --output-dir ~/dp_test1/ --data-type actigraphy --pipeline geneactiv_extract --data-dir GENERAL

# To generate reports for STUDY_A's subject B under ~/dp_test1 directory
geneactiv_extract.py --output-dir ~/dp_test1/ --study STUDY_A --subject B --data-type actigraphy --pipeline geneactiv_extract --data-dir GENERAL

# To generate reports for subject A and subject C in STUDY_PILOT under their processed folders
geneactiv_extract.py --study STUDY_PILOT --subject A C --data-type actigraphy --pipeline geneactiv_extract --data-dir GENERAL

# To generate reports for subject A and subject C in STUDY_PILOT under their processed folders
# Define the PHOENIX, consent and MATLAB directories 
geneactiv_extract.py --study STUDY_PILOT --phoenix-dir /data/PHOENIX --consent-dir /data/PHOENIX/GENERAL --mtl-dir MATLAB_DIRECTORY --subject A C --data-type actigraphy --pipeline geneactiv_extract --data-dir GENERAL

# To generate reports for subject A and subject C in STUDY_PILOT under their processed folders
# Define the PHOENIX, consent and MATLAB directories 
# Define extract mode and date
geneactiv_extract.py --study STUDY_PILOT --phoenix-dir /data/PHOENIX --consent-dir /data/PHOENIX/GENERAL --mtl-dir MATLAB_DIRECTORY --subject A C --data-type actigraphy --pipeline geneactiv_extract --data-dir GENERAL --ext-mode specific --ext-date YYYY-MM-DD
```

For more information, please run

```bash
geneactiv_extract.py -h
```

#DPSleep-freq: Step 2 frequency analysis
=========

## Table of contents
1. [Requirements](#requirements)
2. [Usage examples](#usage-examples)

### Requirements
- To run the freq pipeline, make sure that you have time files saved in mtl1. To do so, you need to run the dpsleep-extract pipeline first.

- The output is saved as mtl2_YYYY_MM_DD.mat per day.

- After running this pipeline you should run dpsleep-act.
- 

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

# DPSleep-act: Step 3 activity scoring and sleep estimation
=========

## Table of contents
1. [Requirements](#requirements)
2. [Usage examples](#usage-examples)

### Requirements

- Before this Step, make sure to run 'dpsleep-extract' and 'dpsleep-freq'. Folders mtl1 and mtl2 contain daily time data and minute-based frequency spectrum data files.

- This step performs the main analysis on the data that was explained with firgure 1 in the paper including:
    - Watch-off Remove
    - Activity Score Classification -> Outputs color-coded activity score daily map in mtl3 folder STUDY-SUB-geneactiv_mtl3p.png
    - Activity Level Classification  -> Outputs color-coded activity level daily map in mtl3 folder STUDY-SUB-geneactiv_mtl3act.png
    - Sleep and Nap Epochs Estimation -> Outputs Raw Sleep and Nap estimation in mtl3 folder STUDY-SUB-geneactiv_mtl3ss.png

- The output data is saved as a MATLAB file: STUDY-SUB-geneactiv_mtl3.mat

- After this step even if you don't have phone data, go to step 5 and run dpsleep-sync. If you have phone data, you can include those using other phone-related pipelines such as dplocate (skipped step 4).



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

# DPSleep-sync: Step 5 synchronizing the phone and actigraphy data
=========

## Table of contents
1. [Requirements](#requirements)
2. [Usage examples](#usage-examples)

### Requirements

- You can run this step imediately after "dpsleep-act" even without having the phone data. Step 4 is skipped in case you have phone data.

- The output is saved in processed/mtl5

- After this step, you should run dpsleep-qcact pipeline.



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

# DPSleep-qcact: Step 6 build the quality control pdf file
=========

## Table of contents
1. [Requirements](#requirements)
2. [Usage examples](#usage-examples)

### Requirements
- Before this step, make sure to run "dpsleep-sync", "dpsleep-act", and all previous steps. Input to this pipeline is from mtl3 and mtl5

- Output is saved in mtl6 as a pdf file

- After this step, run dpsleep-upact


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

DPSleep-upact: Step 7 update sleep parameters after QC
=========

## Table of contents
1. [Requirements](#requirements)
2. [Usage examples](#usage-examples)

### Requirements
- Make sure to run the "dpsleep-qcact" pipeline before this step
- Run this step after doing Quality Control on "dpsleep-qcact" results and saving the .csv file with adding "_qcd" to the name
- The output is saved as a .csv file in mtl7 with all sleep parameters



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
