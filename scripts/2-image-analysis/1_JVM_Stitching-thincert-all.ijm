setBatchMode(true);

tArray = newArray(0);

// Select topDir
ubertopDir = getDirectory("Choose image directory"); //C:\Users\joris\OneDrive - Universiteit Antwerpen\Thesis JVM\Epithelium\Data\Supplements\Axio Observer 7\2023-11-08

// Check whether the selection was cancelled
if (ubertopDir == "") {
	exit ("No directory selected");
}

ubertopDirName = File.getName(ubertopDir); //2023-11-08

// Check whether the selection is a directory
if (endsWith(ubertopDir, "/")) {
	exit (ubertopDirName + " is not a folder");
}

topDirList = getFileList(ubertopDir);
topDirList = Array.filter(topDirList, "/");
print(String.join(topDirList));
if (File.exists(ubertopDir + "Stacks")) {
	topDirList = Array.deleteValue(topDirList, "Stacks/");
}
print(String.join(topDirList));


// Loop over contents of topDir = plates
for (u = 0; u < topDirList.length; u++) {
	topDir = ubertopDir + topDirList[u];
	print(topDir);
	topDirName = File.getName(topDirList[u]); 
	
	// Get topDir contents
	subDirList = getFileList(topDir); // [20231108_Medium supplements_GFP-01, 20231108_Medium supplements_GFP-02]
	subDirList = Array.filter(subDirList, "/");

	// Check whether topDir actually has contents
	if (subDirList.length == 0) {
		exit ("No files within " + topDir);
	}
	run("Clear Results");
	row = 0;
	
	for (i = 0; i < subDirList.length; i++) {
	
		subDirName = File.getName(subDirList[i]); //20230811_Medium_GFP-01
	//print(subDirName); 
	//subDir = topDir + subDirList[i]
	
	// Check whether current subDir is a directory
		if (endsWith(subDirList[i], "/")) {
		
		// Get subDir contents
			wellDirList = getFileList(topDir + subDirList[i]); //[A1, A2, A3, ...]
			wellDirList = Array.filter(wellDirList, "/");
		
		// Check whether subDir actually has contents
			if (wellDirList.length > 0) {
			
			// Loop over contents of subDir = wells
				for (j = 0; j < wellDirList.length; j++) {
				
					wellDirName = File.getName(wellDirList[j]); //A1
				//print(wellDirName); 
					wellDir = topDir + subDirList[i] + wellDirList[j];
					print(wellDir);
				
				// Check whether current wellDir is a directory
					if (endsWith(wellDirList[j], "/")) {
					
					// Check whether current wellDir/Tiles exists
						if (File.exists(wellDir + "Tiles")) {
						
						// Get subDir contents
							tileDirList = getFileList(wellDir + "Tiles"); // [20231108_Medium supplements_GFP-01-A1.tif_info.xml, 20231108_Medium supplements_GFP-01-A1.tif_metadata.xml, 20231108_Medium supplements_GFP-01-A1_m01_ORG.tif, 20231108_Medium supplements_GFP-01-A1_m02_ORG.tif, ...] 
						
						// Check whether current wellDir/Tiles actually has contents
							if (tileDirList.length > 0) {
							
								xmlFile = Array.filter(tileDirList, "info.xml");
								if(xmlFile.length == 1) {
									run("Run Script from File", "scriptfile=[" + File.getParent(topDir) + "/" + "1_TileConfiguration.groovy] inputfolder=[" + wellDir + "Tiles] recursive=false filterchoice=Wildcard pattern=*_info.xml");
									// Weird HACK I found to run scripts from an ImageJ macro in Fiji. For some reason runMacroFile() is not available and runMacro() does not work with non-ijm files
									// Bug occurs showing empty message window in some installations of Fiji, if this occurs try a fresh new installation
									// File.getDirectory(getInfo("macro.filepath")) does not work reliably, another alternative would be to call this macro from a script using IJ.runMacroFile() to make the relative path work
									wait(2000);
									//run("Grid/Collection stitching", "type=[Positions from file] order=[Defined by TileConfiguration] directory=[" + wellDir + "Tiles] layout_file=TileConfiguration.txt fusion_method=[Linear Blending] regression_threshold=0.30 max/avg_displacement_threshold=2.50 absolute_displacement_threshold=3.50 compute_overlap subpixel_accuracy computation_parameters=[Save memory (but be slower)] image_output=[Fuse and display]");
									run("Grid/Collection stitching", "type=[Positions from file] order=[Defined by TileConfiguration] directory=[" + wellDir + "Tiles] layout_file=TileConfiguration.txt fusion_method=[Linear Blending] regression_threshold=0.30 max/avg_displacement_threshold=2.50 absolute_displacement_threshold=3.50 subpixel_accuracy computation_parameters=[Save memory (but be slower)] image_output=[Fuse and display]");
								}
							
								else {
									run("Grid/Collection stitching", "type=[Grid: snake by rows] order=[Right & Down                ] grid_size_x=4 grid_size_y=4 tile_overlap=12 first_file_index_i=1 directory=[" + wellDir + "Tiles] file_names=[" + subDirName + "-" + wellDirName + "_m{ii}_ORG.tif] output_textfile_name=TileConfiguration.txt fusion_method=[Linear Blending] regression_threshold=0.30 max/avg_displacement_threshold=2.50 absolute_displacement_threshold=3.50 subpixel_accuracy computation_parameters=[Save memory (but be slower)] image_output=[Fuse and display]");
								}
							
								selectWindow("Fused");
								run("Split Channels");
								close("C3-Fused");
								selectImage("C1-Fused");
								run("32-bit");
								run("Enhance Contrast...", "saturated=0.35 normalize");
								run("Duplicate...", " ");
								selectImage("C1-Fused-1");
								run("Gaussian Blur...", "sigma=400");
								imageCalculator("Divide create 32-bit", "C1-Fused","C1-Fused-1");
								selectImage("Result of C1-Fused");
								setOption("ScaleConversions", true);
								run("8-bit");
								close("C1-Fused");
								close("C1-Fused-1");
							
							//wait(10000);
							//run("Smooth");
							
								t = 0;
								if (tArray.length > 0) {
									Array.getStatistics(tArray, min, max, mean, stdDev);
									t = min;
								}
							//doWand(getWidth()/2, getHeight()/2, -1, "8-connected");
							//t = 5000;
								roundVar = 0;
								solidityVar = 0;
								areaVar = 0;
								qcVar = "";
							
								while (roundVar < 0.95 || solidityVar < 0.95 || areaVar < 26604304){ // 95% of theoretical area
									doWand(getWidth()/2, getHeight()/2, t, "8-connected");
									roundVar = getValue("Round");
 									solidityVar = getValue("Solidity");
 									if (getValue("selection.size") != 0){
										run("Fit Circle");
										areaVar = getValue("Area");
 									}
								//print(areaVar);
									if (areaVar > 30804984) { // The fitted circle should not exceed 110% of theoretical area, see file for calculation
 										while (roundVar < 0.95 || solidityVar < 0.95 || areaVar > 30804984){
 											if (t < 1) {
 												qcVar = "Failed";
 												break;
 											}
 											doWand(getWidth()/2, getHeight()/2, t, "8-connected");
 											roundVar = getValue("Round");
 											solidityVar = getValue("Solidity");
											run("Fit Circle");
											areaVar = getValue("Area");
											t--;
 										}
 										break;
 									}
 									t++;
								}
								setResult("Plate", row, subDirName);
    							setResult("Well", row, wellDirName);
    							setResult("t", row, t - 1);
    							setResult("Round", row, roundVar);
    							setResult("Solidity", row, solidityVar);
    							setResult("Area", row, areaVar);
    							if (areaVar < 26604304){
    								qcVar = "Failed";
    								makeOval((getWidth()/2)-2986, (getHeight()/2)-2986, 5971, 5971);
								//setResult("QC", row, "Passed");
								//print("Passed");
								//print(getValue("selection.size"));
    							} else {
    								qcVar = "Passed";
								//setResult("QC", row, "Failed");
								//print("Failed");
								}
    							setResult("QC", row, qcVar);
    						
    							row++;	
							
								tArrayAppend = newArray(1);
								tArrayAppend[0] = t - 1;
								if (tArray.length == 0) {
									tArray = tArrayAppend;
								} else {
									tArray = Array.concat(tArray,tArrayAppend);
								}
							
							
 								run("Create Mask");
 								close("Result of C1-Fused");
 							
 								selectWindow("Mask");
 								run("Create Selection");
 								selectWindow("C2-Fused");
 								run("Restore Selection");
 								run("Crop");
 								run("Make Inverse");
								setBackgroundColor(0, 0, 0);
								run("Clear", "slice");
 							
 							
 							//imageCalculator("AND create", "Mask","C2-Fused"); // suddenly is not reliable anymore wtf
 							//close("C2-Fused");
							//selectWindow("Result of C2-Fused");
							//run("Restore Selection");
							//run("Crop");
								run("Select None");
							
							// Save result
								selectWindow("C2-Fused");
								saveAs("ZIP", wellDir + "Result of Fused.zip");
							
							// Save mask
								if (!File.exists(wellDir + "Mask")) {
									File.makeDirectory(wellDir + "Mask");
								}
								if (wellDir + "Mask" == "") {
									exit ("Unable to create directory " + wellDir + "Mask");
								}
								selectWindow("Mask");
								saveAs("ZIP", wellDir + "Mask" + "/" + "Mask of Fused.zip");
								updateResults();
								saveAs("Results", topDir + "Masking QC.csv");
								close("*");
								run("Collect Garbage");
								run("Collect Garbage");
							}
						}
					}								
				}
			}
		}
	}
}
updateResults();
saveAs("Results", topDir + "Masking QC.csv");