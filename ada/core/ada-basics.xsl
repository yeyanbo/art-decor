<?xml version="1.0" encoding="UTF-8"?>
<!-- 
Copyright (C) 2013-2014  Marc de Graauw

This program is free software; you can redistribute it and/or modify it under the terms 
of the GNU General Public License as published by the Free Software Foundation; 
either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
See the GNU General Public License for more details.

See http://www.gnu.org/licenses/gpl.html
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <!-- The project prefix, as defined in the ADA XML definition file. -->
    <xsl:variable name="prefix" select="/ada/project/@prefix/string()"/>
    <!-- The URI from where to retrieve transactions, as defined in the ADA XML definition file. -->
    <xsl:variable name="releaseBaseUri" select="/ada/project/release/@baseUri/string()"/>
    <!-- The HTTP URI for access to eXist. -->
    <xsl:variable name="existBaseUri" select="doc('../conf.xml')//exist/@uri"/>
    <!-- The hostname (and port) (without http://) for HTTP access to eXist. -->
    <xsl:variable name="existHostPort" select="replace($existBaseUri, 'http://', '')"/>
    <!-- The location in eXist of this project -->
    <xsl:variable name="existInternalBaseUri" select="'/db/apps/'"/>
    <!-- The hostname (and port) for HTTP access to Orbeon. -->
    <xsl:variable name="orbeonBaseUri" select="concat(doc('../conf.xml')//orbeon/@uri, 'art-decor/')"/>
    <!-- The local folder where the project is stored (one up from definition folder) -->
    <xsl:variable name="projectDiskRoot" select="resolve-uri('..', base-uri())"/>
    <!-- The name of this app -->
    <xsl:variable name="projectName" select="tokenize($projectDiskRoot, '/')[last()-1]"/>
    <!-- The URI for this project, starting from ada-data -->
    <xsl:variable name="projectUri" select="concat('ada-data/projects/', $projectName, '/')"/>
    <!-- The project language, as defined in the ADA XML definition file. -->
    <xsl:variable name="language" select="/ada/project/@language/string()"/>
    <!-- The project versionDate, as defined in the ADA XML definition file. -->
    <xsl:variable name="versionDate" select="/ada/project/@versionDate/string()"/>
</xsl:stylesheet>
