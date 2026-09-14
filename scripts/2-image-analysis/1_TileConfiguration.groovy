// @File(label = "ZEISS _info.xml file", style = "file") xmlFile

import org.scijava.util.XML

tileDir = xmlFile.getParentFile()

// write the header
tcFile = new File(tileDir, "TileConfiguration.txt")
tcFile.delete()
tcFile << "# Define the number of dimensions we are working on\n"
tcFile << "dim = 2\n"
tcFile << "# Define the image coordinates (in pixels)\n"

xml = new XML(xmlFile)
for (image in xml.elements("//ExportDocument/Image")) {
	
	imageName = xml.cdata(image, "Filename").replaceAll("%20", " ")
	imageBounds = xml.elements(image, "Bounds")[0]
	
	x = imageBounds.getAttribute("StartX")
	y = imageBounds.getAttribute("StartY")
	
	tcFile << imageName + "; ; (" + x + ", " + y + ")\n"
	
}

// Credit Curtis Rueden for inspiration