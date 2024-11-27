// param_validation.nf

def validateParameters() {
    def errors = []

    // Check required parameters
    if (!params.input) errors << "Input samplesheet file not specified"
    if (!params.outdir) errors << "Output directory not specified"
    if (!params.database) errors << "Database file not specified"

    // Check file existence
    if (params.input && !file(params.input).exists()) errors << "Input samplesheet file does not exist: ${params.input}"
    if (params.database && !file(params.database).exists()) errors << "Database file does not exist: ${params.database}"

    // Check boolean parameters
    ['skip_fastqc', 'skip_multiqc'].each { param ->
        if (params.containsKey(param) && !(params[param] instanceof Boolean)) {
            errors << "Parameter '$param' must be a boolean (true/false)"
        }
    }

    // Print errors and exit if any
    if (errors) {
        log.error "=== PARAMETER VALIDATION FAILED ==="
        errors.each { log.error it }
        exit 1
    }
}

return this