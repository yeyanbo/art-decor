<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:mif2="urn:hl7-org:v3/mif2" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all">
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:param name="includeDeprecatedCodeSystems" select="false()" as="xs:boolean"/>
    
    <xsl:template match="/">
        <!--<packageLocation combinedId="DEFN=UV=VO=1175-20120802" root="DEFN" artifact="VO" realmNamespace="UV" version="1175-20120802"/>-->
        <xsl:variable name="packageLocation" select="/mif2:vocabularyModel/mif2:packageLocation[1]/@combinedId"/>
        <xsl:for-each select="/*/mif2:codeSystem[mif2:releasedVersion//mif2:concept[mif2:code/@status='active']]">
            <xsl:variable name="theCodeSystemName" select="@name"/>
            <xsl:variable name="theCodeSystemID" select="@codeSystemId"/>
            <xsl:variable name="codeSystemDeprecationInfo" select="mif2:annotations/mif2:appInfo/mif2:deprecationInfo"/>
            <xsl:variable name="theCodeSystemStatus" select="if ($codeSystemDeprecationInfo) then 'deprecated' else ('active')"/>
            
            <xsl:if test="$includeDeprecatedCodeSystems or not($theCodeSystemStatus='deprecated')">
                <xsl:result-document indent="yes" encoding="UTF-8" href="{concat('claml/',$theCodeSystemName,'-',$theCodeSystemID,'.xml')}">
                    <ClaML version="2.0.0">
                        <Meta name="statusCode" value="{$theCodeSystemStatus}"/>
                        <xsl:if test="$codeSystemDeprecationInfo">
                            <Meta name="statusInfo" value="deprecationEffectiveVersion='{$codeSystemDeprecationInfo/@deprecationEffectiveVersion}' - {$codeSystemDeprecationInfo//text()/normalize-space()}"/>
                        </xsl:if>
                        <Meta name="hl7CoreMifPackage" value="{$packageLocation}"/>
                        <xsl:for-each select="mif2:releasedVersion/@*">
                            <Meta name="{name(.)}" value="{.}"/>
                        </xsl:for-each>
                       <Meta name="custodianOrganisation" value="HL7"/>
                       <Meta name="custodianOrganisationLogo" value="HL7NL-logo40.png"/>
                       <Meta name="custodianOrganisationUrl" value="http://www.hl7.nl"/>
                        <Identifier authority="hl7.org" uid="{@codeSystemId}"/>
                        <!-- <releasedVersion releaseDate="2012-08-02" publisherVersionId="60" hl7MaintainedIndicator="true" completeCodesIndicator="true" hl7ApprovedIndicator="true"> -->
                        <Title name="{@name}" date="{mif2:releasedVersion/@releaseDate}" version="1.000">
                            <xsl:value-of select="normalize-space(mif2:annotations/mif2:documentation/mif2:description/mif2:text)"/>
                        </Title>
                        <Authors>
                            <xsl:variable name="authorShort" select="'Responsible'"/>
                            <xsl:variable name="authorLong" select="mif2:header/mif2:responsibleGroup/@organizationName"/>

                            <Author name="{$authorShort}">
                                <xsl:value-of select="$authorLong"/>
                            </Author>

                            <xsl:for-each select="mif2:header/mif2:contributor">
                                <xsl:variable name="authorShort" select="mif2:role"/>
                                <xsl:variable name="authorLong" select="mif2:name/@name"/>

                                <Author name="{$authorShort}">
                                    <xsl:value-of select="$authorLong"/>
                                </Author>
                            </xsl:for-each>
                        </Authors>
                        <ClassKinds>
                            <ClassKind name="abstract"/>
                            <ClassKind name="concept"/>
                        </ClassKinds>
                        <RubricKinds>
                            <RubricKinds>
                                <RubricKind name="definition"/>
                                <RubricKind name="description"/>
                                <RubricKind name="header"/>
                                <RubricKind name="preferred"/>
                                <RubricKind name="short"/>
                            </RubricKinds>
                        </RubricKinds>
                        <xsl:for-each select="mif2:releasedVersion//mif2:concept[mif2:code/@status='active']">
                            <xsl:variable name="theCode" select="mif2:code[@status='active']/@code"/>
                            <Class code="{$theCode}" kind="{if (@isSelectable='false') then 'abstract' else ('concept')}">
                                <xsl:if test="@isSelectable='false'">
                                    <Meta name="isSelectable" value="false"/>
                                </xsl:if>
                                <xsl:for-each select="mif2:conceptProperty">
                                    <Meta name="{@name}" value="{@value}"/>
                                </xsl:for-each>
                                <xsl:for-each select="mif2:code[not(@status='active')]">
                                    <Meta name="code-{@status}" value="{@code}"/>
                                </xsl:for-each>
                                <!-- 
                                    Specializes relationship sometimes point to their super class based on a retired code, so we get the active version
                                    This active version may double another Specialization, so we need to de-duplicate them again
                                -->
                                <xsl:variable name="SuperClasses" as="element(SuperClass)*">
                                    <xsl:for-each select="mif2:conceptRelationship[@relationshipName='Specializes']">
                                        <xsl:variable name="theRefCode" select="mif2:targetConcept/@code"/>
                                        <xsl:variable name="theSuperCode" select="ancestor::mif2:releasedVersion[last()]//mif2:concept[mif2:code/@code=$theRefCode]/mif2:code[@status='active']/@code"/>
                                        <SuperClass code="{$theSuperCode}"/>
                                    </xsl:for-each>
                                </xsl:variable>
                                <xsl:for-each-group select="$SuperClasses" group-by="@code">
                                    <SuperClass code="{current-grouping-key()}"/>
                                </xsl:for-each-group>
                                <!-- 
                                    In certain coremif files we may find the sub classes through the Generalizes relationship
                                    In (most) other coremif files we look them up by checking every concept that claims a Specializes relationship with the current concept
                                -->
                                <xsl:for-each-group select="ancestor::mif2:releasedVersion[last()]//mif2:concept[mif2:code/@status='active'][mif2:conceptRelationship[@relationshipName='Specializes']/mif2:targetConcept/@code=$theCode]/mif2:code[@status='active']/@code" group-by=".">
                                    <SubClass code="{current-grouping-key()}"/>
                                </xsl:for-each-group>
                                <xsl:for-each select="mif2:annotations">
                                    <xsl:for-each select="mif2:documentation/mif2:definition">
                                        <Rubric id="{generate-id()}" kind="definition">
                                            <Label xml:lang="en-US">
                                                <xsl:call-template name="copyIntoNamespace">
                                                    <xsl:with-param name="nodes" select="mif2:text/node()"/>
                                                </xsl:call-template>
                                            </Label>
                                        </Rubric>
                                    </xsl:for-each>
                                </xsl:for-each>
                                <xsl:for-each select="mif2:printName">
                                    <xsl:variable name="lang">
                                        <xsl:choose>
                                            <xsl:when test="@language='en'">
                                                <xsl:value-of select="'en-US'"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="@language"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:variable>
                                    <Rubric id="{generate-id()}" kind="short">
                                        <Label xml:lang="{$lang}">
                                            <xsl:value-of select="@text"/>
                                        </Label>
                                    </Rubric>
                                    <xsl:if test="@preferredForLanguage='true'">
                                        <Rubric id="{generate-id()}" kind="preferred">
                                            <Label xml:lang="{$lang}">
                                                <xsl:value-of select="@text"/>
                                            </Label>
                                        </Rubric>
                                    </xsl:if>
                                </xsl:for-each>
                            </Class>
                        </xsl:for-each>
                    </ClaML>
                </xsl:result-document>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="copyIntoNamespace">
        <xsl:param name="nodes"/>
        <xsl:if test="not(empty($nodes))">
            <xsl:for-each select="$nodes">
                <xsl:choose>
                    <xsl:when test="self::text()[string-length(normalize-space(.))>0]">
                        <xsl:value-of select="normalize-space(.)"/>
                        <xsl:if test="position() != last()">
                            <xsl:text> </xsl:text>
                        </xsl:if>
                    </xsl:when>
                    <xsl:when test="self::mif2:*">
                        <xsl:element name="{local-name(.)}">
                            <xsl:copy-of select="@*" copy-namespaces="no"/>
                            <xsl:call-template name="copyIntoNamespace">
                                <xsl:with-param name="nodes" select="node()"/>
                            </xsl:call-template>
                        </xsl:element>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="*">
        <xsl:element name="{local-name()}">
            <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="@*">
        <xsl:attribute name="{local-name()}">
            <xsl:value-of select="."/>
        </xsl:attribute>
    </xsl:template>
</xsl:stylesheet>
