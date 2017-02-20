task CollectSequencingArtifactMetrics {

    String id
    File bam
    File bamIndex
    File refFasta
    File refFastaIdx
    File refFastaDict
    File DB_SNP_VCF
    File DB_SNP_VCF_IDX

    command <<<
        set -x

        samtools idxstats $BAM

        java -Xmx3600M -jar  /usr/local/bin/picard.1.895.jar CollectSequencingArtifactMetrics \
        DB_SNP=${DB_SNP_VCF} INPUT=${bam} OUTPUT="${id}.sequencing_artifact_metrics.txt"  REFERENCE_SEQUENCE=${refFasta}  MINIMUM_QUALITY_SCORE=20 \
        MINIMUM_MAPPING_QUALITY=30 MINIMUM_INSERT_SIZE=60 MAXIMUM_INSERT_SIZE=600 INCLUDE_UNPAIRED=false \
        TANDEM_READS=false USE_OQ=true CONTEXT_SIZE=1 ASSUME_SORTED=true STOP_AFTER=100000000 VERBOSITY=INFO \
        QUIET=false VALIDATION_STRINGENCY=STRICT COMPRESSION_LEVEL=5 MAX_RECORDS_IN_RAM=500000 CREATE_INDEX=false \
        CREATE_MD5_FILE=false


        >>>

    runtime {
        docker: "broadinstitute/broadmutationcalling_qc_beta"
        memory: "3 GB"
        disks: "local-disk 100 HDD"
        preemptible: 4
    }


    output {
        File SAM_Bait_Detail="${id}.sequencing_artifact_metrics.txt.bait_bias_detail_metrics"
        File SAM_Bait_Summary="${id}.sequencing_artifact_metrics.txt.bait_bias_summary_metrics"
        File SAM_PreAdapter_Detail="${id}.sequencing_artifact_metrics.txt.pre_adapter_detail_metrics"
        File SAM_PreAdapter_Summary="${id}.sequencing_artifact_metrics.txt.pre_adapter_summary_metrics"
    }
}



workflow Picard_SequencingMetrics_Workflow {

    File Bam
    File BamIdx
    File refFasta
    File refFastaIdx
    File refFastaDict
    File DB_SNP_VCF
    File DB_SNP_VCF_IDX


    #Piccard
    call CollectSequencingArtifactMetrics as PicardMetrics {
        input:
            bam=Bam,
            bamIndex=BamIdx,
            refFasta=refFasta,      
            refFastaIdx=refFastaIdx,
            refFastaDict=refFastaDict,  
            DB_SNP_VCF=DB_SNP_VCF,
            DB_SNP_VCF_IDX=DB_SNP_VCF_IDX
        }


}
