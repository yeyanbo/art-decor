#!/bin/bash

export xslcreate=create_decor_valueSets_from_coreMif.xsl
export xslmerge=merge_decor_valuesets.xsl

if [ ! -e ${jarPath:?"Parameter jarPath not set. Example: export jarPath=/mypath/lib/saxon9"}/saxon9.jar ]; then
    echo "Parameter jarPath does not lead to saxon9.jar."
    exit 1
fi

# Build new project
echo "Building from DEFN=UV=VO=1099-20110726.coremif"
java -jar ${jarPath}/saxon9.jar -s:"DEFN=UV=VO=1099-20110726.coremif" -xsl:"$xslcreate" -o:"DEFN=UV=VO=1099-20110726.xml" includeDeprecatedValuesets=false
echo "Building from DEFN=UV=VO=1150-20120331.coremif"
java -jar ${jarPath}/saxon9.jar -s:"DEFN=UV=VO=1150-20120331.coremif" -xsl:"$xslcreate" -o:"DEFN=UV=VO=1150-20120331.xml" includeDeprecatedValuesets=true
echo "Building from DEFN=UV=VO=1175-20120802.coremif"
java -jar ${jarPath}/saxon9.jar -s:"DEFN=UV=VO=1175-20120802.coremif" -xsl:"$xslcreate" -o:"DEFN=UV=VO=1175-20120802.xml" includeDeprecatedValuesets=true

# Get current base project from art-decor.org
# curl -o $xmlbase http://art-decor.org/decor/services/modules/RetrieveProject.xquery?prefix=ad1bbr-&mode=verbatim&language=&download=false

# Merge 1150 info into old
echo "Merging DEFN=UV=VO=1150-20120331.xml into DEFN=UV=VO=1150-20120331-merged.xml"
java -jar ${jarPath}/saxon9.jar -s:"DEFN=UV=VO=1150-20120331.xml" -xsl:"$xslmerge" -o:"DEFN=UV=VO=1150-20120331-merged.xml" baseLineProject=DEFN=UV=VO=1099-20110726.xml
# Merge 1175 info into result of previous merge
echo "Merging DEFN=UV=VO=1175-20120802.xml into DEFN=UV=VO=1175-20120802-merged.xml"
java -jar ${jarPath}/saxon9.jar -s:"DEFN=UV=VO=1175-20120802.xml" -xsl:"$xslmerge" -o:"DEFN=UV=VO=1175-20120802-merged.xml" baseLineProject=DEFN=UV=VO=1150-20120331-merged.xml
