#!/bin/bash

export xslcreate=mif2_2_claml.xsl

if [ ! -e ${jarPath:?"Parameter jarPath not set. Example: export jarPath=/mypath/lib/saxon9"}/saxon9.jar ]; then
    echo "Parameter jarPath does not lead to saxon9.jar."
    exit 1
fi

# Build new project
#echo "Building from DEFN=UV=VO=1099-20110726.coremif"
#java -jar ${jarPath}/saxon9.jar -s:"../hl7-coremif-vocab/DEFN=UV=VO=1099-20110726.coremif" -xsl:"$xslcreate"
#echo "Building from DEFN=UV=VO=1150-20120331.coremif"
#java -jar ${jarPath}/saxon9.jar -s:"../hl7-coremif-vocab/DEFN=UV=VO=1150-20120331.coremif" -xsl:"$xslcreate"
echo "Building from DEFN=UV=VO=1175-20120802.coremif"
java -jar ${jarPath}/saxon9.jar -s:"../hl7-coremif-vocab/DEFN=UV=VO=1175-20120802.coremif" -xsl:"$xslcreate"

echo "Building denormalized files"
mkdir denormalized
for file in `ls claml/*.xml` ; do
    echo "    Processing $file as `echo $file | sed 's/claml\/\(.*\)\.xml/denormalized\/\1-denormalized.xml/'`..."
    java -jar ${jarDir}/saxon9.jar -s:$file -xsl:../../terminology/claml/resources/stylesheets/ClaML-2-denormalized.xsl -o:`echo $file | sed 's/claml\/\(.*\)\.xml/denormalized\/\1-denormalized.xml/'`
done

echo "Building description files"
mkdir descriptions
for file in `ls claml/*.xml` ; do
    echo "    Processing $file as `echo $file | sed 's/claml\/\(.*\)\.xml/descriptions\/\1-descriptions.xml/'`..."
    java -jar ${jarDir}/saxon9.jar -s:$file -xsl:../../terminology/claml/resources/stylesheets/ClaML-2-descriptions.xsl -o:`echo $file | sed 's/claml\/\(.*\)\.xml/descriptions\/\1-descriptions.xml/'`
done

