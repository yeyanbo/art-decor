<!-- 
	Copyright (C) 2011-2014 Art Decor Expert Group art-decor.org
	
	Author: Gerrit Boers
	
	This program is free software; you can redistribute it and/or modify it under the terms of the
	GNU Lesser General Public License as published by the Free Software Foundation; either version
	2.1 of the License, or (at your option) any later version.
	
	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
	without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
	See the GNU Lesser General Public License for more details.
	
	The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:hl7="urn:hl7-org:v3" xmlns:saxon="http://saxon.sf.net/" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:UML="omg.org/UML1.3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" exclude-result-prefixes="#all" version="2.0">
    <xsl:output method="xhtml" exclude-result-prefixes="#all" encoding="UTF-8"/>
    <xsl:template match="/refset">
        <html>
            <head>
                <title>
                    <xsl:value-of select="project/name[@language=../@defaultLanguage]"/>
                </title>
                <style type="text/css" media="print, screen">
               body{
                  font-family:Verdana;
                  font-size:10px;
                  margin-left:0em;
                  padding-left:0em;
                  width:100%;
                  heigth:100%;
               }
               table{
                  width:100%;
                  heigth:100%;
                  border-spacing:0px;
                  border-bottom:1px solid lavender;
                  font-family:Verdana;
                  font-size:11px;
               }
               table.outer{
                  border-style:none;
               }
               tfoot{
                  vertical-align:bottom;
               }
               th{
                  background-color:lightgrey;
                  font-weight:bold;
                  text-align:left;
                  font-size:12px;
               }
               th.section{
                  background-color:inherit;
                  border-bottom:2px solid black;
                  padding-top:10px;
                  font-size:14px;
               }
               th.pagetitle{
                  display:table-header-group;
               }
               tr{
                  page-break-inside:avoid;
               }
               th.title{
                  font-size:14px;
               }
               td{
                  text-align:left;
                  vertical-align:top;
               }
               td.alert{
                  color:Red;
               }
               td.retired{
               color:#30a3e1;
               }
               td.normal{
                  text-align:left;
                  vertical-align:top;
                  padding-left:15px;
                  display:block;
               }
               td.toggler{
                  text-align:left;
                  vertical-align:top;
                  background-image:url(/xis/resources/images/trClosed.gif);
                  background-repeat:no-repeat;
                  padding-left:15px;
               }
               td.toggler:hover{
                  cursor:pointer;
               }
               td.indent{
                  text-align:left;
                  vertical-align:top;
                  padding-left:15px;
               }
               table.toggled{
                  display:none;
               }
               td.toprule{
                  border-top:2px solid black;
               }
               td.botrule{
                  border-bottom:1px solid lavender;
               }
               td.leftrule{
                  border-left:1px solid lavender;
               }
               .zebra{
                  border-collapse:collapse;
               }
               .scheme1{
                  background-color:inherit;
               }
               .scheme1 .even{
                  background-color:#EEE;
               }
               .tooltip{
                  border-bottom:1px dotted #000000;
                  color:#000000;
                  outline:none;
                  cursor:help;
                  text-decoration:none;
                  position:relative;
               }
               .tooltip span{
                  margin-left:-999em;
                  position:absolute;
               }
               .tooltip:hover span{
                  border-radius:5px 5px;
                  -moz-border-radius:5px;
                  -webkit-border-radius:5px;
                  box-shadow:5px 5px 5px rgba(0, 0, 0, 0.1);
                  -webkit-box-shadow:5px 5px rgba(0, 0, 0, 0.1);
                  -moz-box-shadow:5px 5px rgba(0, 0, 0, 0.1);
                  font-family:Calibri, Tahoma, Geneva, sans-serif;
                  position:absolute;
                  left:1em;
                  top:2em;
                  z-index:99;
                  margin-left:0;
                  width:250px;
               }
               .tooltip:hover img{
                  border:0;
                  margin:-10px 0 0 -55px;
                  float:left;
                  position:absolute;
               }
               .tooltip:hover em{
                  font-family:Candara, Tahoma, Geneva, sans-serif;
                  font-size:1.2em;
                  font-weight:bold;
                  display:block;
                  padding:0.2em 0 0.6em 0;
               }
               .classic{
                  padding:0.8em 1em;
               }
               .custom{
                  padding:0.5em 0.8em 0.8em 2em;
               }
               * html a:hover{
                  background:transparent;
               }
               .classic{
                  background:#FFFFAA;
                  border:1px solid #FFAD33;
               }
               .critical{
                  background:#FFCCAA;
                  border:1px solid #FF3334;
               }
               .help{
                  background:#9FDAEE;
                  border:1px solid #2BB0D7;
               }
               .info{
                  background:#9FDAEE;
                  border:1px solid #2BB0D7;
               }
               .warning{
                  background:#FFFFAA;
                  border:1px solid #FFAD33;
               }</style>
                <script language="Javascript" type="text/javascript" src="/terminology/resources/scripts/gs_sortable.js"/>
                <script language="Javascript" type="text/javascript" src="/terminology/resources/scripts/terminology.js"/>
                <script type="text/javascript">
               var TSort_Data = new Array ('refset', 's', 's','','s');
               var TSort_Initial = 0;
               var TSort_Classes = new Array ('plain', 'alternate');
               tsRegister();
            </script>
                <link type="text/css" href="/terminology/resources/css/terminology.css" rel="stylesheet"/>
            </head>
            <body>
                <h1>
                    <xsl:value-of select="project/name[@language=../@defaultLanguage]"/>
                </h1>
                <table id="refset">
                    <thead>
                        <tr>
                            <th>Omschrijving</th>
                            <th>SNOMED-CT FSN</th>
                            <th>Id</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <xsl:for-each select="members/member">
                        <tr>
                            <td width="40%" class="{if (@statusCode='retired') then 'retired' else ''}">
                                <xsl:choose>
                                    <xsl:when test="concept/desc[@type='pref']/@languageCode='nl'">
                                        <xsl:value-of select="concept/desc[@type='pref'][@languageCode='nl']"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="concept/desc[@type='pref'][1]"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </td>
                            <td width="40%" class="{if (@statusCode='retired') then 'retired' else ''}">
                                <xsl:value-of select="concept/desc[@type='fsn'][1]"/>
                            </td>
                           <td width="10%" class="{if (@statusCode='retired') then 'retired' else ''}">
                                <xsl:value-of select="concept/@conceptId"/>
                            </td>
                           <td width="10%" class="{if (@statusCode='retired') then 'retired' else ''}">
                                <xsl:value-of select="@statusCode"/>
                            </td>
                        </tr>
                    </xsl:for-each>
                </table>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>