<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:local="urn"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all"
    version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Apr 8, 2014</xd:p>
            <xd:p><xd:b>Author:</xd:b> ahenket</xd:p>
            <xd:p>Step 1: Create new value set project using create_decorvalueSets_from_coreMif.xsl</xd:p>
            <xd:p>Step 2: Use this XSL to merge previous iteration of the project and that output. The previous iteration may be handed through the parameter baseLineProject.</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:param name="baseLineProject" select="'ad2bbr-decor.xml'"/>
    <xsl:variable name="baseLineDocument" select="if (doc-available($baseLineProject)) then doc($baseLineProject) else ()"/>
    
    <xsl:variable name="baseProjectInfo" select="$baseLineDocument/decor/project"/>
    <xsl:variable name="baseTerminology" select="$baseLineDocument/decor/terminology"/>
    
    <xsl:variable name="newProjectInfo" select="/decor/project"/>
    <xsl:variable name="newTerminology" select="/decor/terminology"/>
    <xsl:variable name="newTerminologyDate" select="max($newTerminology/valueSet/xs:dateTime(@effectiveDate))"/>
    <xsl:variable name="newTerminologyMarker" select="($newProjectInfo/release/@versionLabel)[1]"/>
    
    <!-- Sanity check -->
    <xsl:variable name="baseLineIsOlder">
        <xsl:variable name="maxReleaseOld" select="max($baseLineDocument/decor/project/(release|version)/xs:dateTime(@date))"/>
        <xsl:variable name="maxReleaseNew" select="max(/decor/project/(release|version)/xs:dateTime(@date))"/>
        
        <xsl:if test="$maxReleaseOld &gt;= $maxReleaseNew">
            <xsl:message terminate="yes">ERROR: base line version of project (<xsl:value-of select="$maxReleaseOld"/>) is equal/newer than new version (<xsl:value-of select="$maxReleaseNew"/>)</xsl:message>
        </xsl:if>
    </xsl:variable>
    
    <xsl:template match="/">
        <xsl:apply-templates select="$baseLineDocument/node()"/>
    </xsl:template>
    
    <!-- Start from base project info and merge new version/release info into it. TODO: cater for other things to merge in like BBR? -->
    <xsl:template match="project">
        <project>
            <xsl:copy-of select="$baseProjectInfo/@*"/>
            <xsl:for-each select="$baseProjectInfo/node()">
                <xsl:if test="(self::release | self::version)[not(preceding-sibling::release or preceding-sibling::version)]">
                    <xsl:copy-of select="$newProjectInfo/(release|version)[@date=max(xs:dateTime(@date))]"/>
                </xsl:if>
                <xsl:copy-of select="self::node()"/>
            </xsl:for-each>
        </project>
    </xsl:template>
    
    <xsl:template match="terminology">
        <terminology>
            <xsl:for-each-group select="$baseTerminology/valueSet" group-by="@id">
                <xsl:copy-of select="current-group()"/>
                <xsl:variable name="latestFromBase" select="current-group()[@effectiveDate=max(current-group()/xs:dateTime(@effectiveDate))]"/>
                <xsl:variable name="matchingNewValueSet" select="$newTerminology/valueSet[@id=current-grouping-key()]" as="element(valueSet)?"/>
                <xsl:choose>
                    <!-- Deprecated in this version of the vocabulary -->
                    <xsl:when test="$matchingNewValueSet[@status='deprecated']">
                        <!-- Add deprecated from new version only if not already deprecated -->
                        <xsl:if test="$latestFromBase[not(@statusCode='deprecated')]">
                            <xsl:call-template name="handleNewValueSet">
                                <xsl:with-param name="newValueSet" select="$matchingNewValueSet"/>
                            </xsl:call-template>
                        </xsl:if>
                    </xsl:when>

                    <!-- We have the value set in both base and new. Add base as-is, add new as-is only if different from latest base, else ignore new -->
                    <xsl:when test="not(empty($matchingNewValueSet))">
                        <xsl:variable name="expandedBase" select="local:getExpandedValueSet($latestFromBase,true())"/>
                        <xsl:variable name="expandedNew" select="local:getExpandedValueSet($matchingNewValueSet,false())"/>
                        <xsl:if test="local:valueSetsAreDifferent($expandedBase,$expandedNew)">
                            <xsl:call-template name="handleNewValueSet">
                                <xsl:with-param name="newValueSet" select="$matchingNewValueSet"/>
                            </xsl:call-template>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="$latestFromBase[not(@statusCode='deprecated')]">
                            <xsl:message>WARNING. Found non-deprecated base valueSets with id <xsl:value-of select="current-grouping-key()"/> / name <xsl:value-of select="current-group()[1]/@name"/> missing in the new project. Assuming intermediate deprecation.</xsl:message>
                            <valueSet>
                                <xsl:copy-of select="$latestFromBase/@*"/>
                                <xsl:attribute name="effectiveDate" select="$newTerminologyDate"/>
                                <xsl:attribute name="statusCode" select="'deprecated'"/>
                                <xsl:attribute name="expirationDate" select="$newTerminologyDate"/>
                                <xsl:attribute name="versionLabel" select="$newTerminologyMarker"/>
                                <xsl:copy-of select="$latestFromBase/node()"/>
                            </valueSet>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
            <!-- Add whatever was added in the new terminology set and not deprecated. Deprecated would only appear to be new. -->
            <xsl:copy-of select="$newTerminology/valueSet[not(@id=$baseTerminology/valueSet/@id)][not(@statusCode='deprecated')]"/>
        </terminology>
    </xsl:template>
    
    <!-- When we copy a valueSet from the new project, it might have includes that will not resolve in the merged result because the include does not differ from the base. 
        In this case we need to rewrite the include/@flexibility to the latest version in the base project -->
    <xsl:template name="handleNewValueSet">
        <xsl:param name="newValueSet" required="yes" as="element(valueSet)"/>
        
        <valueSet>
            <xsl:copy-of select="$newValueSet/@*"/>
            <xsl:for-each select="$newValueSet/node()">
                <xsl:choose>
                    <xsl:when test="self::conceptList">
                        <xsl:copy>
                            <xsl:copy-of select="@*"/>
                            <xsl:for-each select="node()">
                                <xsl:choose>
                                    <xsl:when test="self::include">
                                        <xsl:variable name="includeRef" select="@ref"/>
                                        <xsl:variable name="baseValueSet" select="$baseTerminology/valueSet[@id=$includeRef][@effectiveDate=max($baseTerminology/valueSet[@id=$includeRef]/xs:dateTime(@effectiveDate))]"/>
                                        <xsl:variable name="newValueSet" select="$newTerminology/valueSet[@id=$includeRef]"/>
                                        <xsl:choose>
                                            <xsl:when test="empty($baseValueSet)">
                                                <xsl:copy-of select="self::include"/>
                                            </xsl:when>
                                            <xsl:when test="empty($newValueSet)">
                                                <xsl:message terminate="yes">ERROR: Cannot resolve valueSet include with @ref <xsl:value-of select="$includeRef"/>
                                                </xsl:message>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:variable name="expandedBase" select="local:getExpandedValueSet($baseValueSet,true())"/>
                                                <xsl:variable name="expandedNew" select="local:getExpandedValueSet($newValueSet,false())"/>
                                                <xsl:choose>
                                                    <xsl:when test="local:valueSetsAreDifferent($expandedBase,$expandedNew)">
                                                        <xsl:copy-of select="self::include"/>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <include>
                                                            <xsl:copy-of select="@*"/>
                                                            <xsl:attribute name="flexibility" select="$baseValueSet/@effectiveDate"/>
                                                        </include>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:copy-of select="self::node()"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each>
                        </xsl:copy>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="self::node()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </valueSet>
    </xsl:template>
    
    <xsl:function name="local:getExpandedValueSet" as="element(valueSet)">
        <xsl:param name="valueSet" as="element(valueSet)"/>
        <xsl:param name="fromBase" as="xs:boolean"/>
        
        <xsl:variable name="includetrail" as="element(include)"><include ref="{$valueSet/(@ref|@id)}" flexibility="{$valueSet/@effectiveDate}"/></xsl:variable>
        <xsl:variable name="rawValueSet" select="local:getRawValueSet($valueSet,$includetrail,$fromBase)"/>
        
        <valueSet>
            <xsl:copy-of select="$rawValueSet/@*"/>
            <xsl:copy-of select="$rawValueSet/desc"/>
            <xsl:copy-of select="$rawValueSet/completeCodeSystem"/>
            <xsl:if test="$rawValueSet/conceptList">
                <conceptList>
                    <xsl:copy-of select="$rawValueSet//conceptList/concept[not(ancestor::include[string(@exception)='true'])]"/>
                    <xsl:for-each-group select="$rawValueSet//conceptList/(exception|concept[ancestor::include[string(@exception)='true']])" group-by="concat(@code,@codeSystem)">
                        <exception>
                            <xsl:copy-of select="current-group()[1]/@*"/>
                            <xsl:copy-of select="current-group()[1]/*"/>
                        </exception>
                    </xsl:for-each-group>
                </conceptList>
            </xsl:if>
        </valueSet>
    </xsl:function>
    
    <xsl:function name="local:getRawValueSet" as="element(valueSet)">
        <xsl:param name="valueSet" as="element(valueSet)"/>
        <xsl:param name="includetrail" as="element(include)*"/>
        <xsl:param name="fromBase" as="xs:boolean"/>
        
        <valueSet>
            <xsl:copy-of select="$valueSet/@*"/>
            <xsl:copy-of select="$valueSet/desc"/>
            <xsl:copy-of select="$valueSet/completeCodeSystem"/>
            <xsl:if test="$valueSet/conceptList">
                <conceptList>
                    <xsl:for-each select="$valueSet/conceptList/concept">
                        <xsl:copy-of select="@*[string-length()>0]"/>
                        <xsl:copy-of select="desc"/>
                    </xsl:for-each>
                    <xsl:for-each select="$valueSet/conceptList/include">
                        <xsl:copy-of select="local:getValueSetInclude(.,$includetrail,$fromBase)"/>
                    </xsl:for-each>
                    <xsl:for-each select="$valueSet/conceptList/exception">
                        <xsl:copy-of select="@*[string-length()>0]"/>
                        <xsl:copy-of select="desc"/>
                    </xsl:for-each>
                </conceptList>
            </xsl:if>
        </valueSet>
    </xsl:function>
    
    <xsl:function name="local:getValueSetInclude" as="element()">
        <xsl:param name="include" as="element(include)"/>
        <xsl:param name="includetrail" as="element(include)*"/>
        <xsl:param name="fromBase" as="xs:boolean"/>
        
        <xsl:variable name="valuesetId" select="$include/@ref"/>
        <xsl:variable name="valuesetFlex" select="$include/@flexibility"/>
        
        <xsl:variable name="effectiveDate">
            <xsl:choose>
                <xsl:when test="matches($valuesetFlex,'^\d{4}')">
                    <xsl:value-of select="$valuesetFlex"/>
                </xsl:when>
                <xsl:when test="$fromBase">
                    <xsl:value-of select="string(max($baseTerminology/valueSet[@id=$valuesetId]/xs:dateTime(@effectiveDate))[1])"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="string(max($newTerminology/valueSet[@id=$valuesetId]/xs:dateTime(@effectiveDate))[1])"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="valueSet" as="element(valueSet)?">
            <xsl:choose>
                <xsl:when test="$fromBase">
                    <xsl:copy-of select="($baseTerminology/valueSet[@id=$valuesetId][@effectiveDate=$effectiveDate])[1]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="($newTerminology/valueSet[@id=$valuesetId][@effectiveDate=$effectiveDate])[1]"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$includetrail[@ref=$include/@ref][@flexibility=$effectiveDate]">
                <duplicate>
                    <xsl:copy-of select="$include/@*"/>
                </duplicate>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="newincludetrail">
                    <xsl:copy-of select="$includetrail"/>
                    <include ref="{$include/@ref}" flexibility="{$effectiveDate}"/>
                </xsl:variable>
                <include ref="{$include/@ref}">
                    <xsl:copy-of select="$include/@flexibility"/>
                    <xsl:copy-of select="$include/@exception"/>
                    <xsl:if test="exists($valueSet)">
                        <xsl:copy-of select="local:getRawValueSet($valueSet,$includetrail,$fromBase)"/>
                    </xsl:if>
                </include>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="local:valueSetsAreDifferent" as="xs:boolean">
        <xsl:param name="expandedBaseValueSet" as="element(valueSet)"/>
        <xsl:param name="expandedNewValueSet" as="element(valueSet)"/>
        
        <!-- Are name/displayName different? -->
        <xsl:variable name="diffMeta" as="xs:boolean">
            <xsl:choose>
                <xsl:when test="$expandedBaseValueSet/@name != $expandedNewValueSet/@name">true</xsl:when>
                <xsl:when test="$expandedBaseValueSet/@displayName != $expandedNewValueSet/@displayName">true</xsl:when>
                <xsl:otherwise>false</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-- Is any of the contents different? Not expecting includes here -->
        <xsl:variable name="diffContent" as="xs:boolean" select="not(deep-equal($expandedBaseValueSet/(node() except conceptList),$expandedNewValueSet/(node() except conceptList)))"/>
        
        <xsl:choose>
            <xsl:when test="$diffMeta or $diffContent">true</xsl:when>
            <xsl:otherwise>false</xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:template match="text()|processing-instruction()|comment()">
        <xsl:copy/>
    </xsl:template>
    
    <xsl:template match="*">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>