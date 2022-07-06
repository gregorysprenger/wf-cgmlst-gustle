nextflow.enable.dsl = 2


process GUSTLE_INDEX {
    publishDir "${params.outpath}", mode: "copy"
    container "gregorysprenger/gustle@sha256:1dfdf38a8eac159b5f21ba33ea34402bde2d493335378877f796b6b111cb2dfd"

    input:
        path(cgst)
        path(query)

    output:
        file("out.gus")

    script:
        """
        echo "INFO: running gustle index"

        touch out.gus
     
        gustle index \
        --cgst ${params.cgst} \
        --output out.gus \
        ${params.query}

        cat .command.out >> ${params.logpath}/stdout.nextflow.txt
        cat .command.err >> ${params.logpath}/stderr.nextflow.txt

        """
}

process GUSTLE_GENOTYPE {
    publishDir "${params.outpath}", mode: "copy"
    container "gregorysprenger/gustle@sha256:1dfdf38a8eac159b5f21ba33ea34402bde2d493335378877f796b6b111cb2dfd"

    input:
        path("out.gus")
        path(genome)

    output:
        file("summary.tsv")

    script:
        """
        echo "INFO: running gustle genotype"

        touch summary.tsv

        gustle genotype \
        --index $PWD/results/out.gus \
        ${genome} \
        > summary.tsv

        cat .command.out >> ${params.logpath}/stdout.nextflow.txt
        cat .command.err >> ${params.logpath}/stderr.nextflow.txt

        """

}