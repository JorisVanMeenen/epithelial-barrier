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
Table.create("Results of median.csv");
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

selectWindow("Results of median.csv");
Table.update;
saveAs("Results of median.csv", ubertopDir + "Results of median.csv");
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
						fusedtifName = getTitle();
						Table.set("Date", row, topDirName, "Results of median.csv");
						Table.set("Plate", row, subDirName2, "Results of median.csv");
    					Table.set("Well", row, wellDirName2, "Results of median.csv");
    					setThreshold(1, 65535, "raw");
    					Table.set("Median", row, getValue("Median limit"), "Results of median.csv");
    					Table.update;
    					row++;	
						close(fusedtifName);
					}
				}
				selectWindow("Results of median.csv");
				Table.update;
				saveAs("Results of median.csv", ubertopDir + "Results of median.csv");
				close("*");
				run("Collect Garbage");
				run("Collect Garbage");
			}
		}
	}
}
selectWindow("Results of median.csv");
Table.update;
saveAs("Results of median.csv", ubertopDir + "Results of median.csv");