include { INPUT_CHECK } from '../subworkflows/local/input_check'
include { FASTQC     } from '../modules/local/fastqc'
include { MULTIQC    } from '../modules/local/multiqc'
include { TRACS_ALIGN      } from '../modules/local/tracs'


    // Replace the WorkflowTracs.paramsSummaryMultiqc call with this function
def paramsSummaryMultiqc(workflow, summary) {
    def summary_section = ''
    for (group in summary.keySet()) {
        def group_params = summary.get(group)  // This gets the parameters of that particular group
        if (group_params) {
            summary_section += "    <p style=\"font-size:110%\"><b>$group</b></p>\n"
            summary_section += "    <dl class=\"dl-horizontal\">\n"
            for (param in group_params.keySet()) {
                summary_section += "        <dt>$param</dt><dd><samp>${group_params.get(param) ?: '<span style=\"color:#999999;\">N/A</a>'}</samp></dd>\n"
            }
            summary_section += "    </dl>\n"
        }
    }

    String yaml_file_text  = "id: '${workflow.manifest.name.replace('/','-')}-summary'\n"
    yaml_file_text        += "description: ' - this information is collected when the pipeline is started.'\n"
    yaml_file_text        += "section_name: '${workflow.manifest.name} Workflow Summary'\n"
    yaml_file_text        += "section_href: 'https://github.com/${workflow.manifest.name}'\n"
    yaml_file_text        += "plot_type: 'html'\n"
    yaml_file_text        += "data: |\n"
    yaml_file_text        += "${summary_section}"
    return yaml_file_text
}

workflow TRACS {
    main:
    ch_versions = Channel.empty()

    // Define MultiQC config file
    ch_multiqc_config = file("$projectDir/assets/multiqc_config.yaml", checkIfExists: true)
    ch_multiqc_custom_config = params.multiqc_config ? Channel.fromPath( params.multiqc_config ) : Channel.empty()

    // Add more parameter groups as needed
    //
    // SUBWORKFLOW: Read in samplesheet, validate and stage input files
    //
    INPUT_CHECK (
        file(params.input)
    )
    ch_versions = ch_versions.mix(INPUT_CHECK.out.versions)
    
    //
    // MODULE: Run FastQC
    //
    FASTQC (
        INPUT_CHECK.out.reads
    )
    ch_versions = ch_versions.mix(FASTQC.out.versions.first())

    //
    // MODULE: Run TRACS
    //
    TRACS_ALIGN (
        INPUT_CHECK.out.reads,
        file(params.database)
    )
    ch_versions = ch_versions.mix(TRACS_ALIGN.out.versions.first())

    //
    // MODULE: MultiQC
    //


// Define summary_params
    def summary_params = [:]
    summary_params['Input/Output Options'] = [
        input: params.input,
        outdir: params.outdir,
        database: params.database
    ]
    summary_params['Generic Options'] = [
        help: params.help,
        version: params.version
    ]

    // Use the function like this
    workflow_summary = paramsSummaryMultiqc(workflow, summary_params)

    ch_workflow_summary = Channel.value(workflow_summary)

    ch_multiqc_files = Channel.empty()
    ch_multiqc_files = ch_multiqc_files.mix(Channel.from(ch_multiqc_config))
    ch_multiqc_files = ch_multiqc_files.mix(ch_multiqc_custom_config.collect().ifEmpty([]))
    ch_multiqc_files = ch_multiqc_files.mix(ch_workflow_summary.collectFile(name: 'workflow_summary_mqc.yaml'))
    ch_multiqc_files = ch_multiqc_files.mix(FASTQC.out.zip.collect{it[1]}.ifEmpty([]))
    ch_multiqc_files = ch_multiqc_files.mix(TRACS_ALIGN.out.tracs_output.collect{it[1]}.ifEmpty([]))

    MULTIQC (
        ch_multiqc_files.collect()
    )
    multiqc_report = MULTIQC.out.report
    ch_versions    = ch_versions.mix(MULTIQC.out.versions)

    emit:
    multiqc_report = multiqc_report
    versions       = ch_versions
}