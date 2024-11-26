#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

// log.info "Schema file location: ${params.validationSchemaFile}"

include { TRACS } from './workflows/tracs'

include { validateParameters; paramsHelp } from 'plugin/nf-validation'

// Validate input parameters
// Validate input parameters
if (!params.version && !params.help) {
    validateParameters()
}

// Print help message if requested
if (params.help) {
    log.info paramsHelp("nextflow run main.nf --input samplesheet.csv --outdir <OUTDIR> --database <database>")
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

