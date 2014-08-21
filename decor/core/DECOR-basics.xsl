<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    
    DECOR-basics
    Copyright (C) 2009-2014 Dr. Kai U. Heitmann
    
    This program is free software; you can redistribute it and/or modify it under the terms 
    of the GNU General Public License as published by the Free Software Foundation; 
    either version 3 of the License, or (at your option) any later version.
    
    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
    See the GNU General Public License for more details.
    
    See http://www.gnu.org/licenses/gpl.html
    
-->
<xsl:stylesheet xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xforms="http://www.w3.org/2002/xforms" xmlns:uuid="java:java.util.UUID" xmlns:local="http://art-decor.org/functions" version="2.0" exclude-result-prefixes="#all">
    
    <!-- provide a mapping from string logLevel to numeric value -->
    <xsl:variable name="logALL" select="'ALL'"/>
    <xsl:variable name="logDEBUG" select="'DEBUG'"/>
    <xsl:variable name="logINFO" select="'INFO'"/>
    <xsl:variable name="logWARN" select="'WARN'"/>
    <xsl:variable name="logERROR" select="'ERROR'"/>
    <xsl:variable name="logFATAL" select="'FATAL'"/>
    <xsl:variable name="logOFF" select="'OFF'"/>
    <xsl:variable name="logLevelMap">
        <level name="{$logALL}" int="6" desc="The ALL has the lowest possible rank and is intended to turn on all logging."/>
        <level name="{$logDEBUG}" int="5" desc="The DEBUG Level designates fine-grained informational events that are most useful to debug an application."/>
        <level name="{$logINFO}" int="4" desc="The INFO level designates informational messages that highlight the progress of the application at coarse-grained level."/>
        <level name="{$logWARN}" int="3" desc="The WARN level designates potentially harmful situations."/>
        <level name="{$logERROR}" int="2" desc="The ERROR level designates error events that might still allow the application to continue running."/>
        <level name="{$logFATAL}" int="1" desc="The FATAL level designates very severe error events that will presumably lead the application to abort."/>
        <level name="{$logOFF}" int="0" desc="The OFF level has the highest possible rank and is intended to turn off logging."/>
    </xsl:variable>
    <xsl:variable name="chkdLogLevel"  select="if (exists($logLevelMap/level[@name=$logLevel])) then $logLevel else $logINFO"/>
    
    <!-- the all and one art-decor.org website and the sourceforge svn -->
    <xsl:variable name="theARTDECORwebsite" select="'https://art-decor.org'"/>
    <xsl:variable name="theARTDECORsourceforge" select="'https://sourceforge.net/p/artdecor'"/>
    
    <!-- path names to current DECOR -->
    <xsl:variable name="theDECOR" select="static-base-uri()"/>
    <xsl:variable name="theBaseURI2DECOR" select="string-join(tokenize(base-uri(), '/')[position() &lt; last()], '/')"/>
    
    <!-- cache full DECOR for resolving generic ids such as object/@id -->
    <xsl:variable name="allDECOR" select="/decor"/>
    
    <!-- cache all ids for later processing -->
    <xsl:variable name="allIDs" select="//ids"/>

    <!-- cache all i18n messages -->
    <xsl:variable name="theMESSAGES" select="document('DECOR-i18n.xml')"/>

    <!-- cache all value sets for later processing, sorted descending order -->
    <xsl:variable name="allValueSets">
        <sortedValueSets>
            <xsl:for-each select="//terminology/valueSet">
                <xsl:sort select="@name"/>
                <xsl:sort select="@effectiveDate" order="descending"/>
                <xsl:variable name="ref" select="@ref"/>
                <xsl:variable name="name" select="@name"/>
                <xsl:choose>
                    <xsl:when test="@id">
                        <xsl:copy-of select="self::node()"/>
                    </xsl:when>
                    <xsl:when test="@ref and not(exists(//terminology/valueSet[@id=$ref][@name=$name]))">
                        <!-- this a reference that could not be resolved, or this project has not been compiled before transform -->
                        <xsl:copy>
                            <xsl:copy-of select="@*"/>
                            <xsl:attribute name="missing" select="'true'"/>
                            <xsl:copy-of select="node()"/>
                        </xsl:copy>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- do not copy valueSet/@ref where valueSet/@id exists (compiled project) -->
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </sortedValueSets>
    </xsl:variable>

    <!-- cache all terminology associations for later processing -->
    <xsl:variable name="allTerminologyAssociations">
        <terminologyAssociations>
            <xsl:for-each select="//terminology/terminologyAssociation">
                <xsl:copy-of select="."/>
            </xsl:for-each>
        </terminologyAssociations>
    </xsl:variable>

    <!-- cache all base id of the project for later processing -->
    <xsl:variable name="allBaseIDs" select="//ids/baseId"/>

    <!-- cache all concepts for later processing -->
    <xsl:variable name="allCodedConcepts" select="//codedConcepts"/>

    <!-- cache all scenarios for later processing -->
    <xsl:variable name="allScenarios">
        <scenarios>
            <xsl:for-each-group select="//scenarios/scenario" group-by="@id">
                <xsl:sort select="@effectiveDate" order="descending"/>
                <xsl:copy-of select="."/>
            </xsl:for-each-group>
        </scenarios>
    </xsl:variable>
    
    <!-- cache all actords for later processing -->
    <xsl:variable name="allActors">
        <xsl:copy-of select="//scenarios/actors"/>
    </xsl:variable>

    <!-- source directory for external rule sets -->
    <xsl:variable name="theSourceDir" select="concat($projectPrefix, 'source/')"/>

    <!-- template repository -->
    <xsl:variable name="projectTemplateRepository" select="concat($projectPrefix, 'template-repository.xml')"/>

    <!-- variables to create the output -->

    <!-- current date and time -->
    <xsl:variable name="currentDateTime">
        <xsl:value-of select="dateTime(current-date(), current-time())"/>
    </xsl:variable>
    <!-- time stamp format example 20120112T094340 -->
    <xsl:variable name="theTimeStamp">
        <xsl:choose>
            <xsl:when test="$inDevelopment=true()">
                <xsl:value-of select="'develop'"/>
            </xsl:when>
            <xsl:when test="$useLatestDecorVersion=true()">
                <xsl:value-of select="substring(translate(string($latestVersion), '[-:]', ''), 1, 15)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="substring(translate($currentDateTime, '[-:]', ''), 1, 15)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <!-- get the URL as a prefix for the reference to definitions -->
    <xsl:variable name="seeURLprefix" select="//project/reference/@url"/>

    <!-- get project name -->
    <xsl:variable name="projectName" select="(//project/name)[1]"/>

    <!-- get project id prefix -->
    <xsl:variable name="projectPrefix" select="//project/@prefix"/>

    <!-- get project contact email -->
    <xsl:variable name="projectContactEmail" select="//project/contact/@email"/>

    <!-- get project id (oid) -->
    <xsl:variable name="projectId" select="//project/@id"/>

    <!-- get project rest URIs -->
    <xsl:variable name="projectRestURIs" select="//project/restURI"/>
    
    <!-- get project default element namespace -->
    <xsl:variable name="projectDefaultElementNamespace">
        <xsl:choose>
            <xsl:when test="string-length(//project/defaultElementNamespace/@ns)>0">
                <xsl:value-of select="//project/defaultElementNamespace/@ns"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- guess the default: hl7: -->
                <xsl:text>hl7:</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <!-- html directory for html file objects -->
    <xsl:variable name="theHtmlDir" select="concat($projectPrefix, 'html-', $theTimeStamp, '/')"/>
    
    <!-- docbook directory for docbook file objects -->
    <xsl:variable name="theDocbookDir" select="concat($projectPrefix, 'docbook-', $theTimeStamp, '/')"/>

    <!-- 
        runtime directory for schematron file objects and vocabs etc 
        example
        
        peri20-runtime-20120117T114955
        +  schematron1.sch
        +  schematron2.sch
        +  include/  other types of schematrons
        +  include/  vocabs etc
    -->
    <xsl:variable name="theRuntimeDir" select="concat($projectPrefix, 'runtime-', $theTimeStamp, '/')"/>
    <xsl:variable name="theRuntimeDirZIP">
        <xsl:choose>
            <xsl:when test="string-length($seeURLprefix)>0">
                <xsl:value-of select="concat($seeURLprefix, $projectPrefix, 'runtime-', $theTimeStamp, '.zip')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat('../', $projectPrefix, 'runtime-', $theTimeStamp, '.zip')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="theRuntimeIncludeDir" select="concat($theRuntimeDir, 'include', '/')"/>
    <xsl:variable name="theRuntimeRelativeIncludeDir" select="concat('include', '/')"/>

    <!-- the assets directory -->
    <!-- 
        2DO: versioning of assets
    -->
    <!--  old 
    <xsl:param name="theAssetsDir" select="concat('../assets', '', '/')"/>
    -->
    <!--xsl:variable name="theAssetsVersion" select="'v32'"/-->
    <xsl:variable name="theAssetsVersion" select="''"/>
    <xsl:variable name="theAssetsDir">
        <xsl:choose>
            <xsl:when test="$useLocalAssets=true()">
                <xsl:value-of select="concat('../assets', '', '/')"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- use ref to online version of assets -->
                <xsl:value-of select="concat($theARTDECORwebsite, '/ADAR/rv/assets', $theAssetsVersion, '/')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <!-- where the logos are -->
    <xsl:variable name="theLogosDir">
        <xsl:choose>
            <xsl:when test="$useLocalLogos=true()">
                <xsl:value-of select="concat('../', $projectPrefix, 'logos/')"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- use ref to online version of assets -->
                <xsl:value-of select="concat($seeURLprefix, $projectPrefix, 'logos/')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <!-- cache all templates with a ref element around per template done by doGetAllTemplates for later processing -->
    
    <xsl:variable name="allTemplateWithIncludes">
        <templates>
            <xsl:call-template name="doGetAllTemplates"/>
        </templates>
    </xsl:variable>
    
    <xsl:variable name="allTemplates">
        <xsl:copy-of select="$allTemplateWithIncludes"/>
        <!-- does not work yet properly
        <xsl:apply-templates select="$allTemplateWithIncludes" mode="derefinclude"/>
        -->
    </xsl:variable>
    
    <!-- cache all templates with their id, name and effectiveDate only for later processing -->
    <xsl:variable name="allTemplateRefs">
        <xsl:variable name="rctmp">
            <tmp>
                <xsl:call-template name="getRulesetContent24"/>
            </tmp>
        </xsl:variable>
        <templateRefs>
            <xsl:for-each select="$rctmp/*/template">
                <template>
                    <xsl:copy-of select="@id|@name|@effectiveDate"/>
                </template>
            </xsl:for-each>
        </templateRefs>
    </xsl:variable>
    
    <!-- cache all template associations for later processing -->
    <xsl:variable name="allTemplatesAssociations">
        <tmpassocs>
            <xsl:for-each select="//rules/templateAssociation">
                <templateAssociation>
                    <xsl:copy-of select="@*"/>
                    <!-- get list of all concept associated with this template -->
                    <xsl:copy-of select="*"/>
                </templateAssociation>
            </xsl:for-each>
        </tmpassocs>
    </xsl:variable>

    <!-- cache all concepts with their id, name and desc for later processing -->
    <xsl:variable name="allDatasetConceptsFlat">
        <datasets>
            <xsl:for-each select="//datasets/dataset">
                <xsl:sort select="@effectiveDate" order="descending"/>
                <dataset>
                    <xsl:copy-of select="@*"/>
                    <xsl:copy-of select="name"/>
                    <xsl:copy-of select="desc"/>
                    <!-- get the flat list of all concept names and descriptions -->
                    <xsl:apply-templates select="concept" mode="delist"/>
                </dataset>
            </xsl:for-each>
        </datasets>
    </xsl:variable>

    <!-- create a list of supported data types -->
    <xsl:variable name="supportedDatatypes">
        <xsl:for-each select="document('DECOR-supported-datatypes.xml')//(dataType|flavor)[@name][not(ancestor-or-self::atomicDataType)]">
            <dt>
                <xsl:attribute name="name" select="@name"/>
                <xsl:if test="name()='flavor'">
                    <xsl:attribute name="isFlavorOf" select="(ancestor-or-self::dataType/@name)[last()]"/>
                </xsl:if>
                <xsl:if test="@realm">
                    <xsl:attribute name="realm" select="@realm"/>
                </xsl:if>
            </dt>
        </xsl:for-each>
    </xsl:variable>
    
    <!-- create list of supported atomic data types, i.e. applicable to attributes -->
    <!-- 2DO add to external file. Cannot currently do this as this would lead to side effects such as failure to write DTr1_dt.sch -->
    <xsl:variable name="supportedAtomicDatatypes">
        <xsl:for-each select="document('DECOR-supported-datatypes.xml')//atomicDataType[@name]">
            <dt>
                <xsl:attribute name="name" select="@name"/>
                <xsl:if test="@realm">
                    <xsl:attribute name="realm" select="@realm"/>
                </xsl:if>
            </dt>
        </xsl:for-each>
    </xsl:variable>
    
    <!-- some global params -->
    <xsl:variable name="valueSetReferenceErrors">
        <xsl:call-template name="getValueSetReferenceErrors"/>
    </xsl:variable>
    
    <xsl:variable name="missingTemplates">
        <xsl:call-template name="getMissingTemplates"/>
    </xsl:variable>
    
    <!-- cache actual datasets -->
    <xsl:variable name="allDatasets" select="//datasets"/>
    
    <!-- cache actual issues -->
    <xsl:variable name="allIssues" select="//issues"/>
    
    <!-- cache actual template associations -->
    <xsl:variable name="allTemplateAssociation">
        <templateAssociations>
            <xsl:copy-of select="//rules/templateAssociation"/>
        </templateAssociations>
    </xsl:variable>
    
    <!-- which random generator tcan be used? -->
    <xsl:variable name="useJAVArandomuuid" select="function-available('uuid:randomUUID')"/>
    
    <!-- is this project a repository? -->
    <xsl:variable name="projectIsRepository" select="exists(/decor[string(@repository)='true'])" as="xs:boolean"/>
    <!-- is this project marked private? -->
    <xsl:variable name="projectIsPrivate" select="exists(/decor[string(@private)='true'])" as="xs:boolean"/>
    <!-- is the newest current project/(version|release) a version element or a release element? -->
    <xsl:variable name="publicationIsRelease" select="exists(//project/release[@date=max(parent::project/(version|release)/xs:dateTime(@date))])" as="xs:boolean"/>
    
    <xsl:template name="getValueSetReferenceErrors">
        <!-- create a list of referenced value sets that cannot be found -->
        <errors>
            <xsl:for-each select="$allTerminologyAssociations/*/terminologyAssociation[@valueSet]">
                <xsl:variable name="xvsref" select="@valueSet"/>
                <xsl:variable name="xvsflex" select="if (@flexibility) then (@flexibility) else ('dynamic')"/>
                <xsl:variable name="xvs">
                    <xsl:call-template name="getValueset">
                        <xsl:with-param name="reference" select="$xvsref"/>
                        <xsl:with-param name="flexibility" select="$xvsflex"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:variable name="id" select="@conceptId/string()"/>
                <xsl:variable name="conceptOrConceptList" select="($allDatasets//*[@id=$id])[1]"/>
                <xsl:variable name="effectiveDate" select="max($allDatasets//*[@id=$id][not(ancestor::history)]/xs:dateTime(@effectiveDate))"/>
                <xsl:variable name="name">
                    <xsl:choose>
                        <xsl:when test="$conceptOrConceptList/self::concept">
                            <xsl:copy-of select="$conceptOrConceptList/*/name"/>
                        </xsl:when>
                        <xsl:when test="$conceptOrConceptList/self::conceptList">
                            <xsl:copy-of select="$conceptOrConceptList/parent::*/parent::concept/name"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:variable>
                <xsl:if test="not(exists($xvs/valueSet))">
                    <error id="{$xvsref}" flexibility="{$xvsflex}" errortype="terminologyref" from-id="{$id}" from-effectiveDate="{$effectiveDate}">
                        <xsl:copy-of select="$name"/>
                    </error>
                </xsl:if>
            </xsl:for-each>
            <xsl:for-each select="$allValueSets/*/valueSet[@ref][@missing='true']">
                <xsl:variable name="xvsref" select="@ref"/>
                <xsl:variable name="xvsflex" select="if (@flexibility) then (@flexibility) else ('dynamic')"/>
                <xsl:variable name="id" select="@ref"/>
                <xsl:variable name="name" select="if (@displayName) then @displayName else (@name)"/>
                <error id="{$xvsref}" flexibility="{$xvsflex}" errortype="valuesetref" from-id="{$id}">
                    <name language="{$defaultLanguage}"><xsl:value-of select="$name"/></name>
                </error>
            </xsl:for-each>
            <xsl:for-each select="$allTemplates//vocabulary[@valueSet]">
                <xsl:variable name="xvsref" select="@valueSet"/>
                <xsl:variable name="xvsflex" select="if (@flexibility) then (@flexibility) else ('dynamic')"/>
                <xsl:variable name="xvs">
                    <xsl:call-template name="getValueset">
                        <xsl:with-param name="reference" select="$xvsref"/>
                        <xsl:with-param name="flexibility" select="$xvsflex"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:variable name="id" select="ancestor::template[last()]/@id"/>
                <xsl:variable name="effectiveDate" select="ancestor::template[last()]/@ffectiveDate"/>
                <xsl:variable name="name" select="if (ancestor::template[last()]/@displayName) then ancestor::template[last()]/@displayName else (ancestor::template[last()]/@name)"/>
                <xsl:if test="not(exists($xvs/valueSet))">
                    <error id="{$xvsref}" flexibility="{$xvsflex}" errortype="templateref" from-id="{$id}" from-effectiveDate="{$effectiveDate}">
                        <name language="{$defaultLanguage}"><xsl:value-of select="$name"/></name>
                    </error>
                </xsl:if>
            </xsl:for-each>
        </errors>
    </xsl:template>
    
    <xsl:template name="getMissingTemplates">
        <!-- create list of missing templates from includes or contains -->
        <errors>
            <xsl:for-each select="$allTemplates//include">
                <xsl:variable name="inc" select="@ref"/>
                <xsl:variable name="incflex" select="if (@flexibility) then (@flexibility) else ('dynamic')"/>
                <xsl:variable name="rccontent">
                    <xsl:call-template name="getRulesetContent">
                        <xsl:with-param name="ruleset" select="$inc"/>
                        <xsl:with-param name="flexibility" select="$incflex"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:if test="count($rccontent/*/(element|assert|report|defineVariable|let|include|choice))=0">
                    <error>
                        <xsl:attribute name="ref" select="$inc"/>
                        <xsl:attribute name="flexibility" select="$incflex"/>
                        <xsl:if test="count($rccontent/*)>0">
                            <xsl:attribute name="empty" select="'true'"/>
                        </xsl:if>
                    </error>
                </xsl:if>
            </xsl:for-each>
            <xsl:for-each select="$allTemplates//*[@contains]">
                <xsl:variable name="inc" select="@contains"/>
                <xsl:variable name="incflex" select="if (@flexibility) then (@flexibility) else ('dynamic')"/>
                <xsl:variable name="rccontent">
                    <xsl:call-template name="getRulesetContent">
                        <xsl:with-param name="ruleset" select="$inc"/>
                        <xsl:with-param name="flexibility" select="$incflex"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:if test="count($rccontent/*/(element|assert|report|defineVariable|let|include|choice))=0">
                    <error>
                        <xsl:attribute name="ref" select="$inc"/>
                        <xsl:attribute name="flexibility" select="$incflex"/>
                        <xsl:if test="count($rccontent/*)>0">
                            <xsl:attribute name="empty" select="'true'"/>
                        </xsl:if>
                    </error>
                </xsl:if>
            </xsl:for-each>
        </errors>
    </xsl:template>

    <!-- get disclaimer -->
    <xsl:param name="disclaimer">
        <xsl:call-template name="getMessage">
            <xsl:with-param name="key" select="'disclaimer'"/>
            <xsl:with-param name="lang" select="$defaultLanguage"/>
            <xsl:with-param name="p1">
                <xsl:for-each select="//project/copyright[@by]">
                    <xsl:value-of select="@by"/>
                    <xsl:choose>
                        <xsl:when test="position() &lt; last() - 1">
                            <xsl:text>, </xsl:text>
                        </xsl:when>
                        <xsl:when test="position() = last()">
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text> </xsl:text>
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'andWord'"/>
                                <xsl:with-param name="lang" select="$defaultLanguage"/>
                            </xsl:call-template>
                            <xsl:text> </xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:param>

    <!--<xsl:template match="node()" mode="ccopy">
        <xsl:copy xml:space="preserve">
             <xsl:copy-of select="@*"/>
             <xsl:apply-templates select="node()" mode="ccopy"/>
        </xsl:copy>
    </xsl:template>-->
    <xsl:template name="getMessage">
        <xsl:param name="key"/>
        <xsl:param name="lang"/>
        <xsl:param name="p1"/>
        <xsl:param name="p2"/>
        <xsl:param name="p3"/>
        <xsl:param name="p4"/>

        <xsl:variable name="tmp1">
            <tmp1>
                <xsl:choose>
                    <xsl:when test="not(empty($lang)) and $theMESSAGES/*/entry[@key=$key]/text[@language=$lang]">
                        <xsl:copy-of select="$theMESSAGES/*/entry[@key=$key]/text[@language=$lang]/node()"/>
                    </xsl:when>
                    <xsl:when test="$theMESSAGES/*/entry[@key=$key]/text[@language=$defaultLanguage]">
                        <xsl:copy-of select="$theMESSAGES/*/entry[@key=$key]/text[@language=$defaultLanguage]/node()"/>
                    </xsl:when>
                    <xsl:when test="$theMESSAGES/*/entry[@key=$key]/text[substring(@language, 1, 2)=substring($defaultLanguage, 1, 2)]">
                        <xsl:copy-of select="$theMESSAGES/*/entry[@key=$key]/text[substring(@language, 1, 2)=substring($defaultLanguage, 1, 2)]/node()"/>
                    </xsl:when>
                    <xsl:when test="$theMESSAGES/*/entry[@key=$key]/text[@language='en-US']">
                        <xsl:copy-of select="$theMESSAGES/*/entry[@key=$key]/text[@language='en-US']/node()"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>+++Error: NOT FOUND in messages: MESSAGE key=</xsl:text>
                        <xsl:value-of select="$key"/>
                        <xsl:call-template name="logMessage">
                            <xsl:with-param name="level" select="$logERROR"/>
                            <xsl:with-param name="msg">
                                <xsl:text>+++ NOT FOUND in messages: MESSAGE key=</xsl:text>
                                <xsl:value-of select="$key"/>
                                <xsl:text> p1=</xsl:text>
                                <xsl:value-of select="$p1"/>
                                <xsl:text> p2=</xsl:text>
                                <xsl:value-of select="$p2"/>
                                <xsl:text> p3=</xsl:text>
                                <xsl:value-of select="$p3"/>
                                <xsl:text> p4=</xsl:text>
                                <xsl:value-of select="$p4"/>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </tmp1>
        </xsl:variable>

        <xsl:variable name="tmp2">
            <xsl:apply-templates select="$tmp1" mode="substitute">
                <!-- 
                compile all substitution strings
                á la
                <p n="1" v="(substitution for %%1)"/>
                etc
                CAVE don't use $ in the substitution strings, use \$ instead (regex)
            -->
                <xsl:with-param name="px">
                    <xsl:if test="not(empty($p1))">
                        <p n="1" v="{$p1}"/>
                    </xsl:if>
                    <xsl:if test="not(empty($p2))">
                        <p n="2" v="{$p2}"/>
                    </xsl:if>
                    <xsl:if test="not(empty($p3))">
                        <p n="3" v="{$p3}"/>
                    </xsl:if>
                    <xsl:if test="not(empty($p4))">
                        <p n="4" v="{$p4}"/>
                    </xsl:if>
                </xsl:with-param>
            </xsl:apply-templates>
        </xsl:variable>

        <xsl:copy-of select="$tmp2"/>

    </xsl:template>

    <xsl:template name="getXFormsLabel">
        <xsl:param name="simpleTypeKey"/>
        <xsl:param name="lang"/>
        <xsl:param name="simpleTypeValue"/>
        
        <xsl:choose>
            <xsl:when test="doc-available('DECOR.xsd')">
                <xsl:choose>
                    <xsl:when test="document('DECOR.xsd')/*/xs:simpleType[@name=$simpleTypeKey]/*/xs:enumeration[@value=$simpleTypeValue]//xforms:label[@xml:lang=$lang]">
                        <xsl:value-of select="document('DECOR.xsd')/*/xs:simpleType[@name=$simpleTypeKey]/*/xs:enumeration[@value=$simpleTypeValue]//xforms:label[@xml:lang=$lang]"/>
                    </xsl:when>
                    <xsl:when test="document('DECOR.xsd')/*/xs:simpleType[@name=$simpleTypeKey]/*/xs:enumeration[@value=$simpleTypeValue]//xforms:label[@xml:lang=$defaultLanguage]">
                        <xsl:value-of select="document('DECOR.xsd')/*/xs:simpleType[@name=$simpleTypeKey]/*/xs:enumeration[@value=$simpleTypeValue]//xforms:label[@xml:lang=$defaultLanguage]"/>
                    </xsl:when>
                    <xsl:when test="document('DECOR.xsd')/*/xs:simpleType[@name=$simpleTypeKey]/*/xs:enumeration[@value=$simpleTypeValue]//xforms:label[@xml:lang='en-US']">
                        <xsl:value-of select="document('DECOR.xsd')/*/xs:simpleType[@name=$simpleTypeKey]/*/xs:enumeration[@value=$simpleTypeValue]//xforms:label[@xml:lang='en-US']"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$simpleTypeValue"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$simpleTypeValue"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="node()" mode="substitute">
        <xsl:param name="px"/>
        <!--
            use the text node (maybe a nodeset) of the message from getMessage
            and substitute all %%1..%%4 by parameter values p1..p4
            in all the text() and @* nodes of this node (set)
        -->
        <xsl:for-each select="node()">
            <xsl:choose>
                <xsl:when test="string-length(name())>0">
                    <!-- recursively check nested elements and their attributes -->
                    <xsl:copy copy-namespaces="no">
                        <xsl:for-each select="@*">
                            <!-- do string replacement per attribute content -->
                            <xsl:attribute name="{name()}">
                                <xsl:call-template name="multipleReplace">
                                    <xsl:with-param name="in" select="."/>
                                    <xsl:with-param name="px" select="$px"/>
                                    <xsl:with-param name="ix" select="1"/>
                                </xsl:call-template>
                            </xsl:attribute>
                        </xsl:for-each>
                        <xsl:apply-templates select="." mode="substitute">
                            <xsl:with-param name="px" select="$px"/>
                        </xsl:apply-templates>
                    </xsl:copy>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="multipleReplace">
                        <xsl:with-param name="in" select="."/>
                        <xsl:with-param name="px" select="$px"/>
                        <xsl:with-param name="ix" select="1"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="multipleReplace">
        <xsl:param name="in"/>
        <xsl:param name="px"/>
        <xsl:param name="ix"/>
        <xsl:choose>
            <xsl:when test="$ix > 0 and $ix &lt;= count($px/p)">
                <xsl:call-template name="multipleReplace">
                    <xsl:with-param name="in" select="replace($in, concat ('%%', $px/p[$ix]/@n), $px/p[$ix]/@v)"/>
                    <xsl:with-param name="px" select="$px"/>
                    <xsl:with-param name="ix" select="$ix+1"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$in"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="getIDDisplayName">
        <!-- 
            for a given OID in param root get the identification (ids) or baseId displayName or description text
        -->
        <xsl:param name="root"/>
        <xsl:param name="lang"/>

        <xsl:choose>

            <xsl:when test="string-length($allIDs/id[@root = $root]/designation[@language=$lang]/@displayName)>0">
                <xsl:value-of select="$allIDs/id[@root = $root]/designation[@language=$lang]/@displayName"/>
            </xsl:when>
            <xsl:when test="string-length($allIDs/id[@root = $root]/designation[@language=$lang]/text())>0">
                <xsl:value-of select="$allIDs/id[@root = $root]/designation[@language=$lang]/text()"/>
            </xsl:when>
            <xsl:when test="string-length(($allIDs/id[@root = $root]/designation[@language=$defaultLanguage or not(@language)]/@displayName)[1])>0">
                <xsl:value-of select="($allIDs/id[@root = $root]/designation[@language=$defaultLanguage or not(@language)]/@displayName)[1]"/>
            </xsl:when>
            <xsl:when test="string-length($allIDs/id[@root = $root]/designation[@language=$defaultLanguage or not(@language)]/text())>0">
                <xsl:value-of select="$allIDs/id[@root = $root]/designation[@language=$defaultLanguage or not(@language)]/text()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$allIDs/id[@root = $root]/designation[@language='en-US']/@displayName"/>
            </xsl:otherwise>

        </xsl:choose>

    </xsl:template>

    <xsl:template name="getValueset" as="element()*">
        <xsl:param name="reference"/>
        <xsl:param name="flexibility"/>
        
        <xsl:variable name="allByReference" select="$allValueSets/*/valueSet[(@name|@id)=$reference or @id=$allValueSets/*/valueSet[@name=$reference]/@ref]" as="element()*"/>
        
        <xsl:variable name="xvsflex" select="if (@flexibility) then (@flexibility) else ('dynamic')"/>
        <xsl:variable name="xvslatest" select="max($allByReference/xs:dateTime(@effectiveDate))"/>
        
        <xsl:copy-of select="$allByReference[@id][($xvsflex='dynamic' and @effectiveDate=$xvslatest) or @effectiveDate=$xvsflex]"/>
    </xsl:template>

    <xsl:template name="getRulesetContent">
        <xsl:param name="ruleset"/>
        <xsl:param name="flexibility"/>
        
        <xsl:variable name="flex">
            <xsl:choose>
                <xsl:when test="empty($flexibility) or $flexibility=''">
                    <xsl:value-of select="'dynamic'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$flexibility"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-- 
            input parameter is id or name of the rule set
            
            rule set as a template is returned - if found
        -->

        <!--
            <xsl:message terminate="no">
            ?:<xsl:value-of select="$ruleset"/>
            </xsl:message>
        -->

        <xsl:choose>
            <xsl:when test="count($allTemplates/*/ref[@ref=$ruleset][not(@duplicateOf)][($flex='dynamic' and @newestForId=true()) or @effectiveDate=$flex])>0">
                <!-- original rule set, return first found content -->
                <xsl:copy-of select="($allTemplates/*/ref[@ref=$ruleset and not(@duplicateOf)][($flex='dynamic' and @newestForId=true()) or @effectiveDate=$flex])[1]/template"/>
                <!--
                <xsl:message terminate="no"> ORIG:<xsl:value-of select="($allTemplates/*/ref[@ref=$ruleset and not(@duplicateOf)])[1]/template/@name"/>
                </xsl:message>
                -->
            </xsl:when>
            <xsl:when test="count($allTemplates/*/ref[@ref=$ruleset][@duplicateOf][($flex='dynamic' and @newestForName=true()) or @effectiveDate=$flex])>0">
                <!-- duplication of a ruleset with id, return this referenced one and first found content -->
                <xsl:variable name="rs" select="$allTemplates/*/ref[@ref=$ruleset and @duplicateOf][($flex='dynamic' and @newestForName=true()) or @effectiveDate=$flex]/@duplicateOf"/>
                <xsl:variable name="ed" select="$allTemplates/*/ref[@ref=$ruleset and @duplicateOf][($flex='dynamic' and @newestForName=true()) or @effectiveDate=$flex]/@effectiveDate"/>
                <xsl:copy-of select="($allTemplates/*/ref[@ref=$rs][not(@duplicateOf)][@effectiveDate=$ed])[1]/template"/>
                <!--
                <xsl:message terminate="no"> DUPL:<xsl:value-of select="($allTemplates/*/ref[@ref=$rs and not(@duplicateOf)])[1]/template/@id"/>
                </xsl:message>
                -->
            </xsl:when>
            <!--
                <xsl:otherwise>
                <xsl:message terminate="yes">
                MISSING:<xsl:value-of select="$ruleset"/>
                </xsl:message>
                </xsl:otherwise>
            -->
        </xsl:choose>
        <!--
            <xsl:for-each select="$allTemplates/*/ref[@ref=$ruleset]">
            <xsl:sort select="template/@effectiveDate"/>
            <xsl:if test="last()">
            <xsl:copy-of select="template"/>
            </xsl:if>
            
            <xsl:if test="position()=1">
            <xsl:copy-of select="template"/>
            </xsl:if>
            </xsl:for-each>
        -->
    </xsl:template>

    <xsl:template name="getRulesetContent24">
        <!-- 
            the rule set is either contained in a single external file
            or is part of this DECOR file
            
            for example
            <element name="hl7:pertinentInformation3" contains="2.16.840.1.113883.2.4.6.99999.90.2.4">
            means
            search for a file object named @contains.sch and look for template with that id
            or
            search in this DECOR file for a template with that id
            
            return the nodeset of the corresponding rule set
            or null if not found (with emiting an appropriate message)
            
            at this point in time only the MOST RECENT VERSION of a set of rule sets will be returned
        -->
        <xsl:param name="ruleset"/>
        <xsl:param name="flexibility"/>
        
        <xsl:variable name="flex">
            <xsl:choose>
                <xsl:when test="empty($flexibility) or $flexibility=''">
                    <xsl:value-of select="'dynamic'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$flexibility"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- external file reference (a guess) -->
        <xsl:variable name="p1">
            <xsl:choose>
                <xsl:when test="$flex='dynamic'">
                    <xsl:value-of select="concat($theBaseURI2DECOR, '/', $theSourceDir, $ruleset,'-DYNAMIC', '.xml')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat($theBaseURI2DECOR, '/', $theSourceDir, $ruleset,'-',replace($flex,':',''), '.xml')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- template repository -->
        <xsl:variable name="p2" select="concat($theBaseURI2DECOR, '/', $projectTemplateRepository)"/>

        <xsl:choose>
            <xsl:when test="string-length($ruleset)=0">
                <!-- get them all, skip all template ref's as they have to present in resolved form as well with an @id -->
                <xsl:for-each select="//rules/template[not(@ref)]">
                    <xsl:sort select="@id"/>
                    <xsl:sort select="@effectiveDate" order="descending"/>
                    <xsl:copy-of select="."/>
                </xsl:for-each>
                <xsl:if test="doc-available($p2)">
                    <xsl:for-each select="document($p2, .)//rules/template[not(@ref)]">
                        <xsl:sort select="@id"/>
                        <xsl:sort select="@effectiveDate" order="descending"/>
                        <xsl:copy-of select="."/>
                    </xsl:for-each>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="doc-available($p1)">
                    <xsl:for-each select="document($p1, .)//rules/template[not(@ref)]">
                        <xsl:sort select="@id"/>
                        <xsl:sort select="@effectiveDate" order="descending"/>
                        <xsl:copy-of select="."/>
                    </xsl:for-each>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <xsl:template name="doGetAllTemplates">
        
        <!-- get all templates in DECOR and repositories -->
        <xsl:variable name="rccontent">
            <tmp>
                <xsl:call-template name="getRulesetContent24"/>
            </tmp>
        </xsl:variable>

        <xsl:variable name="list1">
            <list1>
                <xsl:apply-templates select="$rccontent/*/template" mode="FIND"/>
            </list1>
        </xsl:variable>

        <xsl:variable name="list2">
            <list2>
                <xsl:for-each select="$list1/*/ref">
                    <xsl:sort select="@ref"/>
                    <xsl:variable name="r" select="@ref"/>
                    <xsl:if test="string-length($r)>0">
                        <xsl:choose>
                            <xsl:when test="count($list1/*/ref[@ref=$r and not(@error)])=0">
                                <xsl:call-template name="logMessage">
                                    <xsl:with-param name="level" select="$logERROR"/>
                                    <xsl:with-param name="msg">
                                        <xsl:text>+++ doGetAllTemplates template not found: </xsl:text>
                                        <xsl:value-of select="@ref"/>
                                        <xsl:text> </xsl:text>
                                        <xsl:value-of select="@flexibility"/>
                                    </xsl:with-param>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <!--
                                    <xsl:message terminate="no">
                                    <xsl:text>doGetAllTemplates found: </xsl:text>
                                    <xsl:value-of select="@ref"/>
                                    <xsl:if test="@error">
                                    <xsl:text> ERRORFLAG</xsl:text>
                                    </xsl:if>
                                    <xsl:if test="@duplicateOf">
                                    <xsl:text> DUPLICATEOF=</xsl:text>
                                    <xsl:value-of select="@duplicateOf"/>
                                    </xsl:if>
                                    <xsl:text> tmp#=</xsl:text>
                                    <xsl:value-of select="count(template)"/>
                                    <xsl:text> elm#=</xsl:text>
                                    <xsl:value-of select="count(template/element)"/>
                                    </xsl:message>
                                -->
                                <xsl:if test="not(@error)">
                                    <xsl:copy-of select="."/>
                                </xsl:if>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:if>
                </xsl:for-each>
            </list2>
        </xsl:variable>

        <xsl:for-each select="$list2/*/ref">
            <xsl:variable name="tid" select="@id"/>
            <xsl:variable name="tnm" select="@name"/>
            <xsl:variable name="ted" select="@effectiveDate"/>
            
            <xsl:copy>
                <xsl:copy-of select="@*"/>
                <xsl:attribute name="newestForId" select="$ted=max($list2/*/ref[@id=$tid]/xs:dateTime(@effectiveDate))"/>
                <xsl:attribute name="newestForName" select="$ted=max($list2/*/ref[@name=$tnm]/xs:dateTime(@effectiveDate))"/>
                <xsl:copy-of select="node()"/>
            </xsl:copy>
            <!--
            <xsl:message>
                <xsl:value-of select="$tid"/>
                <t>
                    <xsl:copy-of select="@*"/>
                    <xsl:attribute name="newestForId" select="$ted=max($list2/*/ref[@id=$tid]/xs:dateTime(@effectiveDate))"/>
                </t>
            </xsl:message>
            -->
            <!--
            <xsl:message terminate="no">
                <xsl:text>doGetAllTemplates all: </xsl:text>
                <xsl:value-of select="@ref"/>
                <xsl:if test="@error">
                    <xsl:text> ERRORFLAG</xsl:text>
                </xsl:if>
                <xsl:if test="@duplicateOf">
                    <xsl:text> DUPLICATEOF=</xsl:text>
                    <xsl:value-of select="@duplicateOf"/>
                </xsl:if>
                <xsl:text> tmp#=</xsl:text>
                <xsl:value-of select="count(template)"/>
                <xsl:text> elm#=</xsl:text>
                <xsl:value-of select="count(template/element)"/>
            </xsl:message>
            -->
        </xsl:for-each>

    </xsl:template>
    
    <xsl:template match="*" mode="derefinclude">
        <xsl:variable name="en" select="name()"/>
        <xsl:element name="{$en}">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="derefinclude"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="include" mode="derefinclude">
        <xsl:comment>
            <xsl:text> dereferenced include: </xsl:text>
            <xsl:value-of select="@ref"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="@flexibility"/>
        </xsl:comment>
        
        <xsl:call-template name="getRulesetContent">
            <xsl:with-param name="ruleset" select="@ref"/>
            <xsl:with-param name="flexibility" select="@flexibility"/>
        </xsl:call-template>
        
        <xsl:apply-templates mode="derefinclude"/>
    </xsl:template>
    
    <xsl:template match="template" mode="FIND">
        <!-- 
            create ref elements per template
            attributes
            - ref contains the reference (id or name of template) 
            - duplicateOf point to the original template if this a duplicate of template @id
            - error is true if there is no processable content
            
        -->
        <!--
            <xsl:message>
            <xsl:text>tmp FIND=</xsl:text>
            <xsl:value-of select="@id"/>
            <xsl:value-of select="@name"/>
            </xsl:message>
        -->
        <xsl:choose>
            <xsl:when test="string-length(@id) > 0 and string-length(@name) > 0">
                <ref>
                    <xsl:attribute name="ref" select="@id"/>
                    <xsl:attribute name="id" select="@id"/>
                    <xsl:attribute name="name" select="@name"/>
                    <xsl:attribute name="effectiveDate" select="@effectiveDate"/>
                    <xsl:copy-of select="."/>
                </ref>
                <ref>
                    <xsl:attribute name="ref" select="@name"/>
                    <xsl:attribute name="id" select="@id"/>
                    <xsl:attribute name="name" select="@name"/>
                    <xsl:attribute name="effectiveDate" select="@effectiveDate"/>
                    <xsl:attribute name="duplicateOf" select="@id"/>
                </ref>
            </xsl:when>
            <xsl:when test="string-length(@id) > 0">
                <ref>
                    <xsl:attribute name="ref" select="@id"/>
                    <xsl:attribute name="id" select="@id"/>
                    <xsl:attribute name="name" select="@name"/>
                    <xsl:attribute name="effectiveDate" select="@effectiveDate"/>
                    <xsl:copy-of select="."/>
                </ref>
            </xsl:when>
            <xsl:when test="string-length(@name) > 0">
                <ref>
                    <xsl:attribute name="ref" select="@name"/>
                    <xsl:attribute name="id" select="@id"/>
                    <xsl:attribute name="name" select="@name"/>
                    <xsl:attribute name="effectiveDate" select="@effectiveDate"/>
                    <xsl:copy-of select="."/>
                </ref>
            </xsl:when>
        </xsl:choose>

        <xsl:for-each select="*//include|*//element[@contains]">
            <xsl:variable name="include">
                <xsl:choose>
                    <xsl:when test="@ref">
                        <xsl:value-of select="@ref"/>
                    </xsl:when>
                    <xsl:when test="@contains">
                        <xsl:value-of select="@contains"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="flexibility" select="if (@flexibility) then (@flexibility) else ('dynamic')"/>
            <xsl:variable name="rccontent">
                <tmp>
                    <xsl:call-template name="getRulesetContent24">
                        <xsl:with-param name="ruleset" select="$include"/>
                        <xsl:with-param name="flexibility" select="$flexibility"/>
                    </xsl:call-template>
                </tmp>
            </xsl:variable>
            <!-- 
                <xsl:message>
                <xsl:text>tmp FIND INC=</xsl:text>
                <xsl:value-of select="$include"/>
                <xsl:text> tmp#=</xsl:text>
                <xsl:value-of select="count($rccontent/*/template)"/>
                <xsl:text> elm#=</xsl:text>
                <xsl:value-of select="count($rccontent/*/template/element)"/>
                </xsl:message>
            -->
            <xsl:variable name="outt">
                <ref>
                    <xsl:attribute name="ref" select="$include"/>
                    <xsl:attribute name="flexibility" select="$flexibility"/>
                    <xsl:if test="count($rccontent/*/template[@id=$include or @name=$include][$flexibility='dynamic' or @effectiveDate=$flexibility])=0">
                        <xsl:attribute name="error" select="'true'"/>
                    </xsl:if>
                    <xsl:copy-of select="$rccontent/*/*"/>
                </ref>
            </xsl:variable>
            <xsl:copy-of select="$outt"/>
            <xsl:apply-templates select="$rccontent/*/template" mode="FIND"/>
        </xsl:for-each>

    </xsl:template>

    <xsl:template match="concept" mode="delist">

        <xsl:choose>
            <!-- Compilation already resolves inherit info. Check if this is the case by checking whether or we already have a name.
                The concept will not have a name in a normal inherit situation.
            -->
            <xsl:when test="inherit/@ref[string-length()>0] and not(name)">
                <xsl:variable name="theconcept">
                    <xsl:apply-templates select="." mode="deinherit"/>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="$theconcept/concept/@id[string-length()=0]">
                        <!-- no nodes - this is an error -->
                        <table width="100%" border="0" cellspacing="3" cellpadding="2">
                            <tr>
                                <!-- show error in concept node -->
                                <td class="nodetype" align="center">
                                    <xsl:call-template name="showStatusDot">
                                        <xsl:with-param name="status" select="error"/>
                                    </xsl:call-template>
                                    <xsl:text> </xsl:text>
                                </td>
                                <!-- show the error message -->
                                <td valign="center" colspan="2" class="nodename tabtab">
                                    <table>
                                        <xsl:call-template name="doMessage">
                                            <xsl:with-param name="level" select="'error'"/>
                                            <xsl:with-param name="msg">
                                                <xsl:choose>
                                                    <xsl:when test="string-length(inherit/@effectiveDate)>0">
                                                        <xsl:call-template name="getMessage">
                                                            <xsl:with-param name="key" select="'theReferencedConceptAsOfCannotBeFound'"/>
                                                            <xsl:with-param name="p1" select="inherit/@ref"/>
                                                            <xsl:with-param name="p2" select="inherit/@effectiveDate"/>
                                                        </xsl:call-template>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:call-template name="getMessage">
                                                            <xsl:with-param name="key" select="'theReferencedConceptCannotBeFound'"/>
                                                            <xsl:with-param name="p1" select="inherit/@ref"/>
                                                        </xsl:call-template>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:with-param>
                                        </xsl:call-template>
                                    </table>
                                </td>
                            </tr>
                        </table>
                        
                        <xsl:call-template name="logMessage">
                            <xsl:with-param name="level" select="$logERROR"/>
                            <xsl:with-param name="msg">
                                <xsl:text>+++ The referenced concept cannot be found: id='</xsl:text>
                                <xsl:value-of select="@id"/>
                                <xsl:text>' effectiveDate='</xsl:text>
                                <xsl:value-of select="@effectiveDate"/>
                                <xsl:text>' inherit id='</xsl:text>
                                <xsl:value-of select="inherit/@ref"/>
                                <xsl:text>' effectiveDate='</xsl:text>
                                <xsl:value-of select="inherit/@effectiveDate"/>
                                <xsl:text>'</xsl:text>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="$theconcept/*" mode="delist"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="@id[string-length()>0]">
                <concept>
                    <xsl:copy-of select="@*"/>
                    <xsl:copy-of select="* except concept"/>
                </concept>
                <xsl:apply-templates select="concept" mode="delist"/>
            </xsl:when>
        </xsl:choose>

    </xsl:template>

    <xsl:template name="doDescription">
        <!--
            print out multi language descriptions/names
            input:
            - node set of desc elements
            - a specific language or null (which means process all languages)
            output:
            - the descriptions
            - in defaultLanguage or no language specified in black
            - other languages in grey
            - the defaultLanguage if present always first
            - show small flag for "ART DECOR well known languages"
        -->
        
        <!-- the desc nodeset -->
        <xsl:param name="ns"/>
        <!-- do short desc, i.e. first X chars only, use for display inside h3 on datasets.html / scenarios.html etc.: forces text only... -->
        <xsl:param name="shortDesc" as="xs:boolean" select="false()"/>
        <!-- max chars. Max X chars will be retained per language. If input is bigger, then "..." is added -->
        <xsl:param name="maxChars" as="xs:integer" select="200"/>
        
        <!-- create a list of desc items to show -->
        <xsl:variable name="descs">
            <d>
            <xsl:choose>
                <xsl:when test="string-length($defaultLanguage)>0 and not($defaultLanguage='ALL')">
                    <!-- a specific language to be shown, if not present, show en-US -->
                    <xsl:copy-of select="$ns[@language=$defaultLanguage]" copy-namespaces="no"/>
                    <xsl:if test="count($ns[@language=$defaultLanguage])=0">
                        <xsl:copy-of select="$ns[@language='en-US']" copy-namespaces="no"/>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <!-- no specific language to be shown, show all, projectDefaultLanguage first if present, then others -->
                    <xsl:copy-of select="$ns[@language=$projectDefaultLanguage]" copy-namespaces="no"/>
                    <xsl:copy-of select="$ns[not(@language=$projectDefaultLanguage)]" copy-namespaces="no"/>
                </xsl:otherwise>
            </xsl:choose>
            </d>
        </xsl:variable>
        <!-- - ->
        <xsl:message>
            <xsl:text>==&#10;</xsl:text>
            <xsl:value-of select="count($descs/d/*)"/>
            <xsl:copy-of select="$descs"/>
            <xsl:text>==&#10;</xsl:text>
        </xsl:message>
        <!- - -->
        <xsl:for-each select="$descs/d/*">
            <xsl:variable name="desc">
                <xsl:choose>
                    <xsl:when test="$shortDesc">
                        <xsl:variable name="longdesc" select="string-join((text()|.//text()),' ')"/>
                        <xsl:value-of select="substring($longdesc,1,$maxChars)"/>
                        <xsl:if test="string-length($longdesc)>$maxChars">
                            <xsl:text>...</xsl:text>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="node()" copy-namespaces="no"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="@language=$defaultLanguage or not(@language)">
                    <xsl:copy-of select="$desc" copy-namespaces="no"/>
                </xsl:when>
                <xsl:otherwise>
                    <!-- show in grey only -->
                    <font color="grey">
                        <xsl:choose>
                            <!-- check for flags for ART DECOR well known languages -->
                            <xsl:when test="@language='de-DE'">
                                <xsl:call-template name="showIcon">
                                    <xsl:with-param name="which" select="'de-DE'"/>
                                    <xsl:with-param name="tooltip" select="'de-DE'"/>
                                </xsl:call-template>
                                <xsl:text> </xsl:text>
                            </xsl:when>
                            <xsl:when test="@language='en-US'">
                                <xsl:call-template name="showIcon">
                                    <xsl:with-param name="which" select="'en-US'"/>
                                    <xsl:with-param name="tooltip" select="'en-US'"/>
                                </xsl:call-template>
                                <xsl:text> </xsl:text>
                            </xsl:when>
                            <xsl:when test="@language='nl-NL'">
                                <xsl:call-template name="showIcon">
                                    <xsl:with-param name="which" select="'nl-NL'"/>
                                    <xsl:with-param name="tooltip" select="'nl-NL'"/>
                                </xsl:call-template>
                                <xsl:text> </xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <i>
                                    <xsl:text>(</xsl:text>
                                    <xsl:value-of select="@language"/>
                                    <xsl:text>) </xsl:text>
                                </i>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:copy-of select="$desc" copy-namespaces="no"/>
                    </font>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="position()!=last()">
                <br/>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="showIcon">
        <xsl:param name="which"/>
        <xsl:param name="tooltip"/>

        <xsl:variable name="imgprefix" select="$theAssetsDir"/>
        <xsl:variable name="size" select="'16px'"/>

        <img>
            <xsl:attribute name="width" select="$size"/>
            <xsl:attribute name="height" select="$size"/>
            <xsl:choose>
                <xsl:when test="$which='info'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'info.png')"/>
                </xsl:when>
                <xsl:when test="$which='alert'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'alert.png')"/>
                </xsl:when>
                <xsl:when test="$which='notice'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'notice.png')"/>
                </xsl:when>
                <xsl:when test="$which='doublearrow'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'doublearrow.png')"/>
                </xsl:when>
                <xsl:when test="$which='arrowleft'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'arrowleft.png')"/>
                </xsl:when>
                <xsl:when test="$which='arrowright'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'arrowright.png')"/>
                </xsl:when>
                <xsl:when test="$which='tracking'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'tracking.png')"/>
                </xsl:when>
                <xsl:when test="$which='mail'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'mail.png')"/>
                </xsl:when>
                <xsl:when test="$which='folder'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'folder.png')"/>
                </xsl:when>
                <xsl:when test="$which='folderopen'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'folderopen.png')"/>
                </xsl:when>
                <xsl:when test="$which='item'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'item.png')"/>
                </xsl:when>
                <xsl:when test="$which='attachment'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'attachment.png')"/>
                </xsl:when>
                <xsl:when test="$which='construction'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'construction.png')"/>
                </xsl:when>
                <xsl:when test="$which='document'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'document.png')"/>
                </xsl:when>
                <xsl:when test="$which='user'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'user.png')"/>
                </xsl:when>
                <xsl:when test="$which='users'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'users.png')"/>
                </xsl:when>
                <xsl:when test="$which='zoomin'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'zoomin.png')"/>
                </xsl:when>
                <xsl:when test="$which='zoomout'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'zoomout.png')"/>
                </xsl:when>
                <xsl:when test="$which='clock'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'clock.png')"/>
                </xsl:when>
                <xsl:when test="$which='blueclock'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'blueclock.png')"/>
                </xsl:when>
                <xsl:when test="$which='download'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'download.png')"/>
                </xsl:when>
                <xsl:when test="$which='flag'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'flag.png')"/>
                </xsl:when>
                <xsl:when test="$which='flag16'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'flag.png')"/>
                    <!-- override size -->
                    <xsl:attribute name="width" select="'16px'"/>
                    <xsl:attribute name="height" select="'16px'"/>
                </xsl:when>
                <xsl:when test="$which='write'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'write.png')"/>
                </xsl:when>
                <xsl:when test="$which='target'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'target.png')"/>
                </xsl:when>
                <xsl:when test="$which='rotate'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'rotate.png')"/>
                </xsl:when>
                <xsl:when test="$which='treetree'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'treetree.png')"/>
                </xsl:when>
                <xsl:when test="$which='treeblank'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'treeblank.png')"/>
                </xsl:when>
                <xsl:when test="$which='link11'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'link.png')"/>
                    <!-- override size -->
                    <xsl:attribute name="width" select="'11px'"/>
                    <xsl:attribute name="height" select="'11px'"/>
                </xsl:when>
                <xsl:when test="$which='link'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'link.png')"/>
                </xsl:when>

                <xsl:when test="$which='red'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'reddot.gif')"/>
                    <!-- override size -->
                    <xsl:attribute name="width" select="'11px'"/>
                    <xsl:attribute name="height" select="'11px'"/>
                </xsl:when>
                <xsl:when test="$which='orange'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'orangedot.gif')"/>
                    <!-- override size -->
                    <xsl:attribute name="width" select="'11px'"/>
                    <xsl:attribute name="height" select="'11px'"/>
                </xsl:when>
                <xsl:when test="$which='yellow'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'yellowdot.gif')"/>
                    <!-- override size -->
                    <xsl:attribute name="width" select="'11px'"/>
                    <xsl:attribute name="height" select="'11px'"/>
                </xsl:when>
                
                <xsl:when test="$which='de-DE'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'de-DE.png')"/>
                    <!-- override size -->
                    <xsl:attribute name="width" select="'16px'"/>
                    <xsl:attribute name="height" select="'11px'"/>
                </xsl:when>
                <xsl:when test="$which='nl-NL'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'nl-NL.png')"/>
                    <!-- override size -->
                    <xsl:attribute name="width" select="'16px'"/>
                    <xsl:attribute name="height" select="'11px'"/>
                </xsl:when>
                <xsl:when test="$which='en-US'">
                    <xsl:attribute name="alt" select="$which"/>
                    <xsl:attribute name="src" select="concat($imgprefix, 'en-US.png')"/>
                    <!-- override size -->
                    <xsl:attribute name="width" select="'16px'"/>
                    <xsl:attribute name="height" select="'11px'"/>
                </xsl:when>
                
            </xsl:choose>

            <!-- assign the tooltip -->
            <xsl:if test="string-length($tooltip)>0">
                <!-- <img src="/..." alt="..." class="Tips1" title="Tips Title :: This is my tip content" /> -->
                
                <!--<xsl:attribute name="class" select="'tipz'"/>-->
                <xsl:attribute name="title" select="$tooltip"/>
            </xsl:if>

        </img>

    </xsl:template>
    
    <xsl:template name="showStatusDot">
        <xsl:param name="status"/>
        <!--
            show status for issues
            
            draft            kyellow.png
            final            kgreen.png
            new              kgrey.png
            review, pending  korange.png
            rejected         kpurple.png
            open             kred.png
            cancelled        kvalidblue.png
            closed           kvalidgreen.png
            deprectated,
            retired          kblue.png
       -->
        <xsl:variable name="size" select="'20px'"/>
        <xsl:variable name="imgprefix" select="$theAssetsDir"/>
        
        <img>
            <xsl:choose>
                <xsl:when test="$status='new'">
                    <xsl:attribute name="src" select="concat($imgprefix, 'kgrey.png')"/>
                </xsl:when>
                <xsl:when test="$status='draft'">
                    <xsl:attribute name="src" select="concat($imgprefix, 'kyellow.png')"/>
                </xsl:when>
                <xsl:when test="$status='final' or $status='active'">
                    <xsl:attribute name="src" select="concat($imgprefix, 'kgreen.png')"/>
                </xsl:when>
                <xsl:when test="$status='open'">
                    <xsl:attribute name="src" select="concat($imgprefix, 'kred.png')"/>
                </xsl:when>
                <xsl:when test="$status='closed'">
                    <xsl:attribute name="src" select="concat($imgprefix, 'kvalidgreen.png')"/>
                </xsl:when>
                <xsl:when test="$status='rejected'">
                    <xsl:attribute name="src" select="concat($imgprefix, 'kpurple.png')"/>
                </xsl:when>
                <xsl:when test="$status='cancelled'">
                    <xsl:attribute name="src" select="concat($imgprefix, 'kvalidblue.png')"/>
                </xsl:when>
                <xsl:when test="$status='pending' or $status='review'">
                    <xsl:attribute name="src" select="concat($imgprefix, 'korange.png')"/>
                </xsl:when>
                <xsl:when test="$status='deprecated' or $status='retired'">
                    <xsl:attribute name="src" select="concat($imgprefix, 'kblue.png')"/>
                </xsl:when>
                <!-- uitzondering: archived -->
                <xsl:when test="$status='archived' or $status='inactive'">
                    <xsl:attribute name="src" select="concat($imgprefix, 'kgrey.png')"/>
                </xsl:when>
                <xsl:when test="$status='ref'">
                    <xsl:attribute name="src" select="concat($imgprefix, 'kblank.png')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="src" select="concat($imgprefix, 'kred.png')"/>
                </xsl:otherwise>
            </xsl:choose>
            <!-- We don't want to control size fixed here, but using its class so so may adjust from there/localize it -->
            <!--xsl:attribute name="width" select="$size"/>
            <xsl:attribute name="height" select="$size"/-->
            
            <xsl:attribute name="class" select="'tipsz'"/>
            <xsl:attribute name="title" select="$status"/>
            
        </img>
    </xsl:template>

    <xsl:template name="showDate">
        <!--
            make date more readable
            2012-02-16T00:00:00       => 2012-02-16
            2012-02-16T19:24:11       => 2012-02-16 19:24:11
            2012-02-16T19:11:23+0100  => 2012-02-16 19:11:23 +01:00
            
            also replace "-" by non-breaking hyphen
        -->
        <xsl:param name="date"/>
        <xsl:variable name="predate" select="replace(string($date), '-', '&#8209;')"/>
        <xsl:choose>
            <xsl:when test="matches(string($date), '\d\d\d\d-\d\d-\d\dT00:00:00.*')">
                <xsl:value-of select="replace(string($predate), 'T00:00:00.*', '')"/>
            </xsl:when>
            <xsl:when test="matches(string($date), '\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\d.*')">
                <xsl:value-of select="replace(string($predate), 'T(\d\d:\d\d:\d\d).*', ' $1')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$predate"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="doName">
        <!--
            print out multi language names
            use template doDescription to do the work
        -->
        <!-- the name nodeset -->
        <xsl:param name="ns"/>
        
        <xsl:call-template name="doDescription">
            <xsl:with-param name="ns" select="$ns"/>
            <!--<xsl:with-param name="lang" select="$lang"/>-->
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template name="doCopyFile">
        <!-- copy XML file from to -->
        <xsl:param name="from"/>
        <xsl:param name="to"/>
        <xsl:variable name="cn" select="document($from)"/>
        <xsl:result-document href="{$to}" format="xml" indent="yes">
            <xsl:copy-of select="$cn"/>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="showDirection">
        <xsl:param name="dir"/>
        <xsl:choose>
            <xsl:when test="$dir='initial'">
                <xsl:call-template name="showIcon">
                    <xsl:with-param name="which">arrowright</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$dir='back'">
                <xsl:call-template name="showIcon">
                    <xsl:with-param name="which">arrowleft</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$dir='stationary'">
                <xsl:call-template name="showIcon">
                    <xsl:with-param name="which">rotate</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>?</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="getWherePathFromNodeset">
        <xsl:param name="rccontent"/>
        
        <xsl:variable name="toplevelelementname" select="($rccontent/@name)[1]"/>
        
        <!-- Unpack includes as they might lead to a template that has templateIds/codes we can use -->
        <xsl:variable name="rcunpacked">
            <xsl:for-each select="$rccontent">
                <xsl:choose>
                    <xsl:when test="self::element[@contains]">
                        <!-- lookup contained template content -->
                        <xsl:variable name="rctemp">
                            <xsl:call-template name="getRulesetContent">
                                <xsl:with-param name="ruleset" select="@contains"/>
                                <xsl:with-param name="flexibility" select="@flexibility"/>
                            </xsl:call-template>
                        </xsl:variable>

                        <!-- merge stuff -->
                        <element>
                            <xsl:copy-of select="@* except (@contains|@flexibility)" copy-namespaces="no"/>
                            <xsl:apply-templates select="./node()" mode="mergeContainingTemplate">
                                <xsl:with-param name="mergeNodes" select="$rctemp/template/(element|include|choice)"/>
                                <xsl:with-param name="mergeContext" select="exists($rctemp/template/context[@id=('*','**')])"/>
                                <xsl:with-param name="mergeLabel" select="''"/>
                            </xsl:apply-templates>
                            <xsl:apply-templates select="$rctemp/template/(element|include|choice)" mode="mergeContainedTemplate">
                                <xsl:with-param name="mergeNodes" select="./(element|include|choice)"/>
                                <xsl:with-param name="mergeContext" select="exists($rctemp/template/context[@id=('*','**')])"/>
                                <xsl:with-param name="mergeLabel" select="''"/>
                            </xsl:apply-templates>
                        </element>
                    </xsl:when>
                    <xsl:when test="self::element[include]">
                        <xsl:copy>
                            <xsl:copy-of select="@*" copy-namespaces="no"/>
                            <!-- TODO Could run into yet another element with @contains with potential influence on our path. Should have recursion... -->
                            <xsl:for-each select="attribute|vocabulary|element|include|choice">
                                <xsl:choose>
                                    <xsl:when test="self::include">
                                        <xsl:variable name="rccontentinclude">
                                            <xsl:call-template name="getRulesetContent">
                                                <xsl:with-param name="ruleset" select="@ref"/>
                                                <xsl:with-param name="flexibility" select="@flexibility"/>
                                            </xsl:call-template>
                                        </xsl:variable>
                                        <xsl:copy-of select="$rccontentinclude/template/(attribute|vocabulary|element|include|choice)" copy-namespaces="no"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:copy-of select="."/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each>
                        </xsl:copy>
                    </xsl:when>
                    <xsl:when test="self::include">
                        <xsl:variable name="rccontentinclude">
                            <xsl:call-template name="getRulesetContent">
                                <xsl:with-param name="ruleset" select="@ref"/>
                                <xsl:with-param name="flexibility" select="@flexibility"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:copy-of select="$rccontentinclude/template/(attribute|vocabulary|element|include|choice)" copy-namespaces="no"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="."/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:choose>
            
            <xsl:when test="count($rcunpacked/*)>1 or count($rcunpacked/element)!=1">
                <xsl:call-template name="logMessage">
                    <xsl:with-param name="level" select="$logWARN"/>
                    <xsl:with-param name="msg">
                        <xsl:text>+++ (getWherePathFromNodeset): exactly one top level element node allowed to get predicate from node set, found: </xsl:text>
                        <xsl:value-of select="$rccontent[1]/name()"/>
                        <xsl:text>/name=</xsl:text>
                        <xsl:value-of select="$toplevelelementname"/>
                        <xsl:for-each select="$rccontent/*">
                            <xsl:value-of select="@name"/>
                            <xsl:text> </xsl:text>
                            <xsl:value-of select="count($rccontent/element)"/>
                        </xsl:for-each>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            
            <xsl:when test="$skipPredicateCreation=true()">
                <xsl:value-of select="$toplevelelementname"/>
            </xsl:when>
            
            <xsl:when test="contains($toplevelelementname,'[')">
                <!-- if pathname already contains [] where => don't try to get a where selector -->
                <xsl:value-of select="$toplevelelementname"/>
            </xsl:when>
            
            <xsl:when test="$rcunpacked/element[@contains]">
                <xsl:call-template name="logMessage">
                    <xsl:with-param name="level" select="$logFATAL"/>
                    <xsl:with-param name="msg">
                        <xsl:text>+++ (getWherePathFromNodeset): merging went wrong somewhere, we still have @contains: </xsl:text>
                        <xsl:value-of select="$rcunpacked/element/name()"/>
                        <xsl:text>/name=</xsl:text>
                        <xsl:value-of select="$rcunpacked/element/@name"/>
                        <xsl:for-each select="$rccontent/@*">
                            <xsl:text> </xsl:text>
                            <xsl:value-of select="name()"/>
                            <xsl:text>="</xsl:text>
                            <xsl:value-of select="."/>
                            <xsl:text>"</xsl:text>
                        </xsl:for-each>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            
            <xsl:otherwise>

                <!-- THIS IS STILL IN TESTING MODE -->

                <!-- 
                    pick all hl7:templateId element with attribute/@root populated as child of that element, if any 
                    only template with an explicit context * or ** can determined where clauses by template id
                    
                    supports element with multiple elements, at least one of which contains a templateId. Useful e.g. for 
                        hl7:author
                            hl7:time
                            hl7:assignedEntity[hl7:templateId] 
                    or 
                        hl7:entryRelationship
                            hl7:sequenceNumber
                            hl7:observation[hl7:templateId]
                            
                    If for some reason there are multiple elements with templateId, it assumes the first only:
                        hl7:entryRelationship[not(hl7:templateId)]
                            hl7:sequenceNumber
                            hl7:entryRelationship[hl7:templateId]
                            hl7:entryRelationship[hl7:templateId]
                -->
                <xsl:variable name="telmname" select="concat($projectDefaultElementNamespace, 'templateId')"/>
                
                <xsl:variable name="theTemplateIdElement">
                    <xsl:choose>
                        <xsl:when test="$rcunpacked/template/context/@id='*'">
                            <xsl:for-each select="$rcunpacked/template/element[@name=$telmname]">
                                <xsl:if test="attribute[@root[string-length()>0] or @value[../@name='root'][string-length()>0]]">
                                    <xsl:copy-of select="."/>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:when test="$rcunpacked/template/context/@id='**'">
                            <xsl:for-each select="$rcunpacked/template/element/element[@name=$telmname]">
                                <xsl:if test="attribute[@root[string-length()>0] or @value[../@name='root'][string-length()>0]]">
                                    <xsl:copy-of select="."/>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:when test="$rcunpacked/element/element[@name=$telmname][@minimumMultiplicity > 0]">
                            <!-- Only take templateIds that are at least required, null is far fetched hence not taken into account -->
                            <xsl:for-each select="$rcunpacked/element/element[@name=$telmname][@minimumMultiplicity > 0]">
                                <xsl:if test="attribute[@root[string-length()>0] or @value[../@name='root'][string-length()>0]]">
                                    <xsl:copy-of select="."/>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:when test="$rcunpacked/element/element/element[@name=$telmname][@minimumMultiplicity > 0]">
                            <!-- Only take templateIds that are at least required, null is far fetched hence not taken into account -->
                            <xsl:for-each select="$rcunpacked/element/element[element[@name=$telmname][@minimumMultiplicity > 0]][1]/element[@name=$telmname][@minimumMultiplicity > 0]">
                                <xsl:if test="attribute[@root[string-length()>0] or @value[../@name='root'][string-length()>0]]">
                                    <xsl:copy-of select="."/>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:when>
                    </xsl:choose>
                </xsl:variable>
                
                <!--
                <xsl:message>
                    <xsl:copy-of select="$theTemplateIdElement"/>
                </xsl:message>
                -->

                <!-- 
                    deal with codes, situations
                    
                    1. template
                       id
                       code
                       value
                      
                    then $pn is predicated with $pn[code]
                    
                    2. template
                       observation|procedure|substanceAdministration|supply|act etc = intermediatelement
                         id
                         code
                          ...
                          
                    then $pn is predicated with $pn[intermediatelement[code]]
                    
                    2DO: includes
                -->

                <!--
                    do for codes
                    get 1st element on top level or one level down named 'code'
                    2DO includes!
                -->
                <!-- expected hl7:code name, but in case hl7:code is not found, see if the current element happens to be some other 
                    kind of coded element e.g. processingCode, processingModeCode, statusCode, versionCode, reasonCode, formCode etc.
                    For the fallback only test on current element, because it makes no sense matching on deeper levels. Final fallback
                    is hl7:code which is then handled under variable clevel and further on.
                -->
                <xsl:variable name="celmname">
                    <xsl:variable name="tmpcelmname" select="concat($projectDefaultElementNamespace, 'code')"/>
                    <xsl:choose>
                        <xsl:when test="$rcunpacked/element[@name=$tmpcelmname]">
                            <xsl:value-of select="$tmpcelmname"/>
                        </xsl:when>
                        <xsl:when test="$rcunpacked/element/element[@name=$tmpcelmname]">
                            <xsl:value-of select="$tmpcelmname"/>
                        </xsl:when>
                        <xsl:when test="$rcunpacked/element/element/element[@name=$tmpcelmname]">
                            <xsl:value-of select="$tmpcelmname"/>
                        </xsl:when>
                        <xsl:when test="$rcunpacked/element[@name][vocabulary]">
                            <xsl:value-of select="($rcunpacked/element[vocabulary]/@name)[1]"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$tmpcelmname"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>

                <!-- get level where code resides (probably) -->
                <xsl:variable name="clevel">
                    <xsl:choose>
                        <xsl:when test="count($rcunpacked/element[@name=$celmname])>0">
                            <xsl:value-of select="'0'"/>
                        </xsl:when>
                        <xsl:when test="count($rcunpacked/element/element[@name=$celmname])>0">
                            <xsl:value-of select="'1'"/>
                        </xsl:when>
                        <xsl:when test="count($rcunpacked/element/element/element[@name=$celmname])>0">
                            <!-- top level + 1 of template, store the name of the ancestor element of the element named code -->
                            <xsl:value-of select="($rcunpacked/element/element[element[@name=$celmname]]/@name)[1]"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- no element named code found, mark this as empty -->
                            <xsl:value-of select="''"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>

                <!-- pick code element, if any -->
                <xsl:variable name="theCodeElement">
                    <xsl:choose>
                        <xsl:when test="$clevel=''">
                            <!-- none -->
                        </xsl:when>
                        <xsl:when test="$clevel='0'">
                            <xsl:copy-of select="($rcunpacked/element[@name=$celmname])[1]"/>
                        </xsl:when>
                        <xsl:when test="$clevel='1'">
                            <xsl:copy-of select="($rcunpacked/element/element[@name=$celmname])[1]"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:copy-of select="($rcunpacked/element/element/element[@name=$celmname])[1]"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>

                <!-- get properties from this code attribute, either a single code/codeSystem or a set of values-->

                <!--
                <xsl:if test="$clevel='hl7:observation'">
                    <xsl:message>
                        <xsl:value-of select="$pn"/>
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="$clevel"/>
                        <xsl:text>::</xsl:text>
                        <xsl:copy-of select="$theCodeElement"/>
                    </xsl:message>
                </xsl:if>
                -->

                <!-- now make the checks and output pathname -->
                <xsl:variable name="predicate">
                    <xsl:choose>
                        <!--
                            give priority to template ids as where selectors if any
                        -->
                        <xsl:when test="$theTemplateIdElement/element">
                            <!--
                                <xsl:message>
                                <xsl:copy-of select="$theTemplateIdElement"/>
                                </xsl:message>
                            -->
                            <xsl:choose>
                                <xsl:when test="string-length($toplevelelementname)>0">
                                    <xsl:value-of select="$toplevelelementname"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>*</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:choose>
                                <xsl:when test="$rcunpacked/template/context/@id='*'"/>
                                <xsl:when test="$rcunpacked/template/context/@id='**'">
                                    <xsl:text>[</xsl:text>
                                    <xsl:value-of select="($rcunpacked/template/element/@name)[1]"/>
                                </xsl:when>
                                <xsl:when test="$rcunpacked/element/element[@name=$telmname][@minimumMultiplicity > 0]">
                                    <!-- Skip this level explicitly -->
                                </xsl:when>
                                <xsl:when test="$rcunpacked/element/element/element[@name=$telmname][@minimumMultiplicity > 0]">
                                    <xsl:text>[</xsl:text>
                                    <!-- Insert parent element for the templateId element -->
                                    <xsl:value-of select="($rcunpacked/element/element[element[@name=$telmname][@minimumMultiplicity > 0]][1]/@name)[1]"/>
                                </xsl:when>
                            </xsl:choose>

                            <xsl:text>[</xsl:text>
                            <xsl:value-of select="$projectDefaultElementNamespace"/>
                            <xsl:text>templateId[</xsl:text>
                            <xsl:for-each select="$theTemplateIdElement/*">
                                <xsl:text>@root='</xsl:text>
                                <xsl:value-of select="(attribute/@root[string-length()>0] | attribute[@name='root']/@value[string-length()>0])[1]"/>
                                <xsl:text>'</xsl:text>
                                <xsl:if test="position()!=last()">
                                    <xsl:text> or </xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                            <xsl:text>]]</xsl:text>

                            <xsl:choose>
                                <xsl:when test="$rcunpacked/template/context/@id='*'"/>
                                <xsl:when test="$rcunpacked/template/context/@id='**'">
                                    <xsl:text>]</xsl:text>
                                </xsl:when>
                                <xsl:when test="$rcunpacked/element/element[@name=$telmname][@minimumMultiplicity > 0]">
                                    <!-- Skip this level explicitly -->
                                </xsl:when>
                                <xsl:when test="$rcunpacked/element/element/element[@name=$telmname][@minimumMultiplicity > 0]">
                                    <xsl:text>]</xsl:text>
                                </xsl:when>
                            </xsl:choose>

                        </xsl:when>
                        <xsl:when test="$theCodeElement/*[@minimumMultiplicity > 0]/vocabulary[@code or @codeSystem or @valueSet]">
                            <!-- has code attribute, output name and where path -->
                            <xsl:if test="string-length($toplevelelementname)>0">
                                <xsl:value-of select="$toplevelelementname"/>
                            </xsl:if>

                            <!-- if top level + 1 then emit the intermediate element also -->
                            <!--
                            <xsl:if test="$clevel!='' and $clevel!='*'">
                                <xsl:value-of select="$clevel"/>
                                <xsl:text>[</xsl:text>
                            </xsl:if>
                            -->
                            <!--
                            <xsl:message>
                                <xsl:value-of select="$pn"/>
                                <xsl:text>:::</xsl:text>
                                <xsl:value-of select="$clevel"/>
                            </xsl:message>
                           -->

                            <xsl:variable name="whereselector">
                                <xsl:for-each select="$theCodeElement/*/vocabulary[@code or @codeSystem or @valueSet]">
                                    <xsl:choose>
                                        <xsl:when test="@code and @codeSystem">
                                            <xsl:text>(@code='</xsl:text>
                                            <xsl:value-of select="@code"/>
                                            <xsl:text>' and @codeSystem='</xsl:text>
                                            <xsl:value-of select="@codeSystem"/>
                                            <xsl:text>')</xsl:text>
                                        </xsl:when>
                                        <xsl:when test="@codeSystem">
                                            <!-- this is easliy be underdetermined -->
                                            <xsl:text>@codeSystem='</xsl:text>
                                            <xsl:value-of select="@codeSystem"/>
                                            <xsl:text>'</xsl:text>
                                        </xsl:when>
                                        <xsl:when test="@code">
                                            <!-- this is easliy be underdetermined -->
                                            <xsl:text>@code='</xsl:text>
                                            <xsl:value-of select="@code"/>
                                            <xsl:text>'</xsl:text>
                                        </xsl:when>
                                        <xsl:when test="@valueSet">
                                            <xsl:variable name="vsdatatype" select="../@datatype"/>
                                            <xsl:variable name="xvsref" select="@valueSet"/>
                                            <xsl:variable name="xvsflex" select="if (@flexibility) then (@flexibility) else ('dynamic')"/>
                                            <xsl:variable name="xvs">
                                                <xsl:call-template name="getValueset">
                                                    <xsl:with-param name="reference" select="$xvsref"/>
                                                    <xsl:with-param name="flexibility" select="$xvsflex"/>
                                                </xsl:call-template>
                                            </xsl:variable>
                                            <xsl:variable name="xvsid" select="($xvs/valueSet)[1]/@id"/>
                                            <xsl:variable name="valueSetFileObject">
                                                <xsl:choose>
                                                    <xsl:when test="$xvsflex='dynamic'">
                                                        <xsl:value-of select="concat($theRuntimeRelativeIncludeDir, 'voc-', $xvsid, '-DYNAMIC.xml')"/>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:value-of select="concat($theRuntimeRelativeIncludeDir, 'voc-', $xvsid, '-',replace($xvsflex,':',''),'.xml')"/>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:variable>
                                            <xsl:choose>
                                                <xsl:when test="$vsdatatype='CS'">
                                                    <!-- If CS we do not have a codeSystem. Can check code against conceptList, but cannot check codeSystem against completeCodeSystem -->
                                                    <xsl:if test="$xvs/valueSet[1][conceptList/concept]">
                                                        <xsl:text>@code=doc('</xsl:text>
                                                        <xsl:value-of select="$valueSetFileObject"/>
                                                        <xsl:text>')/*/valueSet/conceptList/*/@code</xsl:text>
                                                    </xsl:if>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <!-- If not CS, but no datatype given or any other (assumed coded) datatype, we should find a matching conceptList/code or completeCodeSystem -->
                                                    <xsl:for-each select="$xvs/valueSet[1]/completeCodeSystem">
                                                        <xsl:text>@codeSystem='</xsl:text>
                                                        <xsl:value-of select="@codeSystem"/>
                                                        <xsl:text>'</xsl:text>
                                                        <xsl:if test="position() != last()">
                                                            <xsl:text> or </xsl:text>
                                                        </xsl:if>
                                                    </xsl:for-each>
                                                    <xsl:if test="$xvs/valueSet[1][completeCodeSystem][conceptList/concept]">
                                                        <xsl:if test="position() != last()">
                                                            <xsl:text> or </xsl:text>
                                                        </xsl:if>
                                                    </xsl:if>
                                                    <xsl:if test="$xvs/valueSet[1][conceptList/concept]">
                                                        <xsl:text>concat(@code,@codeSystem)=doc('</xsl:text>
                                                        <xsl:value-of select="$valueSetFileObject"/>
                                                        <xsl:text>')/*/valueSet/conceptList/concept/concat(@code,@codeSystem) or (@nullFlavor=doc('</xsl:text>
                                                        <xsl:value-of select="$valueSetFileObject"/>
                                                        <xsl:text>')/*/valueSet/conceptList/exception/@code)</xsl:text>
                                                    </xsl:if>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:when>
                                    </xsl:choose>

                                    <xsl:if test="position() != last()">
                                        <xsl:text> or </xsl:text>
                                    </xsl:if>

                                </xsl:for-each>
                            </xsl:variable>

                            <xsl:choose>
                                <xsl:when test="string-length($whereselector)=0">
                                    <xsl:call-template name="logMessage">
                                        <xsl:with-param name="level" select="$logWARN"/>
                                        <xsl:with-param name="msg">
                                            <xsl:text>+++ where selector (predicate) insufficient in: </xsl:text>
                                            <xsl:value-of select="$toplevelelementname"/>
                                            <xsl:text> - code=</xsl:text>
                                            <xsl:value-of select="$theCodeElement/*/vocabulary/@code"/>
                                            <xsl:text> codeSystem=</xsl:text>
                                            <xsl:value-of select="$theCodeElement/*/vocabulary/@codeSystem"/>
                                            <xsl:text> valueSet=</xsl:text>
                                            <xsl:value-of select="$theCodeElement/*/vocabulary/@valueSet"/>
                                            <xsl:text> templateId=</xsl:text>
                                            <xsl:value-of select="$theTemplateIdElement/element/attribute/@root | $theTemplateIdElement/element/attribute[@name='root']/@value"/>
                                            <xsl:text> element=</xsl:text>
                                            <xsl:value-of select="$theTemplateIdElement/element/@name"/>
                                        </xsl:with-param>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:when test="$clevel='0'">
                                    <xsl:if test="string-length($whereselector)>0">
                                        <xsl:text>[</xsl:text>
                                        <xsl:value-of select="$whereselector"/>
                                        <!-- add nullFlavor if applicable -->
                                        <xsl:if test="$theCodeElement/*[not(string(@isMandatory)='true')]">
                                            <xsl:text> or @nullFlavor</xsl:text>
                                        </xsl:if>
                                        <xsl:text>]</xsl:text>
                                    </xsl:if>
                                </xsl:when>
                                <xsl:when test="$clevel='1'">
                                    <xsl:if test="string-length($toplevelelementname)>0">
                                        <xsl:text>[</xsl:text>
                                    </xsl:if>
                                    <!-- if code is toplevel + 1 then $pn contains hl7:code already -->
                                    <xsl:value-of select="$projectDefaultElementNamespace"/>
                                    <xsl:text>code[</xsl:text>
                                    <xsl:value-of select="$whereselector"/>
                                    <!-- add nullFlavor if applicable -->
                                    <xsl:if test="$theCodeElement/*[not(string(@isMandatory)='true')]">
                                        <xsl:text> or @nullFlavor</xsl:text>
                                    </xsl:if>
                                    <xsl:text>]</xsl:text>
                                    <xsl:if test="string-length($toplevelelementname)>0">
                                        <xsl:text>]</xsl:text>
                                    </xsl:if>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:if test="string-length($toplevelelementname)>0">
                                        <xsl:text>[</xsl:text>
                                    </xsl:if>
                                    <!-- if code is toplevel + 2 then intersperse intermediate element -->
                                    <xsl:value-of select="$clevel"/>
                                    <xsl:text>[</xsl:text>
                                    <xsl:value-of select="$projectDefaultElementNamespace"/>
                                    <xsl:text>code[</xsl:text>
                                    <xsl:value-of select="$whereselector"/>
                                    <!-- add nullFlavor if applicable -->
                                    <xsl:if test="$theCodeElement/*[not(string(@isMandatory)='true')]">
                                        <xsl:text> or @nullFlavor</xsl:text>
                                    </xsl:if>

                                    <xsl:text>]]</xsl:text>
                                    <xsl:if test="string-length($toplevelelementname)>0">
                                        <xsl:text>]</xsl:text>
                                    </xsl:if>
                                </xsl:otherwise>
                            </xsl:choose>

                            <!-- if top level + 1 then close brackets -->
                            <!--xsl:if test="$clevel!='' and $clevel!='*'">
                                <xsl:text>]</xsl:text>
                            </xsl:if-->
                        </xsl:when>
                        <xsl:when test="count($rcunpacked/element/attribute[@root or (@name='root' and string-length(@value)>0)][not(string(@isOptional)='true')])>0">
                            <!-- immediate element of template has a @root attribute -->
                            <!-- @root might be optional allowing for nullFlavor or name=root may not contain any @value -->
                            <xsl:value-of select="$toplevelelementname"/>
                            <xsl:text>[</xsl:text>
                            <xsl:for-each select="tokenize(string-join(($rcunpacked/element/attribute[not(string(@isOptional)='true')]/@root|$rcunpacked/element/attribute[@name='root'][not(string(@isOptional)='true')]/@value),'|'), '\|')">
                                <xsl:text>@root='</xsl:text>
                                <xsl:value-of select="."/>
                                <xsl:text>'</xsl:text>
                                <xsl:if test="position() != last()">
                                    <xsl:text> or </xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                            <xsl:text>]</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- no where found, return name -->
                            <xsl:choose>
                                <xsl:when test="string-length($toplevelelementname)>0">
                                    <xsl:value-of select="$toplevelelementname"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$rccontent/element/@name"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>

                <!-- output it -->
                <xsl:value-of select="$predicate"/>

            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="lastIndexOf">
        <!-- declare that it takes two parameters - the string and the char -->
        <xsl:param name="string"/>
        <xsl:param name="char"/>
        <xsl:choose>
            <!-- if the string contains the character... -->
            <xsl:when test="contains($string, $char)">
                <!-- call the template recursively... -->
                <xsl:call-template name="lastIndexOf">
                    <!-- with the string being the string after the character
                    -->
                    <xsl:with-param name="string" select="substring-after($string, $char)"/>
                    <!-- and the character being the same as before -->
                    <xsl:with-param name="char" select="$char"/>
                </xsl:call-template>
            </xsl:when>
            <!-- otherwise, return the value of the string -->
            <xsl:otherwise>
                <xsl:value-of select="$string"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="splitString">
        <xsl:param name="str"/>
        <xsl:param name="del"/>
        <xsl:param name="preceedIndent"/>
        <xsl:variable name="xstr1">
            <!-- never split / -->
            <xsl:value-of select="replace($str, '/', '%%1')"/>
        </xsl:variable>
        <xsl:variable name="xstr2">
            <!-- never split /@ attribute -->
            <xsl:value-of select="replace($xstr1, '/@', '%%2')"/>
        </xsl:variable>
        <xsl:variable name="x">
            <xsl:call-template name="tokenize">
                <xsl:with-param name="string" select="$xstr2"/>
                <xsl:with-param name="delimiters" select="$del"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:for-each select="$x/token">
            <xsl:call-template name="repeatString">
                <xsl:with-param name="number" select="count(preceding-sibling::node())"/>
                <xsl:with-param name="theString" select="$preceedIndent"/>
            </xsl:call-template>
            <!-- replace placeholders again -->
            <xsl:variable name="xstr3">
                <xsl:value-of select="replace(., '%%1', '/')"/>
            </xsl:variable>
            <xsl:value-of select="replace($xstr3, '%%2', '/@')"/>
            <br/>
        </xsl:for-each>
    </xsl:template>
    
    <!-- output # of strings (repeat) -->
    <xsl:template name="repeatString">
        <xsl:param name="number"/>
        <xsl:param name="theString"/>
        <xsl:for-each select="1 to $number">
            <xsl:value-of select="$theString"/>
        </xsl:for-each>
    </xsl:template>
    
    <!-- 
        
        tokenize functions
        
    -->
    <xsl:template name="tokenize">
        <xsl:param name="string" select="''"/>
        <xsl:param name="delimiters" select="' &#x9;&#xA;'"/>
        <xsl:choose>
            <xsl:when test="not($string)"/>
            <xsl:when test="not($delimiters)">
                <xsl:call-template name="tokenize-characters">
                    <xsl:with-param name="string" select="$string"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="tokenize-delimiters">
                    <xsl:with-param name="string" select="$string"/>
                    <xsl:with-param name="delimiters" select="$delimiters"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="tokenize-characters">
        <xsl:param name="string"/>
        <xsl:if test="$string">
            <token>
                <xsl:value-of select="substring($string, 1, 1)"/>
            </token>
            <xsl:call-template name="tokenize-characters">
                <xsl:with-param name="string" select="substring($string, 2)"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="tokenize-delimiters">
        <xsl:param name="string"/>
        <xsl:param name="delimiters"/>
        <xsl:variable name="delimiter" select="substring($delimiters, 1, 1)"/>
        <xsl:choose>
            <xsl:when test="not($delimiter)">
                <token>
                    <xsl:value-of select="$string"/>
                </token>
            </xsl:when>
            <xsl:when test="contains($string, $delimiter)">
                <xsl:if test="not(starts-with($string, $delimiter))">
                    <xsl:call-template name="tokenize-delimiters">
                        <xsl:with-param name="string" select="substring-before($string, $delimiter)"/>
                        <xsl:with-param name="delimiters" select="substring($delimiters, 2)"/>
                    </xsl:call-template>
                </xsl:if>
                <xsl:call-template name="tokenize-delimiters">
                    <xsl:with-param name="string" select="substring-after($string, $delimiter)"/>
                    <xsl:with-param name="delimiters" select="$delimiters"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="tokenize-delimiters">
                    <xsl:with-param name="string" select="$string"/>
                    <xsl:with-param name="delimiters" select="substring($delimiters, 2)"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:function name="local:randomString2">
        <!-- gid parameter is dummy to prevent caching of document() -->
        <xsl:param name="gid"/>
        <xsl:variable name="r" select="document(concat('http://art-decor.org/decor/services/modules/random-string.xquery?', $gid))/random/text()"/>
        <xsl:value-of select="$r"/>
        <!--
        <xsl:message>
            <xsl:value-of select="$r"/>
        </xsl:message>
        -->
    </xsl:function>
    
    <xsl:template name="local:randomString">
        <!--
        <xsl:value-of select="uuid:randomUUID()"/>
        -->
    </xsl:template>
    
    <xsl:template name="logMessage">
        <xsl:param name="msg" as="item()*"/>
        <xsl:param name="level" select="$logINFO" as="xs:string"/>
        <xsl:param name="terminate" select="false()" as="xs:boolean"/>
        
        <xsl:variable name="term" select="if ($terminate) then 'yes' else 'no'"/>
        <xsl:if test="$logLevelMap/level[@name=$level]/number(@int) &lt;= $logLevelMap/level[@name=$chkdLogLevel]/number(@int)">
            <xsl:message terminate="{$term}">
                <!-- Avoid unnecessary strain on time service. Only log time based from INFO -->
                <!--<xsl:if test="$lvl=$logINFO">
                    <xsl:value-of select="doc('http://art-decor.org/decor/services/modules/current-milliseconds.xquery?format=string')"/>
                    <xsl:text> </xsl:text>
                </xsl:if>-->
                <xsl:value-of select="substring(concat($level,'        '),1,7)"/>
                <xsl:text>: </xsl:text>
                <xsl:copy-of select="$msg"/>
            </xsl:message>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
