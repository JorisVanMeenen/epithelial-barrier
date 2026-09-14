//!!!!!!!!!!!!!! use modified ImageJ to save all overlays to stack
debugPrint = true; // set to true to print details
setBatchMode(true);
// Select topDir
topDir = getDirectory("Choose image directory"); 

// Check whether the selection was cancelled
if (topDir == "") {
	exit ("No directory selected");
}

topDirName = File.getName(topDir); //2024-01-26
//print(topDirName);

// Check whether the selection is a directory
if (endsWith(topDir, "/")) {
	exit (topDirName + " is not a folder");
}

// Get topDir contents
subDirList = getFileList(topDir);
subDirList = Array.filter(subDirList, "/");
if (debugPrint == true) {
	Array.print(subDirList);
}

// Check whether topDir actually has contents
if (subDirList.length == 0) {
	exit ("No files within " + topDir);
}

run("Clear Results");
Table.create("Results of experiment.csv");
row = 0;

//make Stacks dir on same level as topdir but make sure it is not included in loop
ubertopDir = File.getParent(topDir) + "/";
topDirList = getFileList(ubertopDir);
topDirList = Array.filter(topDirList, "/");
if (File.exists(ubertopDir + "Stacks")) {
	topDirList = Array.deleteValue(topDirList, "Stacks/");
}
else {
	File.makeDirectory(ubertopDir + "Stacks");
}
if (debugPrint == true) {
	Array.print(topDirList);
}

