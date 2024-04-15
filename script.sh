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
# module load apptainer/1.1
module load StdEnv/2020 apptainer/1.1.3
export SINGULARITY_CACHEDIR="/scratch/$USER"
export APPTAINER_CACHEDIR="/scratch/$USER"
export APPTAINER_BINDBATH="/scratch/$USER,$SLURM_TMPDIR"
export SINGULARITY_BINDPATH="/scratch/$USER,$SLURM_TMPDIR"
export JULIA_NUM_THREADS="$SLURM_CPUS_PER_TASK"

echo "Checking if remote lib is available ..."

export LISTED=`apptainer remote list | grep -c SylabsCloud`
# apptainer remote list | grep -q SylabsCloud

if [ $LISTED -eq 1 ]
then
    apptainer remote use SylabsCloud
else
    echo "Not available, adding .."
    apptainer remote add --no-login SylabsCloud cloud.sycloud.io
    apptainer remote use SylabsCloud
fi

echo "Downloading required files"
singularity pull --arch amd64 library://bcvcsert/datacurator/datacurator:nabilab
mv datacurator_nabilab.sif datacurator.sif
chmod u+x datacurator.sif

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
./datacurator.sif -r recipe.toml
echo "Done"   
