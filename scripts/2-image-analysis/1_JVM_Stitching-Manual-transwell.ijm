setBatchMode(true);
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
//for (u = 0; u < 1; u++) {
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
	//for (i = 0; i < 1; i++) {
	
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
				//for (j = 0; j < 2; j++) {
				
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
								close("Fused");
								close("C1-Fused");
								close("C3-Fused");
								selectWindow("C2-Fused");
			
								if (File.exists(wellDir + "Mask" + File.separator + "Mask of Fused.zip")) {
									open(wellDir + "Mask" + File.separator + "Mask of Fused.zip");
									setThreshold(1, 255, "raw");
									run("Create Selection");
									selectWindow("C2-Fused");
									run("Restore Selection");
								}
								else {
									selectWindow("C2-Fused");
									setBatchMode(false);
									run("Duplicate...", " ");
									selectWindow("C2-Fused-1");
									run("Enhance Contrast", "saturated=0.35");
									// The range is 29046166 - 30429316 pixels², so 29737741 pixels² is the average, which means a diameter of 6153 pixels, see file for calculation
									makeOval(0, 0, 6153, 6153);
									waitForUser("Click Ok after selecting area of interest");	
									run("Create Mask");	
									if (!File.exists(wellDir + "Mask")) {
										File.makeDirectory(wellDir + "Mask");
										if (wellDir + "Mask" == "") {
											exit ("Unable to create directory " + wellDir + "Mask");
										}
									}
									selectWindow("Mask");
									saveAs("ZIP", wellDir + "Mask" + "/" + "Mask of Fused.zip");
									close("Mask of Fused.tif");
									selectWindow("C2-Fused");
									run("Restore Selection");
									close("C2-Fused-1");
									setBatchMode(true);
								}
			
								run("Make Inverse");
								run("Clear", "slice");
								run("Make Inverse");
								run("Crop");
			
			
			//imageCalculator("AND create", "Mask","C2-Fused");
			//close("C2-Fused");
			//selectWindow("Result of Mask");
			//run("Restore Selection");
			//run("Crop");
								run("Select None");
			// Save result
								saveAs("ZIP", wellDir + "Result of Fused.zip");
			
			// Save mask
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