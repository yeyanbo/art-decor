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
    <xsl:param name="vocabPath"/>
    <xsl:param name="reference-date" select="''"/>
    <xsl:output method="html" exclude-result-prefixes="#all" encoding="UTF-8"/>
    <xsl:include href="payload2html.xsl"/>
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
                    togglerStyle.backgroundImage = "url(/xis/resources/images/trClosed.gif)";
                    } else {
                    currentStyle.display = "block";
                    togglerStyle.backgroundImage = "url(/xis/resources/images/triangleOpen.gif)";
                    }
                    return false;
                    } else {
                    return true;
                    }
                    }
                </script>
                <script src="/xis/resources/scripts/boxover.js" type="text/javascript"/>
                <link href="/xis/resources/css/nictiz.css" type="text/css" rel="stylesheet"/>
            </head>
            <body>
                <xsl:apply-templates/>
            </body>
        </html>
    </xsl:template>
    <xsl:template match="*[hl7:interactionId]">
        <xsl:choose>
            <xsl:when test="local-name(../.)=local-name(/.)">
                <table width="100%">
                    <tr>
                        <td valign="bottom">
                            <h1>
                                <xsl:variable name="codeValue" select="hl7:interactionId/@extension"/>
                                <xsl:variable name="codeSystem" select="hl7:interactionId/@root"/>
                                <xsl:variable name="displayName" select="if (doc-available(concat($vocabPath,$codeSystem,'.xml'))) then document(concat($vocabPath,$codeSystem,'.xml'))/*/hl7:code[@code=$codeValue]/@displayName else (hl7:interactionId/@root)"/>
                                <xsl:value-of select="$displayName"/>
                            </h1>
                        </td>
                        <td align="right">
                            <div class="logo"/>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2">
                            <p/>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2">Disclaimer: Deze stylesheet en de resulterende html weergave van xml berichten zijn
                            uitsluitend bedoeld voor testdoeleinden. Zij zijn uitdrukkelijk niet bedoeld voor gebruik in de medische praktijk.</td>
                    </tr>
                </table>
                <p/>
                <table class="container" width="100%">
                    <tr>
                        <td class="content">
                            <h2>Transmission Wrapper</h2>
                            <div class="level2">
                                <xsl:apply-templates/>
                            </div>
                        </td>
                    </tr>
                </table>
            </xsl:when>
            <xsl:otherwise>
                <h1>
                    <xsl:variable name="codeValue" select="hl7:interactionId/@extension"/>
                    <xsl:variable name="codeSystem" select="hl7:interactionId/@root"/>
                    <xsl:variable name="displayName" select="if (doc-available(concat($vocabPath,$codeSystem,'.xml'))) then document(concat($vocabPath,$codeSystem,'.xml'))/*/hl7:code[@code=$codeValue]/@displayName else (hl7:interactionId/@root)"/>
                    <xsl:value-of select="$displayName"/>
                </h1>
                <h2>Transmission Wrapper</h2>
                <div class="level2">
                    <xsl:apply-templates/>
                </div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="hl7:creationTime">
        <table class="values">
            <tr>
                <td class="labelSmall">Datum-tijd</td>
                <td class="value">
                    <xsl:call-template name="formatDate">
                        <xsl:with-param name="hl7date" select="@value"/>
                    </xsl:call-template>
                </td>
            </tr>
        </table>
    </xsl:template>
    <xsl:template match="hl7:versionCode">
        <table class="values">
            <tr>
                <td class="labelSmall">Versiecode</td>
                <td class="value">
                    <xsl:value-of select="@code"/>
                </td>
            </tr>
        </table>
    </xsl:template>
    <xsl:template match="hl7:interactionId">
        <table class="values">
            <tr>
                <td class="labelSmall">Interactie id</td>
                <td class="value">
                    <xsl:value-of select="@extension"/>
                </td>
            </tr>
        </table>
    </xsl:template>
    <xsl:template match="hl7:profileId">
        <table class="values">
            <tr>
                <td class="labelSmall">Profile id</td>
                <td class="value">
                    <xsl:value-of select="@extension"/>
                </td>
            </tr>
        </table>
    </xsl:template>
    <xsl:template match="hl7:transmissionQuantity">
        <table class="values">
            <tr>
                <td class="labelSmall">Aantal berichten in batch</td>
                <td class="value">
                    <xsl:value-of select="@value"/>
                </td>
            </tr>
        </table>
    </xsl:template>
    <xsl:template match="hl7:acknowledgement">
        <xsl:call-template name="CodedSimple">
            <xsl:with-param name="label" select="'Acknowledgement'"/>
            <xsl:with-param name="code" select="@typeCode"/>
            <xsl:with-param name="codeSystemOID" select="'2.16.840.1.113883.5.18'"/>
        </xsl:call-template>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="hl7:acknowledgementDetail">
        <table class="values">
            <tr>
                <td class="labelSmall"> Detail code </td>
                <td class="value">
                    <xsl:choose>
                        <xsl:when test="@typeCode='E'">
                            <xsl:text>E : Fout </xsl:text>
                        </xsl:when>
                        <xsl:when test="@typeCode='W'">
                            <xsl:text>W : Waarschuwing </xsl:text>
                        </xsl:when>
                        <xsl:when test="@typeCode='I'">
                            <xsl:text>I : Ter informatie </xsl:text>
                        </xsl:when>
                    </xsl:choose>
                </td>
            </tr>
        </table>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="hl7:attentionLine">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Attention line'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:keyWordText">
        <table class="values">
            <tr>
                <td class="labelSmall"> Key word </td>
                <td class="value">
                    <xsl:value-of select="."/>
                </td>
            </tr>
        </table>
    </xsl:template>
    <xsl:template match="hl7:sender">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Verzender'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:receiver">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Ontvanger'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:ControlActProcess | hl7:controlActProcess">
        <h2>Control Act Wrapper</h2>
        <div class="level2">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="hl7:author | hl7:authorOrPerformer">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Auteur'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:custodian">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Beheerverantwoordelijke'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:authenticator">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Ondertekenaar'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:legalAuthenticator">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Wettelijk ondertekenaar'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:participant">
        <xsl:variable name="participantType">
            <xsl:choose>
                <xsl:when test="@typeCode='HLD'">Verzekerde</xsl:when>
                <xsl:when test="@typeCode='LOC'">Lokatie</xsl:when>
                <xsl:otherwise>Deelnemer</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="$participantType"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:performer">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Uitvoerder'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:responsibleParty">
        <h4>Verantwoordelijke</h4>
        <div class="level2">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="hl7:overseer">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Overseer'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:justifiedDetectedIssue">
        <h4>Detected issue</h4>
        <div class="level2">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="hl7:Patient|hl7:patient|hl7:patientRole">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Patiënt'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:queryAck">
        <table class="section">
            <tr>
                <td class="section-label"> Query Acknowledgement </td>
                <td>
                    <table class="values">
                        <tr>
                            <td class="labelSmall">Query id</td>
                            <td class="value">
                                <xsl:value-of select="concat(hl7:queryId/@root,' - ',hl7:queryId/@extension)"/>
                            </td>
                        </tr>
                        <tr>
                            <td class="labelSmall">Query response code</td>
                            <td class="value">
                                <xsl:choose>
                                    <xsl:when test="hl7:queryResponseCode/@code='OK'">
                                        <xsl:text>OK (Data gevonden)</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="hl7:queryResponseCode/@code='NF'">
                                        <xsl:text>NF (Niets gevonden, geen fouten)</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="hl7:queryResponseCode/@code='AE'">
                                        <xsl:text>AE (Applicatie probleem, beantwoording afgebroken)</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="hl7:queryResponseCode/@code='QE'">
                                        <xsl:text>QE (Query Parameter Error, beantwoording afgebroken)</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="hl7:queryResponseCode/@code"/>
                                        <xsl:text> Onbekende code</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </td>
                        </tr>
                        <tr>
                            <td class="labelSmall">Query total quantity</td>
                            <td class="value">
                                <xsl:value-of select="hl7:resultTotalQuantity/@value"/>
                            </td>
                        </tr>
                        <tr>
                            <td class="labelSmall">Query current quantity</td>
                            <td class="value">
                                <xsl:value-of select="hl7:resultCurrentQuantity/@value"/>
                            </td>
                        </tr>
                        <tr>
                            <td class="labelSmall">Query remaining quantity</td>
                            <td class="value">
                                <xsl:value-of select="hl7:resultRemainingQuantity/@value"/>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
    </xsl:template>
    <xsl:template match="hl7:queryByParameter">
        <table class="section">
            <tr>
                <td class="section-label"> Query by parameter </td>
                <td>
                    <table class="values">
                        <tr>
                            <td class="labelSmall">Query id</td>
                            <td class="value">
                                <xsl:value-of select="concat(hl7:queryId/@root,' - ',hl7:queryId/@extension)"/>
                            </td>
                        </tr>
                        <tr>
                            <td class="labelSmall">Status code</td>
                            <td class="value">
                                <xsl:value-of select="hl7:statusCode/@code"/>
                            </td>
                        </tr>
                        <tr>
                            <td class="labelSmall">Response modality code</td>
                            <td class="value">
                                <xsl:choose>
                                    <xsl:when test="hl7:responseModalityCode/@code='R'">
                                        <xsl:text>R (Realtime)</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="hl7:responseModalityCode/@code='B'">
                                        <xsl:text>B (Batch)</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="hl7:responseModalityCode/@code='T'">
                                        <xsl:text>T (Bolus, niet gebruiken)</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>Onbekende code</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </td>
                        </tr>
                        <tr>
                            <td class="labelSmall">Response priority code</td>
                            <td class="value">
                                <xsl:choose>
                                    <xsl:when test="hl7:responsePriorityCode/@code='I'">
                                        <xsl:text>I (Immediate)</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="hl7:responsePriorityCode/@code='D'">
                                        <xsl:text>D (Deferred)</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>-</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </td>
                        </tr>
                        <tr>
                            <td class="labelSmall">Initial quantity</td>
                            <td class="value">
                                <xsl:value-of select="hl7:initialQuantity/@value"/>
                            </td>
                        </tr>
                        <tr>
                            <td class="labelSmall">Initial quantity code</td>
                            <td class="value">
                                <xsl:choose>
                                    <xsl:when test="hl7:responsPriorityCode/@code='MC'">
                                        <xsl:text>I (Immediate)</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>-</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </td>
                        </tr>
                        <tr>
                            <td class="labelSmall">Execution and delivery time</td>
                            <td class="value">
                                <xsl:call-template name="formatDate">
                                    <xsl:with-param name="hl7date" select="hl7:executionAndDeliveryTime/@value"/>
                                </xsl:call-template>
                            </td>
                        </tr>
                    </table>
                    <table class="values">
                        <xsl:for-each select="*/hl7:value">
                            <tr>
                                <td class="labelSmall">
                                    <xsl:value-of select="local-name(../.)"/>
                                </td>
                                <td class="value">
                                    <xsl:choose>
                                        <xsl:when test="@root and @extension">
                                            <xsl:value-of select="concat(@root,' - ',@extension)"/>
                                        </xsl:when>
                                        <xsl:when test="hl7:low or hl7:high">
                                            <xsl:call-template name="IVL_TS">
                                                <xsl:with-param name="theIVL" select="."/>
                                            </xsl:call-template>
                                        </xsl:when>
                                        <xsl:when test="@value">
                                            <xsl:value-of select="@value"/>
                                        </xsl:when>
                                        <xsl:when test="@code and @codeSystem">
                                            <xsl:variable name="codeValue" select="@code"/>
                                            <xsl:variable name="codeSystem" select="@codeSystem"/>
                                            <xsl:variable name="displayName" select="if (doc-available(concat($vocabPath,$codeSystem,'.xml'))) then document(concat($vocabPath,$codeSystem,'.xml'))/*/hl7:code[@code=$codeValue]/@displayName else (@displayName)"/>
                                            <xsl:value-of select="concat($codeValue,' : ',$displayName)"/>
                                        </xsl:when>
                                    </xsl:choose>
                                </td>
                            </tr>
                        </xsl:for-each>
                    </table>
                </td>
            </tr>
        </table>
    </xsl:template>
    <xsl:template match="hl7:ClinicalDocument">
        <xsl:choose>
            <xsl:when test="local-name(../.)=local-name(/.)">
                <table width="100%">
                    <tr>
                        <td valign="bottom">
                            <h1>
                                <xsl:variable name="codeValue" select="hl7:id/@extension"/>
                                <xsl:variable name="codeSystem" select="hl7:id/@root"/>
                                <xsl:variable name="displayName" select="if (doc-available(concat($vocabPath,$codeSystem,'.xml'))) then document(concat($vocabPath,$codeSystem,'.xml'))/*/hl7:code[@code=$codeValue]/@displayName else (hl7:id/@root)"/>
                                <xsl:value-of select="$displayName"/>
                            </h1>
                        </td>
                        <td align="right">
                            <div class="logo"/>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2">
                            <p/>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2">Disclaimer: Deze stylesheet en de resulterende html weergave van xml berichten zijn
							uitsluitend bedoeld voor testdoeleinden. Zij zijn uitdrukkelijk niet bedoeld voor gebruik in de medische praktijk.</td>
                    </tr>
                </table>
                <p/>
                <table class="container" width="100%">
                    <tr>
                        <td class="content">
                            <h2>ClinicalDocument</h2>
                            <div class="level2">
                                <xsl:apply-templates/>
                            </div>
                        </td>
                    </tr>
                </table>
            </xsl:when>
            <xsl:otherwise>
                <h1>
                    <xsl:variable name="codeValue" select="hl7:id/@extension"/>
                    <xsl:variable name="codeSystem" select="hl7:id/@root"/>
                    <xsl:variable name="displayName" select="if (doc-available(concat($vocabPath,$codeSystem,'.xml'))) then document(concat($vocabPath,$codeSystem,'.xml'))/*/hl7:code[@code=$codeValue]/@displayName else (hl7:id/@root)"/>
                    <xsl:value-of select="$displayName"/>
                </h1>
                <h2>ClinicalDocument</h2>
                <div class="level2">
                    <xsl:apply-templates/>
                </div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>