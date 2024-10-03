#! /bin/bash

#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --mem=16G
#SBATCH --time=12:00:00 
#SBATCh --job-name=wget_novogene
#SBATCH --partition=cpu-core-sponsored
#SBATCH --mail-type=END 

echo "FASTQ file: $1"
echo "Destination: $2"

fq=$1
dest=$2
mkdir -p $dest

cd $dest

wget -c -r --cut-dirs=2 --no-remove-listing -nH $fq
