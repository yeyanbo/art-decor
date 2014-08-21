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
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0">
    <xsl:output method="xml" indent="yes"/>
    <xsl:include href="ada-basics.xsl"/>
    <xsl:template match="/">
        <xsl:apply-templates select="ada/transactionDatasets/dataset"/>
    </xsl:template>

    <xsl:template name="dataset" match="dataset[@transactionId]">
        <xsl:variable name="href" select="concat($projectDiskRoot, 'schemas/', @shortName, '.xsd')"/>
        <xsl:variable name="schema">
            <xs:schema>
                <xsl:comment>ADA Schema generator, <xsl:value-of select="current-dateTime()"/></xsl:comment>
                <xsl:text>&#xa;</xsl:text>
                <xsl:comment>Type for empty value-strings on non-mandatory concepts</xsl:comment>
                <xs:simpleType name="empty_string">
                    <xs:restriction base="xs:string"> </xs:restriction>
                </xs:simpleType>
                <xsl:comment>Schema for transaction: <xsl:value-of select="@transactionId"/></xsl:comment>
                <xsl:text>&#xa;</xsl:text>
                <xs:element name="{@shortName}"  type="{@shortName}_type"/>
                <xs:complexType name="{@shortName}_type">
                    <xs:sequence>
                        <xsl:apply-templates select="concept[@type='group']"/>
                    </xs:sequence>
                    <xs:attribute name="id" type="xs:string"/>
                    <xs:attribute name="app" type="xs:string"/>
                    <xs:attribute name="transactionRef" type="xs:string"/>
                    <xs:attribute name="transactionEffectiveDate" type="xs:dateTime"/>
                    <xs:attribute name="versionDate" type="xs:string"/>
                    <xs:attribute name="language" type="xs:string"/>
                    <xs:attribute name="prefix" type="xs:string"/>
                    <xs:attribute name="adaVersion" type="xs:decimal"/>
                </xs:complexType>
                <xsl:apply-templates select=".//concept[@type='item']"/>
            </xs:schema>
        </xsl:variable>
        <xsl:result-document method="xml" href="{$href}">
            <xsl:copy-of select="$schema"/>
        </xsl:result-document>
        <!-- Draft schema, will be copy of original schema, but 
        <attribute name="value" use="required"/>
        is replaced by
        <attribute name="value"/>
        which makes elements without @value valid, even for 1..1 elements.
        Allows 'draft' xml which still is incomplete to be valid against {schema-name}-draft.xsd
        -->
        <xsl:variable name="href-draft" select="concat($projectDiskRoot, 'schemas/', @shortName, '_draft.xsd')"/>
        <xsl:result-document method="xml" href="{$href-draft}">
            <xsl:apply-templates mode="doDraftSchema" select="$schema/*"/>
        </xsl:result-document>
        <!-- Wrapper schema which validates ADA XML Storage format -->
        <xsl:result-document method="xml" href="{concat($projectDiskRoot, 'schemas/ada_', @shortName, '.xsd')}">
            <xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema" elementFormDefault="qualified">
                <xs:include schemaLocation="{@shortName}.xsd"/>
                <xs:include schemaLocation="ada_meta.xsd"/>
                <xs:element name="adaxml">
                    <xs:complexType>
                        <xs:sequence>
                            <xs:element name="meta" type="meta_type"/>
                            <xs:element name="data">
                                <xs:complexType>
                                    <xs:sequence>
                                        <xs:element name="{@shortName}" type="{@shortName}_type"/>
                                    </xs:sequence>
                                </xs:complexType>
                            </xs:element>
                        </xs:sequence>
                    </xs:complexType>
                </xs:element>
            </xs:schema>
        </xsl:result-document>
        <!-- Wrapper schema which validates ADA XML Storage format for drafts -->
        <xsl:result-document method="xml" href="{concat($projectDiskRoot, 'schemas/ada_', @shortName, '_draft.xsd')}">
            <xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema" elementFormDefault="qualified">
                <xs:include schemaLocation="{@shortName}_draft.xsd"/>
                <xs:include schemaLocation="ada_meta.xsd"/>
                <xs:element name="adaxml">
                    <xs:complexType>
                        <xs:sequence>
                            <xs:element name="meta" type="meta_type"/>
                            <xs:element name="data">
                                <xs:complexType>
                                    <xs:sequence>
                                        <xs:element name="{@shortName}" type="{@shortName}_type"/>
                                    </xs:sequence>
                                </xs:complexType>
                            </xs:element>
                        </xs:sequence>
                    </xs:complexType>
                </xs:element>
            </xs:schema>
        </xsl:result-document>
        <!-- ADA meta part to be included in both -->
        <xsl:result-document method="xml" href="{concat($projectDiskRoot, 'schemas/ada_meta.xsd')}">
            <xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema" elementFormDefault="qualified">
                <xs:complexType name="meta_type">
                    <xs:sequence>
                        <xs:any namespace="##targetNamespace" minOccurs="0"  maxOccurs="unbounded"/>
                    </xs:sequence>
                    <xs:attribute name="status" type="xs:string"/>
                    <xs:attribute name="created-by" type="xs:string"/>
                    <xs:attribute name="last-update-by" type="xs:string"/>
                    <xs:attribute name="creation-date" type="xs:dateTime"/>
                    <xs:attribute name="last-update-date" type="xs:dateTime"/>
                </xs:complexType>
            </xs:schema>
        </xsl:result-document>
    </xsl:template>

    <xsl:template match="xs:attribute" mode="doDraftSchema">
        <xsl:copy>
            <xsl:apply-templates select="(@* except @use)|node()" mode="doDraftSchema"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@*|node()"  mode="doDraftSchema">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="doDraftSchema"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="concept[@type='group']">
        <xsl:comment>Hook for insertion into empty group: <xsl:value-of select="name"/></xsl:comment>
        <xs:element name="{./implementation/@shortName}-start" minOccurs="0" maxOccurs="1">
            <xs:complexType>
                <xs:attribute name="conceptId" fixed="{@id}"/>
                <xs:attribute name="hidden"/>
            </xs:complexType>
        </xs:element>
        <xsl:comment>Type for concept group: <xsl:value-of select="name"/></xsl:comment>
        <xs:element name="{./implementation/@shortName}">
            <xsl:apply-templates select="@minimumMultiplicity|@maximumMultiplicity"/>
            <xs:complexType>
                <xs:sequence>
                    <xsl:for-each select="concept">
                        <xsl:choose>
                            <xsl:when test="@type='item'">
                                <xs:element name="{./implementation/@shortName}" type="{./implementation/@shortName}_type_{translate(@id, '.', '_')}">
                                    <xsl:apply-templates select="@minimumMultiplicity|@maximumMultiplicity"/>
                                </xs:element>
                            </xsl:when>
                            <xsl:when test="@type='group'">
                                <xsl:apply-templates select="."/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:for-each>
                </xs:sequence>
                <xs:attribute name="conceptId" fixed="{@id}"/>
            </xs:complexType>
        </xs:element>
    </xsl:template>

    <xsl:template name="doConceptItems" match="concept[@type='item']">
        <xsl:comment>Type for concept item: <xsl:value-of select="name"/> - <xsl:value-of select="@minimumMultiplicity"/>..<xsl:value-of select="@maximumMultiplicity"/><xsl:value-of select="@conformance"/></xsl:comment>
        <!-- complexType for concept item -->
        <xs:complexType name="{implementation/@shortName}_type_{translate(@id, '.', '_')}">
            <!-- @conceptId -->
            <xs:attribute name="conceptId" fixed="{@id}"/>
            <!-- @value -->
            <xs:attribute name="value">
                <xsl:if test="@conformance='M'">
                    <xsl:attribute name="use">required</xsl:attribute>
                </xsl:if>
                <xsl:if test="not(valueDomain/@type='code') and not(valueDomain/property/@*)">
                    <xs:simpleType>
                        <xs:restriction>
                            <xsl:attribute name="base">
                                <xsl:choose>
                                    <xsl:when test="valueDomain/@type='count'">xs:nonNegativeInteger</xsl:when>
                                    <xsl:when test="valueDomain/@type='ordinal'">xs:integer</xsl:when>
                                    <xsl:when test="valueDomain/@type='boolean'">xs:boolean</xsl:when>
                                    <xsl:when test="valueDomain/@type='datetime'">xs:dateTime</xsl:when>
                                    <xsl:when test="valueDomain/@type='date'">xs:date</xsl:when>
                                    <xsl:when test="valueDomain/@type='duration'">xs:duration</xsl:when>
                                    <xsl:when test="valueDomain/@type='blob'">xs:base64Binary</xsl:when>
                                    <!-- this would be strange, a quantity without property, just in case... -->
                                    <xsl:when test="valueDomain/@type='quantity'">xs:decimal</xsl:when>
                                    <!-- complex, currency, ratio not supported yet -->
                                    <!-- For others (string, text, identifier, catchall we do a string -->
                                    <xsl:otherwise>xs:string</xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
                            <xsl:if
                                test="(@conformance='M') and (valueDomain[@type='string'] or valueDomain[@type='text'] or valueDomain[@type='identifier'])">
                                <xsl:comment>@conformance='M'</xsl:comment>
                                <xs:minLength value="1"/>
                                <xs:pattern value=".*[^\s].*"/>
                            </xsl:if>
                        </xs:restriction>
                    </xs:simpleType>
                </xsl:if>
                <!-- For code, always use a simpleType with enumeration -->
                <xsl:if test="valueDomain/@type='code'">
                    <xs:simpleType>
                        <xs:restriction base="xs:string">
                            <xsl:comment>valueSet/conceptList/concept</xsl:comment>
                            <xsl:for-each select="valueSet/conceptList/concept">
                                <xs:enumeration value="{@localId}">
                                    <xs:annotation>
                                        <xs:documentation>
                                            <xsl:value-of select="@displayName"/>
                                        </xs:documentation>
                                    </xs:annotation>
                                </xs:enumeration>
                            </xsl:for-each>
                        </xs:restriction>
                    </xs:simpleType>
                </xsl:if>
                <!-- For valueDomain with non-empty properties, use a simpleType memberTypes for each property -->
                <!-- 
                Note: for
                <property minInclude="25" maxInclude="240" unit="kg"/>
                <property minInclude="2500" maxInclude="24000" unit="g"/>
                this will still allow 2500 kg... To fix, we need XML Schema 1.1 or Schematron 
            -->

                <xsl:if test="not(valueDomain/@type='code') and valueDomain/property/@*">
                    <xs:simpleType>
                        <xs:union>
                            <xsl:attribute name="memberTypes">
                                <xsl:for-each select="valueDomain/property[@*]">
                                    <xsl:value-of select="../../implementation/@shortName"/>
                                    <xsl:text>_</xsl:text>
                                    <xsl:value-of select="position()"/>
                                    <xsl:text>_datatype_</xsl:text>
                                    <xsl:value-of select="translate(../../@id, '.', '_')"/>
                                    <xsl:text> </xsl:text>
                                </xsl:for-each>
                                <!-- For non-mandatory elements, allow empty value strings -->
                                <xsl:if test="@minimumMultiplicity!='1'">
                                    <xsl:text>empty_string</xsl:text>
                                </xsl:if>
                            </xsl:attribute>
                        </xs:union>
                    </xs:simpleType>
                </xsl:if>
            </xs:attribute>
            <!-- @unit, use an anonymous simpleType with enumeration -->
            <xsl:if test="(valueDomain/@type='quantity') or (valueDomain/@type='duration')">
                <xs:attribute name="unit">
                    <xs:simpleType>
                        <xs:restriction base="xs:string">
                            <xsl:for-each select="valueDomain/property/@unit">
                                <xs:enumeration value="{.}"/>
                            </xsl:for-each>
                        </xs:restriction>
                    </xs:simpleType>
                </xs:attribute>
            </xsl:if>
            <!-- @displayName, @code and @codeSystem, optional attributes for code. -->
            <xsl:if test="valueDomain/@type='code'">
                <xs:attribute name="displayName" type="xs:string"/>
                <xs:attribute name="code" type="xs:string"/>
                <xs:attribute name="codeSystem" type="xs:string"/>
            </xsl:if>
        </xs:complexType>
        <xsl:apply-templates/>
    </xsl:template>

    <!-- Do the multiplicities -->
    <xsl:template name="minimumMultiplicity" match="@minimumMultiplicity">
        <xsl:choose>
            <xsl:when test="(.='') or (.='0')">
                <xsl:attribute name="minOccurs">0</xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="minOccurs">1</xsl:attribute>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="maximumMultiplicity" match="@maximumMultiplicity">
        <xsl:choose>
            <xsl:when test="(.='') or (.='*')">
                <xsl:attribute name="maxOccurs">unbounded</xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="maxOccurs">
                    <xsl:value-of select="."/>
                </xsl:attribute>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Make a simpleType for each property. Name will be {@shortName)_{counter for each property}_datatype_{underscored_id}, 
        i.e. weight_1_datatype_2_16..., weight_2_datatype_2_16... -->
    <xsl:template name="simpleTypeForProperty" match="valueDomain[property/@*]">
        <!-- For all non-empty properties -->
        <xsl:for-each select="property[@*]">
            <xsl:variable name="baseType" as="xs:string">
                <xsl:choose>
                    <xsl:when test="../@type='count'">xs:nonNegativeInteger</xsl:when>
                    <xsl:when test="../@type='ordinal'">xs:integer</xsl:when>
                    <xsl:when test="../@type='quantity'">xs:decimal</xsl:when>
                    <xsl:when test="../@type='duration'">xs:decimal</xsl:when>
                    <xsl:otherwise>xs:string</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            
            <xsl:comment>simpleType for valueDomain: <xsl:value-of select="../../name"/>: <xsl:value-of select="../@type"/></xsl:comment>
            <xs:simpleType name="{../../implementation/@shortName}_{position()}_datatype_{translate(../../@id, '.', '_')}">
                <xs:restriction>
                    <xsl:attribute name="base" select="$baseType"/>
                    <xsl:if test="@minInclude and not($baseType='xs:string')">
                        <xsl:element name="xs:minInclusive">
                            <xsl:attribute name="value">
                                <xsl:value-of select="@minInclude"/>
                            </xsl:attribute>
                        </xsl:element>
                    </xsl:if>
                    <xsl:if test="@maxInclude and not($baseType='xs:string')">
                        <xsl:element name="xs:maxInclusive">
                            <xsl:attribute name="value">
                                <xsl:value-of select="@maxInclude"/>
                            </xsl:attribute>
                        </xsl:element>
                    </xsl:if>
                    <xsl:if test="@minLength and $baseType='xs:string'">
                        <xsl:element name="xs:minLength">
                            <xsl:attribute name="value">
                                <xsl:value-of select="@minLength"/>
                            </xsl:attribute>
                        </xsl:element>
                    </xsl:if>
                    <xsl:if test="@maxLength and $baseType='xs:string'">
                        <xsl:element name="xs:maxLength">
                            <xsl:attribute name="value">
                                <xsl:value-of select="@maxLength"/>
                            </xsl:attribute>
                        </xsl:element>
                    </xsl:if>
                </xs:restriction>
            </xs:simpleType>
        </xsl:for-each>
    </xsl:template>

    <!-- Skip the rest -->
    <xsl:template match="text()|@*"/>
</xsl:stylesheet>
