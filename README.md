# TRACS: TAPIR Pipeline for Separating Strains from Mock Communities

## Introduction

TRACS is a bioinformatics pipeline designed for separating strains from mock communities. It utilizes the align submodule of TRACS to analyze sequencing data and provide insights into community composition. Further details on TRACS can be found on the [original author's Github Page](https://github.com/gtonkinhill/tracs).

## Pipeline Summary

1. Read QC ([`FastQC`](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/))
2. TRACS alignment and analysis
3. Present QC for raw reads ([`MultiQC`](http://multiqc.info/))

## Quick Start

1. Install [`Nextflow`](https://www.nextflow.io/docs/latest/getstarted.html#installation) (`>=21.10.3`)

2. Install any of [`Docker`](https://docs.docker.com/engine/installation/), [`Singularity`](https://www.sylabs.io/guides/3.0/user-guide/) (you can follow [this tutorial](https://singularity-tutorial.github.io/01-installation/)), [`Podman`](https://podman.io/), [`Shifter`](https://nersc.gitlab.io/development/shifter/how-to-use/) or [`Charliecloud`](https://hpc.github.io/charliecloud/) for full pipeline reproducibility _(you can use [`Conda`](https://conda.io/miniconda.html) both to install Nextflow itself and also to manage software within pipelines. Please only use it within pipelines as a last resort; see [docs](https://nf-co.re/usage/configuration#basic-configuration-profiles))_.

3. Download the pipeline and test it on a minimal dataset with a single command:

   ```
   nextflow run tracs -profile test,YOURPROFILE --outdir <OUTDIR>
   ```

   Note that some form of configuration will be needed so that Nextflow knows how to fetch the required software. This is usually done in the form of a config profile (YOURPROFILE in the example command above). You can chain multiple config profiles in a comma-separated string.

The pipeline comes with config profiles called docker, singularity, podman, shifter, charliecloud and conda which instruct the pipeline to use the named tool for software management. For example, -profile test,docker.
Please check nf-core/configs to see if a custom config file to run nf-core pipelines already exists for your Institute. If so, you can simply use -profile <institute> in your command. This will enable either docker or singularity and set the appropriate execution settings for your local compute environment.
If you are using singularity, please use the nf-core download command to download images first, before running the pipeline. Setting the NXF_SINGULARITY_CACHEDIR or singularity.cacheDir Nextflow options enables you to store and re-use the images from a central location for future pipeline runs.
If you are using conda, it is highly recommended to use the NXF_CONDA_CACHEDIR or conda.cacheDir settings to store the environments in a central location for future pipeline runs.
Start running your own analysis!

```
nextflow run tracs --input samplesheet.csv --outdir <OUTDIR> --database <database_file>
```

Documentation
The tracs pipeline comes with documentation about the pipeline usage, parameters and output.

Credits
tracs was originally written by The TAPIR team. 
This is an ongoing project at the Microbial Genome Analysis Group, Institute for Infection Prevention and Hospital Epidemiology, Üniversitätsklinikum, Freiburg. The project is funded by BMBF, Germany, and is led by [Dr. Sandra Reuter](https://www.uniklinik-freiburg.de/institute-for-infection-prevention-and-control/microbial-genome-analysis.html).
