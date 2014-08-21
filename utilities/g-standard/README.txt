Stylesheets for converting G-Standard ascii distribution files to xml.

NB The ascii files contain an empty line at the end of the file, this has to be removed before processing.

The examples assume that the saxon9.jar is in the same directory as the stylesheets.

Directory structure for usage:

g-standard
	dummy.xml		dummy output file from xml conversion, can be removed
	file-merge.xml		merged xml files output for processing
	g-standard_2_XML.xsl	stylesheet for converting ascii to xml
	gpk.xml			hierarchical product xml output file
	merge_files.xsl		stylesheet for merging xml files for processing
	process_merge.xsl	stylesheet for generating hierarchical generic product xml from merge
	README.txt		this readme file
	Text			directory containing G-Standard distribution ascii files
	XML			directory for g-standard xml files

Usage:
1. Run xml conversion:
	java -Xmx2048m -jar saxon9.jar -t -s:g-standard_2_XML.xsl -xsl:g-standard_2_XML.xsl -o:dummy.xml

2. Merge files:
	java -Xmx2048m -jar saxon9.jar -t -s:merge_files.xsl -xsl:merge_files.xsl -o:file-merge.xml

3. Generate hierarchical product xml file:
	java -Xmx2048m -jar saxon9.jar -t -s:file-merge.xml -xsl:process_merge.xsl -o:gpk.xml

 