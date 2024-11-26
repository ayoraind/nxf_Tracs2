process FASTQC {
    tag "$meta.id"
    label 'process_medium'

    conda "bioconda::fastqc=0.11.9"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/fastqc:0.11.9--0' :
        'quay.io/biocontainers/fastqc:0.11.9--0' }"

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*.html"), emit: html
    tuple val(meta), path("*.zip") , emit: zip
    path  "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    // Modified symlink creation to avoid conflicts
    def fastq_1 = meta.single_end ? "ln -sf $reads ${prefix}_fastqc.fastq.gz" : "ln -sf ${reads[0]} ${prefix}_1_fastqc.fastq.gz"
    def fastq_2 = meta.single_end ? '' : "ln -sf ${reads[1]} ${prefix}_2_fastqc.fastq.gz"
    """
    $fastq_1
    $fastq_2

    fastqc $args --threads $task.cpus ${prefix}*_fastqc.fastq.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        fastqc: \$( fastqc --version | sed -e "s/FastQC v//g" )
    END_VERSIONS
    """
}
