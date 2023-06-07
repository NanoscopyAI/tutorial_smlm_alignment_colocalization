
## Table of Contents

0. [What this will do for you](#quickstart)
2. [Walkthrough](#walk)
    1. [Login](#login)
    2. [Copy data](#data)
    3. [Run analysis](#exec)
    4. [Optional -- change parameters](#optional)
3. [Output files](#outputfiles)
4. [Collecting output](#collecting) 
5. [Troubleshooting](#faq)
6. [Parameters](#param)


<a name="quickstart"></a>
## What this will do for you:
- Given any number of directories with 2 CSV files (from Thunderstorm 2D point cloud data)
- Detect fiducials, by looking for peaks in emissions. Fiducials in SMLM continuously emit, so treating the emissions as a distributions we can select the local maxima (set to top 2 now).
- Pair the fiducials across the channels
- If the closest pair is > 400nm apart
  - Abort
- Track their fiducials, if < 400nm apart (center to center)
- Correct temporal drift
- Align the channels
- Compute localization metrics (10)
- Save the output in CSV and image format

Correction is done by a linear translation in 3D using euclidean distance.


<a name="walk"></a>
## Walkthrough
The below steps allow you to run fiduciual alignment on 2/3D point cloud data, then compute colocalization metrics.


<a name="login"></a>
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
Create a new directory, to make sure existing files do not clash:
```
mkdir -p testexperiment
cd testexperiment
```

<a name="data"></a>
### Step 2 Copy your data to the cluster
Copy your data to a folder under /scratch/$USER, preferably using [Globus](https://globus.computecanada.ca/)

<a name="exec"></a>
### Step 3 Run analysis
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

**NOTE** Please make sure your dataset is organized like so:
```
yourdatasetdirectory
  --cell1
    --file1.csv
    --file2.csv
  --cell2
    -- ...
```
You are free to choose the dataset directory naming, as well and the 'cell1' and 'cell2' directories (or even have just 1 subdirectory), but the data is expected to be nested.

The remainder is done by executing a script, to keep things simple for you.
This script assumes you want to process dStorm data in CSV format, output by Thunderstorm.
```bash
wget https://raw.githubusercontent.com/NanoscopyAI/tutorial_smlm_alignment_colocalization/main/script.sh -O script.sh && chmod u+x script.sh
```
For GSD data (bin, ascii).
```bash
wget https://raw.githubusercontent.com/NanoscopyAI/tutorial_smlm_alignment_colocalization/main/script_lydia.sh -O script.sh && chmod u+x script.sh
```
Make it executable
```bash
chmod u+x script.sh
```

<a name="optional"></a>
#### 3.1 -- OPTIONAL, if you want to change parameters for processing
**OPTIONAL NOTE** Processing uses `recipes`, text files that describe in plain language what should be done. 
If you do not have a recipe, it will be downloaded for you. 
However, **if you want to change parameters**, save a `recipe.toml` file in your current directory, and the script will skip downloading a new one.
For example:
##### Download the thunderstorm recipe
```bash
  wget https://raw.githubusercontent.com/bencardoen/DataCurator.jl/main/example_recipes/coloc_and_align.toml -O recipe.toml    
```
##### Change the recipe
Change the filtering and fiducial parameters (you can use a text editor such as [Nano, which is preinstalled](https://linuxize.com/post/how-to-use-nano-text-editor/)
Example recipes can be found [here](https://github.com/bencardoen/DataCurator.jl/blob/main/example_recipes/coloc_and_align.toml)
You'd change this line
```toml
actions=[["smlm_alignment",".csv", "is_thunderstorm", 500, 5], ["image_colocalization", 3, "C[1,2].tif", "is_2d_img", "filter", 1]]
```
to now detect up to **10** fiducials, and be a lot more stringent in filtering before colocalization. Also, you want a 5x5 window, not 3x3. You're ok with fiducials being a bit further apart as well (600).
Edit the recipe so that it reads like this:
**do not run this line, change the recipe so it looks like this**
```toml
actions=[["smlm_alignment",".csv", "is_thunderstorm", 600, 10], ["image_colocalization", 5, "C[1,2].tif", "is_2d_img", "filter", 2]]
```
**Note** Make sure the inputdirectory field is set to **testdir**, the script will automatically update it with your dataset.

You can use commands like `nano recipe.toml` to open an editor and modify a file.

<a name="run"></a>
#### 3.2 Execute the script
```bash
./script.sh
```
That's it. Your output is now stored in the same folders as your source data.
At the end you'll see something like
```bash
 Info: 2023-02-27 06:14:21 curator.jl:180: Complete with exit status proceed
+ echo Done
Done
[you@cdrxyz scratch]$ 
```

<a name="outputfiles"></a>
### Output files
Per processed directory where 2 localization files were found, the following will be produced: (1 and 2 refer to the CSV channels in order or appearance)

**Files are prefixed with the original filename**: so "1p.csv" --> "1p_aligned_c1.csv"

- 1_segmentation_mask.tif: Segmentation mask for channel 1
- 2_segmentation_mask.tif: Segmentation mask for channel 2
- aligned_c1.csv: channel 1 point cloud after tracking and alignment         
- aligned_c2.csv: channel 2 point cloud after tracking and alignment
- C1.tif: projection image of channel 1 aligned point cloud (binned localizations per pixel)                       
- C1_distance_to_C2.tif: Distance, for each object in C1, to nearest in C2. The distance is rescaled so it can be saved in the image (8bit), so a distance of 2 = 2/(256) = 0.0078125 **note**
- C1_notaligned.tif: projection image of channel 1 unaligned point cloud (binned localizations per pixel)  
- C2.tif: : projection image of channel 1 aligned point cloud (binned localizations per pixel)           
- C2_distance_to_C1.tif: Distance, for each object in C2, to nearest in C1. The distance is rescaled so it can be saved in the image (8bit), so a distance of 2 = 2/(256) = 0.0078125
- C2_notaligned.tif
- colocalization.csv:  Summarized (mean/metric/cell) colocalization metrics
- colocalization_per_object.csv : Contains 1 line, per channel, per object, with the size, mean/std intensity, distance to nearest object in other channel, and overlap (if any)
#### 1 Tif per colocalization metric
- haussdorff_max.tif    
- haussdorff_mean.tif
- jaccard.tif
- m1.tif
- m2.tif
- manders.tif
- pearson.tif
- sorensen.tif
- spearman.tif

**Note** in the distance map, objects with distance 0, that overlap, will have a token value of 0.1 / 256, so that they still are different from background

For each execution, temporary output is saved in the directory `tmp_{DATE}`.

See below for more docs.


<a name="collecting"></a>
### Collecting output
You can use DataCurator to collect all colocalization csv files, and concatenate them into 1. 
```bash
salloc --mem=62GB --account=FIXME --cpus-per-task=8 --time=3:00:00
```
Once you have the compute node
```
module load singularity
export SINGULARITY_CACHEDIR="$SLURM_TMPDIR/singularity/cache"
export SINGULARITY_BINDPATH="/scratch/$USER,$SLURM_TMPDIR"
export JULIA_NUM_THREADS="$SLURM_CPUS_PER_TASK"
```
If you need to download datacurator, you can do so, otherwise skip
```bash
echo "Downloading required files"
singularity pull --arch amd64 library://bcvcsert/datacurator/datacurator:nabilab
mv datacurator_nabilab.sif datacurator.sif
chmod u+x datacurator.sif

```
Download the recipe
```bash
FILE="recipe.toml"
if test -f "$FILE"; then
    echo "$FILE exists -- not going to download a new recipe"
else
    echo "No recipe found, downloading fresh one"
    wget https://raw.githubusercontent.com/bencardoen/DataCurator.jl/specht/example_recipes/aggregatecolocresults.toml -O recipe.toml 
fi
```
Execute
```bash
./datacurator.sif -r recipe.toml --inputdirectory "where/your/data/is/stored"
```
A file `all_coloc_results.csv` will be saved in the current directory, containing all results.

See [tips](https://github.com/NanoscopyAI/cluster-tips) for tips on compressing data

<a name="faq"></a>
### Troubleshooting
See [DataCurator.jl](https://github.com/NanoscopyAI/DataCurator.jl), [SmlmTools](https://github.com/NanoscopyAI/SmlmTools.jl) and [Colocalization](https://github.com/NanoscopyAI/Colcocalization.jl) repositories for documentation.

#### Possible errors
##### File not found errors
- this occurs if you ask to look for csv files, but the files are of .bin format. Or if there are more than 2 files, or less than two files in the folder.
##### Fiducials too far apart
- You'll see a message "nearest pair = .... nm", if this exceeds 500nm (default center to center distance), the code will refuse to align.

Create an [issue here](https://github.com/NanoscopyAI/tutorial_smlm_alignment_colocalization/issues/new/choose) with
- Exact error (if any)
- Input
- Expected output


<a name="quickstart"></a>
### Parameters
Parameter choices are better documented in [DataCurator.jl](https://github.com/NanoscopyAI/DataCurator.jl), [SmlmTools](https://github.com/NanoscopyAI/SmlmTools.jl) and [Colocalization](https://github.com/NanoscopyAI/Colcocalization.jl), but for quick reference:
```toml
actions=[["smlm_alignment",".csv", "is_thunderstorm", 600, 10], ["image_colocalization", 5, "C[1,2].tif", "is_2d_img", "filter", 2]]
```
- this looks for **.csv** files, generated by **thunderstorm**
- It will try to find the brightest pair of fiducials, and consider up to **10**
- If it can't find any pair of fiducials that are closer than **600nm**, it will stop, otherwise it'll use the nearest brightest pair to do temporal and cross-channel correction
- In colocalizaton, it will use a **5x5** window on the the 2D images. Use `3` for more finegrained results, 7 for higher range. For example, if your objects can be up to **2** pixels apart, `7` is a safe choice. **always pick an odd value**
- Colocalizations often requires segmentation
    - "filter" --> remove pixels with k <= localizations per pixel
    - "otsu" --> use otsu thresholding, k < 1 removes less, k > 1 removes more
    - "specht" --> adaptive segmentation, pick k = 2. K > 2 : recover more, K < 2 recover less




