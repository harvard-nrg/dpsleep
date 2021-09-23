# DPSleep Step 1: Extract the raw data

## Table of contents

1. [Requirements](#requirements)
2. [Installation](#installation)
3. [Usage](#usage)

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

## Installation

To install `dpsleep-extract` on your system

```bash
git clone git@github.com:harvard-nrg/dpsleep-extract.git 
cd extract
pip install -r requirements.txt
```

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

