#!/bin/bash

#SBATCH --nodes=1          # Number of requested nodes
#SBATCH --ntasks=1          # Number of requested cores
#SBATCH --time=2-11:59:59         # Max walltime
#SBATCH --partition=blanca-curc-gpu
#SBATCH --qos=blanca-curc-gpu
#SBATCH --account=blanca-curc-gpu
#SBATCH --mem=48g
#SBATCH --gres=gpu:1

module purge


source /curc/sw/anaconda3/2020.11/etc/profile.d/conda.sh
conda init bash
source ~/.bashrc

# module load anaconda
conda activate mb

cd "$PWD"
echo "beginning training..."

bash pretrain.sh $1


### #sBATCH --gres=gpu:1