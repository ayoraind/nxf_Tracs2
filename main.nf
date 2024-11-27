#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

// log.info "Schema file location: ${params.validationSchemaFile}"

include { TRACS } from './workflows/tracs'

include { validateParameters } from './param_validation'

// Validate input parameters
// Validate input parameters
if (!params.version && !params.help) {
    validateParameters()
}

// Print help message if requested
if (params.help) {
    log.info paramsHelp()
    exit 0
}

// Print version if requested
if (params.version) {
    log.info "TRACS: TAPIR Pipeline version ${workflow.manifest.version}"
    exit 0
}

// Main workflow
workflow {
    TRACS ()
}

def paramsHelp() {
    return """
    TRACS: TAPIR Pipeline for separating strains from mock communities
    ===================================
    Usage:
    nextflow run main.nf --input samplesheet.csv --outdir <OUTDIR> --database <database>

    Mandatory arguments:
        --input                       Path to input samplesheet CSV file
        --outdir                      The output directory where the results will be saved
        --database                    Path to the reference database file used by TRACS

    Optional arguments:
        --multiqc_config              Custom config file for MultiQC
        --multiqc_title               MultiQC report title
        --skip_fastqc                 Skip FastQC
        --skip_multiqc                Skip MultiQC
        --help                        Display this help message
        --version                     Display version information

    For more information, visit https://github.com/ayoraind/nxf_Tracs2
    """
}