process TRACS_ALIGN {
    tag "$meta.id"
    label 'process_medium'

    conda "bioconda::tracs=1.0.1"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/tracs:1.0.1--py312h43eeafb_1' :
        'quay.io/biocontainers/tracs:1.0.1--py312h43eeafb_1' }"

    input:
    tuple val(meta), path(reads)
    path database

    output:
    tuple val(meta), path("*.tracs_output"), emit: tracs_output
    path "versions.yml"                    , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def input_reads = meta.single_end ? reads : reads[0]
    """
    tracs align \\
        $args \\
        --input $input_reads \\
        --database $database \\
        --output ${prefix}.tracs_output

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        tracs: \$(tracs --version 2>&1 | sed 's/^.*tracs //; s/ .*\$//')
    END_VERSIONS
    """
}
