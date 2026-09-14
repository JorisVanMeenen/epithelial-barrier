//Sort zips according to conditions instead of well plate layout
debugPrint = true; // set to true to print details
setBatchMode(true);
// Select topDir
hcetList = newArray();
hydrogelcontrolList = newArray();
hydrogelList = newArray();
tearList = newArray();
alihydratedList = newArray();
aliList = newArray();
controlList = newArray();
flowList = newArray();
titleList = newArray();
t = 1
topDir = getDirectory("Choose image directory"); 

// Check whether the selection was cancelled
if (topDir == "") {
	exit ("No directory selected");
}

topDirName = File.getName(topDir); //Stacks
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

// Loop over contents of subDirs = plates
for (i = 0; i < subDirList.length; i++) {
//for (i = 1; i < 2; i++) {
	
	subDirName = File.getName(subDirList[i]); //20250901_Seeding density_HCE-T P82_25-50-100-ser-bul-con-01
	if (debugPrint == true) {
		print("i is " + i);
		print("subDir is " + subDirName);
	}
	//print(subDirName); 
	//subDir = topDir + subDirList[i]
		
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
		//for (j = 2; j < 3; j++) {
				
			wellDirName = File.getName(wellDirList[j]); //A1
			if (debugPrint == true) {
				print("j is " + j);
				print("wellDir is " + wellDirName);
			}
			wellDir = topDir + subDirList[i] + wellDirList[j];
			
			
			// Get wellDir contents = stacks
			fusedDirList = getFileList(wellDir); 
			fusedDirList = Array.filter(fusedDirList, "(.zip$)");
			if (debugPrint == true) {
				Array.print(fusedDirList);
			}
						
			// Ensure only one stack in wellDir
			if (fusedDirList.length == 1) {	
				open(wellDir + fusedDirList[0]);
				run("Remove Overlay");
				run("Set Scale...", "distance=1 known=1.095 unit=µm");
				title = getTitle();
				//run("Enhance Contrast...", "saturated=0.35 process_all");
				run("Scale Bar...", "width=1000 height=1000 thickness=100 font=0 bold hide overlay");
				run("Flatten", "stack");
				run("Canvas Size...", "width=7000 height=7000 position=Center");
				run("Size...", "width=1000 height=1000 constrain average interpolation=Bilinear");
				//run("Duplicate...", " "); 
				run("Add Slice"); // STUPID WORKAROUND TO MAKE CODE WORK WITHOUT STACKS
				close(title);
				//run("Images to Stack", "name=[" + getTitle() + "] use");
				if (matches(subDirName, ".*04")) {
					if (matches(wellDirName, "A.*") | matches(wellDirName, "D.*")) {
						controlList = Array.concat(controlList, getTitle());
					}
					else {
						flowList = Array.concat(flowList, getTitle());
					}
				}
				else {
					if (matches(wellDirName, ".*1")) {
						hcetList = Array.concat(hcetList, getTitle());
					}
					if (matches(wellDirName, ".*2")) {
						hydrogelcontrolList = Array.concat(hydrogelcontrolList, getTitle());
					}
					if (matches(wellDirName, ".*3")) {
						hydrogelList = Array.concat(hydrogelList, getTitle());
					}
					if (matches(wellDirName, ".*4")) {
						tearList = Array.concat(tearList, getTitle());
					}
					if (matches(wellDirName, ".*5")) {
						alihydratedList = Array.concat(alihydratedList, getTitle());
					}
					if (matches(wellDirName, ".*6")) {
						aliList = Array.concat(aliList, getTitle());
					}
				}
				
				if (debugPrint == true) {
					Array.print(hcetList);
					Array.print(hydrogelcontrolList);
					Array.print(hydrogelList);
					Array.print(tearList);
					Array.print(alihydratedList);
					Array.print(aliList);
					Array.print(controlList);
					Array.print(flowList);
				}
				run("Collect Garbage");
				run("Collect Garbage");
			}
		}
	}
}
titleList = Array.concat(controlList, hydrogelcontrolList, hcetList, hydrogelList, tearList, flowList, alihydratedList, aliList);
if (debugPrint == true) {
	Array.print(titleList);
}
for (t = 1; t < titleList.length+1; t++) {
	titleList[t-1] = "stack_" + t + "=[" + titleList[t-1] + "]";
}
titles = String.join(titleList, " ");
print(titles);
run("Multi Stack Montage...", titles + " rows=8 columns=10"); //DO IF STACKS OR NOT
//titles = "stack_1=20231023_Medium supplements_GFP-01-A1.tif stack_2=20231023_Medium supplements_GFP-01-A2.tif stack_3=20231023_Medium supplements_GFP-01-A3.tif stack_4=20231023_Medium supplements_GFP-01-A4.tif stack_5=20231023_Medium supplements_GFP-01-A5.tif stack_6=20231023_Medium supplements_GFP-01-A6.tif stack_7=20231023_Medium supplements_GFP-02-A1.tif stack_8=20231023_Medium supplements_GFP-02-A2.tif stack_9=20231023_Medium supplements_GFP-02-A3.tif stack_10=20231023_Medium supplements_GFP-02-A4.tif stack_11=20231023_Medium supplements_GFP-01-B1.tif stack_12=20231023_Medium supplements_GFP-01-B2.tif stack_13=20231023_Medium supplements_GFP-01-B3.tif stack_14=20231023_Medium supplements_GFP-01-B4.tif stack_15=20231023_Medium supplements_GFP-01-B5.tif stack_16=20231023_Medium supplements_GFP-01-B6.tif stack_17=20231023_Medium supplements_GFP-02-B1.tif stack_18=20231023_Medium supplements_GFP-02-B2.tif stack_19=20231023_Medium supplements_GFP-02-B3.tif stack_20=20231023_Medium supplements_GFP-02-B4.tif stack_21=20231023_Medium supplements_GFP-01-C1.tif stack_22=20231023_Medium supplements_GFP-01-C2.tif stack_23=20231023_Medium supplements_GFP-01-C3.tif stack_24=20231023_Medium supplements_GFP-01-C4.tif stack_25=20231023_Medium supplements_GFP-01-C5.tif stack_26=20231023_Medium supplements_GFP-01-C6.tif stack_27=20231023_Medium supplements_GFP-02-C1.tif stack_28=20231023_Medium supplements_GFP-02-C2.tif stack_29=20231023_Medium supplements_GFP-02-C3.tif stack_30=20231023_Medium supplements_GFP-02-C4.tif stack_31=20231023_Medium supplements_GFP-01-D1.tif stack_32=20231023_Medium supplements_GFP-01-D2.tif stack_33=20231023_Medium supplements_GFP-01-D3.tif stack_34=20231023_Medium supplements_GFP-01-D4.tif stack_35=20231023_Medium supplements_GFP-01-D5.tif stack_36=20231023_Medium supplements_GFP-01-D6.tif stack_37=20231023_Medium supplements_GFP-02-D1.tif stack_38=20231023_Medium supplements_GFP-02-D2.tif stack_39=20231023_Medium supplements_GFP-02-D3.tif stack_40=20231023_Medium supplements_GFP-02-D4.tif"
//run("Multi Stack Montage...", titles + " rows=4 columns=10");

selectWindow("Montage of Stacks");
saveAs("ZIP", topDir + "Montage of Stacks.zip");
close("*");
//setBatchMode(false);

//run("Multi Stack Montage...", "stack_1=20230811_Medium_GFP-01-A1.tif stack_2=20230811_Medium_GFP-01-A2.tif stack_3=20230811_Medium_GFP-01-A3.tif stack_4=20230811_Medium_GFP-01-A4.tif rows=2 columns=2");

// if rows=5 columns=10"
// A1 = 1, A2 = 11, A3 = 21, A4 = 31, A5 = 41
// B1 = 2 ...
// C1 = 3 ...
// D1 = 4 ...
// A1 = 5 ...
// ...


//run("Size...", "width=2000 height=900 depth=6 constrain average interpolation=Bilinear");
//run("8-bit Color", "number=256");
//saveAs("Gif", "D:/Documents/Work/Data/Cornea-on-chip/Epithelial barrier/05_Seeding density/Axio Observer 7/Stacks/Montage of Stacks.gif");