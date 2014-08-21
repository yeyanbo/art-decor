<?xml version="1.0" encoding="UTF-8"?>
<!-- 
	Copyright (C) 2012-2014 ART-DECOR expert group art-decor.org
	
	Author: Gerrit Boers
	
	This program is free software; you can redistribute it and/or modify it under the terms of the
	GNU Lesser General Public License as published by the Free Software Foundation; either version
	2.1 of the License, or (at your option) any later version.
	
	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
	without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
	See the GNU Lesser General Public License for more details.
	
	The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:hl7="urn:hl7-org:v3" xmlns:saxon="http://saxon.sf.net/" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xis="http://art-decor.org/ns/xis" xmlns:UML="omg.org/UML1.3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" exclude-result-prefixes="#all" version="2.0">
    <xsl:output method="xhtml" exclude-result-prefixes="#all" encoding="UTF-8"/>
    <xsl:param name="xslt.root" select="'/'"/>
    <xsl:param name="language" select="'nl-NL'"/>
    <xsl:template match="/xis:validation">
        <html>
            <head>
                <style type="text/css" media="print, screen">
                    body{
                        font-family:Verdana;
                        font-size:12px;
                    }
                    h1{
                        font-size:20px;
                        font-weight:bold;
                        margin-left:0px;
                        margin-right:0px;
                        margin-top:10px;
                        margin-bottom:10px;
                        color:#e16e22;
                    }
                    table{
                        width:100%;
                        border-bottom:1px solid lavender;
                        font-family:Verdana;
                        font-size:12px;
                    }
                    table.outer{
                        border-style:none;
                    }
                    th{
                        background-color:lightgrey;
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
                    th{
                        font-weight:bold;
                        text-align:left;
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
                    td.item-label{
                        width:15%;
                        background-color:#f0ebe4;
                        color:#7a6e62;
                        font-weight:bold;
                        padding-left:0.5em;
                        padding-right:0em;
                        padding-top:0.25em;
                        padding-bottom:0.25em;
                        text-align:left;
                        vertical-align:top;
                    }
                    td.heading{
                        background-color:#ece9e4;
                        color:#7a6e62;
                        font-size:14px;
                        font-weight:bold;
                        text-align:left;
                        vertical-align:top;
                        border-bottom:1px solid #d7b0c6;
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
                        background-color:#FFF8C6;
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
                <script language="Javascript" type="text/javascript" src="/xis/resources/scripts/nictiz.js"/>
            </head>
            <body onload="paintZebra()">
                <table width="100%">
                    <tr>
                        <td colspan="2">
                            <h1>
                                <div style="float:left">
                                    <xsl:value-of select="analyseMessage/testcase/name[@language=$language]"/>
                                </div>
                                <div style="float:right">
                                    <xsl:value-of select="format-dateTime(xs:dateTime(@dateTime), '[D01]-[M01]-[Y0001] - [H01]:[m01]:[s01]')"/>
                                </div>
                            </h1>
                        </td>
                    </tr>
                    <tr>
                        <td class="item-label">Description</td>
                        <td>
                            <xsl:value-of select="analyseMessage/testcase/desc[@language=$language]"/>
                        </td>
                    </tr>
                    <tr>
                        <td class="item-label">Message</td>
                        <td>
                            <xsl:value-of select="analyseMessage/message-path"/>
                        </td>
                    </tr>
                </table>
                <xsl:apply-templates select="analyseMessage/result/analyseConcept"/>
            </body>
        </html>
    </xsl:template>
    <xsl:template match="analyseConcept">
        <table width="100%">
            <tr>
                <td class="heading" colspan="2">
                    <xsl:value-of select="@name"/>
                    <xsl:choose>
                        <xsl:when test="test/result='success' or not(test/result)">
                            <img src="/xis/resources/images/node-sfinal.png" alt=""/>
                        </xsl:when>
                        <xsl:when test="test/result='failed'">
                            <img src="/xis/resources/images/node-sopen.png" alt=""/>
                        </xsl:when>
                    </xsl:choose>
                </td>
            </tr>
            <!--
                <test>
                    <result>failed</result>
                    <expected-value>2.16.840.1.113883.2.4.3.11.60.90.77.8.1.20050.1</expected-value>
                </test>
                <test>
                    <result>failed</result>
                    <reason>No Xpath found for concept 2.16.840.1.113883.2.4.3.11.60.90.77.2.2.20080</reason>
                </test>
            -->
            <xsl:if test="test/result">
                <tr>
                    <td class="item-label">Result</td>
                    <td>
                        <xsl:value-of select="test/result"/>
                    </td>
                </tr>
            </xsl:if>
            <xsl:if test="test/reason">
                <tr>
                    <td class="item-label">Reason</td>
                    <td>
                        <xsl:value-of select="test/reason"/>
                    </td>
                </tr>
            </xsl:if>
            <tr>
                <td class="item-label">Expected card</td>
                <td>
                    <xsl:value-of select="iter"/>
                </td>
            </tr>
            <tr>
                <td class="item-label">Found card</td>
                <td>
                    <xsl:value-of select="found"/>
                </td>
            </tr>
            <xsl:if test="at">
                <tr>
                    <td class="item-label">Xpath</td>
                    <td>
                        <xsl:value-of select="at/@xpath"/>
                    </td>
                </tr>
            </xsl:if>
            <xsl:if test="test/expected-value">
                <tr>
                    <td class="item-label">Expected value</td>
                    <td>
                        <xsl:value-of select="test/expected-value"/>
                    </td>
                </tr>
            </xsl:if>
            <xsl:if test="count(got-value)&gt;0">
                <tr>
                    <td class="item-label">Found value</td>
                    <td>
                        <xsl:value-of select="got-value"/>
                    </td>
                </tr>
            </xsl:if>
            <xsl:if test="analyseConcept">
                <tr>
                    <td class="item-label"/>
                    <td>
                        <xsl:apply-templates select="analyseConcept"/>
                    </td>
                </tr>
            </xsl:if>
        </table>
    </xsl:template>
</xsl:stylesheet>