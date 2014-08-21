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
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html"/>
    
    <xsl:template match="/">
        <html>
            <head>
                <style>
                    table {border-collapse:collapse;}
                    table,th, td {border: 1px solid black;}
                    h1 {font-size:x-large;}
                    h2 {font-size:large;}
                </style>
            </head>
            <body>
                <p><xsl:text>Versie </xsl:text><xsl:value-of select="*/@versionDate"/></p>
                <xsl:for-each select="//dataset">
                    <h1><xsl:text>Tabellen </xsl:text><xsl:value-of select="name"/></h1>
                    <xsl:apply-templates select=".//concept[valueSet]">
                        <xsl:sort select="name"></xsl:sort>
                    </xsl:apply-templates>              
                </xsl:for-each>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="concept[valueSet]">
        <h2>
            <xsl:value-of select="name"/>
        </h2>
        <table>
            <tr>
                <th>LocalId</th>
                <th>Naam</th>
                <th>Code</th>
                <th>Codesysteem</th>
            </tr>
            <xsl:apply-templates select="valueSet/conceptList/(concept|exception)"/>
        </table>
    </xsl:template>

    <xsl:template match="concept|exception">
        <tr>
            <td><xsl:value-of select="@localId"/></td>
            <td><xsl:value-of select="name"/></td>
            <td><xsl:value-of select="@code"/></td>
            <td><xsl:value-of select="@codeSystem"/></td>
        </tr>
    </xsl:template>

    <xsl:template match="@*|node()">
    </xsl:template>
</xsl:stylesheet>