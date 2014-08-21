<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0" exclude-result-prefixes="#all">


    <xsl:template match="attribute" mode="GEN">
        <xsl:param name="itemlabel"/>
        <xsl:param name="context"/>
        <xsl:param name="uniqueId"/>
        <xsl:param name="seethisthingurl"/>
        <xsl:param name="contextSuffix"/>

        <!-- use the attribute's item/@label if any -->
        <xsl:variable name="attitem">
            <xsl:choose>
                <xsl:when test="item/@label">
                    <xsl:value-of select="item/@label"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$itemlabel"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- cache @isOptional -->
        <xsl:variable name="isOptional" select="@isOptional"/>
        <!-- cache @prohibited -->
        <xsl:variable name="isProhibited" select="@prohibited"/>
        <!-- 
            check HL7 related short hand attributes 
            the following may have choice value denoted by A|B|C, just check all values
        -->
        <!-- element/vocabulary[@valueSet] logic already handles nullFlavor, don't duplicate that here -->
        <xsl:for-each select="@extension|@operator|@contextControlCode|@institutionSpecified|@independentInd|@determinerCode|
            @contextConductionInd|@inversionInd|@negationInd|@unit|@code|@classCode|@moodCode|@typeCode|@mediaType|
            @representation|@use|@qualifier|@nullFlavor[not(../vocabulary[@valueSet])]">
            <xsl:variable name="attname" select="name(.)"/>
            <xsl:variable name="attvalue" select="."/>
            <!-- build the test expression, also test for optionality of this attribute -->
            <xsl:variable name="theTest">
                <xsl:for-each select="tokenize($attvalue, '\|')">
                    <xsl:text>string(@</xsl:text>
                    <xsl:value-of select="$attname"/>
                    <xsl:text>)='</xsl:text>
                    <xsl:value-of select="."/>
                    <xsl:text>'</xsl:text>
                    <xsl:if test="position() != last()">
                        <xsl:text> or </xsl:text>
                    </xsl:if>
                </xsl:for-each>
                <xsl:if test="$isOptional=true()">
                    <xsl:text> or not(@</xsl:text>
                    <xsl:value-of select="$attname"/>
                    <xsl:text>)</xsl:text>
                </xsl:if>
            </xsl:variable>
            <assert role="error" see="{$seethisthingurl}" test="{$theTest}">
                <xsl:choose>
                    <xsl:when test="contains($attvalue, '|')">
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'attribCodeset'"/>
                            <xsl:with-param name="p1" select="$attitem"/>
                            <xsl:with-param name="p2" select="concat('@', $attname)"/>
                            <xsl:with-param name="p3">
                                <xsl:for-each select="tokenize($attvalue, '\|')">
                                    <xsl:value-of select="."/>
                                    <xsl:if test="position() != last()">
                                        <xsl:text>', '</xsl:text>
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'attribValue'"/>
                            <xsl:with-param name="p1" select="$attitem"/>
                            <xsl:with-param name="p2" select="concat('@', $attname)"/>
                            <xsl:with-param name="p3" select="$attvalue"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </assert>
        </xsl:for-each>

        <!-- 
            special
            @name
            @name + @value
            
            attribute specified in @name is required
            no choices
            if @value is present check whether attribute @name is valued correctly
        -->
        <xsl:if test="@name">
            <xsl:variable name="an" select="@name"/>
            <xsl:choose>
                <xsl:when test="$an='xsi:type' and string-length(@value)>0">
                    <!-- 
                        Get namespace-uri for the @datatype.
                        1. If has namespace prefix hl7: or cda:, then must be in namespace 'urn:hl7-org:v3'
                        2. If has no namespace prefix, then must be in DECOR default namespace-uri
                        3. If has namespace prefix then get the namespace-uri form DECOR file
                    -->
                    <xsl:variable name="dfltNS">
                        <xsl:choose>
                            <xsl:when test="string-length($projectDefaultElementNamespace)=0">
                                <xsl:value-of select="'urn:hl7-org:v3'"/>
                            </xsl:when>
                            <xsl:when test="$projectDefaultElementNamespace='hl7:' or $projectDefaultElementNamespace='cda:'">
                                <xsl:value-of select="'urn:hl7-org:v3'"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="namespace-uri-for-prefix(substring-before($projectDefaultElementNamespace,':'),.)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:variable name="dtPfx" select="substring-before(@value,':')"/>
                    <xsl:variable name="dtNS">
                        <xsl:choose>
                            <xsl:when test="$dtPfx='hl7' or $dtPfx='cda'">
                                <xsl:value-of select="'urn:hl7-org:v3'"/>
                            </xsl:when>
                            <xsl:when test="$dtPfx=''">
                                <xsl:value-of select="$dfltNS"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="namespace-uri-for-prefix($dtPfx,.)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:variable name="dtVal" select="if (contains(@value,':')) then (substring-after(@value,':')) else (@value)"/>

                    <!-- Note that different versions of Saxon interpret QName differently. You cannot assume that casting @xsi:type to QName works, hence the substring-* functions -->
                    <let name="xsiLocalName" value="if (contains(@xsi:type, ':')) then substring-after(@xsi:type,':') else @xsi:type"/>
                    <let name="xsiLocalNS" value="if (contains(@xsi:type, ':')) then namespace-uri-for-prefix(substring-before(@xsi:type,':'),.) else namespace-uri-for-prefix('',.)"/>

                    <!-- check for the presence of xsi:type and if present check correct data type requested -->
                    <xsl:variable name="theTest">
                        <xsl:text>@nullFlavor or ($xsiLocalName='</xsl:text>
                        <xsl:value-of select="$dtVal"/>
                        <xsl:text>' and $xsiLocalNS='</xsl:text>
                        <xsl:value-of select="$dtNS"/>
                        <xsl:text>')</xsl:text>
                        <xsl:if test="@isOptional=true()">
                            <xsl:text> or not(@</xsl:text>
                            <xsl:value-of select="$an"/>
                            <xsl:text>)</xsl:text>
                        </xsl:if>
                    </xsl:variable>
                    <assert role="error" see="{$seethisthingurl}" test="{$theTest}">
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'datatypeXSIShallBe'"/>
                            <xsl:with-param name="p1" select="$itemlabel"/>
                            <xsl:with-param name="p2">
                                <xsl:value-of select="$dtVal"/>
                            </xsl:with-param>
                        </xsl:call-template>
                    </assert>
                </xsl:when>
                <xsl:when test="string-length(@value)>0">
                    <xsl:variable name="theTest">
                        <xsl:text>string(@</xsl:text>
                        <xsl:value-of select="$an"/>
                        <xsl:text>)='</xsl:text>
                        <xsl:value-of select="@value"/>
                        <xsl:text>'</xsl:text>
                        <xsl:if test="@isOptional=true()">
                            <xsl:text> or not(@</xsl:text>
                            <xsl:value-of select="$an"/>
                            <xsl:text>)</xsl:text>
                        </xsl:if>
                    </xsl:variable>
                    <assert role="error" see="{$seethisthingurl}" test="{$theTest}">
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'attribValue'"/>
                            <xsl:with-param name="p1" select="$attitem"/>
                            <xsl:with-param name="p2" select="concat('@', $an)"/>
                            <xsl:with-param name="p3" select="@value"/>
                        </xsl:call-template>
                    </assert>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="$isProhibited!='true'">
                        <xsl:variable name="theTest">
                            <xsl:text>string-length(@</xsl:text>
                            <xsl:value-of select="$an"/>
                            <xsl:text>)>0</xsl:text>
                            <xsl:if test="@isOptional=true()">
                                <xsl:text> or not(@</xsl:text>
                                <xsl:value-of select="$an"/>
                                <xsl:text>)</xsl:text>
                            </xsl:if>
                        </xsl:variable>
                        <assert role="error" see="{$seethisthingurl}" test="{$theTest}">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'attribPresent'"/>
                                <xsl:with-param name="p1" select="$attitem"/>
                                <xsl:with-param name="p2" select="$an"/>
                            </xsl:call-template>
                        </assert>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>

            <!-- check for @name @value pair, then attribute @name SHALL be of value @value -->

        </xsl:if>
        <!-- 
            special
            @prohibited
            
            attributes specified along with @prohibited are not permitted
            no choices
        -->
        <xsl:if test="$isProhibited='true'">
            <assert role="error" see="{$seethisthingurl}" test="not(@{./@name})">
                <xsl:call-template name="getMessage">
                    <xsl:with-param name="key" select="'attribProhibited'"/>
                    <xsl:with-param name="p1" select="$attitem"/>
                    <xsl:with-param name="p2" select="@name"/>
                </xsl:call-template>
            </assert>
        </xsl:if>
        <!-- 
            special
            
            @root
            choices
            
            usage:
            @root=<constant>   '1.2.3.4.5.6.7'
            @root=<choice>     '1.2.3|6.7.8|9.10.11'
            
        -->
        <xsl:if test="@root">
            <!-- the given root must be present but be relaxed if others siblings with a different root are there as well -->
            <xsl:variable name="csf">
                <xsl:call-template name="lastIndexOf">
                    <xsl:with-param name="string" select="$context"/>
                    <xsl:with-param name="char" select="'/'"/>
                </xsl:call-template>
            </xsl:variable>
            <!-- create expression for one or multiple roots given (choice list) -->
            <xsl:variable name="cexroot">
                <xsl:for-each select="tokenize(@root, '\|')">
                    <xsl:text>string(@root)='</xsl:text>
                    <xsl:value-of select="."/>
                    <xsl:text>'</xsl:text>
                    <xsl:if test="position() != last()">
                        <xsl:text> or </xsl:text>
                    </xsl:if>
                </xsl:for-each>
                <xsl:if test="$isOptional=true()">
                    <xsl:text> or not(@root)</xsl:text>
                </xsl:if>
            </xsl:variable>
            <xsl:variable name="rooterrmsg">
                <xsl:for-each select="tokenize(@root, '\|')">
                    <xsl:value-of select="."/>
                    <xsl:if test="position() != last()">
                        <xsl:text>' </xsl:text>
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'orWord'"/>
                        </xsl:call-template>
                        <xsl:text> '</xsl:text>
                    </xsl:if>
                </xsl:for-each>
            </xsl:variable>
            <!-- do not use otherSiblingsAllowed any more -->
            <xsl:choose>
                <xsl:when test="@otherSiblingsAllowed-not-used=true()">
                    <assert role="error" see="{$seethisthingurl}" test="count(../{$csf}[{$cexroot}])&gt;0">
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'elmWithRootPresent'"/>
                            <xsl:with-param name="p1" select="$attitem"/>
                            <xsl:with-param name="p2" select="$contextSuffix"/>
                            <xsl:with-param name="p3" select="$rooterrmsg"/>
                        </xsl:call-template>

                        <!--
                            <xsl:value-of select="$item"/>
                            <xsl:text>: there SHALL be at least one </xsl:text>
                            <xsl:value-of select="$contextSuffix"/>
                            <xsl:text> with @root present </xsl:text>
                            <xsl:choose>
                                <xsl:when test="contains(@root, '|')">
                                    <xsl:text> where the value of @root is one out of </xsl:text>
                                    <xsl:for-each select="tokenize(@root, '\|')">
                                        <xsl:value-of select="."/>
                                        <xsl:text> </xsl:text>
                                    </xsl:for-each>
                                    <xsl:text> only </xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text> and valued '</xsl:text>
                                    <xsl:value-of select="@root"/>
                                    <xsl:text>' STATIC </xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        -->
                    </assert>
                </xsl:when>
                <xsl:otherwise>
                    <assert role="error" see="{$seethisthingurl}" test="{$cexroot}">
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'rootValue'"/>
                            <xsl:with-param name="p1" select="$attitem"/>
                            <xsl:with-param name="p2" select="@root"/>
                        </xsl:call-template>
                    </assert>
                </xsl:otherwise>
            </xsl:choose>

            <!-- attribute SHALL be a syntactically correct UUID or OID. -->
            <!-- AH: Moved this check into II coreschemtron -->
            <!--assert role="error" see="{$seethisthingurl}" test="matches(string(@root), '{$OIDpattern}') or matches(string(@root), '{$UUIDpattern}')">
                <xsl:call-template name="getMessage">
                    <xsl:with-param name="key" select="'rootUuidOrOid'"/>
                    <xsl:with-param name="p1" select="$attitem"/>
                </xsl:call-template>
            </assert-->

        </xsl:if>

        <!-- 
            element content DEPRECATED
            no choices
        -->
        <xsl:if test="@elementContent">
            <assert role="error" see="{$seethisthingurl}" test="text()='{@elementContent}'">
                <xsl:call-template name="getMessage">
                    <xsl:with-param name="key" select="'attribElmContent'"/>
                    <xsl:with-param name="p1" select="$attitem"/>
                    <xsl:with-param name="p2" select="$contextSuffix"/>
                    <xsl:with-param name="p3" select="@elementContent"/>
                </xsl:call-template>
            </assert>
        </xsl:if>

        <!-- 
            special
            @datatype (for attribute)
        -->
        <xsl:if test="string-length(@datatype)>0">

            <!--
                for attributes this is only a very restricted set of data types
                a data type is allowed in context of <attribute name="..."... only
                then
                   <attribute name="x" datatype="st"/>
                means that @name must be of data type st.
                Allowed data types so far are: 
                bl (boolean)
                st (string, the default) 
                ts (timestamp)
                int (integer)
                real (real)
                cs (code)
                
                some not yet checked. 2DO
            -->
            <xsl:if test="string-length(@name)>0">
                <!-- do data type check only if name is given -->

                <xsl:choose>
                    <xsl:when test="@datatype=('bl','bn')">
                        <assert role="error" see="{$seethisthingurl}" test="not(@{@name}) or string(@{@name})=('true','false')">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'attribShallBeOfDatatype'"/>
                                <xsl:with-param name="p1" select="$attitem"/>
                                <xsl:with-param name="p2" select="concat('@',@name)"/>
                                <xsl:with-param name="p3" select="@datatype"/>
                            </xsl:call-template>
                        </assert>
                    </xsl:when>
                    <xsl:when test="@datatype='oid'">
                        <assert role="error" see="{$seethisthingurl}" test="not(@{@name}) or matches(@{@name},'{$OIDpattern}')>0">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'attribShallBeOfDatatype'"/>
                                <xsl:with-param name="p1" select="$attitem"/>
                                <xsl:with-param name="p2" select="concat('@',@name)"/>
                                <xsl:with-param name="p3" select="@datatype"/>
                            </xsl:call-template>
                        </assert>
                    </xsl:when>
                    <xsl:when test="@datatype='uuid'">
                        <assert role="error" see="{$seethisthingurl}" test="not(@{@name}) or matches(@{@name},'{$UUIDpattern}')>0">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'attribShallBeOfDatatype'"/>
                                <xsl:with-param name="p1" select="$attitem"/>
                                <xsl:with-param name="p2" select="concat('@',@name)"/>
                                <xsl:with-param name="p3" select="@datatype"/>
                            </xsl:call-template>
                        </assert>
                    </xsl:when>
                    <xsl:when test="@datatype=('bin','st')">
                        <assert role="error" see="{$seethisthingurl}" test="not(@{@name}) or string-length(@{@name})>0">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'attribShallBeOfDatatype'"/>
                                <xsl:with-param name="p1" select="$attitem"/>
                                <xsl:with-param name="p2" select="concat('@',@name)"/>
                                <xsl:with-param name="p3" select="@datatype"/>
                            </xsl:call-template>
                        </assert>
                    </xsl:when>
                    <xsl:when test="@datatype='cs'">
                        <assert role="error" see="{$seethisthingurl}" test="not(@{@name}) or (string-length(@{@name})>0 and not(matches(@{@name},'\s')))">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'attribShallBeOfDatatype'"/>
                                <xsl:with-param name="p1" select="$attitem"/>
                                <xsl:with-param name="p2" select="concat('@',@name)"/>
                                <xsl:with-param name="p3" select="@datatype"/>
                            </xsl:call-template>
                        </assert>
                    </xsl:when>
                    <xsl:when test="@datatype='set_cs'">
                        <assert role="error" see="{$seethisthingurl}" test="not(@{@name}) or string-length(@{@name})>0">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'attribShallBeOfDatatype'"/>
                                <xsl:with-param name="p1" select="$attitem"/>
                                <xsl:with-param name="p2" select="concat('@',@name)"/>
                                <xsl:with-param name="p3" select="@datatype"/>
                            </xsl:call-template>
                        </assert>
                    </xsl:when>
                    <xsl:when test="@datatype='ts'">
                        <assert role="error" see="{$seethisthingurl}" test="not(@{@name}) or matches(string(@{@name}), '^[0-9]{4,14}')">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'attribShallBeOfDatatype'"/>
                                <xsl:with-param name="p1" select="$attitem"/>
                                <xsl:with-param name="p2" select="concat('@',@name)"/>
                                <xsl:with-param name="p3" select="@datatype"/>
                            </xsl:call-template>
                        </assert>
                    </xsl:when>
                    <xsl:when test="@datatype='int'">
                        <assert role="error" see="{$seethisthingurl}" test="not(@{@name}) or matches(string(@{@name}), '{$INTdigits}')">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'attribNotAValidDatatypeNumber'"/>
                                <xsl:with-param name="p1" select="$attitem"/>
                                <xsl:with-param name="p2" select="concat('@',@name)"/>
                                <xsl:with-param name="p3" select="@datatype"/>
                            </xsl:call-template>
                            <value-of select="$theValue"/>
                        </assert>
                    </xsl:when>
                    <xsl:when test="@datatype='real'">
                        <assert role="error" see="{$seethisthingurl}" test="not(@{@name}) or matches(string(@{@name}), '{$REALdigits}')">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'attribNotAValidDatatypeNumber'"/>
                                <xsl:with-param name="p1" select="$attitem"/>
                                <xsl:with-param name="p2" select="concat('@',@name)"/>
                                <xsl:with-param name="p3" select="@datatype"/>
                            </xsl:call-template>
                            <value-of select="$theValue"/>
                        </assert>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="logMessage">
                            <xsl:with-param name="level" select="$logWARN"/>
                            <xsl:with-param name="msg">
                                <xsl:text>+++ Found unsupported datatype '</xsl:text>
                                <xsl:value-of select="@datatype"/>
                                <xsl:text>' on attribute '</xsl:text>
                                <xsl:value-of select="@name"/>
                                <xsl:text>' (template '</xsl:text>
                                <xsl:value-of select="ancestor::template/@name"/>
                                <xsl:text>' </xsl:text>
                                <xsl:value-of select="ancestor::template/@effectiveDate"/>
                                <xsl:text>)</xsl:text>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>

        </xsl:if>

        <!-- element/vocabulary[@valueSet] logic already handles nullFlavor, don't duplicate that here -->
        <xsl:if test="@name[not(.='nullFlavor' and ../vocabulary[@valueSet])] and vocabulary[@code or @valueSet]">
            <!-- 
                handle vocabulary @code for attributes, e.g.
                <attribute name="mediaType">
                  <vocabulary code="image/gif"/>
                  <vocabulary code="image/jpg"/>
                  <vocabulary code="image/png"/>
                </attribute>
            -->
            <xsl:variable name="theAttName" select="@name"/>
            <xsl:variable name="cdexpr">
                <xpr>
                    <xsl:if test="vocabulary[@code]">
                        <code>
                            <xsl:attribute name="dn">
                                <xsl:text>for $code in tokenize(@</xsl:text>
                                <xsl:value-of select="$theAttName"/>
                                <xsl:text>,' ') return if ($code=('</xsl:text>
                                <xsl:value-of select="string-join(vocabulary/@code,''',''')"/>
                                <xsl:text>')) then ($code) else ()</xsl:text>
                            </xsl:attribute>
                        </code>
                    </xsl:if>
                    <xsl:for-each select="vocabulary[@valueSet]">
                        <xsl:variable name="xvsref" select="@valueSet"/>
                        <xsl:variable name="xvsflex" select="if (@flexibility) then (@flexibility) else ('dynamic')"/>
                        <xsl:variable name="xvs">
                            <xsl:call-template name="getValueset">
                                <xsl:with-param name="reference" select="$xvsref"/>
                                <xsl:with-param name="flexibility" select="$xvsflex"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:variable name="xvsid" select="($xvs/valueSet)[1]/@id"/>
                        <xsl:variable name="xvsdn" select="($xvs/valueSet)[1]/@displayName"/>

                        <xsl:choose>
                            <xsl:when test="empty($xvsid) or $xvsid=''">
                                <xsl:call-template name="logMessage">
                                    <xsl:with-param name="level" select="$logERROR"/>
                                    <xsl:with-param name="msg">
                                        <xsl:text>+++ value set skipped for use in schematron because the value set contents are missing - </xsl:text>
                                        <xsl:text>value set </xsl:text>
                                        <xsl:value-of select="$xvsref"/>
                                        <xsl:text>: </xsl:text>
                                        <xsl:value-of select="$xvsflex"/>
                                        <xsl:text> in rule </xsl:text>
                                        <xsl:value-of select="ancestor::template/@name"/>
                                        <xsl:text>: </xsl:text>
                                        <xsl:value-of select="ancestor::template/@effectiveDate"/>
                                        <xsl:text> (context=</xsl:text>
                                        <xsl:value-of select="$context"/>
                                        <xsl:text>)</xsl:text>
                                    </xsl:with-param>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="($xvs/valueSet)[1]/conceptList/concept">
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
                                
                                <valueset>
                                    <xsl:attribute name="dn">
                                        <xsl:text>document('</xsl:text>
                                        <xsl:value-of select="$valueSetFileObject"/>
                                        <xsl:text>')/*/valueSet</xsl:text>
                                        <xsl:text>/conceptList/concept[@code = $theAttValue]</xsl:text>
                                        <xsl:text>/@code</xsl:text>
                                    </xsl:attribute>
                                </valueset>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="logMessage">
                                    <xsl:with-param name="level" select="$logWARN"/>
                                    <xsl:with-param name="msg">
                                        <xsl:text>+++ value set skipped for use in schematron as it binds to an attribute but has no concepts - </xsl:text>
                                        <xsl:text>value set </xsl:text>
                                        <xsl:value-of select="$xvsref"/>
                                        <xsl:text>: </xsl:text>
                                        <xsl:value-of select="$xvsflex"/>
                                        <xsl:text> in rule </xsl:text>
                                        <xsl:value-of select="ancestor::template/@name"/>
                                        <xsl:text>: </xsl:text>
                                        <xsl:value-of select="ancestor::template/@effectiveDate"/>
                                        <xsl:text> (context=</xsl:text>
                                        <xsl:value-of select="$context"/>
                                        <xsl:text>)</xsl:text>
                                    </xsl:with-param>
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </xpr>
            </xsl:variable>
            <xsl:variable name="cderr">
                <xsl:for-each select="vocabulary[@code]">
                    <xsl:variable name="codeWord">
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'code'"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:value-of select="normalize-space($codeWord)"/>
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="@code"/>
                    <xsl:if test="position() != last()">
                        <xsl:text> </xsl:text>
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'orWord'"/>
                        </xsl:call-template>
                        <xsl:text> </xsl:text>
                    </xsl:if>
                </xsl:for-each>
                <xsl:if test="vocabulary[@code] and vocabulary[@valueSet]">
                    <xsl:text> </xsl:text>
                    <xsl:call-template name="getMessage">
                        <xsl:with-param name="key" select="'orWord'"/>
                    </xsl:call-template>
                    <xsl:text> </xsl:text>
                </xsl:if>
                <xsl:for-each select="vocabulary[@valueSet]">
                    <xsl:variable name="xvsref" select="@valueSet"/>
                    <xsl:variable name="xvsflex" select="if (@flexibility) then (@flexibility) else ('dynamic')"/>
                    <xsl:variable name="xvs">
                        <xsl:call-template name="getValueset">
                            <xsl:with-param name="reference" select="$xvsref"/>
                            <xsl:with-param name="flexibility" select="$xvsflex"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:variable name="xvsdn" select="($xvs/valueSet)[1]/@displayName"/>
                    
                    <xsl:call-template name="getMessage">
                        <xsl:with-param name="key" select="'valueset'"/>
                    </xsl:call-template>
                    <xsl:text> '</xsl:text>
                    <xsl:value-of select="$xvsref"/>
                    <xsl:text>'</xsl:text>
                    <xsl:if test="string-length($xvsdn)>0 and ($xvsdn != $xvsref)">
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="$xvsdn"/>
                    </xsl:if>
                    <xsl:text> (</xsl:text>
                    <xsl:choose>
                        <xsl:when test="matches($xvsflex,'^\d{4}')">
                            <xsl:value-of select="$xvsflex"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'associationDYNAMIC'"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:text>)</xsl:text>
                    <xsl:if test="position() != last()">
                        <xsl:text> </xsl:text>
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'orWord'"/>
                        </xsl:call-template>
                        <xsl:text> </xsl:text>
                    </xsl:if>
                </xsl:for-each>
            </xsl:variable>
            
            <!-- Need to check whether or not we have something to check. If we don't we get an illegal theAttCheck distinct-value() -->
            <xsl:if test="$cdexpr/*/*[@dn]">
                <let name="theAttValue" value="distinct-values(tokenize(normalize-space(@{@name}),' '))"/>
                <let name="theAttCheck">
                    <xsl:attribute name="value">
                        <xsl:text>distinct-values(</xsl:text>
                        <xsl:for-each select="$cdexpr/*/*[@dn]">
                            <xsl:value-of select="@dn"/>
                            <xsl:if test="position() != last()">
                                <xsl:text> | </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                        <xsl:text>)</xsl:text>
                    </xsl:attribute>
                </let>
                <assert role="error" see="{$seethisthingurl}" test="not(@{@name}) or count($theAttValue) = count($theAttCheck)">
                    <xsl:choose>
                        <xsl:when test="$cdexpr/*[count(*)=1][code]">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'attribValue'"/>
                                <xsl:with-param name="p1" select="$attitem"/>
                                <xsl:with-param name="p2" select="$theAttName"/>
                                <xsl:with-param name="p3" select="$cderr"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'attribCodeCS'"/>
                                <xsl:with-param name="p1" select="$attitem"/>
                                <xsl:with-param name="p2" select="$theAttName"/>
                                <xsl:with-param name="p3" select="$cderr"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </assert>
            </xsl:if>
        </xsl:if>

    </xsl:template>
    
    <xsl:template match="template" mode="ATTRIBCHECK">
        <xsl:variable name="tmpId" select="@id"/>
        <xsl:variable name="tmpName" select="@name"/>
        <xsl:variable name="tmpDate" select="@effectiveDate"/>
        
        <xsl:for-each select=".//attribute/parent::*">
            <xsl:variable name="attributeNodes">
                <xsl:apply-templates select="attribute" mode="NORMALIZE"/>
            </xsl:variable>
            
            <xsl:if test="count(distinct-values($attributeNodes/attribute/@name)) != count($attributeNodes/attribute/@name)">
                <xsl:call-template name="logMessage">
                    <xsl:with-param name="level" select="$logFATAL"/>
                    <xsl:with-param name="terminate" select="true()"/>
                    <xsl:with-param name="msg">
                        <xsl:text>+++ xsl:template mode ATTRIBCHECK template=</xsl:text>
                        <xsl:value-of select="$tmpName"/>
                        <xsl:text> effectiveDate=</xsl:text>
                        <xsl:value-of select="$tmpDate"/>
                        <xsl:text> contains a duplicate attribute declaration. This will lead to schematron errors so we cannot continue. </xsl:text>
                        <xsl:text> Context: </xsl:text>
                        <xsl:value-of select="string-join(ancestor-or-self::element/@name,'/')"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="attribute" mode="NORMALIZE">
        <xsl:for-each select="@*[not(name()=('xsi:type','selected','originalOpt','originalType','conf','isOptional','prohibited','datatype','value'))]">
            <xsl:variable name="anme" select="if (.[name()='name']) then ./string() else (./name())"/>
            <xsl:variable name="aval" select="if (.[name()='name']) then ./../@value/string() else (./string())"/>
            
            <attribute name="{$anme}">
                <xsl:if test="string-length($aval)>0">
                    <xsl:attribute name="value" select="$aval"/>
                </xsl:if>
                <xsl:copy-of select="../@isOptional"/>
                <xsl:copy-of select="../@prohibited"/>
                <xsl:copy-of select="../@datatype"/>
                <xsl:copy-of select="../node()"/>
            </attribute>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
