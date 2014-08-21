<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:hl7="urn:hl7-org:v3" exclude-result-prefixes="xs hl7" version="2.0">
    <!--:
    Copyright (C) 2012-2014 ART-DECOR expert group art-decor.org
    
    Author: Alexander Henket
    
    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.
    
    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.
    
    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
    -->
    
    <!-- PURPOSE: removes anything that is not in the HL7 (urn:hl7-org:v3) namespace. This is useful for pre-processing CDA documents before 
        feeding them off to XML Schema validation. In CDA it is legal to have extra element in your own namespace, but the default XML Schema 
        doesn't like it
    -->
    <xsl:output indent="yes"/>
    <xsl:template match="/">
        <xsl:apply-templates select="hl7:*"/>
    </xsl:template>
    <xsl:template match="*[namespace-uri() != 'urn:hl7-org:v3']"/>
    <xsl:template match="text()|comment()|processing-instruction()">
        <xsl:copy-of select="self::node()"/>
    </xsl:template>
    <xsl:template match="hl7:*">
        <xsl:copy>
            <xsl:copy-of select="@*" copy-namespaces="no"/>
            <xsl:apply-templates select="hl7:*|text()|comment()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>