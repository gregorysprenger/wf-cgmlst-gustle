# Gustle Workflow

## Steps in the workflow
1. Run [gustle](https://github.com/supernifty/gustle) to find exact matches for fasta sequences in a genome.

## Requirements
* Nextflow
* Docker or Singularity

## Install
```
git clone https://github.com/gregorysprenger/wf-cgmlst-gustle.git
```

## For Aspen Cluster - Set up Singularity PATH
```
# Add to $HOME/.bashrc
SINGULARITY_BASE=/scicomp/scratch/$USER
export SINGULARITY_TMPDIR=$SINGULARITY_BASE/singularity.tmp
export SINGULARITY_CACHEDIR=$SINGULARITY_BASE/singularity.cache
export NXF_SINGULARITY_CACHEDIR=$SINGULARITY_BASE/singularity.cache
mkdir -pv $SINGULARITY_TMPDIR $SINGULARITY_CACHEDIR
```

Reload .bashrc
```
source ~/.bashrc
```

Load nextflow
```
module load nextflow
```

# Run workflow
Example data are included in example_input directory. Data is from [gustle](https://github.com/supernifty/gustle) repo.

```
nextflow run \
-profile docker main.nf \
    --cgst example_input/test.cgst \
    --query example_input/test_query.fa.gz \
    --genome example_input/test_cgst.fa \
    --outpath results/
```
