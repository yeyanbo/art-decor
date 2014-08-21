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
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:saxon="http://saxon.sf.net/" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:hl7="urn:hl7-org:v3" xmlns:UML="omg.org/UML1.3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" exclude-result-prefixes="#all" version="2.0">
    <xsl:output method="xhtml" exclude-result-prefixes="#all" encoding="UTF-8"/>
    <xsl:param name="xslt.root" select="'/'"/>
    <xsl:param name="referenceDateString" select="''"/>
<!--   <xsl:variable name="referenceDate" select="xs:date($referenceDateString)"/>-->
    <xsl:variable name="referenceDate" select="current-date()"/>
    <xsl:template match="/medicationOverview">
        <html>
            <head>
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
               <!--                    <thead class="pagetitle">
                        <tr>
                            <th class="title">
                                <xsl:text>MEDICATIEOVERZICHT </xsl:text>
                                <xsl:value-of select="format-date( $referenceDate,'[D]-[M]-[Y]')"/>
                            </th>
                        </tr>
                    </thead>-->
                    <tbody>
                        <xsl:apply-templates select="patient"/>
                        <xsl:if test="conditions/condition">
                            <xsl:apply-templates select="conditions"/>
                        </xsl:if>
                        <xsl:if test="medications/medication">
                            <xsl:apply-templates select="medications"/>
                        </xsl:if>
                        <xsl:if test="labresults/labresult">
                            <xsl:apply-templates select="labresults"/>
                        </xsl:if>
                    </tbody>
               <!--<tfoot>
                        <tr>
                            <td>Dit medicatieoverzicht is met grote zorgvuldigheid samengesteld. Het bevat de gegevens die bekend zijn bij deze zorgverlener en behoeft<br/>
                        daarom niet compleet te zijn. Als geneesmiddelgebruiker heeft ook u de eigen verantwoordelijkheid om uw apotheek op de hoogte te stellen<br/>
                        van uw geneesmiddelgebruik. De zorgverlener is niet aansprakelijk voor fouten in dit medicatieoverzicht, tenzij er sprake is van opzet of grove schuld.</td>
                        </tr>
                    </tfoot>-->
                </table>
            </body>
        </html>
    </xsl:template>
    <xsl:template match="patient">
        <tr>
            <td>
                <table>
                    <tr>
                        <td class="botrule">Patiënt</td>
                        <td class="botrule">
                            <xsl:value-of select="name"/>
                        </td>
                        <td class="botrule">BSN</td>
                        <td class="botrule">
                            <xsl:value-of select="bsn"/>
                        </td>
                        <td class="botrule">Geverifieerd met patiënt</td>
                        <td class="botrule">TODO Ja/Nee</td>
                        <td rowspan="4" style="border: 1px solid black;">
                     Afgegeven door:
                     <br/>
                     TODO AORTA
                     <br/>
                     TODO Aantal systemen: <xsl:value-of select="''"/>
                        </td>
                    </tr>
                    <tr>
                        <td class="botrule">Adres</td>
                        <td class="botrule">
                            <xsl:value-of select="addres"/>
                        </td>
                        <td class="botrule">Geb. Datum</td>
                        <td class="botrule">
                            <xsl:value-of select="birthDate"/>
                        </td>
                        <td class="botrule">Patiënt heeft innameschema</td>
                        <td class="botrule">TODO Ja/Nee</td>
                    </tr>
                    <tr>
                        <td class="botrule">Postcode &amp; plaats</td>
                        <td class="botrule">
                            <xsl:value-of select="postcodeCity"/>
                        </td>
                        <td class="botrule">Geslacht</td>
                        <td class="botrule">
                            <xsl:value-of select="gender"/>
                        </td>
                        <td class="botrule">&#160;</td>
                        <td class="botrule">&#160;</td>
                    </tr>
                    <tr>
                        <td class="botrule">Telefoon</td>
                        <td class="botrule">
                            <xsl:value-of select="telephone"/>
                        </td>
                        <td class="botrule">Lengte/gewicht</td>
                        <td class="botrule">TODO 1,98 m/85 Kg</td>
                        <td class="botrule" colspan="2">Datum gewicht: TODO nvt</td>
                    </tr>
                </table>
            </td>
        </tr>
    </xsl:template>
    <xsl:template match="conditions">
      <!-- ICA Header -->
        <tr>
            <th class="section">Intoleranties, Contra indicaties, Allergieën (ICA)</th>
        </tr>
      <!-- ICA content -->
        <tr>
            <td>
                <table class="zebra scheme1">
                    <tr>
                        <th>Omschrijving</th>
                        <th>Datum</th>
                        <th>Einddatum</th>
                        <th>Soort</th>
                        <th>Opmerking</th>
                        <th>Melder</th>
                    </tr>
                    <xsl:for-each select="condition">
                        <tr>
                            <td>
                                <xsl:if test="@negationInd='true'">
                                    <strong>Geen </strong>
                                </xsl:if>
                                <xsl:value-of select="description"/>
                            </td>
                            <td>
                                <xsl:value-of select="startDate"/>
                            </td>
                            <td>
                                <xsl:value-of select="stopDate"/>
                            </td>
                            <td>
                                <xsl:value-of select="type"/>
                            </td>
                            <td>
                                <xsl:value-of select="remark"/>
                            </td>
                            <td>
                                <xsl:value-of select="author"/>
                            </td>
                        </tr>
                    </xsl:for-each>
                </table>
            </td>
        </tr>
    </xsl:template>
    <xsl:template match="medications">
        <tr>
            <th class="section">Medicatie (Voorschriften / Afleveringen)</th>
        </tr>
        <tr>
            <td>
                <xsl:call-template name="active-medication"/>
            </td>
        </tr>
        <tr>
            <th class="section">Gestopte medicatie (actief/gedurende ziekenhuisopname)</th>
        </tr>
        <tr>
            <td>
                <xsl:call-template name="inactive-medication"/>
            </td>
        </tr>
    </xsl:template>
    <xsl:template name="active-medication">
        <table width="100%" class="zebra scheme1">
         <!-- Prescriptions / DispenseEvents Header -->
            <tr>
                <th width="30%">Geneesmiddel (op ATC code)</th>
                <th width="10%">Datum</th>
                <th width="10%">Einddatum</th>
                <th width="10%">Dosering</th>
                <th width="20%">Toelichting</th>
                <th width="10%">TW</th>
                <th width="10%">Door</th>
            </tr>
         <!-- Prescriptions / DispenseEvents Content -->
            <xsl:for-each select="medication">
                <xsl:sort select="@atc"/>
                <xsl:variable name="id" select="generate-id(.)"/>
                <xsl:variable name="class">
                    <xsl:choose>
                        <xsl:when test="medication">
                            <xsl:text>toggler</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>normal</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="icon">
                    <xsl:choose>
                        <xsl:when test="@type='prescription'">
                            <xsl:value-of select="'/xis/resources/images/doctor.png'"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>/xis/resources/images/pharmacy.png</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="maxStopDate">
                    <xsl:choose>
                        <xsl:when test="@stop/string-length()&gt;0">
                            <xsl:value-of select="xs:decimal(max(.//@stop))"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="''"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="active">
                    <xsl:choose>
                        <xsl:when test="concat(substring($maxStopDate,1,4),'-',substring($maxStopDate,5,2),'-',substring($maxStopDate,7,2)) castable as xs:date">
                            <xsl:choose>
                                <xsl:when test="xs:date(concat(substring($maxStopDate,1,4),'-',substring($maxStopDate,5,2),'-',substring($maxStopDate,7,2))) &lt; $referenceDate">
                                    <xsl:value-of select="'false'"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="'true'"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="'true'"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:if test="$active='true'">
                    <tr>
                        <td colspan="7">
                            <table width="100%">
                                <tr>
                                    <td width="30%" id="{concat($id,'-toggler')}" class="{$class}">
                                        <xsl:if test="medication">
                                            <xsl:attribute name="onclick" select="concat('return toggle(&#34;',$id,'&#34;,&#34;',concat($id,'-toggler'),'&#34;)')"/>
                                        </xsl:if>
                                        <xsl:choose>
                                            <xsl:when test="string-length(product/description)&gt;0">
                                                <a class="tooltip" href="#">
                                                    <xsl:value-of select="product/name"/>
                                                    <span class="classic">
                                                        <xsl:value-of select="product/description"/>
                                                    </span>
                                                </a>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <span>
                                                    <xsl:value-of select="product/name"/>
                                                    <br/>
                                                    <xsl:value-of select="product/labelName"/>
                                                </span>
                                            </xsl:otherwise>
                                        </xsl:choose>
                              <!-- <xsl:if test="string-length(product/description)>0">
                                            <a class="tooltip" href="#">
                                                <xsl:value-of select="product/name"/>
                                                <span class="classic">
                                                    <xsl:value-of select="product/description"/>
                                                </span>
                                            </a>
                                        </xsl:if>-->
                                    </td>
                                    <td width="10%">
                                        <xsl:call-template name="formatHL7Date">
                                            <xsl:with-param name="hl7Date" select="@start"/>
                                        </xsl:call-template>
                                    </td>
                                    <td width="10%">
                                        <xsl:call-template name="formatHL7Date">
                                            <xsl:with-param name="hl7Date" select="@stop"/>
                                        </xsl:call-template>
                                    </td>
                                    <td width="10%">
                                        <xsl:value-of select="usage"/>
                                    </td>
                                    <td width="20%">
                                        <xsl:value-of select="reason"/>
                                    </td>
                                    <td width="10%">
                                        <xsl:value-of select="product/route"/>
                                    </td>
                                    <td width="10%">
                                        <img src="{$icon}" style="float:left;"/>
                                        <xsl:value-of select="author"/>
                                    </td>
                                </tr>
                            </table>
                            <table width="100%" id="{$id}" class="toggled">
                                <xsl:for-each select="medication">
                                    <tr>
                                        <td width="30%" class="indent">
                                            <xsl:if test="string-length(product/description)&gt;0">
                                                <a class="tooltip" href="#">
                                                    <xsl:value-of select="product/name"/>
                                                    <span class="classic">
                                                        <xsl:value-of select="product/description"/>
                                                    </span>
                                                </a>
                                            </xsl:if>
                                            <span>
                                                <xsl:value-of select="product/name"/>
                                                <br/>
                                                <xsl:value-of select="product/labelName"/>
                                            </span>
                                        </td>
                                        <td width="10%">
                                            <xsl:call-template name="formatHL7Date">
                                                <xsl:with-param name="hl7Date" select="@start"/>
                                            </xsl:call-template>
                                        </td>
                                        <td width="10%">
                                            <xsl:call-template name="formatHL7Date">
                                                <xsl:with-param name="hl7Date" select="@stop"/>
                                            </xsl:call-template>
                                        </td>
                                        <td width="10%">
                                            <xsl:value-of select="usage"/>
                                        </td>
                                        <td width="20%">
                                            <xsl:value-of select="reason"/>
                                        </td>
                                        <td width="10%">
                                            <xsl:value-of select="route"/>
                                        </td>
                                        <td width="10%">
                                            <img src="/xis/resources/images/pharmacy.png" style="float:left;"/>
                                            <xsl:value-of select="author"/>
                                        </td>
                                    </tr>
                                </xsl:for-each>
                            </table>
                        </td>
                    </tr>
                </xsl:if>
            </xsl:for-each>
        </table>
    </xsl:template>
    <xsl:template name="inactive-medication">
        <table width="100%" class="zebra scheme1">
         <!-- Prescriptions / DispenseEvents Header -->
            <tr>
                <th width="30%">Geneesmiddel (op ATC code)</th>
                <th width="10%">Datum</th>
                <th width="10%">Einddatum</th>
                <th width="10%">Dosering</th>
                <th width="20%">Toelichting</th>
                <th width="10%">TW</th>
                <th width="10%">Door</th>
            </tr>
         <!-- Prescriptions / DispenseEvents Content -->
            <xsl:for-each select="medication">
                <xsl:sort select="@atc"/>
                <xsl:variable name="id" select="generate-id(.)"/>
                <xsl:variable name="class">
                    <xsl:choose>
                        <xsl:when test="medication">
                            <xsl:text>toggler</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>normal</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="icon">
                    <xsl:choose>
                        <xsl:when test="@type='prescription'">
                            <xsl:text>/xis/resources/images/doctor.png</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>/xis/resources/images/pharmacy.png</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="maxStopDate">
                    <xsl:choose>
                        <xsl:when test="@stop/string-length()&gt;0">
                            <xsl:value-of select="xs:decimal(max(.//@stop))"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="''"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="active">
                    <xsl:choose>
                        <xsl:when test="concat(substring($maxStopDate,1,4),'-',substring($maxStopDate,5,2),'-',substring($maxStopDate,7,2)) castable as xs:date">
                            <xsl:choose>
                                <xsl:when test="xs:date(concat(substring($maxStopDate,1,4),'-',substring($maxStopDate,5,2),'-',substring($maxStopDate,7,2))) &lt; $referenceDate">
                                    <xsl:value-of select="xs:boolean('false')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="xs:boolean('true')"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="xs:boolean('true')"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:if test="$active='false'">
                    <tr>
                        <td colspan="7">
                            <table width="100%">
                                <tr>
                                    <td width="30%" id="{concat($id,'-toggler')}" class="{$class}">
                                        <xsl:if test="medication">
                                            <xsl:attribute name="onclick" select="concat('return toggle(&#34;',$id,'&#34;,&#34;',concat($id,'-toggler'),'&#34;)')"/>
                                        </xsl:if>
                                        <xsl:choose>
                                            <xsl:when test="string-length(product/description)&gt;0">
                                                <a class="tooltip" href="#">
                                                    <xsl:value-of select="product/name"/>
                                                    <span class="classic">
                                                        <xsl:value-of select="product/description"/>
                                                    </span>
                                                </a>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <span>
                                                    <xsl:value-of select="product/name"/>
                                                    <br/>
                                                    <xsl:value-of select="product/labelName"/>
                                                </span>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </td>
                                    <td width="10%">
                                        <xsl:call-template name="formatHL7Date">
                                            <xsl:with-param name="hl7Date" select="@start"/>
                                        </xsl:call-template>
                                    </td>
                                    <td width="10%">
                                        <xsl:call-template name="formatHL7Date">
                                            <xsl:with-param name="hl7Date" select="@stop"/>
                                        </xsl:call-template>
                                    </td>
                                    <td width="10%">
                                        <xsl:value-of select="usage"/>
                                    </td>
                                    <td width="20%">
                                        <xsl:value-of select="reason"/>
                                    </td>
                                    <td width="10%">
                                        <xsl:value-of select="route"/>
                                    </td>
                                    <td width="10%">
                                        <img src="{$icon}" style="float:left;"/>
                                        <xsl:value-of select="author"/>
                                    </td>
                                </tr>
                            </table>
                            <table width="100%" id="{$id}" class="toggled">
                                <xsl:for-each select="medication">
                                    <tr>
                                        <td width="30%" class="indent">
                                            <xsl:if test="string-length(product/description)&gt;0">
                                                <a class="tooltip" href="#">
                                                    <xsl:value-of select="product/name"/>
                                                    <span class="classic">
                                                        <xsl:value-of select="product/description"/>
                                                    </span>
                                                </a>
                                            </xsl:if>
                                            <span>
                                                <xsl:value-of select="product/name"/>
                                                <br/>
                                                <xsl:value-of select="product/labelName"/>
                                            </span>
                                        </td>
                                        <td width="10%">
                                            <xsl:call-template name="formatHL7Date">
                                                <xsl:with-param name="hl7Date" select="@start"/>
                                            </xsl:call-template>
                                        </td>
                                        <td width="10%">
                                            <xsl:call-template name="formatHL7Date">
                                                <xsl:with-param name="hl7Date" select="@stop"/>
                                            </xsl:call-template>
                                        </td>
                                        <td width="10%">
                                            <xsl:value-of select="usage"/>
                                        </td>
                                        <td width="20%">
                                            <xsl:value-of select="reason"/>
                                        </td>
                                        <td width="10%">
                                            <xsl:value-of select="route"/>
                                        </td>
                                        <td width="10%">
                                            <img src="/xis/resources/images/pharmacy.png" style="float:left;"/>
                                            <xsl:value-of select="author"/>
                                        </td>
                                    </tr>
                                </xsl:for-each>
                            </table>
                        </td>
                    </tr>
                </xsl:if>
            </xsl:for-each>
        </table>
    </xsl:template>
    <xsl:template match="labresults">
      <!-- Labresults Header -->
        <tr>
            <th class="section">Aanvullende labwaarden op aanvraag</th>
        </tr>
      <!-- ICA content -->
        <tr>
            <td>
                <table class="zebra scheme1">
                    <tr>
                        <th>Lab</th>
                        <th>Datum</th>
                        <th>Uitslag</th>
                        <th>Methode/referentiewaarde</th>
                    </tr>
                    <xsl:for-each select="labresult">
                        <tr>
                            <td class="{if (interpretationCode/@code!='N') then 'alert' else ''}">
                                <xsl:value-of select="lab"/>
                            </td>
                            <td class="{if (interpretationCode/@code!='N') then 'alert' else ''}">
                                <xsl:value-of select="date"/>
                            </td>
                            <td class="{if (interpretationCode/@code!='N') then 'alert' else ''}">
                                <xsl:value-of select="result"/>
                            </td>
                            <td>
                                <xsl:value-of select="reference"/>
                            </td>
                        </tr>
                    </xsl:for-each>
                </table>
            </td>
        </tr>
    </xsl:template>
    <xsl:template name="formatHL7Date">
        <xsl:param name="hl7Date"/>
        <xsl:value-of select="concat(substring($hl7Date,7,2),'-',substring($hl7Date,5,2),'-',substring($hl7Date,1,4))"/>
    </xsl:template>
</xsl:stylesheet>