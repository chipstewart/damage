task damage1 {

    #Inputs and constants defined here
    File input_bam
    File input_bai
    File genome
    File genome_dict
    File genome_index
    String id 
    String preemptible_limit 
    String q="20"
    String Q="10"
    String qualityscore="30"
    String min_coverage_limit="1"
    String max_coverage_limit="500"
    String soft_masked="1"
    String output_disk_gb = "500"
    String boot_disk_gb = "50"
    String ram_gb = "4"
    String cpu_cores = "1"
    command {
python_cmd="
import subprocess,os
def run(cmd):
    subprocess.check_call(cmd,shell=True)

run('ln -sT `pwd` /opt/execution')
run('ln -sT `pwd`/../inputs /opt/inputs')
run('/opt/src/algutil/monitor_start.py')

# start task-specific calls
##########################

run('ln -vs ${genome} ')
run('ln -vs ${genome_dict} ')
run('ln -vs ${genome_index} ')
REFERENCE = os.path.basename('${genome}')    

run('ln -vs ${input_bam} ')
run('ln -vs ${input_bai} ')
BAM = os.path.basename('${input_bam}')    

run('samtools idxstats ' + BAM)

run('perl /opt/src/Damage-estimator/split_mapped_reads.pl --bam '+ BAM +' -genome ' +REFERENCE+ ' -mpileup1 ${id}.pileup1.dat -mpileup2 ${id}.pileup2.dat -Q ${Q} -q ${q}')

run('perl /opt/src/Damage-estimator/estimate_damage.pl -mpileup1 ${id}.pileup1.dat -mpileup2 ${id}.pileup2.dat --id ${id} --qualityscore ${qualityscore} --min_coverage_limit ${min_coverage_limit}  --max_coverage_limit ${max_coverage_limit} --soft_masked ${soft_masked}  > ${id}.damage_estimate.dat ')

run('ls -latrh ')

run('tar cvfz ${id}.damage.tar.gz ${id}.pileup1.dat ${id}.pileup2.dat ${id}.damage_estimate.dat')

run('cat ${id}.damage_estimate.dat ')


#########################
# end task-specific calls
run('/opt/src/algutil/monitor_stop.py')
"
        echo "$python_cmd"
        python -c "$python_cmd"

    }

    output {
        File damage_estimate="${id}.damage_estimate.dat"
        File damage_estimate_tar_gz="${id}.damage.tar.gz"
    }

    runtime {
        docker : "docker.io/chipstewart/damage1_workflow:1"
        memory: "${ram_gb}GB"
        cpu: "${cpu_cores}"
        disks: "local-disk ${output_disk_gb} HDD"
        bootDiskSizeGb: "${boot_disk_gb}"
        preemptible: "${preemptible_limit}"
    }


    meta {
        author : "Chip Stewart"
        email : "stewart@broadinstitute.org"
    }

}

workflow damage1_workflow {
    call damage1
}