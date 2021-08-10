#!/usr/bin/env nextflow

// run command
// cd $WD; rm work/ -rf; nextflow run nf_simple.local.nf -with-tower --sample 'NF_sample' --project 'NF_project' --datestamp 'NF_DS' --env 'NF_Env'


/*
 * Define some parameters
 */
params.sample = 'NF_sample'
params.project = 'NF_project'
params.datestamp = 'NF_DS'
params.env = 'NF_Env'


/* =======================
VARIABLES
*/

// project_dir = "/home/ec2-user/"


/* =======================
PROCESSES: local
*/

// need to pull the container to dev instance
// sudo docker pull quay.io/biocontainers/samtools:1.13--h8c37831_0

// docker run \
//   --rm -it \
//   -v ~/.aws:/root/.aws \
//   -v $(pwd):/aws \
//   amazon/aws-cli s3 cp s3://jchap-testbucket/nf/NF_sample-NF_project-NF_DS-NF_Env.txt .
  

process download_file {
    
    container 'amazon/aws-cli'
    cpus 1
    executor 'local'
    
    input:
    val sample from params.sample
    val project from params.project
    val datestamp from params.datestamp
    val env from params.env

    output:
    file "${sample}-${project}-${datestamp}-${env}.txt" into sourcefile_channel

    """
    aws s3 cp s3://jchap-testbucket/nf/${sample}-${project}-${datestamp}-${env}.txt .
    """
}


process create_intermediate_file {
    
    container 'biocontainers/samtools'
    cpus 1
    executor 'local'
        
    input:
    val sample from params.sample
    val project from params.project
    val datestamp from params.datestamp
    val env from params.env
    file "${sample}-${project}-${datestamp}-${env}.txt" from sourcefile_channel

    output:
    file "${sample}-${project}-${datestamp}-${env}.intermediate.txt" into intermediate_channel

    """
    echo -e "NF added this intermediate line" > temp.blob.txt
    cat ${sample}-${project}-${datestamp}-${env}.txt temp.blob.txt > ${sample}-${project}-${datestamp}-${env}.intermediate.txt
    """
}


process create_final_file {
    
    container 'biocontainers/samtools'
    cpus 1
    executor 'local'
    
    input:
    file "${sample}-${project}-${datestamp}-${env}.intermediate.txt" from intermediate_channel
    val sample from params.sample
    val project from params.project
    val datestamp from params.datestamp
    val env from params.env
    
    output:
    file "${sample}-${project}-${datestamp}-${env}.modified.txt" into modified_channel

    """
    echo -e "NF added this as the final line" > temp.blob2.txt
    cat ${sample}-${project}-${datestamp}-${env}.intermediate.txt temp.blob2.txt > ${sample}-${project}-${datestamp}-${env}.modified.txt
    """    
}


process upload_results {
    
    container 'amazon/aws-cli'
    cpus 1
    executor 'local'
        
    input:
    val sample from params.sample
    val project from params.project
    val datestamp from params.datestamp
    val env from params.env
    file "${sample}-${project}-${datestamp}-${env}.modified.txt" from modified_channel

    """
    aws s3 cp ${sample}-${project}-${datestamp}-${env}.modified.txt s3://jchap-testbucket/nf/
    """
}

