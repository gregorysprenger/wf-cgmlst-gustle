#!/usr/bin/env nextflow

def helpMessage() {
    log.info"""
    ========================================
            wf-cgmlst-gustle v${version}
    ========================================

    Usage:
    nextflow run -profile docker main.nf --cgst <path/test.cgst> --query <path/test_query.fa.gz> --genome <path/test_cgst.fa> --outpath <results/>

    Parameters:
        --cgst              Path to cgST file.
        --query             Path to queries to index.
        --genome            Path to genomes for genotyping.
        --outpath           Path for output files.

    Profile options:
      -profile singularity  Use Singularity images to run the workflow. Will pull and convert Docker images from Dockerhub if not locally available.
      -profile docker       Use Docker images to run the workflow. Will pull images from Dockerhub if not locally available.

    """.stripIndent()
}

version = "1.0.0"
nextflow.enable.dsl=2

if (params.help) {
    helpMessage()
    exit 0
}

if (params.version) {
    println "VERSION: $version"
    exit 0
}

// Handle inputs
File cgstFileObj = new File(params.cgst)
File queryFileObj = new File(params.query)
File genomeFileObj = new File(params.genome)

if (!(cgstFileObj.exists())) {
    System.err.println "ERROR: $params.cgst does not exist"
    exit 1
}
else if (!(queryFileObj.exists())) {
    System.err.println "ERROR: $params.query does not exist"
    exit 1
}
else if (!(genomeFileObj.exists())) {
    System.err.println "ERROR: $params.genome does not exist"
    exit 1
}


File outpathFileObj = new File(params.outpath)
if (outpathFileObj.exists()) {
    // Per the config file, outpath stores log & trace files so it is created before this point
    // Check that outpath only contains a trace file created this hour
    dayAndHour = new java.util.Date().format('yyyy-MM-dd HH')
    outFiles = outpathFileObj.list()
    if (!(outFiles[0] ==~ /trace.($dayAndHour):\d\d:\d\d.txt/ && outFiles.size() == 1)) {
        // If it contains an older trace file or other files, warn the user
        System.out.println "WARNING: $params.outpath already exists. Output files will be overwritten."
    }
} else {
    outpathFileObj.mkdirs()
}

File logpathFileObj = new File(params.logpath)
if (logpathFileObj.exists()) {
    System.out.println "WARNING: $params.logpath already exists. Log files will be overwritten."
} else {
    logpathFileObj.mkdirs()
}

// Print parameters used
log.info """
    ========================================
            wf-cgmlst-gustle v${version}
    ========================================
    cgST:               ${params.cgst}
    query:              ${params.query}
    genome:             ${params.genome}
    outpath:            ${params.outpath}

    ========================================
    """.stripIndent()


/*
==============================================================================
                 Import local custom modules and subworkflows
==============================================================================
*/

include {
    GUSTLE_INDEX;
    GUSTLE_GENOTYPE;
} from "./modules/gustle.nf"

/*
==============================================================================
                            Run the main workflow
==============================================================================
*/

workflow {

    cgst = Channel.fromPath(params.cgst, checkIfExists: true)
    query = Channel.fromPath(params.query, checkIfExists: true)
    genome = Channel.fromPath(params.genome, checkIfExists: true)


    GUSTLE_INDEX (
        cgst,
        query
    )

    GUSTLE_GENOTYPE (
        GUSTLE_INDEX.out,
        genome
    )

}

/*
==============================================================================
                        Completion summary
==============================================================================
*/

workflow.onComplete {
    log.info """
                |=====================================
                |Pipeline Execution Summary
                |=====================================
                |Workflow Version : ${version}
                |Nextflow Version : ${nextflow.version}
                |Command Line     : ${workflow.commandLine}
                |Resumed          : ${workflow.resume}
                |Completed At     : ${workflow.complete}
                |Duration         : ${workflow.duration}
                |Success          : ${workflow.success}
                |Exit Code        : ${workflow.exitStatus}
                |Launch Dir       : ${workflow.launchDir}
                |=====================================
             """.stripMargin()
}

workflow.onError {
    def err_msg = """
                     |=====================================
                     |Error summary
                     |=====================================
                     |Completed at : ${workflow.complete}
                     |exit status  : ${workflow.exitStatus}
                     |workDir      : ${workflow.workDir}
                     |Error Report :
                     |${workflow.errorReport ?: '-'}
                     |=====================================
                  """.stripMargin()
    log.info err_msg

}