selectWindow("Results of experiment.csv");
Table.update;
saveAs("Results of experiment.csv", ubertopDir + "Results of experiment.csv");
// Loop over contents of topDir = plates
for (i = 0; i < subDirList.length; i++) {
	
	subDirName = File.getName(subDirList[i]); //20240126_ali_GFP-01
	if (debugPrint == true) {
		print("i is " + i);
		print("subDir is " + subDirName);
	}
	//print(subDirName);
	//subDir = topDir + subDirList[i]
	
		
	//make Plates dir
	if (!File.exists(ubertopDir + "Stacks" + "/" + subDirList[i])) {
		File.makeDirectory(ubertopDir + "Stacks" + "/" + subDirList[i]);
	}
		
	// Get subDir contents
	wellDirList = getFileList(topDir + subDirList[i]); 
	wellDirList = Array.filter(wellDirList, "/");
	if (debugPrint == true) {
		Array.print(wellDirList);
	}
		
	// Check whether subDir actually has contents
	if (wellDirList.length > 0) {
			
		// Loop over contents of subDir = wells
		for (j = 0; j < wellDirList.length; j++) {
				
			wellDirName = File.getName(wellDirList[j]); //A1
			if (debugPrint == true) {
				print("j is " + j);
				print("wellDir is " + wellDirName);
			}
			wellDir = topDir + subDirList[i] + wellDirList[j];
					
			//make Well dir
			if (!File.exists(ubertopDir + "Stacks" + "/" + subDirList[i] + wellDirList[j])) {
				File.makeDirectory(ubertopDir + "Stacks" + "/" + subDirList[i] + wellDirList[j]);
			}
						
			// Get subDir contents
			fusedDirList = getFileList(wellDir); 
			fusedDirList = Array.filter(fusedDirList, "(.zip$)");
			if (debugPrint == true) {
				Array.print(fusedDirList);
			}
						
			// Check whether current wellDir actually has contents
			if (fusedDirList.length > 0) {	
						
				// Loop over contents of wellDir
				for (k = 0; k < fusedDirList.length; k++) {
					fusedName = File.getName(fusedDirList[k]);
					if (debugPrint == true) {
						print(fusedName);
					}
								
					for (u = 0; u < topDirList.length; u++) {
						//print(u);
						topDirName2 = File.getName(ubertopDir + topDirList[u]);
										//print(topDirName2);
						subDirList2 = getFileList(ubertopDir + topDirList[u]);
						subDirList2 = Array.filter(subDirList2, "/");
						subDirName2 = File.getName(subDirList2[i]);
										//print(subDirName2);
						wellDirList2 = getFileList(ubertopDir + topDirList[u] + subDirList2[i]); 
						wellDirList2 = Array.filter(wellDirList2, "/");
						wellDirName2 = File.getName(wellDirList2[j]);
										//print(wellDirName2);
						wellDir2 = ubertopDir + topDirList[u] + subDirList2[i] + wellDirList2[j];
						open(wellDir2 + fusedName);
						setMinAndMax(0,65535);
						setOption("ScaleConversions", true);
						run("8-bit");
						fusedtifName = getTitle();
						run("Smooth");
						Table.set("Date", row, topDirName, "Results of experiment.csv");
						Table.set("Plate", row, subDirName2, "Results of experiment.csv");
    					Table.set("Well", row, wellDirName2, "Results of experiment.csv");
    					setThreshold(1, 255, "raw");
    									//print("hello");
    					run("Create Selection");
    									//print("hello2");
    					roiManager("Add");
    					run("Select None");
    					Table.set("Median", row, getValue("Median limit"), "Results of experiment.csv");
    					Total = getValue("Area limit");
    									//run("Subtract Background...", "rolling=50");
    					run("Median...", "radius=10");
    					setThreshold(14, 255, "raw");
    					run("Analyze Particles...", "size=100-Infinity show=Masks");
    					selectWindow("Mask of " + fusedtifName);
						run("Invert LUT");
						run("Create Selection");
    					if (getValue("selection.size") != 0){
    						roiManager("Add");
    						roiManager("Add");
    						run("Select None");
    					}
    									//print("hello3");
    					Cells = getValue("Area limit");
    					Confluence = (Cells/Total)*100;
    					setResult("Confluence (%)", row, Confluence);
    					Table.set("Confluence (%)", row, Confluence, "Results of experiment.csv");
    					Table.update;
    									// Add confluence
    					row++;	
    					close("Mask of " + fusedtifName);
						close(fusedtifName);
										
										
										//run("Grid/Collection stitching", "type=[Grid: snake by rows] order=[Right & Down                ] grid_size_x=4 grid_size_y=4 tile_overlap=10 first_file_index_i=1 directory=[" + wellDir2 + "Tiles] file_names=[" + subDirName2 + "-" + wellDirName2 + "_m{ii}_ORG.tif] output_textfile_name=TileConfiguration.txt fusion_method=[Linear Blending] regression_threshold=0.30 max/avg_displacement_threshold=2.50 absolute_displacement_threshold=3.50 subpixel_accuracy computation_parameters=[Save memory (but be slower)] image_output=[Fuse and display]");		
										
										// Check whether current wellDir/Tiles exists
						if (File.exists(wellDir2 + "Tiles")) {
						
											// Get subDir contents
							tileDirList = getFileList(wellDir2 + "Tiles"); // !! [20240212_ali_GFP-01-A5.tif_info.xml, 20240212_ali_GFP-01-A5.tif_metadata.xml, 20240212_ali_GFP-01-A5_m01_ORG.tif, 20240212_ali_GFP-01-A5_m02_ORG.tif, ...] 
											//print(String.join(tileDirList));
											
											// Check whether current wellDir/Tiles actually has contents
							if (tileDirList.length > 0) {
							
												//print(String.join(tileDirList));
												//print(String.join(Array.filter(tileDirList, "info.xml")));
								xmlFile = Array.filter(tileDirList, "info.xml");
												//print(String.join(xmlFile));
							
								if(xmlFile.length == 1) {
													
													//tileDirList = getFileList("C:/Users/joris/OneDrive - Universiteit Antwerpen/Thesis JVM/Epithelium/Data/ALI/Axio Observer 7/2024-01-26/20240126_ali_GFP-01/A1/Tiles");
									tileConfig = Array.filter(tileDirList, "TileConfiguration.txt");
													//print(String.join(tileConfig));
													
									if(tileConfig.length != 1) {
														//print("No TileConfig");
										run("Run Script from File", "scriptfile=[" + File.getParent(topDir) + "/" + "TileConfiguration.groovy] inputfolder=[" + wellDir2 + "Tiles] recursive=false filterchoice=Wildcard pattern=*_info.xml");
														// Weird HACK I found to run scripts from an ImageJ macro in Fiji. For some reason runMacroFile() is not available and runMacro() does not work with non-ijm files
														// Bug occurs showing empty message window in some installations of Fiji, if this occurs try a fresh new installation
														// File.getDirectory(getInfo("macro.filepath")) does not work reliably, another alternative would be to call this macro from a script using IJ.runMacroFile() to make the relative path work
										wait(2000);
									}
													//print("Stitching");
									run("Grid/Collection stitching", "type=[Positions from file] order=[Defined by TileConfiguration] directory=[" + wellDir2 + "Tiles] layout_file=TileConfiguration.txt fusion_method=[Linear Blending] regression_threshold=0.30 max/avg_displacement_threshold=2.50 absolute_displacement_threshold=3.50 subpixel_accuracy computation_parameters=[Save memory (but be slower)] image_output=[Fuse and display]");
								}
								else {
													//print("No xml");
									run("Grid/Collection stitching", "type=[Grid: snake by rows] order=[Right & Down                ] grid_size_x=4 grid_size_y=4 tile_overlap=12 first_file_index_i=1 directory=[" + wellDir + "Tiles] file_names=[" + subDirName + "-" + wellDirName + "_m{ii}_ORG.tif] output_textfile_name=TileConfiguration.txt fusion_method=[Linear Blending] regression_threshold=0.30 max/avg_displacement_threshold=2.50 absolute_displacement_threshold=3.50 subpixel_accuracy computation_parameters=[Save memory (but be slower)] image_output=[Fuse and display]");
													//This will not work due to mismatch between wellDirName and filename
								}
										
								selectWindow("Fused");
								if (matches(wellDirName, ".*3") && i < 4) {
									Slices = nSlices;
									for (t = 1; t <= Slices; t++) {
										setSlice(t);
										resetMinAndMax;
									}	
								}
								run("Stack to RGB");
								close("Fused");
								open(wellDir2 + "Mask/Mask of Fused.zip");
								selectWindow("Mask of Fused.tif");
								setThreshold(1, 255, "raw");
								run("Create Selection");
								selectWindow("Fused (RGB)");
												//wait(1000);
								rename(topDirName2);
												//wait(1000);
								run("Restore Selection");
												//wait(1000);
								run("Crop");
												//wait(1000);
								run("Select None");
												//wait(1000);
								if (roiManager("count") >= 2){
    								roiManager("Select", 2);
    								roiManager("Set Fill Color", "#25ffff00");
    							}	
    							n = Array.getSequence(roiManager("count"));
    							roiManager("select", n);
    							run("From ROI Manager");
    							roiManager("Deselect");
								roiManager("Delete");
								close("Mask of Fused.tif");
							}
						}
					}
				}
								//setBatchMode(false);
				//run("Images to Stack", "name=[" + subDirName + "-" + wellDirName + "] use"); Do if more than 1 image
								//setBatchMode(true);
				selectWindow("Results of experiment.csv");
				Table.update;
				saveAs("Results of experiment.csv", ubertopDir + "Results of experiment.csv");
				saveAs("ZIP", ubertopDir + "Stacks" + "/" + subDirList[i] + wellDirList[j] + subDirName + "-" + wellDirName + ".zip");
				close("*");
				run("Collect Garbage");
				run("Collect Garbage");
			}
		}
	}
}
selectWindow("Results of experiment.csv");
Table.update;
saveAs("Results of experiment.csv", ubertopDir + "Results of experiment.csv");