#!/usr/bin/env python

###########################################################
###########################################################
###### Originally written by Habiballah Rahimi Eichi ######
###########################################################
###########################################################

import os
import sys
import argparse as ap
import logging
import subprocess as sp

logger = logging.getLogger(os.path.basename(__file__))
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

def parse_args():
    argparser = ap.ArgumentParser('sync Pipeline for GENEActiv')

    # Input and output parameters
    argparser.add_argument('--read-dir',
        help='Path to the input directory', required=True)
    argparser.add_argument('--output-dir',
        help='Path to the output directory', required=True)
    argparser.add_argument('--study',
        help='Study name', required=True)
    argparser.add_argument('--subject',
        help='Subject ID', required=True)
    argparser.add_argument('--phoenix-dir',
        help='Phoenix directory', required=True)
    argparser.add_argument('--date-from',
        help='Reference date for day 1', required=True)
    argparser.add_argument('--mtl-dir')

    return argparser

def main(args):
    # expand any ~/ in the directories
    read_dir = os.path.expanduser(args.output_dir)
    output_dir = os.path.expanduser(args.output_dir)

    # perform sanity checks for inputs
    read_dir = check_input(read_dir)
    output_dir = check_output(output_dir)
    if read_dir is None or output_dir is None:
        return

    # logger output
    fh = logging.FileHandler(os.path.join(output_dir, 'sync.log'))
    logger.addHandler(fh)

    # run MATLAB
    run_matlab(read_dir, output_dir, args.study, args.subject, args.date_from, args.mtl_dir,args.phoenix_dir)

# Run MATLAB
def run_matlab(read_dir, output_dir, study, subject, date_from, mtl_dir,phoenix_dir):
    try:
        logger.info('Running matlab')
        matlab_path = "addpath('{matlab_dir}');".format(matlab_dir=mtl_dir)

        sub_cmd = "sync('{READ}','{OUT}','{STUDY}','{SUBJECT}','{DATE_FROM}','{PHOENIX_DIR}')"
        sub_cmd = sub_cmd.format(
            READ=read_dir,
            OUT=output_dir,
            STUDY=study,
            SUBJECT=subject,
            DATE_FROM=date_from,
            PHOENIX_DIR=phoenix_dir
        )
        sub_cmd = wrap_matlab(sub_cmd)

        if mtl_dir:
            sub_cmd = matlab_path + sub_cmd

        cmd = ['matlab', '-nodisplay', '-nosplash', '-r', sub_cmd]
        sp.check_call(cmd, stderr=sp.STDOUT)
    except Exception as e:
        logger.error(e)

def wrap_matlab(cmd):
    return 'try; {0}; catch; err = lasterror; disp(err.message); quit(1); end; quit();'.format(cmd)

# Exit program if the input directory does not exist.
def check_input(read_dir):
    if os.path.exists(read_dir):
        return os.path.join(read_dir, 'mtl3')
    else:
        logger.error('%s does not exist.' % read_dir)
        return None

# Exit program if the output directory does not exist.
def check_output(output_dir):
    if os.path.exists(output_dir):
        output_dir = os.path.join(output_dir, 'mtl5')
        if os.path.exists(output_dir):
            clean_output_dir(output_dir)
            return output_dir
        else:
            try:
                os.mkdir(output_dir)
                return output_dir
            except Exception as e:
                logger.error('Could not create %s' % output_dir)
                return None
    else:
        logger.error('%s does not exist.' % output_dir)
        return None

def clean_output_dir(output_dir):
    logger.warn('Cleaning out output directory %s' % output_dir)
    for root_dir, dirs, files in os.walk(output_dir):
        try:
            for name in files:
                os.remove(os.path.join(root_dir, name))
            for name in dirs:
                os.rmdir(os.path.join(root_dir, name))
        except Exception as e:
            logger.error(e)

if __name__ == '__main__':
    parser = parse_args()
    args = parser.parse_args()
    main(args)
