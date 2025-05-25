#!/bin/bash

#SBATCH --nodes=1          # Number of requested nodes
#SBATCH --ntasks=1          # Number of requested cores
#SBATCH --time=2-11:59:59         # Max walltime
#SBATCH --mem=48g
#SBATCH --gres=gpu:1
#SBATCH --partition=blanca-kann
#SBATCH --qos=blanca-kann


module purge


source /curc/sw/anaconda3/2020.11/etc/profile.d/conda.sh # this will depend on your system
conda init bash
source ~/.bashrc

conda activate mb

cd "$PWD"
echo "beginning training..."

bash train.sh $1 