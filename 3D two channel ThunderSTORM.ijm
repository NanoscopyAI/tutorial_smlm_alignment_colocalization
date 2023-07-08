setBatchMode(true);

//call the function to process all folders under the root directory
rootDir = getDirectory("Select root directory"); 

processFolders(rootDir);
print("Finished")
//define the function
function processFolders(rootDir) {
	folderList = getFileList(rootDir);
	RootName = File.getName(rootDir);
	thunderstormRootDir = rootDir + "Thunderstorm/"
	File.makeDirectory(thunderstormRootDir);
	thunderstormCC = thunderstormRootDir + "cc/";
	File.makeDirectory(thunderstormCC);
	thunderstormRaw = thunderstormRootDir + "raw/";
	File.makeDirectory(thunderstormRaw);
	
	for (j=0; j<folderList.length; j++) {
		TreatmentDirectory = rootDir + folderList[j];
		FolderName = replace(folderList[j], "/", "");
		
		ccDestination = thunderstormCC + folderList[j];
		rawDestination = thunderstormRaw + folderList[j];
		File.makeDirectory(ccDestination);
		File.makeDirectory(rawDestination);
		processFiles(TreatmentDirectory);
	}
}

//define the function
function processFiles(currentDir) {

	fileList = getFileList(currentDir);
//open 647 channel frames	
	for(i=0; i<fileList.length; i++) {
		if(endsWith(fileList[i], "647.lif")) {
			open(currentDir+fileList[i]);
//reverse order of frames			
	        run("Reverse");
//run thunderstorm and save original results
            run("Run analysis", "filter=[Wavelet filter (B-Spline)] scale=2.0 order=3 detector=[Local maximum] connectivity=8-neighbourhood threshold=2*std(Wave.F1) estimator=[PSF: Elliptical Gaussian (3D astigmatism)] sigma=1.6 fitradius=3 method=[Least squares] calibrationpath=[C:\\Users\\Nabi Lab Workstation\\Desktop\\ImageJ_Thunderstorm_AA\\manual_calibration\\Gold_bead_high_power_fix] full_image_fitting=false mfaenabled=false renderer=[Averaged shifted histograms] zrange=-500:50:500 magnification=5.0 colorizez=false threed=true shifts=2 zshifts=2 repaint=50");
//save original csv            
            run("Show results table");
//            run("Export results",  "filepath=[" + rootDir + RootName +"_Cav_647_" + FolderName + "_raw.csv] fileformat=[CSV (comma separated)]" + 
            run("Export results",  "filepath=[" + rawDestination + RootName +"_Cav_647_" + FolderName + "_raw.csv] fileformat=[CSV (comma separated)]" + 
		        "chi2=true offset=true saveprotocol=true bkgstd=true uncertainty=true intensity=true x=true sigma2=true y=true sigma1=true z=true id=true frame=true");
//save 3D stacks as tiff        
            run("Visualization", "imleft=0.0 imtop=0.0 imwidth=180.0 imheight=180.0 renderer=[Averaged shifted histograms] zrange=-500:50:500 magnification=5.0 colorizez=false threed=true shifts=2 zshifts=2");
//            saveAs("Tiff", rootDir + RootName +"_Cav_647_" + FolderName + "_raw.tif");
	        saveAs("Tiff",  rawDestination + RootName +"_Cav_647_" + FolderName + "_raw.tif");
//drift correction with cross correlation and save corrected csv
            run("Show results table", "action=drift magnification=5.0 method=[Cross correlation] save=false steps=5 showcorrelations=false");
//            run("Export results",  "filepath=[" + rootDir + RootName +"_Cav_647_" + FolderName + "_CC.csv] fileformat=[CSV (comma separated)]" + 
            run("Export results",  "filepath=[" + ccDestination + RootName +"_Cav_647_" + FolderName + "_CC.csv] fileformat=[CSV (comma separated)]" + 
            "chi2=true offset=true saveprotocol=true bkgstd=true uncertainty=true intensity=true x=true sigma2=true y=true sigma1=true z=true id=true frame=true");
//save 3D stacks as tiff
            run("Visualization", "imleft=0.0 imtop=0.0 imwidth=180.0 imheight=180.0 renderer=[Averaged shifted histograms] zrange=-500:50:500 magnification=5.0 colorizez=false threed=true shifts=2 zshifts=2");
//          saveAs("Tiff", rootDir + RootName +"_Cav_647_" + FolderName + "_CC.tif");
            saveAs("Tiff", ccDestination + RootName +"_Cav_647_" + FolderName + "_CC.tif");


//move on to 568 channel		 	
		 } else if (endsWith(fileList[i], "568.lif")) {
			open(currentDir+fileList[i]);

//run thunderstorm and save original results
            run("Run analysis", "filter=[Wavelet filter (B-Spline)] scale=2.0 order=3 detector=[Local maximum] connectivity=8-neighbourhood threshold=2*std(Wave.F1) estimator=[PSF: Elliptical Gaussian (3D astigmatism)] sigma=1.6 fitradius=3 method=[Least squares] calibrationpath=[C:\\Users\\Nabi Lab Workstation\\Desktop\\ImageJ_Thunderstorm_AA\\manual_calibration\\Gold_bead_high_power_fix] full_image_fitting=false mfaenabled=false renderer=[Averaged shifted histograms] zrange=-500:50:500 magnification=5.0 colorizez=false threed=true shifts=2 zshifts=2 repaint=50");
//            run("Export results",  "filepath=[" + rootDir + RootName +"_eNOS_568_" + FolderName + "_raw.csv] fileformat=[CSV (comma separated)]" + 
	        run("Export results",  "filepath=[" + rawDestination + RootName +"_eNOS_568_" + FolderName + "_raw.csv] fileformat=[CSV (comma separated)]" + 

		        "chi2=true offset=true saveprotocol=true bkgstd=true uncertainty=true intensity=true x=true sigma2=true y=true sigma1=true z=true id=true frame=true");
            run("Visualization", "imleft=0.0 imtop=0.0 imwidth=180.0 imheight=180.0 renderer=[Averaged shifted histograms] zrange=-500:50:500 magnification=5.0 colorizez=false threed=true shifts=2 zshifts=2");
//            saveAs("Tiff", rootDir + RootName +"_eNOS_568_" + FolderName + "_raw.tif");
            saveAs("Tiff", rawDestination +  RootName +"_eNOS_568_" + FolderName + "_raw.tif");
//drift correction with cross correlation and save results
            run("Show results table", "action=drift magnification=5.0 method=[Cross correlation] save=false steps=5 showcorrelations=false");
            run("Export results",  "filepath=[" + ccDestination + RootName +"_eNOS_568_" + FolderName + "_CC.csv] fileformat=[CSV (comma separated)]" + 
		        "chi2=true offset=true saveprotocol=true bkgstd=true uncertainty=true intensity=true x=true sigma2=true y=true sigma1=true z=true id=true frame=true");
            run("Visualization", "imleft=0.0 imtop=0.0 imwidth=180.0 imheight=180.0 renderer=[Averaged shifted histograms] zrange=-500:50:500 magnification=5.0 colorizez=false threed=true shifts=2 zshifts=2");
//            saveAs("Tiff", rootDir + RootName +"_eNOS_568_" + FolderName + "_CC.tif");
            saveAs("Tiff", ccDestination + RootName +"_eNOS_568_" + FolderName + "_CC.tif");

            
		}else if (endsWith(fileList[i], "/")) {
			processFiles(currentDir + fileList[i]);	
		}
	}
}
