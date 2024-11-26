#!/usr/bin/env python

import os
import sys
import errno
import argparse


def parse_args(args=None):
    Description = "Reformat nf-core/tracs samplesheet file and check its contents."
    Epilog = "Example usage: python check_samplesheet.py <FILE_IN> <FILE_OUT>"

    parser = argparse.ArgumentParser(description=Description, epilog=Epilog)
    parser.add_argument("FILE_IN", help="Input samplesheet file.")
    parser.add_argument("FILE_OUT", help="Output file.")
    return parser.parse_args(args)


def make_dir(path):
    if len(path) > 0:
        try:
            os.makedirs(path)
        except OSError as exception:
            if exception.errno != errno.EEXIST:
                raise exception


def print_error(error, context='Line', context_str=''):
    error_str = "ERROR: Please check samplesheet -> {}".format(error)
    if context != '' and context_str != '':
        error_str = "ERROR: Please check samplesheet -> {}\n{}: '{}'".format(
            error, context.strip(), context_str.strip()
        )
    print(error_str)
    sys.exit(1)


def check_samplesheet(file_in, file_out):
    """
    This function checks that the samplesheet follows the following structure:

    sample,fastq_1,fastq_2,single_end,platform
    SAMPLE1,/path/to/sample1_R1.fastq.gz,/path/to/sample1_R2.fastq.gz,false,illumina
    SAMPLE2,/path/to/sample2_R1.fastq.gz,/path/to/sample2_R2.fastq.gz,false,illumina
    SAMPLE3,/path/to/sample3.fastq.gz,,true,nanopore

    For an example see:
    https://github.com/nf-core/test-datasets/raw/viralrecon/samplesheet/samplesheet_test_illumina_amplicon.csv
    """

    sample_mapping_dict = {}
    with open(file_in, "r") as fin:
        ## Check header
        MIN_COLS = 5
        HEADER = ['sample', 'fastq_1', 'fastq_2', 'single_end', 'platform']
        header = [x.strip('"') for x in fin.readline().strip().split(',')]
        if header[:len(HEADER)] != HEADER:
            print("ERROR: Please check samplesheet header -> {} != {}".format(','.join(header), ','.join(HEADER)))
            sys.exit(1)

        ## Check sample entries
        for line in fin:
            lspl = [x.strip().strip('"') for x in line.strip().split(',')]

            # Check valid number of columns per row
            if len(lspl) < len(HEADER):
                print_error(
                    "Invalid number of columns (minimum = {})!".format(len(HEADER)),
                    'Line',
                    line
                )

           # num_cols = len([x for x in lspl if x])
           # if num_cols < MIN_COLS:
           #     print_error(
           #         "Invalid number of populated columns (minimum = {})!".format(MIN_COLS),
           #         'Line',
           #         line
           #     )

            ## Check sample name entries
            sample, fastq_1, fastq_2, single_end, platform = lspl[:5]
            if sample:
                if sample.find(' ') != -1:
                    print_error(
                        "Sample entry contains spaces!",
                        'Line',
                        line
                    )
            else:
                print_error(
                    "Sample entry has not been specified!",
                    'Line',
                    line
                )

            ## Check FastQ file extension
            for fastq in [fastq_1, fastq_2]:
                if fastq:
                    if fastq.find(' ') != -1:
                        print_error(
                            "FastQ file contains spaces!",
                            'Line',
                            line
                        )
                    if not fastq.endswith('.fastq.gz') and not fastq.endswith('.fq.gz'):
                        print_error(
                            "FastQ file does not have extension '.fastq.gz' or '.fq.gz'!",
                            'Line',
                            line
                        )

            ## Check single-end/paired-end
            if single_end:
                if single_end.lower() not in ['true', 'false']:
                    print_error(
                        "Single-end parameter is neither 'true' nor 'false'!",
                        'Line',
                        line
                    )
                # Check single-end/paired-end consistency
                if single_end.lower() == 'false' and not fastq_2:
                    print_error(
                        "For paired-end data, FASTQ 2 file must be specified!",
                        'Line',
                        line
                    )
                if not fastq_1 or fastq_2:
                    print_error(
                        "Invalid combination of single-end parameter and FastQ files!",
                        'Line',
                        line
                    )
            else:
                print_error(
                    "Single-end parameter has not been specified!",
                    'Line',
                    line
                )

            ## Check platform
            if platform:
                if platform.lower() not in ['illumina', 'nanopore']:
                    print_error(
                        "Platform must be either 'illumina' or 'nanopore'!",
                        'Line',
                        line
                    )
            else:
                print_error(
                    "Platform has not been specified!",
                    'Line',
                    line
                )

            ## Create sample mapping dictionary = { sample: [ fastq_1, fastq_2, single_end, platform ] }
            if sample not in sample_mapping_dict:
                sample_mapping_dict[sample] = [fastq_1, fastq_2, single_end, platform]
            else:
                if sample_mapping_dict[sample][0] != fastq_1 or \
                    sample_mapping_dict[sample][1] != fastq_2 or \
                    sample_mapping_dict[sample][2] != single_end or \
                    sample_mapping_dict[sample][3] != platform:
                    print_error("Samplesheet contains duplicate rows!", 'Line', line)

    ## Write validated samplesheet with appropriate columns
    if len(sample_mapping_dict) > 0:
        out_dir = os.path.dirname(file_out)
        make_dir(out_dir)
        with open(file_out, "w") as fout:
            fout.write(','.join(['sample', 'fastq_1', 'fastq_2', 'single_end', 'platform']) + '\n')
            for sample in sorted(sample_mapping_dict.keys()):
                fout.write(','.join([sample] + sample_mapping_dict[sample]) + '\n')
    else:
        print_error("No entries to process!", "Samplesheet: {}".format(file_in))


def main(args=None):
    args = parse_args(args)
    check_samplesheet(args.FILE_IN, args.FILE_OUT)


if __name__ == '__main__':
    sys.exit(main())