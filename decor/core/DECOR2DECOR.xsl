<?xml version="1.0" encoding="UTF-8"?>
<!--

This stylesheet takes the DECOR.xsd schema and generates a description of the Templates DSTU ITS in DECOR format

K. Heitmann 2013-12, 2014-01, 2014-07

-->
<xsl:stylesheet xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:sch="http://purl.oclc.org/dsdl/schematron" 
    xmlns:xforms="http://www.w3.org/2002/xforms" xmlns:uuid="java:java.util.UUID" xmlns:local="http://art-decor.org/functions" version="2.0" exclude-result-prefixes="xsl">

    <xsl:output method="xml" indent="yes" version="1.0" encoding="UTF-8" exclude-result-prefixes="#all" name="xml"/>
    
    <xsl:variable name="tops" select="/*"/>
    
    <xsl:variable name="adoid" select="'2.16.840.1.113883.3.1937.98'"/>
    
    <xsl:template match="/">
        <xsl:result-document format="xml" href="DECORasDECOR.xml">
            <decor-valueset-and-templates-only 
                xmlns:sch="http://purl.oclc.org/dsdl/schematron" 
                xmlns:xforms="http://www.w3.org/2002/xforms"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
                xmlns:xs="http://www.w3.org/2001/XMLSchema" 
                xsi:noNamespaceSchemaLocation="DECORrulesonly.xsd">
                
                
                <xsl:for-each select="$tops/xs:simpleType[*/xs:enumeration]">
                    <xsl:variable name="pos" select="position()"/>
                    <valueSet name="{@name}" displayName="{@name}" id ="{concat($adoid, '.11.', $pos)}" effectiveDate="2013-12-05T00:00:00" statusCode="draft">
                        <conceptList>
                            <xsl:for-each select="*/xs:enumeration">
                                <xsl:variable name="dn" select="(xs:annotation/xs:appinfo/xforms:label[@xml:lang='en-US'])[1]"/>
                                <concept code="{@value}" codeSystem="{concat($adoid, '.5.', $pos)}" displayName="{if (string-length($dn)>0) then $dn else @value}" type="L" level="0"/>
                            </xsl:for-each>
                        </conceptList>
                    </valueSet>
                </xsl:for-each>
                
                <xsl:variable name="temp">
                    <xsl:apply-templates select="//xs:complexType[@name='TemplateDefinition']" mode="template"/>
                </xsl:variable>
                <xsl:for-each select="$temp/template">
                    <xsl:variable name="pos" select="position()"/>
                    <template>
                        <xsl:attribute name="id" select="concat($adoid, '.', $pos)"/>
                        <xsl:copy-of select="@* except @id"/>
                        <xsl:copy-of select="*"/>
                    </template>
                </xsl:for-each>
                
            </decor-valueset-and-templates-only>
            
            
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="dorefs">
        <xsl:for-each-group select=".//xs:element[@ref]" group-by="@ref">
            <xsl:variable name="name" select="@ref"/>
            <xsl:apply-templates select="/*/xs:element[@name=$name]" mode="template"/>
        </xsl:for-each-group>
        <xsl:for-each-group select=".//xs:attribute[@ref]" group-by="@ref">
            <xsl:variable name="name" select="@ref"/>
            <xsl:apply-templates select="/*/xs:attribute[@name=$name]" mode="template"/>
        </xsl:for-each-group>
        <xsl:for-each-group select=".//xs:attributeGroup[@ref]" group-by="@ref">
            <xsl:variable name="name" select="@ref"/>
            <xsl:apply-templates select="/*/xs:attributeGroup[@name=$name]" mode="template"/>
        </xsl:for-each-group>
    </xsl:template>

    <xsl:template match="xs:complexType" mode="template">
        <template id="-will-be-replaced-" name="DECOR" displayName="DECOR" effectiveDate="2013-12-05T00:00:00" statusCode="draft">
            <desc language="en-US">DECOR definitions to describe DECOR in DECOR</desc>
            <element name="hl7:template" minimumMultiplicity="0" maximumMultiplicity="*">
                <xsl:apply-templates select="xs:attribute|xs:attributeGroup" mode="main"/>
                <xsl:apply-templates select="xs:sequence/(xs:element|xs:choice)" mode="main"/>
            </element>
        </template>
        <xsl:call-template name="dorefs"/>
    </xsl:template>

    <xsl:template match="xs:complexType" mode="main">
        <xsl:apply-templates select="xs:attribute|xs:attributeGroup" mode="main"/>
        <xsl:apply-templates select="xs:sequence/(xs:element|xs:choice)" mode="main"/>
    </xsl:template>
    
    
    <xsl:template match="xs:attribute" mode="main">
        <xsl:choose>
            <xsl:when test="@name">
                <attribute name="{@name}">
                    <xsl:call-template name="doAttrCard"/>
                </attribute>
            </xsl:when>
            <xsl:when test="@ref">
                <attribute name="{@ref}">
                    <xsl:call-template name="doAttrCard"/>
                    <xsl:call-template name="doElmCard"/>
                </attribute>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="doAttrCard">
        <xsl:choose>
            <xsl:when test="@use='optional'">
                <xsl:attribute name="isOptional" select="'true'"/>
            </xsl:when>
            <xsl:when test="@use='required'">
                <xsl:attribute name="isOptional" select="'false'"/>
            </xsl:when>
        </xsl:choose>
        <xsl:if test="@type">
            <xsl:variable name="name" select="@type"/>
            <xsl:choose>
                <xsl:when test="$tops/xs:simpleType[@name=$name]/*/xs:enumeration">
                    <vocabulary valueSet="{@type}"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="datatype">
                        <xsl:attribute name="datatype" select="@type"/>
                    </xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="xs:attribute" mode="template">
        <template id="-will-be-replaced-" name="{@name}">
            <attribute name="{@name}">
                <xsl:call-template name="doAttrCard"/>
            </attribute>
        </template>
        <xsl:call-template name="dorefs"/>
    </xsl:template>
    
    <xsl:template match="xs:attributeGroup" mode="main">
        <xsl:choose>
            <xsl:when test="@ref">
                <include ref="{@ref}"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="xs:attributeGroup" mode="template">
        <template id="-will-be-replaced-" name="{@name}">
            <xsl:apply-templates select="xs:attribute|xs:attributeGroup" mode="main"/>
        </template>
        <xsl:call-template name="dorefs"/>
    </xsl:template>
    
    <xsl:template match="xs:choice" mode="main">
        <choice>
            <xsl:apply-templates select="xs:element" mode="main"/>
        </choice>
    </xsl:template>
    
    <xsl:template match="xs:element" mode="main">
        <xsl:choose>
            <xsl:when test="@name">
                <element name="{@name}">
                    <xsl:call-template name="doElmCard"/>
                    <xsl:apply-templates select="xs:complexType" mode="main"/>
                </element>
            </xsl:when>
            <xsl:when test="@ref">
                <include ref="{@ref}">
                    <xsl:call-template name="doElmCard"/>
                </include>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="doElmCard">
        <xsl:choose>
            <xsl:when test="@minOccurs='0' and @maxOccurs='0'">
                <xsl:attribute name="conformance" select="'NP'"/>
            </xsl:when>
            <xsl:when test="@minOccurs or @maxOccurs">
                <xsl:if test="@minOccurs">
                    <xsl:attribute name="minimumMultiplicity" select="@minOccurs"/>
                </xsl:if>
                <xsl:if test="@maxOccurs">
                    <xsl:attribute name="maximumMultiplicity">
                        <xsl:choose>
                            <xsl:when test="@maxOccurs='unbounded'">
                                <xsl:value-of select="'*'"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="@maxOccurs"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                </xsl:if>
            </xsl:when>
        </xsl:choose>        
        <xsl:if test="@type">
            <xsl:variable name="name" select="@type"/>
            <xsl:choose>
                <xsl:when test="$tops/xs:complexType[@name=$name]">
                    <include ref="{@type}"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="datatype">
                        <xsl:value-of select="@type"/>
                    </xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="xs:element" mode="template">
        <template id="-will-be-replaced-" name="{@name}">
            <element name="{@name}">
                <xsl:apply-templates select="xs:complexType" mode="main"/>
            </element>
        </template>
        <xsl:call-template name="dorefs"/>
    </xsl:template>
    
    <xsl:template match="text()|node()|xs:annotation|xs:documentation|xs:appinfo|sch:pattern" mode="#all"/>
    
</xsl:stylesheet>