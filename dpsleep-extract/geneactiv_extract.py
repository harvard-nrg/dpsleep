#!/usr/bin/env python

import os
import sys
import pandas as pd
import logging
import argparse as ap
from importlib import import_module

logger = logging.getLogger(os.path.basename(__file__))
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

def main():
    argparser = ap.ArgumentParser('PHOENIX wrapper for GENEActiv extract Pipeline')

    # Input and output parameters
    argparser.add_argument('--phoenix-dir',
        help='Phoenix directory (Default: /ncf/cnl03/PHOENIX/',
        default='/ncf/cnl03/PHOENIX')
    argparser.add_argument('--consent-dir',
        help='Consent directory (Default: /ncf/cnl03/PHOENIX/GENERAL',
        default='/ncf/cnl03/PHOENIX/GENERAL')
    argparser.add_argument('--mtl-dir',
        help='MTL1 directory',
        default='/ncf/nrg/sw/lib/extract/master/')

    argparser.add_argument('--pipeline',
        help='Name of the pipeline to run',
        required=True)
    argparser.add_argument('--data-type',
        help='Data type name (ex. "phone" or "actigraphy")',
        required=True)
    argparser.add_argument('--data-dir',
        help='Data directory name (ex. "GENERAL" or "PROTECTED")',
        required=True)
    argparser.add_argument('--phone-stream',
        help='Required if data-type is "phone" (ex. "surveyAnswers" or "accel")')
    argparser.add_argument('--output-dir',
        help='Path to the output directory')
    argparser.add_argument('--study', 
        nargs='+', help='Study name')
    argparser.add_argument('--subject',
        nargs='+', help='Subject ID')

    # Basic targeting parameters
    argparser.add_argument('--input-tz',
        help='Timezone info for the input. (Default: UTC)',
        default = 'UTC')
    argparser.add_argument('--ext-mode',
        help='Data extraction mode (all, new, specific). (Default: new)',
        default = 'new')
    argparser.add_argument('--ext-date',
        help='Data extraction date when ext-mode is apec. (Default: 2010-00-00)',
        default = '2010-00-00')
    argparser.add_argument('--output-tz',
        help='Timezone info for the output. (Default: America/New_York)',
        default = 'America/New_York')
    argparser.add_argument('--day-from',
        help='Output day from. (optional; Default: 1)',
        type = int, default = 1)
    argparser.add_argument('--day-to',
        help='Output day to. (optional; By default, process data for all days)',
        type = int, default = -1)

    args = argparser.parse_args()

    mod = get_module(args.pipeline)
    default_path = os.path.join(args.phoenix_dir, args.data_dir)

    # Gets all studies under each subdirectory
    studies = args.study if args.study else scan_dir(default_path)
    for study in studies:
        study_path = os.path.join(default_path, study)
        consent_path = os.path.join(args.consent_dir, study, study + '_metadata.csv')
        consents = get_consents(consent_path)
 #       logger.info('metdat path is {mt}.'.format(mt=consent_path))
 #       logger.info('consent is {mt}.'.format(mt=consents))


        # Gets all subjects under the study directory
        subjects = args.subject if args.subject else scan_dir(study_path)
        for subject in subjects:
            subject_path = os.path.join(study_path, subject)
#            logger.info('Subject path path is {mt}.'.format(mt=subject_path))

            verified = verify_subject(subject, subject_path, consents)
            if not verified:
                continue

            logger.info('Processing {S} in {ST}'.format(S=subject, ST=study))
            date_from = consents[subject][0]

            data_path = os.path.join(subject_path, args.data_type, 'raw/GENEActiv')
            output_path = args.output_dir if args.output_dir else os.path.join(subject_path,
                args.data_type,
                'processed')
            if args.data_type == 'phone':
                mod_parser = mod.parse_args()
                new_args, unknown = mod_parser.parse_known_args([
                    '--date-from', str(date_from),
                    '--read-dir', str(data_path),
                    '--filter-dir', "", str(args.phone_stream),
                    '--output-dir', output_path,
                    '--day-from', str(args.day_from),
                    '--day-to', str(args.day_to),
                    '--input-tz', str(args.input_tz),
                    '--output-tz', str(args.output_tz),
                    '--study', str(study),
                    '--subject', str(subject),
                    '--mtl-dir', str(args.mtl_dir)
                ])
                mod.main(new_args)
            else:
                mod_parser = mod.parse_args()
                new_args, unknown = mod_parser.parse_known_args([
                    '--date-from', str(date_from),
                    '--read-dir', str(data_path),
                    '--output-dir', str(output_path),
                    '--day-from', str(args.day_from),
                    '--day-to', str(args.day_to),
                    '--input-tz', str(args.input_tz),
                    '--output-tz', str(args.output_tz),
                    '--study', str(study),
                    '--ext-mode',str(args.ext_mode),
                    '--ext-date',str(args.ext_date),
                    '--subject', str(subject),
                    '--mtl-dir', str(args.mtl_dir)
                ])
                mod.main(new_args)
    return

# Import module based on user input
def get_module(pipeline):
    try:
        return import_module('{P}'.format(P=pipeline), __name__)
    except Exception as e:
        logger.error(e)
        logger.error('Could not import the pipeline module. Exiting')
        sys.exit(1)

# Ensures data can be processed for the subject
def verify_subject(subject, path, consents):
    # Ensures the subject directory is not the consent directory
    if subject.endswith('.csv'):
        logger.error('Subject {S} is not a valid subject.'.format(S=subject))
        return False

    if not os.path.isdir(path):
        logger.error('Path {P} does not exist.'.format(P=path))
        return False

    if not subject in consents:
        logger.error('Consent date does not exist for {S}.'.format(S=subject))
        return False

    return True

# Get consents for the study
def get_consents(path):
    try:
        df = pd.read_csv(path, keep_default_na=False, engine='c', skipinitialspace=True)
#        logger.info('metdat is {mt}.'.format(mt=df))
        df = df.pivot(
            index='Study',
            columns='Subject ID',
            values='Consent'
        ).reset_index()
        
        return df
    except Exception as e:
        logger.info('Check if the metadata has duplicated subject IDs.')
        logger.error(e)
        return None

# Check if a directory is valid, then return its child directories 
def scan_dir(path):
    if os.path.isdir(path):
        try:
            return os.listdir(path)
        except Exception as e:
            logger.error(e)
            return []
    else:
        return []

if __name__ == '__main__':
    main()
