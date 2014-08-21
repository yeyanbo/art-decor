<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    
    DECOR
    Copyright (C) 2009-2014 Dr. Kai U. Heitmann
    
    This program is free software; you can redistribute it and/or modify it under the terms 
    of the GNU General Public License as published by the Free Software Foundation; 
    either version 3 of the License, or (at your option) any later version.
    
    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
    See the GNU General Public License for more details.
    
    See http://www.gnu.org/licenses/gpl.html
    
    
    Icons by Axialis Team
    <a href="http://www.axialis.com/free/icons">Icons</a> by <a href="http://www.axialis.com">Axialis Team</a>
    
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
   version="2.0" exclude-result-prefixes="#all">

    <!--
        parameters
        ==========
        to this XSLT and all invoked scripts
    -->
    <xsl:param name="language" select="'de-DE'"/>
    <xsl:param name="tmpdir" select="'tmp'"/>
    
    <!-- not used yet, only by DECORbasics -->
    <xsl:variable name="defaultLanguage" select="//project/@defaultLanguage"/>
    <xsl:variable name="projectDefaultLanguage" select="//project/@defaultLanguage"/>
    
    <!-- fixed parameters  -->
    <xsl:param name="switchCreateSchematron" select="false()"/>
    <xsl:param name="switchCreateSchematronWithWrapperIncludes" select="false()"/>
    <xsl:param name="switchCreateDocHTML" select="false()"/>
    <xsl:param name="switchCreateDocSVG" select="false()"/>
    <xsl:param name="switchCreateDocDocbook" select="false()"/>
    <xsl:param name="useLocalAssets" select="false()"/>
    <xsl:param name="useLocalLogos" select="false()"/>
    <xsl:param name="inDevelopment" select="false()"/>
    <xsl:param name="switchCreateDatatypeChecks" select="false()"/>
    <xsl:param name="useCustomLogo" select="false()"/>
    <xsl:param name="useCustomLogoSRC" select="false()"/>
    <xsl:param name="useCustomLogoHREF" select="false()"/>
    <xsl:param name="createDefaultInstancesForRepresentingTemplates" select="false()"/>
    <xsl:param name="skipCardinalityChecks" select="false()"/>
    <xsl:param name="skipPredicateCreation" select="false()"/>
    <xsl:param name="useLatestDecorVersion" select="false()"/>
    <xsl:param name="latestVersion" select="''"/>
    <xsl:param name="hideColumns" select="false()"/>
    
    <xsl:param name="logLevel" select="'INFO'"/>
    <!-- ADRAM deeplink prefix for issues etc -->
    <xsl:param name="artdecordeeplinkprefix" as="xs:string?">
        <xsl:choose>
            <xsl:when test="/decor/@deeplinkprefix">
                <xsl:value-of select="/decor/@deeplinkprefix"/>
            </xsl:when>
        </xsl:choose>
    </xsl:param>
    
    <xsl:include href="http://art-decor.org/ADAR/rv/DECOR2html.xsl"/>
    <xsl:include href="http://art-decor.org/ADAR/rv/DECOR-basics.xsl"/>
    
    <!--
    <xsl:include href="/Users/kai/Documents/Kai/akt/art-decor-tooling/develop/trunk/decor/core/DECOR2html.xsl"/>
    <xsl:include href="/Users/kai/Documents/Kai/akt/art-decor-tooling/develop/trunk/decor/core/DECOR-basics.xsl"/>
    -->


    <xsl:output method="xml" name="xml" indent="yes" version="1.0" encoding="UTF-8" exclude-result-prefixes="#all"/>
    
    <xsl:output method="text" name="text"/>

    <xsl:output method="html" name="html" indent="no" version="4.01" encoding="UTF-8"  doctype-system="http://www.w3.org/TR/html4/strict.dtd"/>

    <xsl:output method="xhtml" name="xhtml" indent="no" encoding="UTF-8" doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>


    <!-- store all value sets and templates of this projects for later reference -->
    <xsl:variable name="allvs" select="//valueSet"/>
    <xsl:variable name="alltmp" select="//template"/>
    

    <xsl:template match="/">

        <xsl:result-document href="{$tmpdir}/index.xml" format="xml">
            <index>
                
                <!-- static -->
                <xsl:for-each select="//template[@id]">
                    <xsl:variable name="templatename">
                        <xsl:choose>
                            <xsl:when test="string-length(@displayName)>0">
                                <xsl:value-of select="@displayName"/>
                                <xsl:if test="@name and (@name != @displayName)">
                                    <i>
                                        <xsl:text> / </xsl:text>
                                        <xsl:value-of select="@name"/>
                                    </i>
                                </xsl:if>
                            </xsl:when>
                            <xsl:when test="string-length(@name)>0">
                                <i>
                                    <xsl:value-of select="@name"/>
                                </i>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'rulesNoNameOrDisplaynameDefinedYet'"/>
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:variable name="t">
                        <xsl:apply-templates select=".">
                            <xsl:with-param name="templatename" select="$templatename"/>
                        </xsl:apply-templates>
                    </xsl:variable>
                    <xsl:variable name="ed" select="replace(@effectiveDate,':','')"/>
                    <xsl:variable name="fns" select="concat($tmpdir, '/tmp-', @id, '-', $ed, '.html')"/>
                    <xsl:variable name="wikis">
                        <xsl:choose>
                            <xsl:when test="string-length(substring-before(@effectiveDate, 'T00:00:00'))>0">
                                <xsl:value-of select="concat(@id, '/static-', substring-before(@effectiveDate, 'T00:00:00'))"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="concat(@id, '/static-', replace(@effectiveDate,':',''))"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <ix fn ="{$fns}" wiki="{$wikis}" type="html"/>
                    <xsl:result-document href="{$fns}" method="html" indent="no">
                        <xsl:apply-templates select="$t" mode="wikicopy"/>
                        <xsl:text>&#10;</xsl:text>
                    </xsl:result-document>
                </xsl:for-each>
                
                <!-- dynamic and summary -->
                <xsl:for-each-group select="//template[@id]" group-by="@id">
                    <!-- dynamic -->
                    <xsl:variable name="tid" select="@id"/>
                    <!-- most recent template version with status code any of draft active review -->
                    <xsl:variable name="maxstaticdate" select="max($alltmp[@id=$tid][@statusCode = ('draft', 'active', 'review')]/xs:dateTime(@effectiveDate))"/>
                    <xsl:variable name="maxstatic">
                        <xsl:choose>
                            <xsl:when test="string-length(substring-before(string($maxstaticdate), 'T00:00:00'))>0">
                                <xsl:value-of select="substring-before(string($maxstaticdate), 'T00:00:00')"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="replace(string($maxstaticdate),':','')"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:variable name="fnd" select="concat($tmpdir, '/tmp-', $tid, '-dynamic.txt')"/>
                    <xsl:variable name="wikid" select="concat(@id, '/dynamic')"/>
                    <ix fn ="{$fnd}" wiki="{$wikid}" type="text"/> 
                    <xsl:result-document href="{$fnd}" format="text"> 
                         <xsl:text>#REDIRECT [[</xsl:text>
                        <xsl:value-of select="concat(@id, '/static-', $maxstatic)"/>
                        <xsl:text>]]</xsl:text>
                        <xsl:text>&#10;</xsl:text>
                        <xsl:text>&lt;!-- </xsl:text>
                        <xsl:value-of select="@name"/>
                        <xsl:text> --&gt;</xsl:text>
                        <xsl:call-template name="nomanualeditstext"/>
                    </xsl:result-document>
                    
                    <!-- summary -->
                    <xsl:variable name="fnr" select="concat($tmpdir, '/tmp-', $tid, '-summary.txt')"/>
                    <xsl:variable name="wikir" select="@id"/>
                    <ix fn ="{$fnr}" wiki="{$wikir}" type="text"/> 
                    <xsl:result-document href="{$fnr}" format="text"> 
                        <xsl:text>__NOTOC__</xsl:text>
                        <xsl:call-template name="nomanualeditstext"/>
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'wikitemplatenote'"/>
                        </xsl:call-template>
                        <xsl:text>&#10;</xsl:text>
                        <xsl:text>[[Category:Template]]</xsl:text>
                        <xsl:text>&#10;</xsl:text>
                        <xsl:text>=Template ''</xsl:text>
                        <xsl:value-of select="@name"/>
                        <xsl:text>''=</xsl:text>
                        <xsl:text>&#10;</xsl:text>
                        <xsl:if test="desc[@language=$language]">
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'wikidescription'"/>
                            </xsl:call-template>
                            <xsl:text>&#10;</xsl:text>
                            <xsl:text>&lt;p></xsl:text>
                            <xsl:copy-of select="desc[@language=$language]"/>
                            <xsl:text>&lt;/p></xsl:text>
                            <xsl:text>&#10;</xsl:text>
                        </xsl:if>
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'wikiactualversion'"/>
                        </xsl:call-template>
                        <xsl:text>&#10;</xsl:text>
                        <xsl:text>{{:{{BASEPAGENAME}}/dynamic}}</xsl:text>
                        <xsl:text>&#10;</xsl:text>
                        <xsl:text>&#10;</xsl:text>
                        <xsl:call-template name="getMessage">
                            <xsl:with-param name="key" select="'wikilisttemplateversions'"/>
                        </xsl:call-template>
                        <xsl:text>&#10;</xsl:text>
                        <xsl:choose>
                            <xsl:when test="count($alltmp[@id = $tid]) &lt;= 0">
                                <xsl:text>(bisher keine weiteren Angaben)</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:for-each select="$alltmp[@id = $tid]">
                                    <xsl:sort select="@effectiveDate" order="descending"/>
                                    <xsl:variable name="edd">
                                        <xsl:choose>
                                            <xsl:when test="string-length(substring-before(@effectiveDate, 'T00:00:00'))>0">
                                                <xsl:value-of select="substring-before(@effectiveDate, 'T00:00:00')"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="replace(@effectiveDate,':','')"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:variable>
                                    <xsl:text>* [[</xsl:text>
                                    <xsl:value-of select="@id"/>
                                    <xsl:text>/static-</xsl:text>
                                    <xsl:value-of select="$edd"/>
                                    <xsl:text>|</xsl:text>
                                    <xsl:value-of select="$edd"/>
                                    <xsl:text> (</xsl:text>
                                    <!-- 
                                        <xsl:value-of select="@statusCode"/>
                                    -->
                                    <xsl:call-template name="getMessage">
                                        <xsl:with-param name="key" select="concat('TemplateStatusCodeLifeCycle-',@statusCode)"/>
                                    </xsl:call-template>
                                    <xsl:text>)</xsl:text>
                                    <xsl:text>]]</xsl:text>
                                    <xsl:text>&#10;</xsl:text>
                                </xsl:for-each>
                            </xsl:otherwise>
                        </xsl:choose>
                        
                    </xsl:result-document>
                    
                </xsl:for-each-group>
                
                
                <!--
                        per value set with id and effective date
                        - create one rendering per effective date (version) with that id, e.g. 2.16.840.1.113883.1.11.1/static-2012-07-24
                        - create one redirect as the dynamic rendering, i.e. 2.16.840.1.113883.1.11.1/dynamic
                        - create one summary 2.16.840.1.113883.1.11.1
                        - create one redirect to the summary page named as the name of the value set
                    -->
                
                <!-- statics, cave duplicate id+effectiveDate combinations due to multiple repository references -->
                <xsl:for-each-group select="//valueSet[@id]" group-by="concat(@id, @effectiveDate)">
                    <xsl:variable name="vid" select="@id"/>
                    <xsl:if test="string-length($vid)>0">
                        <xsl:variable name="ed" select="replace(@effectiveDate,':','')"/>
                        <xsl:variable name="fns" select="concat($tmpdir, '/vs-', @id, '-', $ed, '.html')"/>
                        <xsl:variable name="wikis">
                            <xsl:choose>
                                <xsl:when test="string-length(substring-before(@effectiveDate, 'T00:00:00'))>0">
                                    <xsl:value-of select="concat(@id, '/static-', substring-before(@effectiveDate, 'T00:00:00'))"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="concat(@id, '/static-', replace(@effectiveDate,':',''))"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <ix fn ="{$fns}" wiki="{$wikis}" type="html"/>
                        <xsl:result-document href="{$fns}" format="html">
                            <xsl:call-template name="nomanualedits"/>
                            <!-- render it -->
                            <xsl:variable name="t">    
                                <xsl:apply-templates select=".">
                                    <xsl:with-param name="showOtherVersionsList" select="false()"/>
                                </xsl:apply-templates>
                            </xsl:variable>
                            <xsl:text>&#10;</xsl:text>
                            <xsl:apply-templates select="$t" mode="wikicopy"/>
                            <xsl:text>&#10;</xsl:text>
                        </xsl:result-document>
                    </xsl:if>
                </xsl:for-each-group>
                
                <!-- dynamic and summary -->
                <xsl:for-each-group select="//valueSet[@id]" group-by="@id">
                    <!-- dynamic -->
                    <xsl:variable name="vid" select="@id"/>
                    <xsl:if test="string-length($vid)>0">
                        <!-- most recent value set version with status code any of new draft final review -->
                        <xsl:variable name="maxstaticdate" select="max($allvs[@id=$vid][@statusCode = ('new', 'draft', 'final', 'review')]/xs:dateTime(@effectiveDate))"/>
                        <xsl:variable name="maxstatic">
                            <xsl:choose>
                                <xsl:when test="string-length(substring-before(string($maxstaticdate), 'T00:00:00'))>0">
                                    <xsl:value-of select="substring-before(string($maxstaticdate), 'T00:00:00')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="replace(string($maxstaticdate),':','')"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:variable name="fnd" select="concat($tmpdir, '/vs-', $vid, '-dynamic.txt')"/>
                        <xsl:variable name="wikid" select="concat(@id, '/dynamic')"/>
                        <ix fn ="{$fnd}" wiki="{$wikid}" type="text"/> 
                        <xsl:choose>
                            <xsl:when test="string-length($maxstatic)>0">
                                <xsl:result-document href="{$fnd}" format="text"> 
                                    <xsl:text>#REDIRECT [[</xsl:text>
                                    <xsl:value-of select="concat(@id, '/static-', $maxstatic)"/>
                                    <xsl:text>]]</xsl:text>
                                    <xsl:text>&#10;</xsl:text>
                                    <xsl:text>&lt;!-- </xsl:text>
                                    <xsl:value-of select="@name"/>
                                    <xsl:text> --&gt;</xsl:text>
                                    <xsl:call-template name="nomanualeditstext"/>
                                </xsl:result-document>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:result-document href="{$fnd}" format="text">
                                    <xsl:text>keine</xsl:text>
                                </xsl:result-document>
                            </xsl:otherwise>
                        </xsl:choose>
                        
                        
                        <!-- summary -->
                        <xsl:variable name="fnr" select="concat($tmpdir, '/vs-', $vid, '-summary.txt')"/>
                        <xsl:variable name="wikir" select="@id"/>
                        <ix fn ="{$fnr}" wiki="{$wikir}" type="text"/> 
                        <xsl:result-document href="{$fnr}" format="text"> 
                            <xsl:text>__NOTOC__</xsl:text>
                            <xsl:call-template name="nomanualeditstext"/>
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'wikiterminologynote'"/>
                            </xsl:call-template>
                            <xsl:text>&#10;</xsl:text>
                            <xsl:text>[[Category:Value Set]]</xsl:text>
                            <xsl:text>&#10;</xsl:text>
                            <xsl:text>=Value Set ''</xsl:text>
                            <xsl:value-of select="@name"/>
                            <xsl:text>''=</xsl:text>
                            <xsl:text>&#10;</xsl:text>
                            <xsl:if test="desc[@language=$language]">
                                <xsl:call-template name="getMessage">
                                    <xsl:with-param name="key" select="'wikidescription'"/>
                                </xsl:call-template>
                                <xsl:text>&#10;</xsl:text>
                                <xsl:text>&lt;p></xsl:text>
                                <xsl:copy-of select="desc[@language=$language]"/>
                                <xsl:text>&lt;/p></xsl:text>
                                <xsl:text>&#10;</xsl:text>
                            </xsl:if>
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'wikiactualversion'"/>
                            </xsl:call-template>
                            <xsl:text>&#10;</xsl:text>
                            <xsl:text>{{:{{BASEPAGENAME}}/dynamic}}</xsl:text>
                            <xsl:text>&#10;</xsl:text>
                            <xsl:text>&#10;</xsl:text>
                            <xsl:call-template name="getMessage">
                                <xsl:with-param name="key" select="'wikilistvaluesetversions'"/>
                            </xsl:call-template>
                            <xsl:text>&#10;</xsl:text>
                            <xsl:choose>
                                <xsl:when test="count($allvs[@id = $vid]) &lt;= 0">
                                    <xsl:text>(bisher keine weiteren Angaben)</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:for-each-group select="$allvs[@id = $vid]" group-by="concat(@id, @effectiveDate)">
                                        <xsl:sort select="@effectiveDate" order="descending"/>
                                        <xsl:variable name="edd">
                                            <xsl:choose>
                                                <xsl:when test="string-length(substring-before(@effectiveDate, 'T00:00:00'))>0">
                                                    <xsl:value-of select="substring-before(@effectiveDate, 'T00:00:00')"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="replace(@effectiveDate,':','')"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:variable>
                                        <xsl:text>* [[</xsl:text>
                                        <xsl:value-of select="@id"/>
                                        <xsl:text>/static-</xsl:text>
                                        <xsl:value-of select="$edd"/>
                                        <xsl:text>|</xsl:text>
                                        <xsl:value-of select="$edd"/>
                                        <xsl:text> (</xsl:text>
                                        <xsl:call-template name="getMessage">
                                            <xsl:with-param name="key" select="concat('ItemStatusCodeLifeCycle-', @statusCode)"/>
                                        </xsl:call-template>
                                        <xsl:text>)</xsl:text>
                                        <xsl:text>]]</xsl:text>
                                        <xsl:text>&#10;</xsl:text>
                                    </xsl:for-each-group>
                                </xsl:otherwise>
                            </xsl:choose>
                            
                        </xsl:result-document>
                    </xsl:if>
                </xsl:for-each-group>
                
                <!-- redirect for names -->
                <xsl:for-each-group select="//valueSet[@name][@id]" group-by="@name">
                    <xsl:variable name="fnl" select="concat($tmpdir, '/vs-', @name, '-name.txt')"/>
                    <xsl:variable name="wikil" select="concat(@name, ' (Value Set)')"/>
                    <xsl:if test="string-length(@id)>0">
                        <ix fn ="{$fnl}" wiki="{$wikil}" type="text"/>
                        <xsl:result-document href="{$fnl}" format="text">
                            <xsl:text>#REDIRECT [[</xsl:text>
                            <xsl:value-of select="@id"/>
                            <xsl:text>]]</xsl:text>
                            <xsl:text>&#10;[[Category:Value Set]]&#10;</xsl:text>
                            <xsl:text>&lt;!-- </xsl:text>
                            <xsl:value-of select="@name"/>
                            <xsl:text> --&gt;</xsl:text>
                            <xsl:call-template name="nomanualeditstext"/>
                        </xsl:result-document>
                    </xsl:if>
                </xsl:for-each-group>
                <xsl:for-each-group select="//template[@name][@id]" group-by="@name">
                    <xsl:variable name="fnl" select="concat($tmpdir, '/tmp-', @name, '-name.txt')"/>
                    <xsl:variable name="wikil" select="concat(@name, ' (Template)')"/>
                    <xsl:if test="string-length(@id)>0">
                        <ix fn ="{$fnl}" wiki="{$wikil}" type="text"/>
                        <xsl:result-document href="{$fnl}" format="text">
                            <xsl:text>#REDIRECT [[</xsl:text>
                            <xsl:value-of select="@id"/>
                            <xsl:text>]]</xsl:text>
                            <xsl:text>&#10;[[Category:Template]]&#10;</xsl:text>
                            <xsl:text>&lt;!-- </xsl:text>
                            <xsl:value-of select="@name"/>
                            <xsl:text> --&gt;</xsl:text>
                            <xsl:call-template name="nomanualeditstext"/>
                        </xsl:result-document>
                    </xsl:if>
                </xsl:for-each-group>
                
                
            </index>
            
        </xsl:result-document>

    </xsl:template>

    <xsl:template match="table" mode="wikicopy">
        <table class="artdecor">
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="style" select="'background: transparent;'"/>
            <xsl:apply-templates mode="wikicopy"/>
        </table>
    </xsl:template>
    <xsl:template match="th|tr|font|i|br|tt|span|strong|ul|li|p" mode="wikicopy">
        <xsl:element name="{name()}">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="wikicopy"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="td|div" mode="wikicopy">
        <xsl:element name="{name()}">
            <xsl:copy-of select="@* except (@id|@onclick)"/>
            <xsl:apply-templates mode="wikicopy"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="thead|tbody" mode="wikicopy">
        <xsl:apply-templates mode="wikicopy"/>
    </xsl:template>
    <xsl:template match="a" mode="wikicopy">
        <xsl:apply-templates mode="wikicopy"/>
    </xsl:template>
    <xsl:template match="img[@src='https://art-decor.org/ADAR/rv/assets/treeblank.png']|img[@src='http://art-decor.org/ADAR/rv/assets/treeblank.png']" mode="wikicopy">
        <!-- translate xxxx to [[Datei:Treetree.png]] -->
        <xsl:text>[[Datei:Treeblank.png|15px]]</xsl:text>
    </xsl:template>
    <xsl:template match="img[@src='https://art-decor.org/ADAR/rv/assets/treetree.png']|img[@src='http://art-decor.org/ADAR/rv/assets/treetree.png']" mode="wikicopy">
        <xsl:text>[[Datei:Treetree.png|15px]]</xsl:text>
    </xsl:template>
    <xsl:template match="img[@src='https://art-decor.org/ADAR/rv/assets/notice.png']|img[@src='http://art-decor.org/ADAR/rv/assets/notice.png']" mode="wikicopy">
        <xsl:text>[[Datei:Notice.png|15px]]</xsl:text>
    </xsl:template>
    <xsl:template match="img[@src='https://art-decor.org/ADAR/rv/assets/en-US.png']|img[@src='http://art-decor.org/ADAR/rv/assets/en-US.png']" mode="wikicopy">
        <xsl:text>[[Datei:EN-US.png]]</xsl:text>
    </xsl:template>
    <xsl:template match="img[@src='https://art-decor.org/ADAR/rv/assets/de-DE.png']|img[@src='http://art-decor.org/ADAR/rv/assets/de-DE.png']" mode="wikicopy">
        <xsl:text>[[Datei:DE-DE.png]]</xsl:text>
    </xsl:template>
    <xsl:template match="img[@src='https://art-decor.org/ADAR/rv/assets/nl-NL.png']|img[@src='http://art-decor.org/ADAR/rv/assets/nl-NL.png']" mode="wikicopy">
        <xsl:text>[[Datei:NL-NL.png]]</xsl:text>
    </xsl:template>
    <xsl:template match="img[@src='https://art-decor.org/ADAR/rv/assets/alert.png']|img[@src='http://art-decor.org/ADAR/rv/assets/alert.png']" mode="wikicopy">
        <xsl:text>[[Datei:Alert.png|15px]]</xsl:text>
    </xsl:template>

    <xsl:template match="xxxxxx" mode="wikicopy">
        <xsl:copy-of select="." copy-namespaces="no" exclude-result-prefixes="#all"/>
    </xsl:template>
    <!--
    <xsl:template match="text()" mode="wikicopy">
        <xsl:value-of select="."/>
        <xsl:apply-templates mode="wikicopy"/>
    </xsl:template>
    -->
    <xsl:template match="x/text()[normalize-space(.)][../*]" mode="wikicopy">
        <xsl:value-of select="translate(., '&#10;&#13;', ' ')"/>
    </xsl:template>
    <xsl:template match="text()" mode="wikicopy">
        <xsl:value-of select="translate(., '&#10;&#13;', ' ')"/>
    </xsl:template>

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="wikicopy"/>
        </xsl:copy>
    </xsl:template>
    
    
    
    
    
    
    
    <xsl:template name="nomanualedits">
        <xsl:text>&#10;</xsl:text>
        <xsl:comment> ****** CAUTION Manual changes on this page are ineffective: the page is automagically generated by a transformed from an ART-DECOR project by a bot (ADBot). ****** </xsl:comment>
    </xsl:template>
    <xsl:template name="nomanualeditstext">
        <xsl:text>&#10;</xsl:text>
        <xsl:text>&lt;!-- ****** CAUTION Manual changes on this page are ineffective: the page is automagically generated by a transformed from an ART-DECOR project by a bot (ADBot). ****** --&gt;</xsl:text>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>

</xsl:stylesheet>