include { TRACS_ALIGN } from '../../modules/local/tracs'

workflow TRACS_WORKFLOW {
    take:
    reads // channel: [ val(meta), [ reads ] ]
    database    // path: database

    main:
    TRACS_ALIGN ( reads, database )

    emit:
    tracs_output = TRACS_ALIGN.out.tracs_output // channel: [ val(meta), [ tracs_output ] ]
    versions     = TRACS_ALIGN.out.versions     // channel: [ versions.yml ]
}
