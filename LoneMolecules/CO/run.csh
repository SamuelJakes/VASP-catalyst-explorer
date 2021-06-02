#!/bin/csh
#PBS -N CO
#PBS -l mem=8GB
#PBS -o output.txt
#PBS -j oe
#PBS -q cmt
#PBS -l nodes=1:ppn=4
#PBS -l walltime=999:00:00
#PBS -m ea
#PBS -V
#PBS -M sjak6118@uni.sydney.edu.au

cd "$PBS_O_WORKDIR"
module load PBS
module load IntelCompilerSuite

mpirun -n 4 /usr/physics/VASP/vasp
exit
