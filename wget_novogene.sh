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
cd $dest

wget -r -c $fq
