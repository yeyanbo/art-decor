<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:mif2="urn:hl7-org:v3/mif2"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all"
    version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Jun 5, 2013</xd:p>
            <xd:p><xd:b>Author:</xd:b> ahenket</xd:p>
            <xd:p>Step 1: Feed coreMif vocab file, and get a full project with value sets</xd:p>
            <xd:p>Step 2: Export previous iteration of the project and merge the two using merge_decor_valuesets.xsl</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:output indent="yes" omit-xml-declaration="yes"/>
    
    <xsl:param name="decorProjectOID" select="'2.16.840.1.113883.3.1937.777.2'"/>
    <xsl:param name="decorProjectPrefix" select="'ad2bbr-'"/>
    <xsl:param name="decorProjectLanguage" select="'en-US'"/>
    <xsl:param name="decorProjectName" select="/mif2:vocabularyModel/@title"/>
    <xsl:param name="decorValuesetVersionLabel" select="/mif2:vocabularyModel/mif2:packageLocation/@combinedId"/>
    
    <xsl:param name="includeDeprecatedValuesets" select="true()" as="xs:boolean"/>
    <xsl:param name="includeDeprecatedCodes" select="false()" as="xs:boolean"/>
    
    <!--
        <vocabularyModel xmlns="urn:hl7-org:v3/mif2" name="1206-20130318" title="HL7 Vocabulary" packageKind="version" definitionKind="partial-publishing" schemaVersion="2.1.6">
	<packageLocation combinedId="DEFN=UV=VO=1206-20130318" root="DEFN" artifact="VO" realmNamespace="UV" version="1206-20130318"/>
    -->
    
    <!-- cache conceptDomains -->
    <xsl:variable name="allConceptDomains" select="/mif2:vocabularyModel/mif2:conceptDomain"/>
    
    <!-- cache codeSystems -->
    <xsl:variable name="allCodeSystems" select="/mif2:vocabularyModel/mif2:codeSystem"/>
    
    <!-- cache valueSets -->
    <xsl:variable name="allValueSets" select="/mif2:vocabularyModel/mif2:valueSet"/>
    
    <!-- creationDateTime -->
    <xsl:variable name="creationDateTime" select="current-dateTime()" as="xs:dateTime"/>
    
    <!-- effectiveDate picture string -->
    <xsl:variable name="effectiveDateTimePicture" select="'[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01]'"/>
    
    <xsl:template match="/">
        <xsl:processing-instruction name="xml-stylesheet"> type="text/xsl" href="http://art-decor.org/ADAR/rv/DECOR2schematron.xsl"</xsl:processing-instruction>
        <xsl:processing-instruction name="xml-model"> href="http://art-decor.org/ADAR/rv/DECOR.xsd" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:processing-instruction>
        <decor xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://art-decor.org/ADAR/rv/DECOR.xsd" private="true" repository="true">
            <project id="{$decorProjectOID}" prefix="{$decorProjectPrefix}" defaultLanguage="{$decorProjectLanguage}">
                <name language="en-US">HL7 V3 Value Sets</name>
                <name language="nl-NL">HL7v3-waardelijsten</name>
                <desc language="en-US">
                    <h3>The ART-DECOR Building Block Repository for HL7 V3 Value Sets</h3>
                    <h4>What is it?</h4>
                    This project contains HL7 V3 value sets as defined in coreMif that may be found <a href="http://gforge.hl7.org/gf/project/design-repos/">here</a>.</desc>
                <desc language="nl-NL">
                    <h3>De ART-DECOR Building Block Repository voor HL7v3-waardelijsten</h3>
                    <h4>Wat is het?</h4>
                    Dit project bevat HL7v3-waardelijsten gedefinieerd in coreMif zoals <a href="http://gforge.hl7.org/gf/project/design-repos/">hier</a> te vinden.</desc>
                
                <copyright years="{string-join(for $i in (2000 to xs:integer(year-from-date(current-date()))) return string($i),' ')}" by="HL7" logo="hl7intllogo.jpg">
                    <addrLine>Health Level Seven International</addrLine>
                    <addrLine>3300 Washtenaw Avenue</addrLine>
                    <addrLine>Suite 227</addrLine>
                    <addrLine>Ann Arbor, MI 48104- 4261</addrLine>
                    <addrLine>USA</addrLine>
                    <addrLine>T +1 734 677 7777</addrLine>
                    <addrLine>F +1 734 677 6622</addrLine>
                    <addrLine>E info@hl7.org</addrLine>
                </copyright>
                <copyright years="{string-join(for $i in (2013 to xs:integer(year-from-date(current-date()))) return string($i),' ')}" by="The ART-DECOR expert group" logo="art-decor-logo-small.jpg">
                    <addrLine>E info@art-decor.org</addrLine> 
                    <addrLine>E contact@art-decor.org</addrLine>
                </copyright>
                <author id="1" username="alexander">Alexander Henket</author>
                <author id="2" username="kai">dr Kai U. Heitmann</author>
                <reference url="http://ad2bbr.art-decor.org/"/>
                <release date="{format-dateTime($creationDateTime,$effectiveDateTimePicture)}" by="AH" versionLabel="{$decorValuesetVersionLabel}">
                    <note language="{$decorProjectLanguage}">
                        <xsl:text>Converted </xsl:text>
                        <xsl:choose>
                            <xsl:when test="$includeDeprecatedValuesets=true()">with</xsl:when>
                            <xsl:otherwise>without</xsl:otherwise>
                        </xsl:choose>
                        <xsl:text> deprecated value sets, and </xsl:text>
                        <xsl:choose>
                            <xsl:when test="$includeDeprecatedCodes=true()">with</xsl:when>
                            <xsl:otherwise>without</xsl:otherwise>
                        </xsl:choose>
                        <xsl:text> deprecated codes/codeSystems from file </xsl:text>
                        <xsl:value-of select="tokenize(document-uri(.),'/')[last()]"/>
                        <xsl:text>, packageLocation </xsl:text>
                        <xsl:for-each select="/mif2:vocabularyModel/mif2:packageLocation/@*">
                            <xsl:value-of select="name(.)"/>
                            <xsl:text>="</xsl:text>
                            <xsl:value-of select="."/>
                            <xsl:text>"</xsl:text>
                            <xsl:if test="position()!=last()">
                                <xsl:text> </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                    </note>
                    <note language="nl-NL">
                        <xsl:text>Geconverteerd </xsl:text>
                        <xsl:choose>
                            <xsl:when test="$includeDeprecatedValuesets=true()">met</xsl:when>
                            <xsl:otherwise>zonder</xsl:otherwise>
                        </xsl:choose>
                        <xsl:text> deprecated waardelijsten, en </xsl:text>
                        <xsl:choose>
                            <xsl:when test="$includeDeprecatedCodes=true()">met</xsl:when>
                            <xsl:otherwise>zonder</xsl:otherwise>
                        </xsl:choose>
                        <xsl:text> deprecated codes/valueSets/codeSystems van bestand </xsl:text>
                        <xsl:value-of select="tokenize(document-uri(.),'/')[last()]"/>
                        <xsl:text>, packageLocation </xsl:text>
                        <xsl:for-each select="/mif2:vocabularyModel/mif2:packageLocation/@*">
                            <xsl:value-of select="name(.)"/>
                            <xsl:text>="</xsl:text>
                            <xsl:value-of select="."/>
                            <xsl:text>"</xsl:text>
                            <xsl:if test="position()!=last()">
                                <xsl:text> </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                    </note>
                </release>
            </project>
            <terminology>
                <xsl:for-each select="$allValueSets">
                    <xsl:apply-templates select="."/>
                </xsl:for-each>
            </terminology>
        </decor>
    </xsl:template>
    
    <!--
        <valueSet id="2.16.840.1.113883.1.11.14516" name="OralTablet">
            <version versionDate="2013-03-11">
                <supportedCodeSystem>2.16.840.1.113883.5.85</supportedCodeSystem>
                <supportedLanguage>en</supportedLanguage>
                <content codeSystem="2.16.840.1.113883.5.85">
                    <codeBasedContent code="ORTAB">
                        <includeRelatedCodes relationshipName="Generalizes" relationshipTraversal="TransitiveClosure"/>
                    </codeBasedContent>
                </content>
            </version>
        </valueSet>
    -->
    <xsl:template match="mif2:valueSet">
        <xsl:variable name="vsId" select="@id"/>
        <xsl:variable name="vsName" select="@name"/>
        <xsl:variable name="vsEff">
            <xsl:choose>
                <xsl:when test="string-length(mif2:version/@versionDate)=10">
                    <xsl:value-of select="concat(mif2:version/@versionDate,'T00:00:00')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="mif2:version/@versionDate"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="vsLang">
            <xsl:choose>
                <xsl:when test="mif2:version/mif2:supportedLanguage='en'">en-US</xsl:when>
                <xsl:otherwise>en-US</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="vsStatus">
            <xsl:choose>
                <xsl:when test="mif2:annotations//mif2:deprecationInfo">deprecated</xsl:when>
                <xsl:otherwise>final</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="vsLabel">
            <xsl:choose>
                <xsl:when test="mif2:annotations//mif2:deprecationInfo[@deprecationEffectiveVersion]">
                    <xsl:value-of select="mif2:annotations//mif2:deprecationInfo/@deprecationEffectiveVersion"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$decorValuesetVersionLabel"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:if test="$includeDeprecatedValuesets or not($vsStatus='deprecated')">

            <xsl:variable name="valueSet">
                <valueSet id="{$vsId}" name="{replace($vsName,'\s','')}" displayName="{$vsName}" effectiveDate="{$vsEff}" statusCode="{$vsStatus}" versionLabel="{$vsLabel}">
                    <xsl:if test="$vsStatus='deprecated'">
                        <xsl:attribute name="expirationDate" select="$vsEff"/>
                    </xsl:if>
                    <xsl:call-template name="handleValueSetDescription">
                        <xsl:with-param name="lang" select="$vsLang"/>
                    </xsl:call-template>
                    <xsl:choose>
                        <xsl:when test="mif2:version/mif2:content[not(mif2:* except (mif2:annotations|mif2:nonComputableContent))]">
                            <xsl:call-template name="handleCompleteCodeSystem">
                                <xsl:with-param name="codeSystem" select="mif2:version/mif2:content/@codeSystem"/>
                                <xsl:with-param name="valueSetStatus" select="$vsStatus"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <conceptList>
                                <xsl:call-template name="handleValueSetEnumeration">
                                    <xsl:with-param name="content" select="mif2:version/mif2:content"/>
                                    <xsl:with-param name="level" select="0"/>
                                    <xsl:with-param name="valueSetStatus" select="$vsStatus"/>
                                </xsl:call-template>
                            </conceptList>
                        </xsl:otherwise>
                    </xsl:choose>
                </valueSet>
            </xsl:variable>
            
            <xsl:if test="$valueSet/valueSet//(completeCodeSystem|concept|include)">
                <valueSet>
                    <xsl:copy-of select="$valueSet/valueSet/@*"/>
                    <xsl:copy-of select="$valueSet/valueSet/desc"/>
                    <xsl:copy-of select="$valueSet/valueSet//completeCodeSystem"/>
                    <xsl:if test="$valueSet/valueSet/conceptList/(concept|include)">
                        <conceptList>
                            <xsl:copy-of select="$valueSet/valueSet//conceptList/(comment()|concept|include)"/>
                        </conceptList>
                    </xsl:if>
                </valueSet>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="handleCompleteCodeSystem">
        <xsl:param name="codeSystem" required="yes"/>
        <xsl:param name="valueSetStatus" required="yes"/>
        <xsl:variable name="level" select="0"/>
        <xsl:variable name="codeSystemName">
            <xsl:call-template name="codeSystemName">
                <xsl:with-param name="codeSystem" select="$codeSystem"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="codeSystemVersion">
            <xsl:call-template name="codeSystemVersion">
                <xsl:with-param name="codeSystem" select="$codeSystem"/>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:variable name="completeCodeSystem" select="$allCodeSystems[@codeSystemId=$codeSystem]"/>
        
        <xsl:variable name="codeSystemStatus">
            <xsl:call-template name="codeSystemStatus">
                <xsl:with-param name="codeSystem" select="$codeSystem"/>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$completeCodeSystem/mif2:releasedVersion/mif2:concept">
                <conceptList>
                    <xsl:comment> START completeCodeSystem codeSystem="<xsl:value-of select="$codeSystem"/>" name="<xsl:value-of select="$codeSystemName"/>" </xsl:comment>
                    <xsl:for-each select="$completeCodeSystem/mif2:releasedVersion/mif2:concept[not(mif2:conceptRelationship)]/mif2:code">
                        <xsl:variable name="code" select="@code"/>
                        <xsl:variable name="displayName">
                            <xsl:call-template name="codedConceptDisplayName">
                                <xsl:with-param name="code" select="$code"/>
                                <xsl:with-param name="codeSystem" select="$codeSystem"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:variable name="type">
                            <xsl:call-template name="codedConceptType">
                                <xsl:with-param name="code" select="$code"/>
                                <xsl:with-param name="codeSystem" select="$codeSystem"/>
                            </xsl:call-template>
                        </xsl:variable>
                        
                        <xsl:if test="$valueSetStatus='deprecated' or $includeDeprecatedCodes or not($type='D')">
                            <concept code="{$code}" codeSystem="{$codeSystem}" displayName="{$displayName}" level="{$level}" type="{$type}"/>

                            <xsl:call-template name="codedConceptChildren">
                                <xsl:with-param name="traversalType" select="'TransitiveClosure'"/>
                                <xsl:with-param name="parentLevel" select="$level"/>
                                <xsl:with-param name="parentCode" select="$code"/>
                                <xsl:with-param name="parentCodeSystem" select="$codeSystem"/>
                                <xsl:with-param name="parentCodeSystemName" select="$codeSystemName"/>
                                <!--xsl:with-param name="parentCodeSystemVersion" select="$codeSystemVersion"/-->
                                <xsl:with-param name="valueSetStatus" select="$valueSetStatus"/>
                            </xsl:call-template>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:comment> END completeCodeSystem codeSystem="<xsl:value-of select="$codeSystem"/>" name="<xsl:value-of select="$codeSystemName"/>" </xsl:comment>
                </conceptList>
            </xsl:when>
            <xsl:when test="$valueSetStatus='deprecated' or $includeDeprecatedCodes or not($codeSystemStatus='deprecated')">
                <!--<completeCodeSystem codeSystem="{$codeSystem}" codeSystemName="{$codeSystemName}" codeSystemVersion="{$codeSystemVersion}"/>-->
                <completeCodeSystem codeSystem="{$codeSystem}" codeSystemName="{$codeSystemName}"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- Skipping codeSystem -->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Should we do anything here for associatedConceptProperty? What has it done for us lately?
        <valueSet id="2.16.840.1.113883.1.11.11610" name="x_ActRelationshipDocument">
            <annotations>...</annotations>
            <version versionDate="2013-03-11">
                <supportedCodeSystem>2.16.840.1.113883.5.1002</supportedCodeSystem>
                <supportedLanguage>en</supportedLanguage>
                <associatedConceptProperty name="Name:Act:outboundRelationship:ActRelationship" value="relatedDocument"/>
                <associatedConceptProperty name="Sort:Act:outboundRelationship:ActRelationship" value="BI_______"/>
                <associatedConceptProperty name="Name:Act:inboundRelationship:ActRelationship" value="relatedTo"/>
                <associatedConceptProperty name="Sort:Act:inboundRelationship:ActRelationship" value="BI_______"/>
                <content codeSystem="2.16.840.1.113883.5.1002">
                    <codeBasedContent code="APND"/>
                    <codeBasedContent code="RPLC"/>
                    <codeBasedContent code="XFRM"/>
                </content>
            </version>
        </valueSet>
    -->
    <xsl:template name="handleValueSetEnumeration">
        <xsl:param name="exclude" as="xs:string*"/>
        <xsl:param name="content" required="yes"/>
        <xsl:param name="level" required="yes" as="xs:integer"/>
        <xsl:param name="valueSetStatus" required="yes"/>
        
        <xsl:variable name="codeSystem" select="$content/@codeSystem"/>
        
        <!-- <concept code="_Confidentiality" codeSystem="{$codeSystem}" codeSystemName="{$codeSystemName}" codeSystemVersion="{$codeSystemVersion}" displayName="Confidentiality" level="0" type="A"/> -->
        
        <xsl:for-each select="$content/mif2:*">
            <xsl:choose>
                <xsl:when test="self::mif2:codeBasedContent">
                    <xsl:call-template name="handleCodeBasedContent">
                        <xsl:with-param name="exclude" select="$exclude"/>
                        <xsl:with-param name="level" select="$level"/>
                        <xsl:with-param name="codeSystem" select="$codeSystem"/>
                        <xsl:with-param name="valueSetStatus" select="$valueSetStatus"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="self::mif2:valueSetRef">
                    <xsl:variable name="vsId" select="@id"/>
                    <xsl:variable name="vsName" select="@name"/>
                    <xsl:variable name="vsEff">
                        <xsl:choose>
                            <xsl:when test="string-length(ancestor::mif2:version[last()]/@versionDate)=10">
                                <xsl:value-of select="concat(ancestor::mif2:version[last()]/@versionDate,'T00:00:00')"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="ancestor::mif2:version[last()]/@versionDate"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:variable name="vsType">
                        <xsl:variable name="vsFull" select="$allValueSets[@id=$vsId]"/>
                        <xsl:choose>
                            <xsl:when test="$vsFull/mif2:annotations//mif2:deprecationInfo">deprecated</xsl:when>
                            <xsl:otherwise>final</xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    
                    <xsl:if test="$valueSetStatus='deprecated' or $includeDeprecatedCodes or not($vsType='deprecated')">
                        <xsl:comment> Value set name: <xsl:value-of select="$vsName"/></xsl:comment>
                        <include ref="{$vsId}" flexibility="{$vsEff}" exception="false"/>
                    </xsl:if>
                    
                    <!-- <valueSetRef id="2.16.840.1.113883.1.11.19760" name="ObservationInterpretationOustsideThreshold"/> -->
                    <!--<xsl:comment> START valueSetRef id="<xsl:value-of select="@id"/>" name="<xsl:value-of select="@name"/>" </xsl:comment>
                    <xsl:variable name="vsId" select="@id"/>
                    <xsl:call-template name="handleValueSetEnumeration">
                        <xsl:with-param name="exclude" select="$exclude"/>
                        <xsl:with-param name="level" select="$level"/>
                        <xsl:with-param name="content" select="$allValueSets[@id=$vsId]/mif2:version/mif2:content"/>
                    </xsl:call-template>
                    <xsl:comment> END valueSetRef id="<xsl:value-of select="@id"/>" name="<xsl:value-of select="@name"/>" </xsl:comment>-->
                </xsl:when>
                <xsl:when test="self::mif2:combinedContent">
                    <xsl:variable name="excludeCodes" as="xs:string*">
                        <xsl:value-of select="mif2:excludeContent/mif2:codeBasedContent/concat(@code,'#',parent::mif2:*/@codeSystem)"/>
                        <xsl:for-each select="$exclude"><xsl:value-of select="."/></xsl:for-each>
                    </xsl:variable>
                    
                    <xsl:for-each select="mif2:unionWithContent">
                        <xsl:choose>
                            <xsl:when test="mif2:*">
                                <xsl:call-template name="handleValueSetEnumeration">
                                    <xsl:with-param name="exclude" select="$excludeCodes"/>
                                    <xsl:with-param name="level" select="$level"/>
                                    <xsl:with-param name="content" select="."/>
                                    <xsl:with-param name="valueSetStatus" select="$valueSetStatus"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="handleCompleteCodeSystem">
                                    <xsl:with-param name="codeSystem" select="@codeSystem"/>
                                    <xsl:with-param name="valueSetStatus" select="$valueSetStatus"/>
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="self::mif2:annotations | self::mif2:nonComputableContent">
                    <xsl:comment><xsl:text> Found </xsl:text><xsl:value-of select="name()"/><xsl:text> with: &#10;</xsl:text><xsl:text>                 </xsl:text><xsl:value-of select="normalize-space(string-join(.//text(),' '))"/></xsl:comment>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message terminate="yes">Valueset <xsl:value-of select="ancestor::mif2:valueSet/@id"/> - <xsl:value-of select="ancestor::mif2:valueSet/@name"/> has unknown definition element <xsl:value-of select="name()"/></xsl:message>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
        
    </xsl:template>
    
    <xsl:template name="handleCodeBasedContent">
        <xsl:param name="exclude" as="xs:string*"/>
        <xsl:param name="level" required="yes" as="xs:integer"/>
        <xsl:param name="codeSystem" required="yes"/>
        <xsl:param name="valueSetStatus" required="yes"/>
        
        <xsl:variable name="code" select="@code"/>
        <xsl:variable name="codeSystemName">
            <xsl:call-template name="codeSystemName">
                <xsl:with-param name="codeSystem" select="$codeSystem"/>
            </xsl:call-template>
        </xsl:variable>
        <!--xsl:variable name="codeSystemVersion">
            <xsl:call-template name="codeSystemVersion">
                <xsl:with-param name="codeSystem" select="$codeSystem"/>
            </xsl:call-template>
        </xsl:variable-->
        
        <xsl:variable name="displayName">
            <xsl:choose>
                <xsl:when test="@codeLabel">
                    <xsl:value-of select="@codeLabel"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="codedConceptDisplayName">
                        <xsl:with-param name="code" select="$code"/>
                        <xsl:with-param name="codeSystem" select="$codeSystem"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="type">
            <xsl:choose>
                <xsl:when test="@codeLabel">
                    <xsl:text>L</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="codedConceptType">
                        <xsl:with-param name="code" select="$code"/>
                        <xsl:with-param name="codeSystem" select="$codeSystem"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:if test="$valueSetStatus='deprecated' or $includeDeprecatedCodes or not($type='D')">
            <xsl:choose>
                <xsl:when test="concat(@code,'#',$codeSystem)=$exclude">
                    <xsl:comment>Excluding excluded code="<xsl:value-of select="$code"/>" codeSystem="<xsl:value-of select="$codeSystem"/>" displayName="<xsl:value-of select="$displayName"/>"</xsl:comment>
                </xsl:when>
                <xsl:when test="string(@includeHeadCode)='false'">
                    <xsl:comment>Excluding head code="<xsl:value-of select="$code"/>" codeSystem="<xsl:value-of select="$codeSystem"/>" displayName="<xsl:value-of select="$displayName"/>"</xsl:comment>
                </xsl:when>
                <xsl:otherwise>
                    <concept code="{$code}" codeSystem="{$codeSystem}" displayName="{$displayName}" level="{$level}" type="{$type}"/>
                </xsl:otherwise>
            </xsl:choose>

            <xsl:if test="mif2:includeRelatedCodes">
                <xsl:if test="not(mif2:includeRelatedCodes/@relationshipName='Generalizes')">
                    <xsl:message terminate="yes">Found unsupported @relationshipName code '<xsl:value-of select="mif2:includeRelatedCodes/@relationshipName"/>'. Only supports Generalizes right now.</xsl:message>
                </xsl:if>
                <xsl:variable name="traversalType">
                    <xsl:choose>
                        <xsl:when test="mif2:includeRelatedCodes/@relationshipTraversal='TransitiveClosure'">TransitiveClosure</xsl:when>
                        <xsl:when test="mif2:includeRelatedCodes/@relationshipTraversal='DirectRelationsOnly'">DirectRelationsOnly</xsl:when>
                        <xsl:otherwise>
                            <xsl:message terminate="yes">Found unsupported @relationshipTraversal code '<xsl:value-of select="mif2:includeRelatedCodes/@relationshipTraversal"/>'</xsl:message>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>

                <xsl:call-template name="codedConceptChildren">
                    <xsl:with-param name="traversalType" select="$traversalType"/>
                    <xsl:with-param name="parentLevel" select="$level"/>
                    <xsl:with-param name="parentCode" select="$code"/>
                    <xsl:with-param name="parentCodeSystem" select="$codeSystem"/>
                    <xsl:with-param name="parentCodeSystemName" select="$codeSystemName"/>
                    <!--xsl:with-param name="parentCodeSystemVersion" select="$codeSystemVersion"/-->
                    <xsl:with-param name="valueSetStatus" select="$valueSetStatus"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="codeSystemName">
        <xsl:param name="codeSystem" required="yes"/>
        
        <xsl:variable name="codeSystemFull" select="$allCodeSystems[@codeSystemId=$codeSystem]"/>
        <xsl:value-of select="$codeSystemFull/@name"/>
    </xsl:template>
    
    <xsl:template name="codeSystemVersion">
        <xsl:param name="codeSystem" required="yes"/>
        
        <xsl:variable name="codeSystemFull" select="$allCodeSystems[@codeSystemId=$codeSystem]"/>
        <xsl:choose>
            <xsl:when test="string-length($codeSystemFull/mif2:releasedVersion/@releaseDate)=10">
                <xsl:value-of select="concat($codeSystemFull/mif2:releasedVersion/@releaseDate,'T00:00:00')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$codeSystemFull/mif2:releasedVersion/@releaseDate"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="codeSystemStatus">
        <xsl:param name="codeSystem" required="yes"/>
        
        <xsl:variable name="codeSystemFull" select="$allCodeSystems[@codeSystemId=$codeSystem]"/>
        <xsl:choose>
            <xsl:when test="$codeSystemFull/mif2:annotations//mif2:deprecationInfo">
                <xsl:text>deprecated</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>final</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="codedConceptType">
        <xsl:param name="code" required="yes"/>
        <xsl:param name="codeSystem" required="yes"/>
        
        <!-- Is empty for to codes from external codeSystems -->
        <xsl:variable name="codeSystemConcept" select="$allCodeSystems[@codeSystemId=$codeSystem]/mif2:releasedVersion/mif2:concept[mif2:code/@code=$code]"/>
        
        <xsl:if test="not(empty($codeSystemConcept)) and not($codeSystemConcept/mif2:code/@status=('active','retired'))">
            <xsl:message terminate="yes">Found code '<xsl:value-of select="$code"/>' in codeSystem '<xsl:value-of select="$codeSystem"/>' with unsupported status '<xsl:value-of select="mif2:code/@status"/>'. Currently only support active and retired.</xsl:message>
        </xsl:if>
        
        <xsl:choose>
            <xsl:when test="empty($codeSystemConcept)">
                <xsl:text>L</xsl:text>
            </xsl:when>
            <xsl:when test="$codeSystemConcept/mif2:code[@code=$code]/@status='retired'">
                <xsl:text>D</xsl:text>
            </xsl:when>
            <xsl:when test="string($codeSystemConcept/@isSelectable)='false'">
                <xsl:text>A</xsl:text>
            </xsl:when>
            <xsl:when test="$codeSystemConcept/parent::mif2:*/mif2:concept/mif2:conceptRelationship[@relationshipName='Specializes']/mif2:targetConcept[@code=$code]">
                <xsl:text>S</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>L</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="codedConceptDisplayName">
        <xsl:param name="code" required="yes"/>
        <xsl:param name="codeSystem" required="yes"/>
        
        <xsl:variable name="codeSystemConcept" select="$allCodeSystems[@codeSystemId=$codeSystem]/mif2:releasedVersion/mif2:concept[mif2:code/@code=$code]"/>
        <xsl:choose>
            <xsl:when test="$codeSystemConcept/mif2:printName[@text]">
                <xsl:value-of select="$codeSystemConcept/mif2:printName/@text"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$code"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="codedConceptChildren">
        <xsl:param name="traversalType" required="yes"/>
        <xsl:param name="parentLevel" required="yes" as="xs:integer"/>
        <xsl:param name="parentCode" required="yes"/>
        <xsl:param name="parentCodeSystem" required="yes"/>
        <xsl:param name="parentCodeSystemName" required="yes"/>
        <xsl:param name="parentCodeSystemVersion"/>
        <xsl:param name="valueSetStatus" required="yes"/>
        
        <xsl:variable name="codeSystemConcept" select="$allCodeSystems[@codeSystemId=$parentCodeSystem]/mif2:releasedVersion/mif2:concept[mif2:code/@code=$parentCode]"/>
        <xsl:for-each select="$codeSystemConcept/parent::mif2:*/mif2:concept[mif2:conceptRelationship[@relationshipName='Specializes'][mif2:targetConcept[@code=$parentCode]]]/mif2:code">
            <xsl:variable name="code" select="@code"/>
            <xsl:variable name="displayName">
                <xsl:call-template name="codedConceptDisplayName">
                    <xsl:with-param name="code" select="$code"/>
                    <xsl:with-param name="codeSystem" select="$parentCodeSystem"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:variable name="level" select="$parentLevel+1"/>
            <xsl:variable name="type">
                <xsl:call-template name="codedConceptType">
                    <xsl:with-param name="code" select="$code"/>
                    <xsl:with-param name="codeSystem" select="$parentCodeSystem"/>
                </xsl:call-template>
            </xsl:variable>
            
            <xsl:if test="$valueSetStatus='deprecated' or $includeDeprecatedCodes or not($type='D')">
                <concept code="{$code}" codeSystem="{$parentCodeSystem}">
                    <!--<xsl:attribute name="codeSystemName" select="$parentCodeSystemName"/>-->
                    <xsl:if test="string-length($parentCodeSystemVersion)>0">
                        <xsl:attribute name="codeSystemVersion" select="$parentCodeSystemVersion"/>
                    </xsl:if>
                    <xsl:attribute name="displayName" select="$displayName"/>
                    <xsl:attribute name="level" select="$level"/>
                    <xsl:attribute name="type" select="$type"/>
                </concept>

                <xsl:if test="$traversalType='TransitiveClosure'">
                    <xsl:call-template name="codedConceptChildren">
                        <xsl:with-param name="traversalType" select="$traversalType"/>
                        <xsl:with-param name="parentLevel" select="$level"/>
                        <xsl:with-param name="parentCode" select="$code"/>
                        <xsl:with-param name="parentCodeSystem" select="$parentCodeSystem"/>
                        <xsl:with-param name="parentCodeSystemName" select="$parentCodeSystemName"/>
                        <xsl:with-param name="parentCodeSystemVersion" select="$parentCodeSystemVersion"/>
                        <xsl:with-param name="valueSetStatus" select="$valueSetStatus"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="handleValueSetDescription">
        <xsl:param name="lang" required="yes"/>
        
        <xsl:if test="mif2:historyItem | mif2:annotations/mif2:documentation">
            <desc language="{$lang}">
                <xsl:apply-templates select="mif2:historyItem | mif2:annotations/mif2:documentation"/>
            </desc>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="mif2:historyItem">
        <xsl:for-each select="mif2:*">
            <p>
                <b>
                    <xsl:text>History </xsl:text>
                    <xsl:value-of select="name(.)"/>
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="parent::*/@dateTime"/>
                    <xsl:text>: </xsl:text>
                </b>
                <xsl:call-template name="copyIntoNamespace">
                    <xsl:with-param name="nodes" select="node()"/>
                </xsl:call-template>
            </p>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="mif2:documentation">
        <xsl:for-each select="mif2:*">
            <b>
                <xsl:value-of select="name(.)"/>
                <xsl:text>: </xsl:text>
            </b>
            <xsl:call-template name="copyIntoNamespace">
                <xsl:with-param name="nodes" select="mif2:text/node()"/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="copyIntoNamespace">
        <xsl:param name="nodes"/>
        <xsl:if test="not(empty($nodes))">
            <xsl:for-each select="$nodes">
                <xsl:choose>
                    <xsl:when test="self::text()[string-length(normalize-space(.))>0]">
                        <xsl:value-of select="normalize-space(.)"/>
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
                <xsl:if test="position() != last()">
                    <xsl:text> </xsl:text>
                </xsl:if>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>