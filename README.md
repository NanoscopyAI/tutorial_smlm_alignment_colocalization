# Walkthrough
The below steps allow you to run fiduciual alignment on 2/3D point cloud data, then compute colocalization metrics.

## What this will do for you:
- Given any number of directories with 2 CSV files (from Thunderstorm 2D point cloud data)
- Track their fiducials, if < 400nm apart (center to center)
- Correct temporal drift
- Align the channels
- Compute localization metrics (10)
- Save the output in CSV and image format

### Step 1
Log in to cluster
```bash
ssh you@computecanada.ca
```
You'd see something like this
```
[YOU@cedar5 ~]$
```
Change to `scratch` directory
```bash
cd /scratch/$USER
```
Now it'll show
```bash
[you@cedar5 /scratch/YOU]$
```
### Step 2
Copy your data to a folder under /scratch/$USER, preferably using Globus

### Step 3
Get Compute resources:
Replace `FIXME` with an account ID, which is either `def-yourpiname` or `rrg-yourpiname`. Check ccdb.computecanada.ca, or the output of `groups`.
```bash
salloc --mem=62GB --account=FIXME --cpus-per-task=8 --time=3:00:00
```
Once granted this will look like this:
```bash
salloc --mem=62GB --account=def-hamarneh --cpus-per-task=8 --time=3:00:00
salloc: Pending job allocation 61241941
salloc: job 61241941 queued and waiting for resources
salloc: job 61241941 has been allocated resources
salloc: Granted job allocation 61241941
salloc: Waiting for resource configuration
salloc: Nodes cdr552 are ready for job
[bcardoen@cdr552]$
```
Set the DATASET variable to the name of your dataset
```bash
export DATASET="/scratch/$USER/FIXME"
```
The remainder is done by executing a script, to keep things simple for you
```bash
wget https://raw.githubusercontent.com/NanoscopyAI/tutorial_smlm_alignment_colocalization/main/script.sh
chmod u+x script.sh
```
Execute it
```bash
./script.sh
```
That's it. Your output is now stored in the same folders are your source data. 
This includes, but is not limited to
- Aligned.csv files for point cloud data
- Colocalization images for all implemented metrics

See below for more docs.

### Troubleshooting
See [DataCurator.jl](https://github.com/NanoscopyAI/DataCurator.jl), [SmlmTools](https://github.com/NanoscopyAI/SmlmTools.jl) and [Colocalization](https://github.com/NanoscopyAI/Colcocalization.jl) repositories for documentation.

Create an [issue here](https://github.com/NanoscopyAI/tutorial_smlm_alignment_colocalization/issues/new/choose) with
- Exact error (if any)
- Input
- Expected output

