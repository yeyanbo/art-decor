<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="hl7v2.xml_2_templates.xsl"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:hl7v2="urn:hl7-org:v2xml"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:local="urn:local"
    exclude-result-prefixes="#all"
    version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> May 9, 2014</xd:p>
            <xd:p><xd:b>Author:</xd:b> ahenket</xd:p>
            <xd:p></xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:output indent="yes" omit-xml-declaration="yes"/>
    
    <xsl:variable name="classification-format" select="'hl7v2.5xml'"/>
    <xsl:variable name="template-default-id-root-messages" select="'2.16.840.1.113883.3.1937.99.60.4.12'"/>
    <xsl:variable name="template-default-id-root-segments" select="'2.16.840.1.113883.3.1937.99.60.4.13'"/>
    <xsl:variable name="template-default-id-root-fields" select="'2.16.840.1.113883.3.1937.99.60.4.14'"/>
    <xsl:variable name="template-default-id-root-datatypes" select="'2.16.840.1.113883.3.1937.99.60.4.15'"/>
    <xsl:variable name="template-default-status" select="'draft'"/>
    <xsl:variable name="template-default-effectiveDate" select="'2013-02-10T00:00:00'"/>
    <xsl:variable name="message-definitions" select="collection(iri-to-uri(concat('v25/xsd?select=', '???.xsd;recurse=no')))|collection(iri-to-uri(concat('v25/xsd?select=', '???_???.xsd;recurse=no')))"/>
    <xsl:variable name="segment-definitions" select="doc('v25/xsd/segments.xsd')/xs:schema/xs:element"/>
    <xsl:variable name="field-definitions" select="doc('v25/xsd/fields.xsd')/xs:schema/xs:element"/>
    <xsl:variable name="baseTypes" select="$field-definitions/ancestor::xs:schema//@base"/>
    <xsl:variable name="datatype-definitions" select="doc('v25/xsd/datatypes.xsd')/xs:schema"/>
    
    <xsl:template match="/">
        <xsl:result-document href="../../decor/core/DECOR-supported-datatypes-hl7v2.5xml.xml" method="xml" indent="yes">
            <xsl:comment>
    DECOR-supported-datatypes
    Copyright (C) 2013-214 Dr. Kai U. Heitmann, Alexander Henket
    
    List of supported data types in ART-DECOR
    
    reflects data types as &lt;dataType&gt; elements with the name
    name must be present (as of now) in coreschematrons directory as DTr1_{name}.sch
    
    data type elements are hierarchical representing inheritence, e.g.
    a SC is_a ST is_a ED is_a BIN 
    
    Also reflects possibility of demotion
    
    &lt;flavor&gt; elements may be added as immediate child elements of a data type
    to reflect a data type flavor (variant, data type with further constraint), 
    additionally shall carry a realm indicator, e.g. DE, NL, AT etc. or UV
    
    The mapping to one of the value domain data types of concepts in data sets 
    is also shown.
    So far the possible mapping is shown for the following value domain data types
      blob boolean code complex date datetime decimal duration identifier ordinal
      quantity string text count&#10;</xsl:comment>
            <xsl:text>&#10;</xsl:text>
            <xsl:processing-instruction name="xml-model">href="DECOR-supported-datatypes.sch" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:processing-instruction>
            <xsl:text>&#10;</xsl:text>
            <supportedDataTypes type="{$classification-format}">
                <xsl:for-each select="$datatype-definitions/xs:*[@name=$baseTypes] | $datatype-definitions/xs:*[@name=$datatype-definitions//@base]">
                    <dataType name="{@name}"/>
                </xsl:for-each>
            </supportedDataTypes>
        </xsl:result-document>
        
        <!--xsl:for-each select="$datatype-definitions/xs:*[@name=$baseTypes] | $datatype-definitions/xs:*[@name=$datatype-definitions//@base]">
            <xsl:result-document href="file:/Users/ahenket/Development/sourceforge-exist/trunk/decor/core/coreschematrons-hl7v2.5xml/DTv25_{@name}.sch" method="xml" indent="yes">
                <xsl:comment>
                    <xsl:text>&#10;    </xsl:text>
                    <xsl:text>HL7 V2.5 - Datatype </xsl:text>
                    <xsl:value-of select="@name"/>
                    <xsl:text>&#10;    </xsl:text>
                    <xsl:text>Status: draft</xsl:text>
                    <xsl:text>&#10;</xsl:text>
                </xsl:comment>
                <xsl:text>&#10;</xsl:text>
                <rule abstract="true" id="{@name}" xmlns="http://purl.oclc.org/dsdl/schematron"/>
            </xsl:result-document>
        </xsl:for-each-->
        
        <rules>
            <template id="{$template-default-id-root-messages}.1" name="BATCH" effectiveDate="2013-02-10T00:00:00" statusCode="draft">
                <classification type="messagelevel" format="{$classification-format}"/>
                <context path="/"/>
                <element name="hl7v2:BATCH">
                    <element name="hl7v2:FHS" contains="FHS_segment" minimumMultiplicity="0" maximumMultiplicity="1"/>
                    <include ref="MESSAGEBATCH" minimumMultiplicity="0" maximumMultiplicity="*"/>
                    <element name="hl7v2:FTS" contains="FTS_segment" minimumMultiplicity="0" maximumMultiplicity="1"/>
                </element>
            </template>
            
            <template id="{$template-default-id-root-messages}.2" name="MESSAGEBATCH" effectiveDate="2013-02-10T00:00:00" statusCode="draft">
                <classification type="messagelevel" format="{$classification-format}"/>
                <context path="//"/>
                <element name="hl7v2:MESSAGEBATCH">
                    <element name="hl7v2:BHS" contains="BHS_segment" minimumMultiplicity="0" maximumMultiplicity="1"/>
                    <element name="hl7v2:QRD" contains="QRD_segment" minimumMultiplicity="0" maximumMultiplicity="1"/>
                    <element name="hl7v2:QRF" contains="QRF_segment" minimumMultiplicity="0" maximumMultiplicity="1"/>
                    <element name="hl7v2:MESSAGES" minimumMultiplicity="0" maximumMultiplicity="*">
                        <desc language="en-US">Any message type</desc>
                    </element>
                    <element name="hl7v2:BTS" contains="BTS_segment" minimumMultiplicity="0" maximumMultiplicity="1"/>
                </element>
            </template>
            
            <xsl:for-each select="$message-definitions">
                <xsl:call-template name="process-xsd">
                    <xsl:with-param name="id-start" select="2"/>
                    <xsl:with-param name="id-root" select="$template-default-id-root-messages"/>
                    <xsl:with-param name="template-classification" as="element(classification)">
                        <classification type="messagelevel" format="{$classification-format}"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:for-each>
            
            <template id="{$template-default-id-root-segments}.0" name="QVR_Q17_QBP_group" effectiveDate="2013-02-10T00:00:00" statusCode="draft">
                <classification type="segmentlevel" format="{$classification-format}"/>
                <element name="hl7v2:QVR_Q17.QBP" contains="QVR_Q17_QBP_group" minimumMultiplicity="0" maximumMultiplicity="1"/>
            </template>
            
            <xsl:for-each select="$segment-definitions">
                <xsl:call-template name="process-xsd">
                    <xsl:with-param name="id-root" select="$template-default-id-root-segments"/>
                    <xsl:with-param name="template-classification" as="element()">
                        <classification type="segmentlevel" format="{$classification-format}"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:for-each>
            
            <template id="{$template-default-id-root-datatypes}.0" name="escapeType_datatype" effectiveDate="2013-02-10T00:00:00" statusCode="draft">
                <classification type="datatypelevel" format="{$classification-format}"/>
                <element name="hl7v2:escape" contains="escapeType_datatype" minimumMultiplicity="0">
                    <attribute name="V"/>
                </element>
            </template>
            <xsl:for-each select="$datatype-definitions/xs:complexType[@name=$baseTypes] | $datatype-definitions/xs:complexType[@name=$datatype-definitions//@base]">
                <xsl:call-template name="process-xsd">
                    <xsl:with-param name="id-root" select="$template-default-id-root-datatypes"/>
                    <xsl:with-param name="template-classification" as="element()">
                        <classification type="datatypelevel" format="{$classification-format}"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:for-each>
        </rules>
    </xsl:template>
    
    <xsl:template name="process-xsd">
        <xsl:param name="id-start" select="0"></xsl:param>
        <xsl:param name="id-root"/>
        <xsl:param name="template-classification" as="element(classification)"/>
        <xsl:variable name="template-id" select="$id-start + position()"/>
        <xsl:variable name="template-name">
            <xsl:choose>
                <xsl:when test="$template-classification/@type='messagelevel'">
                    <xsl:value-of select="tokenize(tokenize(document-uri(.),'/')[last()],'\.')[1]"/>
                </xsl:when>
                <xsl:when test="$template-classification/@type='segmentlevel'">
                    <xsl:value-of select="concat(@name,'_segment')"/>
                </xsl:when>
                <xsl:when test="$template-classification/@type='datatypelevel'">
                    <xsl:value-of select="concat(@name,'_datatype')"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="template-display-name" select="'[TODO]'"/>
        
        <template id="{$id-root}.{$template-id}" name="{$template-name}" effectiveDate="{$template-default-effectiveDate}" statusCode="{$template-default-status}">
            <xsl:choose>
                <xsl:when test="$template-classification/@type='messagelevel'">
                    <xsl:copy-of select="$template-classification"/>
                    <context path="/"/>
                    <xsl:apply-templates select="/xs:schema/xs:element[@name=$template-name]" mode="process-root">
                        <xsl:with-param name="template-classification" select="$template-classification"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:when test="$template-classification/@type='segmentlevel'">
                    <xsl:copy-of select="$template-classification"/>
                    <xsl:apply-templates select="." mode="process-root">
                        <xsl:with-param name="template-classification" select="$template-classification"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:when test="$template-classification/@type='datatypelevel'">
                    <xsl:copy-of select="$template-classification"/>
                    <xsl:apply-templates select="xs:sequence/xs:element" mode="process-content">
                        <xsl:with-param name="template-classification" select="$template-classification"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message terminate="yes">XSL template process-xsd <xsl:copy-of select="$template-classification"/> not handled.</xsl:message>
                </xsl:otherwise>
            </xsl:choose>
        </template>
    </xsl:template>
    
    <!--<xsd:element name="ACK" type="ACK.CONTENT"/>-->
    <xsl:template match="xs:element" mode="process-root">
        <xsl:param name="template-classification" as="element(classification)"/>
        <xsl:variable name="name" select="@name"/>
        <xsl:variable name="type" select="@type"/>
        <!--<element name="hl7v2:{$name}">-->
            <xsl:apply-templates select="/xs:schema/xs:complexType[@name=$type]/xs:sequence/xs:element" mode="process-content">
                <xsl:with-param name="template-classification" select="$template-classification"/>
            </xsl:apply-templates>
        <!--</element>-->
    </xsl:template>
    
    <!--
        <xsd:complexType name="ACK.CONTENT">
            <xsd:sequence>
              <xsd:element ref="MSH" minOccurs="1" maxOccurs="1" />
              <xsd:element ref="SFT" minOccurs="0" maxOccurs="unbounded" />
              <xsd:element ref="MSA" minOccurs="1" maxOccurs="1" />
              <xsd:element ref="ERR" minOccurs="0" maxOccurs="unbounded" />
            </xsd:sequence>
        </xsd:complexType>
    -->
    <xsl:template match="xs:element" mode="process-content">
        <xsl:param name="template-classification" as="element(classification)"/>
        <xsl:variable name="ref" select="@ref|@name"/>
        <xsl:variable name="type" select="@type"/>
        <xsl:variable name="min" select="@minOccurs"/>
        <xsl:variable name="max" select="if (@maxOccurs castable as xs:integer) then @maxOccurs else if (@maxOccurs='unbounded') then '*' else ()"/>
        <xsl:choose>
            <!-- QVR_Q17.QBP is a recursive definition -->
            <xsl:when test="$template-classification/@type='messagelevel' and $ref='QVR_Q17.QBP'">
                <element name="hl7v2:{$ref}" contains="QVR_Q17_QBP_group">
                    <xsl:if test="@minOccurs">
                        <xsl:attribute name="minimumMultiplicity" select="$min"/>
                    </xsl:if>
                    <xsl:if test="@maxOccurs">
                        <xsl:attribute name="maximumMultiplicity" select="$max"/>
                    </xsl:if>
                </element>
            </xsl:when>
            <xsl:when test="$template-classification/@type='datatypelevel' and $ref='escape'">
                <xsl:for-each select="/xs:schema/xs:complexType[@name=$type]/xs:sequence/xs:element">
                    <element name="hl7v2:{@name}" contains="escapeType_datatype">
                        <xsl:if test="@minOccurs">
                            <xsl:attribute name="minimumMultiplicity" select="$min"/>
                        </xsl:if>
                        <xsl:if test="@maxOccurs">
                            <xsl:attribute name="maximumMultiplicity" select="$max"/>
                        </xsl:if>
                        <attribute name="V"/>
                    </element>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="$template-classification/@type='datatypelevel'">
                <element name="hl7v2:{$ref}">
                    <xsl:if test="@minOccurs">
                        <xsl:attribute name="minimumMultiplicity" select="$min"/>
                    </xsl:if>
                    <xsl:if test="@maxOccurs">
                        <xsl:attribute name="maximumMultiplicity" select="$max"/>
                    </xsl:if>
                    <xsl:apply-templates select="$datatype-definitions/*[@name=$ref]" mode="process-field"/>
                </element>
            </xsl:when>
            <!-- If definition is inside same schema process it here -->
            <xsl:when test="$ref and /xs:schema/xs:element[@name=$ref]">
                <xsl:variable name="reftype" select="/xs:schema/xs:element[@name=$ref]/@type"/>
                <element name="hl7v2:{$ref}">
                    <xsl:if test="@minOccurs">
                        <xsl:attribute name="minimumMultiplicity" select="$min"/>
                    </xsl:if>
                    <xsl:if test="@maxOccurs">
                        <xsl:attribute name="maximumMultiplicity" select="$max"/>
                    </xsl:if>
                    <xsl:apply-templates select="/xs:schema/xs:complexType[@name=$reftype]/xs:sequence/xs:element" mode="process-content">
                        <xsl:with-param name="template-classification" select="$template-classification"/>
                    </xsl:apply-templates>
                </element>
            </xsl:when>
            <xsl:when test="$template-classification/@type='messagelevel'">
                <element name="{$ref}" contains="{$ref}_segment">
                    <xsl:if test="@minOccurs">
                        <xsl:attribute name="minimumMultiplicity" select="$min"/>
                    </xsl:if>
                    <xsl:if test="@maxOccurs">
                        <xsl:attribute name="maximumMultiplicity" select="$max"/>
                    </xsl:if>
                    <xsl:if test="number(@minOccurs)>0">
                        <xsl:attribute name="conformance" select="'R'"/>
                    </xsl:if>
                </element>
            </xsl:when>
            <xsl:when test="$template-classification/@type='segmentlevel'">
                <element name="hl7v2:{$ref}">
                    <xsl:if test="@minOccurs">
                        <xsl:attribute name="minimumMultiplicity" select="$min"/>
                    </xsl:if>
                    <xsl:if test="@maxOccurs">
                        <xsl:attribute name="maximumMultiplicity" select="$max"/>
                    </xsl:if>
                    <xsl:apply-templates select="$field-definitions[@name=$ref]" mode="process-field"/>
                </element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="yes">XSL template process-content <xsl:copy-of select="$template-classification"/> not handled.</xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="xs:element" mode="process-field">
        <xsl:variable name="ref" select="@ref"/>
        <xsl:variable name="type" select="@type"/>
        <xsl:variable name="min" select="@minOccurs"/>
        <xsl:variable name="max" select="if (@maxOccurs castable as xs:integer) then @maxOccurs else if (@maxOccurs='unbounded') then '*' else ()"/>
        <xsl:variable name="datatype" select="/xs:schema/xs:complexType[@name=$type]//xs:extension/@base"/>
        
        <xsl:attribute name="datatype" select="$datatype"/>
        <xsl:choose>
            <xsl:when test="$datatype-definitions/xs:complexType[@name=$datatype]">
                <xsl:attribute name="contains" select="concat($datatype,'_datatype')"/>
            </xsl:when>
        </xsl:choose>
        
        <xsl:for-each select="/xs:schema/xs:complexType[@name=$type]/xs:annotation/xs:documentation">
            <desc language="{local:handleLanguage(.)}">
                <xsl:copy-of select="node()"/>
            </desc>
        </xsl:for-each>
        <xsl:variable name="attributeGroupRef" select="/xs:schema/xs:complexType[@name=$type]//xs:attributeGroup/@ref"/>
        <xsl:for-each select="/xs:schema/xs:attributeGroup[@name=$attributeGroupRef]//xs:attribute">
            <attribute name="{@name}" value="{@fixed}" isOptional="{not(@required='true')}"/>
            <xsl:if test="not(@name and @fixed)">
                <xsl:message terminate="yes">XSL template process-field attribute missing @name or @fixed.</xsl:message>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:function name="local:handleLanguage" as="xs:string">
        <xsl:param name="element" as="element()?"/>
        <xsl:choose>
            <xsl:when test="$element/@xml:lang='en'">
                <xsl:value-of select="'en-US'"/>
            </xsl:when>
            <xsl:when test="lower-case($element/@xml:lang)='en-us'">
                <xsl:value-of select="'en-US'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="yes">XSL function local:handleLanguage <xsl:value-of select="$element/@xml:lang"/> not handled.</xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
</xsl:stylesheet>