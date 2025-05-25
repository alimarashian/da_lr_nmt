LOGS=/projects/sema4648/mb_fairseq/mbart-bible/logs

sbatch --job-name=$1 --out=$LOGS/$1.out --error=$LOGS/$1.err tr_script_.sh $2 


## $1 : job name
## $2 config file path