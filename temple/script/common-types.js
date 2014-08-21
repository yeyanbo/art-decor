/*
*    Author: Marc de Graauw
*
*    This program is free software; you can redistribute it and/or modify it under the terms 
*    of the GNU General Public License as published by the Free Software Foundation; 
*    either version 3 of the License, or (at your option) any later version.
*    
*    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
*    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
*    See the GNU General Public License for more details.
*    
*    See http://www.gnu.org/licenses/gpl.html
*/
var bool = ["true", "false"];
var languages = [
        { text: '"en-US"', displayText: "English" }, 
        { text: '"nl-NL"', displayText: "Nederlands" }, 
        { text: '"de-DE"', displayText: "Deutsch" }
    ];
var conformance_cardinality = [
        { text: 'minimumMultiplicity="1" maximumMultiplicity="1" conformance="R" isMandatory="true"', displayText: "1..1 M" },
        { text: 'minimumMultiplicity="1" maximumMultiplicity="*" conformance="R" isMandatory="true"', displayText: "1..* M" },
        { text: 'minimumMultiplicity="0" maximumMultiplicity="1" conformance="R"', displayText: "0..1 R" },
        { text: 'minimumMultiplicity="1" maximumMultiplicity="1" conformance="R"', displayText: "1..1 R" },
        { text: 'minimumMultiplicity="0" maximumMultiplicity="*" conformance="R"', displayText: "0..* R" },
        { text: 'minimumMultiplicity="1" maximumMultiplicity="*" conformance="R"', displayText: "1..* R" },
        { text: 'minimumMultiplicity="0" maximumMultiplicity="1"', displayText: "0..1 O" },
        { text: 'minimumMultiplicity="1" maximumMultiplicity="1"', displayText: "1..1 O" },
        { text: 'minimumMultiplicity="0" maximumMultiplicity="*"', displayText: "0..* O" },
        { text: 'minimumMultiplicity="1" maximumMultiplicity="*"', displayText: "1..* O" },
        { text: 'conformance="NP"', displayText: "NP" }
    ];
var cardinality = [
        { text: 'minimumMultiplicity="0" maximumMultiplicity="1"', displayText: "0..1" },
        { text: 'minimumMultiplicity="1" maximumMultiplicity="1"', displayText: "1..1" },
        { text: 'minimumMultiplicity="0" maximumMultiplicity="*"', displayText: "0..*" },
        { text: 'minimumMultiplicity="1" maximumMultiplicity="*"', displayText: "1..*" }
    ];
var attribute_shortcut = [
        { text: 'name="classCode" value=""', displayText: "classCode" },
        { text: 'name="moodCode" value=""', displayText: "moodCode" },
        { text: 'name="extension" value=""', displayText: "extension" },
        { text: 'name="root" value=""', displayText: "root" },
        { text: 'name="typeCode" value=""', displayText: "typeCode" },
        { text: 'name="contextControlCode" value=""', displayText: "contextControlCode" },
        { text: 'name="operator" value=""', displayText: "operator" },
        { text: 'name="institutionSpecified" value=""', displayText: "institutionSpecified" },
        { text: 'name="unit" value=""', displayText: "unit" },
        { text: 'name="determinerCode" value=""', displayText: "determinerCode" },
        { text: 'name="contextConductionInd" value=""', displayText: "contextConductionInd" },
        { text: 'name="inversionInd" value=""', displayText: "inversionInd" },
        { text: 'name="independentInd" value=""', displayText: "independentInd" },
        { text: 'name="negationInd" value=""', displayText: "negationInd" },
        { text: 'name="mediaType" value=""', displayText: "mediaType" },
        { text: 'name="representation" value=""', displayText: "representation" },
        { text: 'name="use" value=""', displayText: "use" },
        { text: 'name="qualifier" value=""', displayText: "qualifier" },
        { text: 'name="nullFlavor" value=""', displayText: "nullFlavor" },
        { text: 'name="xsi:type" value=""', displayText: "xsi:type" },
        { text: 'name="xsi:nil" value=""', displayText: "xsi:nil" }
    ];
