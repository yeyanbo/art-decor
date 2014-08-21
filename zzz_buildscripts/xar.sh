#!/bin/bash

export outputDir=../../xars

# Check variables and exit if they don't
if [ `which java`='' ] || [ `which ant`='' ]; then
    echo "Creates XAR files for every directory with a buid.xml"
    echo "Requirements:"
    echo "  Download and install the JDK from http://java.oracle.com"
    echo "  NOTE: JRE is not enough"
    echo ""
    echo "  Download and unzip ant from http://ant.apache.org/bindownload.cgi"
    echo "  export PATH=\${PATH}:\${JAVA_HOME}:\${ANT_HOME}"
fi

# Create output dir if it doesn't exist
if [ ! -e "$outputDir" ]; then 
    echo "Creating output directory '${outputDir}'"
    mkdir "$outputDir"
else
    echo "Removing contents of output directory '${outputDir}'"
    rm  "$outputDir/*"
fi

# Remove any previous xars
if [ -e "${outputDir}/*.xar" ]; then
    echo "Removing previous xars files from current working dir"
    rm *.xar
fi

# Build xars
echo "Building xar files"
find .. -name 'build.xml' -exec ant xar -buildfile {} \;

# Move them here
echo "Moving xar files to '${outputDir}'"
find .. -name '*.xar' -exec mv {} "${outputDir}" \;
