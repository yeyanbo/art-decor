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
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ev="http://www.w3.org/2001/xml-events" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fr="http://orbeon.org/oxf/xml/form-runner" xmlns:xf="http://www.w3.org/2002/xforms" xmlns:xxforms="http://orbeon.org/oxf/xml/xforms" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.w3.org/1999/xhtml http://www.w3.org/2002/08/xhtml/xhtml1-transitional.xsd     http://www.w3.org/2002/xforms http://www.w3.org/MarkUp/Forms/2002/XForms-Schema.xsd" version="2.0">
    <xsl:output method="html"/>
    <xsl:include href="ada-basics.xsl"/>
    <xsl:variable name="adaModules">
        <xsl:text>http://{xxforms:get-session-attribute('username')}:{xxforms:get-session-attribute('password')}@</xsl:text><xsl:value-of select="$existHostPort"/><xsl:text>ada/modules/</xsl:text>
    </xsl:variable>
    <xsl:variable name="newDir" select="concat($existBaseUri, $projectUri, 'new/')"/>
    <xsl:variable name="schemaDir" select="concat($existBaseUri, $projectUri, 'schemas/')"/>
    <xsl:template match="/">
        <xsl:for-each select="//view[@target='xforms']">
            <xsl:variable name="href" select="concat($projectDiskRoot, 'views/', implementation/@shortName, '.xhtml')"/>
            <xsl:result-document href="{$href}" method="xhtml">
                <xsl:comment>ADA XForms generator, <xsl:value-of select="current-dateTime()"/>
                </xsl:comment>
                <xsl:text>&#10;</xsl:text>
                <xsl:apply-templates/>
            </xsl:result-document>
        </xsl:for-each>
        <ok/>
    </xsl:template>
    <xsl:template match="dataset">
        <xsl:processing-instruction name="xml-model">
            <xsl:text>href="http://www.oxygenxml.com/1999/xhtml/xhtml-xforms.nvdl" schematypens="http://purl.oclc.org/dsdl/nvdl/ns/structure/1.0"</xsl:text>
        </xsl:processing-instruction>
        <xsl:text>&#10;</xsl:text>
        <xhtml:html>
            <xhtml:head>
                <xhtml:link rel="stylesheet" type="text/css" href="{$existBaseUri}ada/resources/css/ada.css"/>
                <xhtml:title>
                    <xsl:value-of select="../name"/>
                </xhtml:title>
                <!-- TODO: actual schema -->
                <xf:model id="m-meting">
                    <xsl:attribute name="schema">
                        <xsl:value-of select="$schemaDir"/>
                        <xsl:value-of select="@shortName"/>
                        <xsl:text>.xsd</xsl:text>
                    </xsl:attribute>
                    <xf:instance id="data">
                        <data/>
                    </xf:instance>
                    <xf:instance id="debug">
                        <formdata>
                            <id/>
                            <username/>
                            <warning>You are not logged in!</warning>
                            <user>User</user>
                            <success>Success</success>
                            <login>Login</login>
                            <logout>Logout</logout>
                            <save>Save</save>
                        </formdata>
                    </xf:instance>
                    <xf:instance id="new">
                        <xsl:attribute name="src">
                            <xsl:value-of select="$newDir"/>
                            <xsl:value-of select="@shortName"/>
                            <xsl:text>.xml</xsl:text>
                        </xsl:attribute>
                    </xf:instance>
                    <xf:submission id="get-data" serialization="none" method="get" replace="instance" instance="data">
                        <xsl:attribute name="resource">
                            <xsl:value-of select="$adaModules"/>
                            <xsl:text>get-data.xquery?id={xxforms:get-request-parameter('id')}&amp;app=</xsl:text>
                            <xsl:value-of select="$projectName"/>
                            <xsl:text>&amp;transactionName=</xsl:text>
                            <xsl:value-of select="@shortName"/>
                        </xsl:attribute>
                    </xf:submission>
                    <xf:submission id="save-data" ref="instance('data')" method="post" replace="none">
                        <xsl:attribute name="resource">
                            <xsl:value-of select="$adaModules"/>
                            <xsl:text>save-data.xquery</xsl:text>
                        </xsl:attribute>
                        <xf:message ev:event="xforms-submit-error" level="modal">
                            A submission error occurred: <xf:output value="event('error-type')"/>; Status: <xf:output value="event('response-status-code')"/>; URI: <xf:output value="event('resource-uri')"/>; Headers: <xf:output value="event('response-headers')"/>; Body: <xf:output value="event('response-body')"/>
                        </xf:message>
                        <xf:action ev:event="xforms-submit-done">
                            <xf:message>
                                <xf:output ref="instance('debug')/success"/>
                            </xf:message>
                        </xf:action>
                    </xf:submission>
                    <xf:action ev:event="xforms-model-construct-done">
                        <xf:send submission="get-data"/>
                        <xf:setvalue ref="instance('debug')/id" value="xxforms:get-request-parameter('id')"/>
                        <xf:setvalue ref="instance('debug')/username" value="xxforms:get-session-attribute('username')"/>
                    </xf:action>
                    <xf:bind nodeset="instance('debug')/warning" relevant="not(instance('debug')/username/text())"/>
                    <xf:bind nodeset="instance('debug')/login" relevant="not(instance('debug')/username/text())"/>
                    <xf:bind nodeset="instance('debug')/logout" relevant="string-length(instance('debug')/username/text())&gt;0"/>
                    <xsl:apply-templates mode="doTheBindings"/>
                    <xsl:apply-templates mode="doTheConditions"/>
                </xf:model>
            </xhtml:head>
            <xhtml:body style="background: none">
                <xf:output ref="instance('debug')/warning"/>
                <xhtml:table id="toprow" width="100%" style="background: transparent;">
                    <!-- row with menu, login -->
                    <xhtml:tr>
                        <!-- menu -->
                        <!-- login -->
                        <xhtml:td align="right" style="margin:0;padding:0;vertical-align:text-bottom;">
                            <xf:output ref="concat(instance('debug')/user,': ',xxforms:get-session-attribute('username'),' - ')"/>
                            <xhtml:a href="../../../../session/logout">
                                <xf:output ref="instance('debug')/logout"/>
                            </xhtml:a>
                            <xhtml:a href="../../../../login">
                                <xf:output ref="instance('debug')/login"/>
                            </xhtml:a>
                        </xhtml:td>
                    </xhtml:tr>
                </xhtml:table>
                <xf:group id="meting-ui" appearance="full">
                    <xhtml:div class="adaForm">
                        <xsl:choose>
                            <xsl:when test="//concept[@widget='tab']">
                                <fr:tabview>
                                    <xsl:apply-templates mode="doTheForm" select="concept"/>
                                </fr:tabview>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates mode="doTheForm" select="concept"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xhtml:div>
                    <xf:trigger>
                        <xf:label>
                            <xf:output ref="instance('debug')/save"/>
                        </xf:label>
                        <xf:action ev:event="DOMActivate">
                            <xf:send submission="save-data"/>
                        </xf:action>
                    </xf:trigger>
                </xf:group>
            </xhtml:body>
        </xhtml:html>
    </xsl:template>

    <!-- Process concepts for bindings -->
    <xsl:template mode="doTheBindings" match="concept[(valueDomain/@type='date') or (valueDomain/@type='datetime') or (valueDomain/@type='boolean')]">
        <xsl:comment>
            <xsl:text>doTheBindings for: </xsl:text>
            <xsl:value-of select="implementation/@shortName"/>
        </xsl:comment>
        <xf:bind nodeset="//*[@conceptId='{@id}']/@value">
            <xsl:choose>
                <xsl:when test="valueDomain/@type='count'">
                    <xsl:attribute name="type">xs:nonNegativeInteger</xsl:attribute>
                </xsl:when>
                <!-- code is restrained by the valueSet -->
                <!-- ordinal -->
                <xsl:when test="valueDomain/@type='ordinal'">
                    <xsl:attribute name="type">xs:integer</xsl:attribute>
                </xsl:when>
                <!-- identifier -->
                <!-- string -->
                <!-- text -->
                <!-- The XForms data types for date(Time) allow empty string, the XSD ones don't -->
                <xsl:when test="(valueDomain/@type='date') and (@conformance='M')">
                    <xsl:attribute name="type">xs:date</xsl:attribute>
                </xsl:when>
                <xsl:when test="(valueDomain/@type='date') and (@conformance!='M')">
                    <xsl:attribute name="type">xf:date</xsl:attribute>
                </xsl:when>
                <xsl:when test="(valueDomain/@type='datetime') and (@conformance='M')">
                    <xsl:attribute name="type">xs:dateTime</xsl:attribute>
                </xsl:when>
                <xsl:when test="(valueDomain/@type='datetime') and (@conformance!='M')">
                    <xsl:attribute name="type">xf:dateTime</xsl:attribute>
                </xsl:when>
                <!-- complex -->
                <xsl:when test="valueDomain/@type='quantity'">
                    <xsl:attribute name="type">xs:decimal</xsl:attribute>
                </xsl:when>
                <!-- duration -->
                <xsl:when test="valueDomain/@type='boolean'">
                    <xsl:attribute name="type">xs:boolean</xsl:attribute>
                </xsl:when>
                <xsl:when test="valueDomain/@type='blob'">
                    <xsl:attribute name="type">xs:base64Binary</xsl:attribute>
                </xsl:when>
                <!-- currency -->
                <!-- ratio -->
            </xsl:choose>
        </xf:bind>
    </xsl:template>

    <!-- Process concepts for bindings -->
    <xsl:template mode="doTheConditions" match="concept[@notPresentWhen]">
        <xsl:comment>
            <xsl:text>doTheConditions for: </xsl:text>
            <xsl:value-of select="implementation/@shortName"/>
        </xsl:comment>
        <xf:bind nodeset="//*[@conceptId='{@id}']">
            <xsl:attribute name="relevant">
                <xsl:text>not(</xsl:text>
                <xsl:value-of select="@notPresentWhen"/>
                <xsl:text>)</xsl:text>
            </xsl:attribute>
        </xf:bind>
    </xsl:template>
    
    <!-- Process concept groups -->
    <xsl:template mode="doTheForm" name="concept_group" match="concept[@type='group']">
        <xsl:comment>
            <xsl:text>doTheForm for concept_group: </xsl:text>
            <xsl:value-of select="implementation/@shortName"/>
        </xsl:comment>
        <xsl:choose>
            <xsl:when test="@widget='tab'">
                <fr:tab>
                    <fr:label>
                        <xsl:value-of select="name"/>
                    </fr:label>
                    <xsl:call-template name="concept_group_content"/>
                </fr:tab>
            </xsl:when>
            <xsl:otherwise>
                <xhtml:div class="adaGroup">
                    <xsl:call-template name="concept_group_content"/>
                </xhtml:div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Process concept group content -->
    <xsl:template name="concept_group_content">
        <xsl:comment>
            <xsl:text>doTheForm for concept_group: </xsl:text>
            <xsl:value-of select="implementation/@shortName"/>
        </xsl:comment>
        <xsl:choose>
            <xsl:when test="@maximumMultiplicity!='1'">
                <!-- TODO: with repeating group, h3 title won't be hidden if nodeset is not relevant -->
                <xhtml:div class="adaMany">
                    <xhtml:h3>
                        <xsl:value-of select="name"/>
                    </xhtml:h3>
                    <!-- The repeater will show all concepts without @hidden, which is there to insert new rows when all are deleted -->
                    <xf:repeat id="repeat-{translate(@id, '.', '_')}" nodeset="instance('data')//*[@conceptId='{@id}'][not(@hidden)]" appearance="full">
                        <xhtml:div class="adaRow">
                            <xhtml:h4>
                                <xsl:value-of select="name"/>
                                <xsl:text> </xsl:text>
                                <xf:output value="position()"/>
                            </xhtml:h4>
                            <xsl:apply-templates mode="doTheForm" select="concept"/>
                            <xf:trigger>
                                <xf:label>- <xsl:value-of select="name"/>
                                </xf:label>
                                <!-- delete based on conceptId, is always unique. Never delete the hidden row. Do the index last.-->
                                <xf:delete ev:event="DOMActivate" nodeset="instance('data')//*[@conceptId='{@id}'][not(@hidden)][index('repeat-{translate(@id, '.', '_')}')]"/>
                            </xf:trigger>
                        </xhtml:div>
                    </xf:repeat>
                </xhtml:div>
                <xf:trigger>
                    <xf:label>+ <xsl:value-of select="name"/>
                    </xf:label>
                    <!-- insert based on conceptId, is always unique. do [1] last. -->
                    <xf:insert ev:event="DOMActivate" nodeset="instance('data')//*[@conceptId='{@id}']" at="last()" position="after" origin="instance('new')//*[@conceptId='{@id}'][not(@hidden)][1]"/>
                </xf:trigger>
            </xsl:when>
            <xsl:otherwise>
                <xhtml:div class="adaSingle">
                    <xf:group ref="{implementation/@shortName}" appearance="full">
                        <xhtml:h3>
                            <xsl:value-of select="name"/>
                        </xhtml:h3>
                        <xhtml:div class="adaRow">
                            <xsl:apply-templates mode="doTheForm" select="concept"/>
                        </xhtml:div>
                    </xf:group>
                </xhtml:div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Process concept items for xform inputs -->
    <xsl:template mode="doTheForm" name="concept_item" match="concept[@type='item']">
        <xsl:comment>
            <xsl:text>doTheForm for concept_item: </xsl:text>
            <xsl:value-of select="implementation/@shortName"/>
        </xsl:comment>
        <p>
            <xsl:choose>
                <xsl:when test="@maximumMultiplicity!='1'">
                    <xf:repeat nodeset="{implementation/@shortName}" appearance="full">
                        <xsl:apply-templates/>
                    </xf:repeat>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </p>
    </xsl:template>
    <xsl:template name="typeIsQuantity" match="valueDomain[@type='quantity']">
        <xsl:comment>Template typeIsQuantity</xsl:comment>
        <xf:input>
            <xsl:call-template name="addInputDetails"/>
        </xf:input>
        <xsl:choose>
            <xsl:when test="count(property/@unit) &gt; 1">
                <xf:select1 ref="{../implementation/@shortName}/@unit">
                    <!-- Choice between available units -->
                    <!-- TODO: translation -->
                    <xf:label>Eenheid</xf:label>
                    <xsl:for-each select="property/@unit">
                        <xf:item>
                            <xf:label>
                                <xsl:value-of select="."/>
                            </xf:label>
                            <xf:value>
                                <xsl:value-of select="."/>
                            </xf:value>
                        </xf:item>
                    </xsl:for-each>
                </xf:select1>
            </xsl:when>
            <xsl:otherwise>
                <xf:output>
                    <xf:label>
                        <xsl:value-of select="property/@unit"/>
                    </xf:label>
                </xf:output>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="typeIsCode" match="valueDomain[@type='code']">
        <xsl:comment>Template typeIsCode</xsl:comment>
        <xf:select1>
            <!-- TODO: translation -->
            <xsl:call-template name="addInputDetails"/>
            <xsl:for-each select="../valueSet/conceptList/(concept|exception)">
                <xf:item>
                    <xf:label>
                        <xsl:value-of select="name"/>
                    </xf:label>
                    <xf:value>
                        <xsl:value-of select="@localId"/>
                    </xf:value>
                </xf:item>
            </xsl:for-each>
        </xf:select1>
    </xsl:template>
    <xsl:template name="typeIsText" match="valueDomain[@type='text']">
        <xf:textarea>
            <xsl:call-template name="addInputDetails"/>
        </xf:textarea>
    </xsl:template>
    <xsl:template name="typeIsOther" match="valueDomain[contains('count identifier string date datetime complex duration boolean blob currency ratio', @type)]">
        <xf:input>
            <xsl:call-template name="addInputDetails"/>
        </xf:input>
    </xsl:template>
    <xsl:template name="addInputDetails">
        <xsl:attribute name="ref">
            <xsl:if test="../@maximumMultiplicity='1'">
                <xsl:value-of select="../implementation/@shortName"/>
                <xsl:text>/@value</xsl:text>
            </xsl:if>
            <xsl:if test="../@maximumMultiplicity!='1'">
                <xsl:text>@value</xsl:text>
            </xsl:if>
        </xsl:attribute>
        <xf:label>
            <xsl:value-of select="../name[1]"/>
        </xf:label>
        <xf:hint>
            <xsl:value-of select="../desc[1]"/>
        </xf:hint>
        <xf:alert>
            <!-- TODO: other properties -->
            <xsl:text>Value must be: </xsl:text>
            <xsl:value-of select="@type"/>
            <xsl:text>  </xsl:text>
            <xsl:for-each select="property">
                <xsl:value-of select="@unit"/>
                <xsl:text> (</xsl:text>
                <xsl:value-of select="@minInclude"/>
                <xsl:text>-</xsl:text>
                <xsl:value-of select="@maxInclude"/>
                <xsl:text>)  </xsl:text>
            </xsl:for-each>
        </xf:alert>
    </xsl:template>

    <!-- Override all default templates for text, attributes -->
    <xsl:template mode="doTheBindings" match="text()|@*"/>
    <xsl:template mode="doTheConditions" match="text()|@*"/>
    <xsl:template match="text()|@*"/>
</xsl:stylesheet>