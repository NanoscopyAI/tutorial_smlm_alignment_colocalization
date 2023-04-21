#!/bin/bash

# Copyright (C) 2023 Ben Cardoen
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
# 
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
set -euxo pipefail


if [ ! -d "$DATASET" ]; then
    echo "Dataset directory $DATASET does not exist. Set it by export DATASET=/scratch/$USER/my/data/directory"
    exit 1
fi


NOW=$(date +"%m_%d_%Y_HH%I_%M")
echo "Creating temporary directory tmp_$NOW"
mkdir tmp_$NOW
FILE="recipe.toml"
if test -f "$FILE"; then
    echo "$FILE exists -- not going to download a new recipe"
else
    echo "No recipe found, downloading fresh one"
    wget https://raw.githubusercontent.com/bencardoen/DataCurator.jl/main/example_recipes/coloc_and_align.toml -O recipe.toml    
fi
cp $FILE tmp_$NOW/
cd tmp_$NOW


echo "Configuring singularity"
module load singularity
export SINGULARITY_CACHEDIR="$SLURM_TMPDIR/singularity/cache"
export SINGULARITY_BINDPATH="/scratch/$USER,$SLURM_TMPDIR"
export JULIA_NUM_THREADS="$SLURM_CPUS_PER_TASK"

echo "Downloading required files"
singularity pull --arch amd64 library://bcvcsert/datacurator/datacurator:latest
chmod u+x datacurator_latest.sif

FILE="recipe.toml"
if test -f "$FILE"; then
    echo "$FILE exists -- not going to download a new recipe"
else
    echo "No recipe found, downloading fresh one"
    wget https://raw.githubusercontent.com/bencardoen/DataCurator.jl/main/example_recipes/coloc_and_align.toml -O recipe.toml    
fi

echo "Updating recipe"
sed -i "s|testdir|${DATASET}|" recipe.toml

echo "Running recipe"
./datacurator_latest.sif -r recipe.toml
echo "Done"   
