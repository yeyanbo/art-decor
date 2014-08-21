<!-- 
    DISCLAIMER
    Deze stylesheet en de resulterende html weergave van xml berichten zijn uitsluitend bedoeld voor testdoeleinden.
    Zij zijn uitdrukkelijk niet bedoeld voor gebruik in de medische praktijk.
    
    Auteur: Gerrit Boers
    Copyright: Nictiz
    
    Boxover javascript door http://boxover.swazz.org
    (BoxOver is free and distributed under the GNU license)
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" exclude-result-prefixes="hl7" version="2.0">
    <xsl:output method="html" exclude-result-prefixes="#all" encoding="UTF-8"/>
    <xsl:template match="/">
        <html>
            <head>
            <!-- Javascript voor tonen/verbergen van elementen
                     toggled is de id van het te tonen/verbergen element
                     toggler de id van het element dat als trigger dient
                -->
                <script type="text/javascript">
                    function toggle(toggled,toggler) {
                    if (document.getElementById) {
                    var currentStyle = document.getElementById(toggled).style;
                    var togglerStyle = document.getElementById(toggler).style;
                    if (currentStyle.display == "block"){
                    currentStyle.display = "none";
                    togglerStyle.backgroundImage = "url(/terminology/resources/images/trClosed.gif)";
                    } else {
                    currentStyle.display = "block";
                    togglerStyle.backgroundImage = "url(/terminology/resources/images/triangleOpen.gif)";
                    }
                    return false;
                    } else {
                    return true;
                    }
                    }
                </script>
                <style type="text/css" media="print, screen">
               body{
                  font-family:Verdana;
                  font-size:12px;
               }
               table{
                  width:100%;
                  border-spacing:0px;
                  font-family:Verdana;
                  font-size:12px;
               }
               td{
                  text-align:left;
                  vertical-align:top;
               }
               td.parent{
                  text-align:center;
                  vertical-align:top;
                  padding-left:1em;
                  padding-right:1em;
                  padding-top:0em;
                  padding-bottom:0em;
               }
               td.child{
                  text-align:left;
                  vertical-align:top;
                  padding-left:1em;
                  padding-right:1em;
                  padding-top:0.3em;
                  padding-bottom:0.3em;
               }
               td.vertical-line{
                  text-align:center;
                  vertical-align:middle;
               }
               td.toggler{
                  background-image:url(/terminology/resources/images/trClosed.gif);
                  background-repeat:no-repeat;
                  padding-left:15px;
               }
               td.toggler:hover{
                  cursor:pointer;
                  /*    	color : #e16e22;*/
               }
               td.toggle{
                  display:none;
               }
               div.navigate{
                  border-radius:5px 5px;
                  -moz-border-radius:5px;
                  -webkit-border-radius:5px;
                  box-shadow:5px 5px 5px rgba(0, 0, 0, 0.1);
                  -webkit-box-shadow:5px 5px rgba(0, 0, 0, 0.1);
                  -moz-box-shadow:5px 5px rgba(0, 0, 0, 0.1);
                  background:#ebe7e1;
                  border:1px solid #e6aa83;
                  padding:0.5em;
                  width:80%;
                  margin:auto;
               }
               div.navigate-child{
                  border-radius:5px 5px;
                  -moz-border-radius:5px;
                  -webkit-border-radius:5px;
                  box-shadow:3px 3px 3px rgba(0, 0, 0, 0.1);
                  -webkit-box-shadow:3px 3px rgba(0, 0, 0, 0.1);
                  -moz-box-shadow:3px 3px rgba(0, 0, 0, 0.1);
                  background:#ebe7e1;
                  border:1px solid #e6aa83;
                  padding:0.2em;
                  padding-left:1em;
                  width:50%;
                  margin:auto;
               }
               div.concept{
                  border-radius:5px 5px;
                  -moz-border-radius:5px;
                  -webkit-border-radius:5px;
                  box-shadow:5px 5px 5px rgba(0, 0, 0, 0.1);
                  -webkit-box-shadow:5px 5px rgba(0, 0, 0, 0.1);
                  -moz-box-shadow:5px 5px rgba(0, 0, 0, 0.1);
                  background:#ebe7e1;
                  border:1px solid #e6aa83;
                  padding:0.5em;
                  margin:auto;
               }
               div.refset{
                  border-radius:5px 5px;
                  -moz-border-radius:5px;
                  -webkit-border-radius:5px;
                  background:#e3dfd9;
                  border:1px solid #bbb;
                  padding:0.2em;
                  padding-left:0.5em;
                  margin-left:1em;
                  margin-top:0.5em;
                  margin-bottom:0.4em;
               }
               div.refsetGroup{
                  border-radius:5px 5px;
                  -moz-border-radius:5px;
                  -webkit-border-radius:5px;
                  background:#ebe7e1;
                  border:1px solid #bbb;
                  padding-top:0.2em;
                  padding-left:0.4em;
                  padding-bottom:0.2em;
                  padding-right:0.4em;
                  margin-top:0.2em;
                  margin-bottom:0.4em;
               }
               div.map-rule:first-child{
                  background:#e3dfd9;
                  margin-top:0.2em;
                  margin-bottom:0.2em;
                  margin-left:0.2em;
                  margin-right:0.2em;
                  padding-left:0.5em;
               }
               div.map-rule{
                  background:#e3dfd9;
                  margin-top:0.8em;
                  margin-bottom:0.2em;
                  margin-left:0.2em;
                  margin-right:0.2em;
                  padding-left:0.5em;
               }
               div.grp{
                  border-radius:5px 5px;
                  -moz-border-radius:5px;
                  -webkit-border-radius:5px;
                  background:#e3dfd9;
                  border:1px solid #e6aa83;
                  padding:0.2em;
                  padding-left:0.5em;
                  margin-left:1em;
                  margin-bottom:0.5em;
               }
               div.syn{
                  border-radius:5px 5px;
                  -moz-border-radius:5px;
                  -webkit-border-radius:5px;
                  background:#dad6d0;
                  padding:0.2em;
                  padding-left:0.5em;
                  margin-top:0.5em;
                  margin-bottom:0.5em;
               }
               span.subcount{
                  border-radius:5px 5px;
                  -moz-border-radius:5px;
                  -webkit-border-radius:5px;
                  background:#dad6d0;
                  margin-right:0.2em;
                  padding-left:0.2em;
                  padding-right:0.2em;
                  float:right;
               }
               td.normal{
                  text-align:left;
                  vertical-align:top;
                  padding-left:15px;
                  display:block;
               }
               td.indent{
                  text-align:left;
                  vertical-align:top;
                  padding-left:15px;
               }</style>
            </head>
            <body>
                <xsl:apply-templates/>
            </body>
        </html>
    </xsl:template>
    <xsl:template match="concept">
        <table>
         <!-- parents -->
            <tr>
                <td>
                    <table>
                        <tr>
                            <xsl:for-each select="grp[@grp='0']/src[@typeId='116680003'][@active]">
                                <td class="parent">
                                    <a href="{@destinationId}">
                                        <div class="navigate">
                                            <xsl:value-of select="."/>
                                        </div>
                                    </a>
                                </td>
                            </xsl:for-each>
                        </tr>
                        <tr>
                            <xsl:for-each select="grp[@grp='0']/src[@typeId='116680003'][@active]">
                                <td class="vertical-line">
                           |
                        </td>
                            </xsl:for-each>
                        </tr>
                    </table>
                </td>
            </tr>
         <!-- focus concept -->
            <tr>
                <td>
                    <div class="concept">
                        <table>
                            <tr>
                        <!-- name, synonyms -->
                                <td width="40%">
                                   <xsl:choose>
                                      <xsl:when test="@active">
                                         
                                         <span style="font-size:110%;font-weight:bold;">
                                            <xsl:value-of select="desc[@active][@type='fsn']"/>
                                         </span>
                                      </xsl:when>
                                      <xsl:otherwise>
                                         <span style="font-size:110%;font-weight:bold;color:red;">
                                            <xsl:value-of select="desc[@active][@type='fsn']"/> DEPRECATED
                                         </span>
                                      </xsl:otherwise>
                                   </xsl:choose>
                                    <br/>
                                    <xsl:for-each select="desc[@active][@type='pref']">
                                        <span style="font-size:110%;">
                                            <xsl:value-of select="."/>
                                        </span>
                                        <br/>
                                    </xsl:for-each>
                                    <xsl:choose>
                                        <xsl:when test="desc[@active][@type='syn']/@language">
                                            <xsl:for-each-group select="desc[@type='syn']" group-by="@language">
                                                <div class="syn">
                                                    <xsl:for-each select="current-group()">
                                                        <xsl:value-of select="."/>
                                                        <br/>
                                                    </xsl:for-each>
                                                </div>
                                            </xsl:for-each-group>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:if test="desc[@active][@type='syn']">
                                                <div class="syn">
                                                    <xsl:for-each select="desc[@active][@type='syn']">
                                                        <xsl:value-of select="."/>
                                                        <br/>
                                                    </xsl:for-each>
                                                </div>
                                            </xsl:if>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </td>
                                <td width="60%">
                           <!-- id, status -->
                                    <div class="grp">
                                        <table>
                                            <tr>
                                                <td width="40%">
                                                    <xsl:value-of select="'Id'"/>
                                                </td>
                                                <td>
                                                    <xsl:value-of select="@conceptId"/>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td width="40%">
                                                    <xsl:value-of select="'Definition status'"/>
                                                </td>
                                                <td>
                                                    <xsl:value-of select="@definitionStatus"/>
                                                </td>
                                            </tr>
                                        </table>
                                    </div>
                           <!-- group -->
                                    <xsl:for-each select="grp[@grp='0'][src[@active]/@typeId!='116680003']">
                                        <div class="grp">
                                            <table>
                                                <xsl:for-each select="src[@typeId!='116680003'][@active]">
                                                    <tr>
                                                        <td width="40%">
                                                            <xsl:value-of select="@type"/>
                                                        </td>
                                                        <td>
                                                            <a href="{@destinationId}">
                                                                <xsl:value-of select="."/>
                                                            </a>
                                                        </td>
                                                    </tr>
                                                </xsl:for-each>
                                            </table>
                                        </div>
                                    </xsl:for-each>
                           <!-- group -->
                                    <xsl:for-each select="grp[@grp!='0'][src/@active]">
                                        <div class="grp">
                                            <table>
                                                <xsl:for-each select="src[@active]">
                                                    <tr>
                                                        <td width="40%">
                                                            <xsl:value-of select="@type"/>
                                                        </td>
                                                        <td>
                                                            <a href="{@destinationId}">
                                                                <xsl:value-of select="."/>
                                                            </a>
                                                        </td>
                                                    </tr>
                                                </xsl:for-each>
                                            </table>
                                        </div>
                                    </xsl:for-each>
                           <!-- simple refsets -->
                           <!--                                    <xsl:for-each select="refsets/refset">
                                        <div class="refset">
                                            <table>
                                                <tr>
                                                    <td colspan="2">
                                                        <xsl:value-of select="@refset"/>
                                                    </td>
                                                </tr>
                                            </table>
                                        </div>
                                    </xsl:for-each>-->
                           <!-- maps -->
                                    <xsl:for-each-group select="maps/map[@refsetId='447562003']" group-by="@refsetId">
                                        <div class="refset">
                                            <table>
                                                <xsl:choose>
                                                    <xsl:when test="count(current-group())=1 and not(current-group()[1]/@correlation)">
                                                        <tr>
                                                            <td width="40%">
                                                                <xsl:value-of select="@refset"/>
                                                            </td>
                                                            <td>
                                                                <xsl:value-of select="@mapTarget"/>
                                                            </td>
                                                        </tr>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:variable name="id" select="generate-id()"/>
                                                        <xsl:variable name="id-toggler" select="concat($id,'-toggler')"/>
                                                        <tr>
                                                            <td colspan="2" class="toggler" id="{$id-toggler}" onclick="{concat('return toggle(&#34;',$id,'&#34;,&#34;',$id-toggler,'&#34;)')}">
                                                                <xsl:value-of select="@refset"/>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td class="toggle" id="{$id}">
                                                                <xsl:for-each-group select="current-group()" group-by="@mapGroup">
                                                                    <xsl:sort select="current-grouping-key()"/>
                                                                    <div class="refsetGroup">
                                                                        <xsl:for-each select="current-group()">
                                                                            <xsl:sort select="@mapPriority"/>
                                                                            <div class="map-rule">
                                                                                <table>
                                                                                    <tr>
                                                                                        <td width="15%">Target</td>
                                                                                        <td>
                                                                                            <xsl:value-of select="@mapTarget"/>
                                                                                        </td>
                                                                                    </tr>
                                                                                    <xsl:if test="string-length(@mapRule)&gt;0">
                                                                                        <tr>
                                                                                            <td width="15%">Rule</td>
                                                                                            <td>
                                                                                                <xsl:value-of select="@mapRule"/>
                                                                                            </td>
                                                                                        </tr>
                                                                                    </xsl:if>
                                                                                    <xsl:if test="string-length(@mapAdvice)&gt;0">
                                                                                        <tr>
                                                                                            <td width="15%">Advice</td>
                                                                                            <td>
                                                                                                <xsl:value-of select="@mapAdvice"/>
                                                                                            </td>
                                                                                        </tr>
                                                                                    </xsl:if>
                                                                                    <xsl:if test="string-length(@correlation)&gt;0">
                                                                                        <tr>
                                                                                            <td width="15%">Correlation</td>
                                                                                            <td>
                                                                                                <xsl:value-of select="@correlation"/>
                                                                                            </td>
                                                                                        </tr>
                                                                                    </xsl:if>
                                                                                </table>
                                                                            </div>
                                                                        </xsl:for-each>
                                                                    </div>
                                                                </xsl:for-each-group>
                                                            </td>
                                                        </tr>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </table>
                                        </div>
                                    </xsl:for-each-group>
                                </td>
                            </tr>
                        </table>
                    </div>
                </td>
            </tr>
            <xsl:if test="dest[@typeId='116680003'][@active]">
                <tr>
                    <td class="vertical-line">|</td>
                </tr>
            </xsl:if>
         <!-- children -->
            <tr>
                <td>
                    <tr>
                        <xsl:for-each select="dest[@typeId='116680003'][@active]">
                            <tr>
                                <td class="child">
                                    <div class="navigate-child">
                                        <a href="{@sourceId}">
                                            <xsl:value-of select="."/>
                                        </a>
                                        <xsl:if test="@subCount&gt;0">
                                            <span class="subcount">
                                                <xsl:value-of select="@subCount"/>
                                            </span>
                                        </xsl:if>
                                    </div>
                                </td>
                            </tr>
                        </xsl:for-each>
                    </tr>
                </td>
            </tr>
        </table>
    </xsl:template>
</xsl:stylesheet>