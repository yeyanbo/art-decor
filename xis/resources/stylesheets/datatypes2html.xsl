<!-- 
    DISCLAIMER
    Deze stylesheet en de resulterende html weergave van xml berichten zijn uitsluitend bedoeld voor testdoeleinden.
    Zij zijn uitdrukkelijk niet bedoeld voor gebruik in de medische praktijk.
    
    Auteur: Gerrit Boers
    Copyright: Nictiz
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" exclude-result-prefixes="hl7" version="2.0">
    <xsl:output method="html"/>
    <!-- Templates op alfabetische volgorde -->
    <xsl:template match="hl7:addr">
        <xsl:variable name="type">
            <xsl:choose>
                <xsl:when test="@use='WP'">
                    <xsl:value-of select="'Werk'"/>
                </xsl:when>
                <xsl:when test="@use='CONF'">
                    <xsl:value-of select="'Geheim'"/>
                </xsl:when>
                <xsl:when test="@use='HP'">
                    <xsl:value-of select="'Officieel'"/>
                </xsl:when>
                <xsl:when test="@use='HP CONF'">
                    <xsl:value-of select="'Officieel (geheim)'"/>
                </xsl:when>
                <xsl:when test="@use='PHYS'">
                    <xsl:value-of select="'Woon/verblijf'"/>
                </xsl:when>
                <xsl:when test="@use='PHYS CONF'">
                    <xsl:value-of select="'Woon/verblijf (geheim)'"/>
                </xsl:when>
                <xsl:when test="@use='TMP PHYS'">
                    <xsl:value-of select="'Bezoek'"/>
                </xsl:when>
                <xsl:when test="@use='HV'">
                    <xsl:value-of select="'Vakantiehuis'"/>
                </xsl:when>
                <xsl:when test="@use='PST'">
                    <xsl:value-of select="'Post/postbus'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@use"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <table class="values">
            <tr>
                <td class="labelSmall">
                    <xsl:choose>
                        <xsl:when test="@use">
                            <xsl:value-of select="concat('Adres (',$type,')')"/>
                        </xsl:when>
                        <xsl:otherwise>Adres</xsl:otherwise>
                    </xsl:choose>
                </td>
                <td>
                    <div>
                        <xsl:value-of select="hl7:streetName"/>
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="hl7:houseNumber"/>
                        <xsl:value-of select="hl7:buildingNumberSuffix"/>
                        <xsl:if test="hl7:additionalLocator">
                            <xsl:text> (</xsl:text>
                            <xsl:value-of select="hl7:additionalLocator"/>)</xsl:if>
                    </div>
                    <div>
                        <xsl:value-of select="hl7:postalCode"/>
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="hl7:city"/>
                    </div>
                    <xsl:if test="hl7:county">
                        <div>
                            <xsl:text>Gemeente </xsl:text>
                            <xsl:choose>
                                <xsl:when test="hl7:county/@code">
                                    <xsl:variable name="codeValue" select="hl7:county/@code"/>
                                    <xsl:variable name="codeSystem" select="hl7:county/@codeSystem"/>
                                    <xsl:variable name="displayName" select="if (doc-available(concat($vocabPath,$codeSystem,'.xml'))) then document(concat($vocabPath,$codeSystem,'.xml'))/*/hl7:code[@code=$codeValue]/@displayName else (hl7:county/@displayName)"/>
                                    <xsl:choose>
                                        <xsl:when test="string-length(hl7:county)&gt;0">
                                            <xsl:value-of select="concat($codeValue,' : ',$displayName,' , ',hl7:county)"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="concat($codeValue,' : ',$displayName)"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="hl7:county"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </div>
                    </xsl:if>
                    <xsl:if test="hl7:country">
                        <div>
                            <xsl:choose>
                                <xsl:when test="hl7:country/@code">
                                    <xsl:variable name="codeValue" select="hl7:country/@code"/>
                                    <xsl:variable name="codeSystem" select="hl7:country/@codeSystem"/>
                                    <xsl:variable name="displayName" select="if (doc-available(concat($vocabPath,$codeSystem,'.xml'))) then document(concat($vocabPath,$codeSystem,'.xml'))/*/hl7:code[@code=$codeValue]/@displayName else (hl7:county/@displayName)"/>
                                    <xsl:choose>
                                        <xsl:when test="string-length(hl7:country)&gt;0">
                                            <xsl:value-of select="concat($codeValue,' : ',$displayName,' , ',hl7:country)"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="concat($codeValue,' : ',$displayName)"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="hl7:country"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </div>
                    </xsl:if>
                    <xsl:if test="hl7:useablePeriod">
                        <div>
                            <xsl:text>Geldig </xsl:text>
                            <xsl:call-template name="IVL_TS">
                                <xsl:with-param name="theIVL" select="hl7:useablePeriod"/>
                            </xsl:call-template>
                        </div>
                    </xsl:if>
                </td>
            </tr>
        </table>
    </xsl:template>
    <xsl:template match="hl7:administrativeGenderCode">
        <table class="values">
            <tr>
                <td class="labelSmall"> Geslacht </td>
                <td class="value">
                    <xsl:choose>
                        <xsl:when test="@code='M'">
                            <xsl:text>Man </xsl:text>
                        </xsl:when>
                        <xsl:when test="@code='F'">
                            <xsl:text>Vrouw </xsl:text>
                        </xsl:when>
                        <xsl:when test="@code='UN'">
                            <xsl:text>Ongedifferentieerd </xsl:text>
                        </xsl:when>
                        <xsl:when test="@nullFlavor">
                            <xsl:text>Onbekend </xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="@code"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </td>
            </tr>
        </table>
    </xsl:template>
    <xsl:template match="hl7:asCitizen/hl7:politicalNation/hl7:code">
        <xsl:call-template name="CodedValue">
            <xsl:with-param name="label" select="'Nationaliteit'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:batchComment">
        <table class="values">
            <tr>
                <td class="labelSmall">Commentaar</td>
                <td class="value">
                    <xsl:value-of select="."/>
                </td>
            </tr>
        </table>
    </xsl:template>
    <xsl:template match="hl7:birthTime">
        <table class="values">
            <tr>
                <td class="labelSmall"> Geboortedatum</td>
                <td class="value">
                    <xsl:call-template name="formatDate">
                        <xsl:with-param name="hl7date">
                            <xsl:value-of select="@value"/>
                        </xsl:with-param>
                    </xsl:call-template>
                </td>
            </tr>
        </table>
    </xsl:template>
    <xsl:template match="hl7:birthplace">
        <table class="values">
            <tr>
                <td class="labelSmall">Geboren te </td>
                <td class="value">
                    <xsl:apply-templates/>
                </td>
            </tr>
        </table>
    </xsl:template>
    <xsl:template match="hl7:code">
        <xsl:call-template name="CodedValue">
            <xsl:with-param name="label" select="'Code'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:confidentialityCode">
        <xsl:call-template name="CodedValue">
            <xsl:with-param name="label" select="'Vertrouwelijkheid'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:desc">
        <table class="values">
            <tr>
                <td class="labelSmall">Omschrijving</td>
                <td class="value">
                    <xsl:value-of select="."/>
                </td>
            </tr>
        </table>
    </xsl:template>
    <xsl:template match="hl7:doseQuantity">
        <table class="values">
            <tr>
                <td class="labelSmall">Dosis</td>
                <td class="value">
                    <xsl:choose>
                        <xsl:when test="hl7:center">
                            <xsl:value-of select="hl7:center/@value"/>
                            <xsl:choose>
                                <xsl:when test="(not(hl7:center/@unit) or hl7:center/@unit='1') and hl7:center/@value&lt;=1"> Eenheid</xsl:when>
                                <xsl:when test="(not(hl7:center/@unit) or hl7:center/@unit='1') and hl7:center/@value&gt;1"> Eenheden</xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="concat(' ' ,hl7:center/@unit)"/>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:for-each select="hl7:center/hl7:translation">
                                <br/>
                                <xsl:choose>
                                    <xsl:when test="@codeSystem='2.16.840.1.113883.2.4.4.1.900.2'">
                                        <xsl:value-of select="concat(@value,' ' ,@displayName,' (G-Standaard code ',@code,')')"/>
                                    </xsl:when>
                                    <xsl:when test="@codeSystem='2.16.840.1.113883.2.4.4.1.361'">
                                        <xsl:value-of select="concat(@value,' ' ,@displayName,' (Tabel 25 code ',@code,')')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="concat(@value,' ' ,@displayName,' ( ',@codeSystem,' ',@code,')')"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:when test="hl7:low">
                            <xsl:value-of select="hl7:low/@value"/>
                            <xsl:text> - </xsl:text>
                            <xsl:value-of select="hl7:high/@value"/>
                            <xsl:choose>
                                <xsl:when test="not(hl7:low/@unit) or hl7:low/@unit='1'"> Eenheden</xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="concat(' ' ,hl7:low/@unit)"/>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:for-each select="hl7:low/hl7:translation">
                                <br/>
                                <xsl:choose>
                                    <xsl:when test="@codeSystem='2.16.840.1.113883.2.4.4.1.900.2'">
                                        <xsl:value-of select="concat(../../hl7:low/@value,' - ',../../hl7:high/@value,' ' ,@displayName,' (G-Standaard code ',@code,')')"/>
                                    </xsl:when>
                                    <xsl:when test="@codeSystem='2.16.840.1.113883.2.4.4.1.361'">
                                        <xsl:value-of select="concat(../../hl7:low/@value,' - ',../../hl7:high/@value,' ' ,@displayName,' (Tabel 25 code ',@code,')')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="concat(../../hl7:low/@value,' - ',../../hl7:high/@value,' ' ,@displayName,' ( ',@codeSystem,' ',@code,')')"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each>
                        </xsl:when>
                    </xsl:choose>
                </td>
            </tr>
        </table>
    </xsl:template>
    <xsl:template match="hl7:educationLevelCode">
        <xsl:call-template name="CodedValue">
            <xsl:with-param name="label" select="'Code opleiding'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:effectiveTime">
        <table class="values">
            <tr>
                <td class="labelSmall">Datum</td>
                <td class="value">
                    <xsl:call-template name="IVL_TS">
                        <xsl:with-param name="theIVL" select="self::node()"/>
                    </xsl:call-template>
                </td>
            </tr>
        </table>
    </xsl:template>
    <xsl:template match="hl7:*[string(@xsi:type)='IVL_TS']">
        <table class="values">
            <tr>
                <td class="labelSmall">Periode</td>
                <td class="value">
                    <xsl:call-template name="IVL_TS">
                        <xsl:with-param name="theIVL" select="."/>
                    </xsl:call-template>
                </td>
            </tr>
        </table>
    </xsl:template>
    <xsl:template match="hl7:*[string(@xsi:type)='PIVL_TS']">
        <table class="values">
            <tr>
                <td class="labelSmall">Tijdschema</td>
                <td class="value">
                    <xsl:call-template name="PIVL_TS">
                        <xsl:with-param name="thePIVL" select="."/>
                    </xsl:call-template>
                </td>
            </tr>
        </table>
    </xsl:template>
    <xsl:template match="hl7:*[string(@xsi:type)='SXPR_TS']">
        <table class="values">
            <tr>
                <td class="labelSmall">Tijdschema</td>
                <td class="value">
                    <xsl:for-each select="hl7:comp">
                        <xsl:choose>
                            <xsl:when test="string(@xsi:type)='IVL_TS'">
                                <xsl:call-template name="IVL_TS">
                                    <xsl:with-param name="theIVL" select="."/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="string(@xsi:type)='PIVL_TS'">
                                <xsl:call-template name="PIVL_TS">
                                    <xsl:with-param name="thePIVL" select="."/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="string(@xsi:type)='SXPR_TS'">
                                <xsl:call-template name="SXPR_TS">
                                    <xsl:with-param name="theSXPR_TS" select="."/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>Niet ondersteund componenttype '</xsl:text>
                                <xsl:value-of select="@xsi:type"/>
                                <xsl:text>'</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="following-sibling::hl7:comp[@operator]">
                            <xsl:choose>
                                <xsl:when test="following-sibling::hl7:comp[@operator='A']">
                                    <xsl:text> intersectie </xsl:text>
                                </xsl:when>
                                <xsl:when test="following-sibling::hl7:comp[@operator='E']">
                                    <xsl:text> behalve </xsl:text>
                                </xsl:when>
                                <xsl:when test="following-sibling::hl7:comp[@operator='H']">
                                    <xsl:text> convex hull </xsl:text>
                                </xsl:when>
                                <xsl:when test="following-sibling::hl7:comp[@operator='I']">
                                    <xsl:text> en </xsl:text>
                                </xsl:when>
                                <xsl:when test="following-sibling::hl7:comp[@operator='P']">
                                    <xsl:text> periodic hull </xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="following-sibling::hl7:comp/@operator"/>
                                    <xsl:text> (onbekend type operator)</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:if>
                        <xsl:if test="following-sibling::hl7:comp">
                            <br/>
                        </xsl:if>
                    </xsl:for-each>
                </td>
            </tr>
        </table>
    </xsl:template>
    <xsl:template match="hl7:functionCode">
        <xsl:call-template name="CodedValue">
            <xsl:with-param name="label" select="'Functie'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:expectedUseTime">
        <table class="values">
            <tr>
                <td class="labelSmall">Verwacht gebruik</td>
                <td class="value">
                    <xsl:call-template name="IVL_TS">
                        <xsl:with-param name="theIVL" select="."/>
                    </xsl:call-template>
                </td>
            </tr>
        </table>
    </xsl:template>
    <xsl:template match="hl7:id">
        <table class="values">
            <tr>
                <xsl:choose>
                    <xsl:when test="parent::hl7:ClinicalDocument">
                        <td class="labelSmall">Document-id</td>
                        <td class="value">
                            <xsl:value-of select="concat(@root,' - ',@extension)"/>
                        </td>
                    </xsl:when>
                    <xsl:when test="../hl7:versionCode">
                        <td class="labelSmall">Bericht-id</td>
                        <td class="value">
                            <xsl:value-of select="concat(@root,' - ',@extension)"/>
                        </td>
                    </xsl:when>
                    <xsl:when test="local-name(..)='targetMessage'">
                        <td class="labelSmall">Doelbericht-id</td>
                        <td class="value">
                            <xsl:value-of select="concat(@root,' - ',@extension)"/>
                        </td>
                    </xsl:when>
                    <xsl:when test="local-name(..)='targetTransmission'">
                        <td class="labelSmall">Doeltransmissie-id</td>
                        <td class="value">
                            <xsl:value-of select="concat(@root,' - ',@extension)"/>
                        </td>
                    </xsl:when>
                    <xsl:when test="@root='2.16.840.1.113883.2.4.6.6'">
                        <td class="labelSmall">Applicatie-id</td>
                        <td class="value">
                            <xsl:value-of select="@extension"/>
                        </td>
                    </xsl:when>
                    <xsl:when test="@root='2.16.528.1.1007.3.1'">
                        <td class="labelSmall">UZI</td>
                        <td class="value">
                            <xsl:value-of select="@extension"/>
                        </td>
                    </xsl:when>
                    <xsl:when test="@root='2.16.528.1.1007.3.2'">
                        <td class="labelSmall">Systeemcertificaat-id</td>
                        <td class="value">
                            <xsl:value-of select="@extension"/>
                        </td>
                    </xsl:when>
                    <xsl:when test="@root='2.16.528.1.1007.3.3'">
                        <td class="labelSmall">URA</td>
                        <td class="value">
                            <xsl:value-of select="@extension"/>
                        </td>
                    </xsl:when>
                    <xsl:when test="@root='2.16.840.1.113883.2.4.6.1'">
                        <td class="labelSmall">Vektis AGB-Z</td>
                        <td class="value">
                            <xsl:value-of select="@extension"/>
                        </td>
                    </xsl:when>
                    <xsl:when test="@root='2.16.840.1.113883.2.4.6.3'">
                        <td class="labelSmall">BSN</td>
                        <td class="value">
                            <xsl:value-of select="@extension"/>
                        </td>
                    </xsl:when>
                    <xsl:otherwise>
                        <td class="labelSmall">id</td>
                        <td class="value">
                            <xsl:value-of select="concat(@root,' - ',@extension)"/>
                            <xsl:if test="@assigningAuthorityName"> (<xsl:value-of select="@assigningAuthorityName"/>)</xsl:if>
                        </td>
                    </xsl:otherwise>
                </xsl:choose>
            </tr>
        </table>
    </xsl:template>
    <xsl:template match="hl7:interpretationCode">
        <xsl:call-template name="CodedValue">
            <xsl:with-param name="label" select="'Interpretatiecode'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:languageCode">
        <table class="values">
            <tr>
                <td class="labelSmall">Taal</td>
                <td class="value">
                    <xsl:value-of select="@code"/>
                </td>
            </tr>
        </table>
    </xsl:template>
    <xsl:template match="hl7:lotNumberText">
        <table class="values">
            <tr>
                <td class="labelSmall">Partijnummer</td>
                <td class="value">
                    <xsl:value-of select="."/>
                </td>
            </tr>
        </table>
    </xsl:template>
    <xsl:template match="hl7:methodCode">
        <xsl:call-template name="CodedValue">
            <xsl:with-param name="label" select="'Methode'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:multipleBirthInd">
        <table class="values">
            <tr>
                <td class="labelSmall">Meerling</td>
                <td class="value">
                    <xsl:choose>
                        <xsl:when test="@value='true'">Ja</xsl:when>
                        <xsl:otherwise>Nee</xsl:otherwise>
                    </xsl:choose>
                </td>
            </tr>
        </table>
    </xsl:template>
    <xsl:template match="hl7:multipleBirthOrderNumber">
        <table class="values">
            <tr>
                <td class="labelSmall">Meerlingvolgnummer</td>
                <td class="value">
                    <xsl:value-of select="@value"/>
                </td>
            </tr>
        </table>
    </xsl:template>
    <xsl:template match="hl7:name">
        <xsl:choose>
            <xsl:when test="not(*)">
                <table class="values">
                    <tr>
                        <td class="labelSmall">
                            <xsl:choose>
                                <xsl:when test="local-name(..)='device' or local-name(..)='AssignedDevice'">Applicatie</xsl:when>
                                <xsl:when test="local-name(..)='Organization' or local-name(..)='representedOrganization'">Organisatie</xsl:when>
                                <xsl:otherwise>Naam</xsl:otherwise>
                            </xsl:choose>
                        </td>
                        <td class="value">
                            <xsl:value-of select="."/>
                        </td>
                    </tr>
                </table>
            </xsl:when>
            <xsl:otherwise>
                <table class="values">
                    <tr>
                        <td class="labelSmall"> Naam </td>
                        <td class="value">
                            <xsl:for-each select="*">
                                <xsl:variable name="namepart" select="."/>
                                <xsl:value-of select="concat($namepart,' ')"/>
                            </xsl:for-each>
                        </td>
                    </tr>
                </table>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="hl7:occupationCode">
        <xsl:call-template name="CodedValue">
            <xsl:with-param name="label" select="'Code beroep'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:priorityCode">
        <xsl:call-template name="CodedValue">
            <xsl:with-param name="label" select="'Prioriteit'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:quantity">
        <table class="values">
            <tr>
                <td class="labelSmall">Hoeveelheid</td>
                <td class="value">
                    <xsl:value-of select="@value"/>
                    <xsl:choose>
                        <xsl:when test="(not(@unit) or @unit='1') and @value=1"> Eenheid</xsl:when>
                        <xsl:when test="(not(@unit) or @unit='1') and @value&gt;1"> Eenheden</xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat(' ' ,@unit)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:for-each select="hl7:translation">
                        <br/>
                        <xsl:choose>
                            <xsl:when test="@codeSystem='2.16.840.1.113883.2.4.4.1.900.2'">
                                <xsl:value-of select="concat(@value,' ' ,@displayName,' (G-Standaard code ',@code,')')"/>
                            </xsl:when>
                            <xsl:when test="@codeSystem='2.16.840.1.113883.2.4.4.1.361'">
                                <xsl:value-of select="concat(@value,' ' ,@displayName,' (Tabel 25 code ',@code,')')"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="concat(@value,' ' ,@displayName,' (',@codeSystem,' ',@code,')')"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </td>
            </tr>
        </table>
    </xsl:template>
    <xsl:template match="hl7:reasonCode">
        <xsl:call-template name="CodedValue">
            <xsl:with-param name="label" select="'Reden'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:statusCode">
        <table class="values">
            <tr>
                <td class="labelSmall">Status</td>
                <td class="value">
                    <xsl:choose>
                        <xsl:when test="@code='active'">Actief</xsl:when>
                        <xsl:when test="@code='completed'">Afgerond</xsl:when>
                        <xsl:when test="@code='nullified'">Opgeheven</xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="@code"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </td>
            </tr>
        </table>
    </xsl:template>
    <xsl:template match="hl7:targetSiteCode">
        <xsl:call-template name="CodedValue">
            <xsl:with-param name="label" select="'Locatie'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:telecom">
        <xsl:variable name="what">
            <xsl:choose>
                <xsl:when test="substring-before(@value,':')='tel'">
                    <xsl:value-of select="'Telefoon'"/>
                </xsl:when>
                <xsl:when test="substring-before(@value,':')='mailto'">
                    <xsl:value-of select="'E-mail'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="substring-before(@value,':')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="type">
            <xsl:choose>
                <xsl:when test="@use='WP'">
                    <xsl:value-of select="'Werk'"/>
                </xsl:when>
                <xsl:when test="@use='HP'">
                    <xsl:value-of select="'Thuis'"/>
                </xsl:when>
                <xsl:when test="@use='MC'">
                    <xsl:value-of select="'Mobiel'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@use"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <table class="values">
            <tr>
                <td class="labelSmall">
                    <xsl:value-of select="concat($what,' (',$type,')')"/>
                </td>
                <td class="value">
                    <xsl:value-of select="substring-after(@value,':')"/>
                </td>
            </tr>
        </table>
    </xsl:template>
    <xsl:template match="hl7:text">
        <table class="values">
            <tr>
                <td class="labelSmall">Tekst</td>
                <td class="value">
                    <xsl:copy-of select="."/>
                </td>
            </tr>
        </table>
    </xsl:template>
    <xsl:template match="hl7:realmCode">
        <table class="values">
            <tr>
                <td class="labelSmall">Realmcode</td>
                <td class="value">
                    <xsl:value-of select="@code"/>
                </td>
            </tr>
        </table>
    </xsl:template>
    <xsl:template match="hl7:setId">
        <table class="values">
            <tr>
                <td class="labelSmall">Set-id</td>
                <td class="value">
                    <xsl:value-of select="concat(@root,' - ',@extension)"/>
                </td>
            </tr>
        </table>
    </xsl:template>
    <xsl:template match="hl7:templateId">
        <table class="values">
            <tr>
                <td class="labelSmall">Template-id</td>
                <td class="value">
                    <xsl:value-of select="@root"/>
                    <xsl:if test="@extension">
                        <xsl:value-of select="concat(' - ',@extension)"/>
                    </xsl:if>
                </td>
            </tr>
        </table>
    </xsl:template>
    <xsl:template match="hl7:time">
        <table class="values">
            <tr>
                <td class="labelSmall">Datum</td>
                <td class="value">
                    <xsl:call-template name="formatDate">
                        <xsl:with-param name="hl7date">
                            <xsl:value-of select="@value"/>
                        </xsl:with-param>
                    </xsl:call-template>
                </td>
            </tr>
        </table>
    </xsl:template>
    <xsl:template match="hl7:title">
        <table class="values">
            <tr>
                <td class="labelSmall">Titel</td>
                <td class="value">
                    <xsl:value-of select="."/>
                </td>
            </tr>
        </table>
    </xsl:template>
    <xsl:template match="hl7:value">
        <xsl:choose>
            <!-- Check if nullFlavor -->
            <xsl:when test="@nullFlavor">
                <table class="values">
                    <tr>
                        <td class="labelSmall">Waarde </td>
                        <td class="value">
                            <xsl:call-template name="CodedSimple">
                                <xsl:with-param name="label" select="'NullFlavor'"/>
                                <xsl:with-param name="code" select="@nullFlavor"/>
                                <xsl:with-param name="codeSystemOID" select="'2.16.840.1.113883.5.1008'"/>
                            </xsl:call-template>
                        </td>
                        <xsl:if test="hl7:originalText">
                            <td class="value">
                                <xsl:value-of select="hl7:originalText"/>
                            </td>
                        </xsl:if>
                    </tr>
                </table>
            </xsl:when>
            <!-- Check if coded value -->
            <xsl:when test="string(@xsi:type)='CV' or string(@xsi:type)='CD' or string(@xsi:type)='CE' or (@code and @codeSystem)">
                <xsl:call-template name="CodedValue">
                    <xsl:with-param name="label" select="'Waarde'"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <table class="values">
                    <tr>
                        <td class="labelSmall">Waarde </td>
                        <td class="value">
                            <xsl:choose>
                                <!-- boolean -->
                                <xsl:when test="@value='true' or @value='false'">
                                    <xsl:choose>
                                        <xsl:when test="@value='true'">Ja</xsl:when>
                                        <xsl:when test="@value='false'">Nee</xsl:when>
                                    </xsl:choose>
                                </xsl:when>
                                <!-- PQ -->
                                <xsl:when test="string(@xsi:type)='PQ' or (@value and @unit)">
                                    <xsl:value-of select="@value"/>
                                    <xsl:choose>
                                        <xsl:when test="(not(@unit) or @unit='1') and @value=1"> Eenheid</xsl:when>
                                        <xsl:when test="(not(@unit) or @unit='1') and @value&gt;1"> Eenheden</xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="concat(' ' ,@unit)"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:when>
                                <!-- IVL_PQ -->
                                <xsl:when test="string(@xsi:type)='IVL_PQ' or hl7:low or hl7:high or hl7:center">
                                    <!-- type of interval -->
                                    <xsl:choose>
                                        <!-- center -->
                                        <xsl:when test="hl7:center">
                                            <xsl:value-of select="hl7:center/@value"/>
                                            <xsl:choose>
                                                <xsl:when test="(not(hl7:center/@unit) or hl7:center/@unit='1') and hl7:center/@value=1"> Eenheid</xsl:when>
                                                <xsl:when test="(not(hl7:center/@unit) or hl7:center/@unit='1') and hl7:center/@value&gt;1"> Eenheden</xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="concat(' ' ,@unit)"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:when>
                                        <!-- low and high -->
                                        <xsl:when test="hl7:low and hl7:high">
                                            <table>
                                                <tr>
                                                    <td class="labelSmall">Ondergrens</td>
                                                    <td class="value">
                                                        <xsl:value-of select="hl7:low/@value"/>
                                                        <xsl:choose>
                                                            <xsl:when test="(not(hl7:low/@unit) or hl7:low/@unit='1') and hl7:low/@value=1"> Eenheid</xsl:when>
                                                            <xsl:when test="(not(hl7:low/@unit) or hl7:low/@unit='1') and hl7:low/@value&gt;1"> Eenheden</xsl:when>
                                                            <xsl:otherwise>
                                                                <xsl:value-of select="concat(' ' ,hl7:low/@unit)"/>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td class="labelSmall">Bovengrens</td>
                                                    <td class="value">
                                                        <xsl:value-of select="hl7:high/@value"/>
                                                        <xsl:choose>
                                                            <xsl:when test="(not(hl7:high/@unit) or hl7:high/@unit='1') and hl7:high/@value=1"> Eenheid</xsl:when>
                                                            <xsl:when test="(not(hl7:high/@unit) or hl7:high/@unit='1') and hl7:high/@value&gt;1"> Eenheden</xsl:when>
                                                            <xsl:otherwise>
                                                                <xsl:value-of select="concat(' ' ,hl7:high/@unit)"/>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    </td>
                                                </tr>
                                            </table>
                                        </xsl:when>
                                        <!-- low only -->
                                        <xsl:when test="hl7:low and not(hl7:high)">
                                            <table>
                                                <tr>
                                                    <xsl:choose>
                                                        <xsl:when test="hl7:low/@inclusive='true'">
                                                            <td class="labelSmall">Groter of gelijk aan</td>
                                                        </xsl:when>
                                                        <xsl:when test="hl7:low/@inclusive='false'">
                                                            <td class="labelSmall">Groter dan</td>
                                                        </xsl:when>
                                                    </xsl:choose>
                                                    <td class="value">
                                                        <xsl:value-of select="hl7:low/@value"/>
                                                        <xsl:choose>
                                                            <xsl:when test="(not(hl7:low/@unit) or hl7:low/@unit='1') and hl7:low/@value=1"> Eenheid</xsl:when>
                                                            <xsl:when test="(not(hl7:low/@unit) or hl7:low/@unit='1') and hl7:low/@value&gt;1"> Eenheden</xsl:when>
                                                            <xsl:otherwise>
                                                                <xsl:value-of select="concat(' ' ,hl7:low/@unit)"/>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    </td>
                                                </tr>
                                            </table>
                                        </xsl:when>
                                        <!-- high only -->
                                        <xsl:when test="hl7:high and not(hl7:low)">
                                            <table>
                                                <tr>
                                                    <xsl:choose>
                                                        <xsl:when test="hl7:high/@inclusive='true'">
                                                            <td class="labelSmall">Kleiner of gelijk aan</td>
                                                        </xsl:when>
                                                        <xsl:when test="hl7:high/@inclusive='false'">
                                                            <td class="labelSmall">Kleiner dan</td>
                                                        </xsl:when>
                                                    </xsl:choose>
                                                    <td class="value">
                                                        <xsl:value-of select="hl7:high/@value"/>
                                                        <xsl:choose>
                                                            <xsl:when test="(not(hl7:high/@unit) or hl7:high/@unit='1') and hl7:high/@value=1"> Eenheid</xsl:when>
                                                            <xsl:when test="(not(hl7:high/@unit) or hl7:high/@unit='1') and hl7:high/@value&gt;1"> Eenheden</xsl:when>
                                                            <xsl:otherwise>
                                                                <xsl:value-of select="concat(' ' ,hl7:high/@unit)"/>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    </td>
                                                </tr>
                                            </table>
                                        </xsl:when>
                                    </xsl:choose>
                                </xsl:when>
                                <!-- INT -->
                                <xsl:when test="string(@xsi:type)='INT'">
                                    <xsl:value-of select="@value"/>
                                </xsl:when>
                                <!-- II -->
                                <xsl:when test="string(@xsi:type)='II'">
                                    <xsl:value-of select="concat(@root,'-',@extension)"/>
                                </xsl:when>
                                <!-- TS -->
                                <xsl:when test="string(@xsi:type)='TS'">
                                    <xsl:call-template name="formatDate">
                                        <xsl:with-param name="hl7date">
                                            <xsl:value-of select="@value"/>
                                        </xsl:with-param>
                                    </xsl:call-template>
                                </xsl:when>
                                <!-- content in element -->
                                <xsl:otherwise>
                                    <xsl:value-of select="."/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                    </tr>
                </table>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="hl7:versionNumber">
        <table class="values">
            <tr>
                <td class="labelSmall">Versienummer</td>
                <td class="value">
                    <xsl:value-of select="@value"/>
                </td>
            </tr>
        </table>
    </xsl:template>
    <!-- Named templates voor afhandeling van datatypes -->
    <xsl:template name="formatDate">
        <xsl:param name="hl7date"/>
        <xsl:choose>
            <!-- Must be valid HL7 date yyyy... to format -->
            <xsl:when test="matches($hl7date,'^\d+(\.\d+)?([+-]\d*)?$')">
                <xsl:variable name="year" select="substring($hl7date,1,4)"/>
                <xsl:variable name="month" select="substring($hl7date,5,2)"/>
                <xsl:variable name="day" select="substring($hl7date,7,2)"/>
                <xsl:variable name="hours" select="substring($hl7date,9,2)"/>
                <xsl:variable name="minutes" select="substring($hl7date,11,2)"/>
                <xsl:choose>
                    <xsl:when test="string-length($minutes) &gt; 0">
                        <xsl:value-of select="concat($day,'-',$month,'-',$year,' om ',$hours,':',$minutes,'u')"/>
                    </xsl:when>
                    <xsl:when test="string-length($hours) &gt; 0">
                        <xsl:value-of select="concat($day,'-',$month,'-',$year,' om ',$hours,'u')"/>
                    </xsl:when>
                    <xsl:when test="(string-length($month) &gt; 0) and (string-length($day)=0)">
                        <xsl:value-of select="concat($month,'-',$year)"/>
                    </xsl:when>
                    <xsl:when test="string-length($day) &gt; 0">
                        <xsl:value-of select="concat($day,'-',$month,'-',$year)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$year"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$hl7date"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="formatPeriod">
        <xsl:param name="theValue"/>
        <xsl:param name="theUnit"/>
        <xsl:choose>
            <xsl:when test="$theValue &lt;= 1">
                <!-- correctie voor period.value kleiner 1 -> door ronden van 1/n op hele getal -->
                <xsl:value-of select="round(round(100000 div $theValue div 100) div 1000)"/>
                <xsl:text> maal per </xsl:text>
            </xsl:when>
            <xsl:when test="$theValue &gt; 1">
                <!-- 1 maal per value -->
                <xsl:text>1 maal per </xsl:text>
                <xsl:value-of select="$theValue"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- in alle anderen gevallen gaat het zo goed -->
                <!--                <xsl:value-of
                    select="round(100000 div $theValue div 100) div 1000"
                    />-->
            </xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
            <xsl:when test="$theUnit='s'">seconde</xsl:when>
            <xsl:when test="$theUnit='min'">minuut</xsl:when>
            <xsl:when test="$theUnit='h'">uur</xsl:when>
            <xsl:when test="$theUnit='d'">dag</xsl:when>
            <xsl:when test="$theUnit='wk'">week</xsl:when>
            <xsl:when test="$theUnit='mo'">maand</xsl:when>
            <xsl:when test="$theUnit='a'">jaar</xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$theUnit"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="formatTime">
        <xsl:param name="hl7date"/>
        <xsl:choose>
            <!-- Must be valid HL7 date yyyy... to format -->
            <xsl:when test="matches($hl7date,'^\d+(\.\d+)?([+-]\d*)?$')">
                <xsl:variable name="hours" select="substring($hl7date,9,2)"/>
                <xsl:variable name="minutes" select="substring($hl7date,11,2)"/>
                <xsl:choose>
                    <xsl:when test="string-length($minutes) &gt; 0">
                        <xsl:value-of select="concat($hours,':',$minutes,'u')"/>
                    </xsl:when>
                    <xsl:when test="string-length($hours) &gt; 0">
                        <xsl:value-of select="concat($hours,'u')"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$hl7date"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="getPeriod">
        <xsl:param name="theValue"/>
        <xsl:param name="theUnit"/>
        <xsl:choose>
            <xsl:when test="$theValue &lt;= 1">
                <xsl:choose>
                    <xsl:when test="$theUnit='s'">seconde</xsl:when>
                    <xsl:when test="$theUnit='min'">minuut</xsl:when>
                    <xsl:when test="$theUnit='h'">uur</xsl:when>
                    <xsl:when test="$theUnit='d'">dag</xsl:when>
                    <xsl:when test="$theUnit='wk'">week</xsl:when>
                    <xsl:when test="$theUnit='mo'">maand</xsl:when>
                    <xsl:when test="$theUnit='a'">jaar</xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="$theUnit and $theUnit != 1 and $theUnit != ''">
                            <xsl:value-of select="$theUnit"/>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$theUnit='s'">seconden</xsl:when>
                    <xsl:when test="$theUnit='min'">minuten</xsl:when>
                    <xsl:when test="$theUnit='h'">uur</xsl:when>
                    <xsl:when test="$theUnit='d'">dagen</xsl:when>
                    <xsl:when test="$theUnit='wk'">weken</xsl:when>
                    <xsl:when test="$theUnit='mo'">maanden</xsl:when>
                    <xsl:when test="$theUnit='a'">jaren</xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="$theUnit and $theUnit != 1 and $theUnit != ''">
                            <xsl:value-of select="$theUnit"/>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="IVL_TS">
        <xsl:param name="theIVL"/>
        <xsl:choose>
            <xsl:when test="$theIVL/@value">
                <xsl:call-template name="formatDate">
                    <xsl:with-param name="hl7date">
                        <xsl:value-of select="$theIVL/@value"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$theIVL/hl7:low and not($theIVL/hl7:high)">
                <xsl:text>Vanaf </xsl:text>
                <xsl:call-template name="formatDate">
                    <xsl:with-param name="hl7date">
                        <xsl:value-of select="$theIVL/hl7:low/@value"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$theIVL/hl7:center">
                <xsl:choose>
                    <xsl:when test="string-length($theIVL/hl7:center/@value) &gt; 8">
                        <xsl:text>Om </xsl:text>
                        <xsl:call-template name="formatTime">
                            <xsl:with-param name="hl7date">
                                <xsl:value-of select="$theIVL/hl7:center/@value"/>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>Op </xsl:text>
                        <xsl:call-template name="formatDate">
                            <xsl:with-param name="hl7date">
                                <xsl:value-of select="$theIVL/hl7:center/@value"/>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$theIVL/hl7:low and $theIVL/hl7:high and substring($theIVL/hl7:low/@value,1,8)=substring($theIVL/hl7:high/@value,1,8)">
                <xsl:text>Op </xsl:text>
                <xsl:call-template name="formatDate">
                    <xsl:with-param name="hl7date">
                        <xsl:value-of select="substring($theIVL/hl7:low/@value,1,8)"/>
                    </xsl:with-param>
                </xsl:call-template>
                <xsl:text> van </xsl:text>
                <xsl:call-template name="formatTime">
                    <xsl:with-param name="hl7date">
                        <xsl:value-of select="$theIVL/hl7:low/@value"/>
                    </xsl:with-param>
                </xsl:call-template>
                <xsl:text> tot </xsl:text>
                <xsl:call-template name="formatTime">
                    <xsl:with-param name="hl7date">
                        <xsl:value-of select="$theIVL/hl7:high/@value"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$theIVL/hl7:low and $theIVL/hl7:high">
                <xsl:text>Van </xsl:text>
                <xsl:call-template name="formatDate">
                    <xsl:with-param name="hl7date">
                        <xsl:value-of select="$theIVL/hl7:low/@value"/>
                    </xsl:with-param>
                </xsl:call-template>
                <xsl:text> tot </xsl:text>
                <xsl:call-template name="formatDate">
                    <xsl:with-param name="hl7date">
                        <xsl:value-of select="$theIVL/hl7:high/@value"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$theIVL/hl7:high">
                <xsl:text>Tot </xsl:text>
                <xsl:call-template name="formatDate">
                    <xsl:with-param name="hl7date">
                        <xsl:value-of select="$theIVL/hl7:high/@value"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
        <xsl:if test="$theIVL/hl7:width">
            <xsl:text> voor </xsl:text>
            <xsl:value-of select="$theIVL/hl7:width/@value"/>
            <xsl:text> </xsl:text>
            <xsl:call-template name="getPeriod">
                <xsl:with-param name="theValue">
                    <xsl:value-of select="$theIVL/hl7:width/@value"/>
                </xsl:with-param>
                <xsl:with-param name="theUnit">
                    <xsl:value-of select="$theIVL/hl7:width/@unit"/>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    <xsl:template name="PIVL_TS">
        <xsl:param name="thePIVL"/>
        <xsl:choose>
            <xsl:when test="$thePIVL/hl7:phase">
                <xsl:call-template name="IVL_TS">
                    <xsl:with-param name="theIVL" select="$thePIVL/hl7:phase"/>
                </xsl:call-template>
                <xsl:text> elke </xsl:text>
                <xsl:if test="$thePIVL/hl7:period/@value != 1">
                    <xsl:value-of select="$thePIVL/hl7:period/@value"/>
                    <xsl:text> </xsl:text>
                </xsl:if>
                <xsl:call-template name="getPeriod">
                    <xsl:with-param name="theValue">
                        <xsl:value-of select="$thePIVL/hl7:period/@value"/>
                    </xsl:with-param>
                    <xsl:with-param name="theUnit">
                        <xsl:value-of select="$thePIVL/hl7:period/@unit"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="formatPeriod">
                    <xsl:with-param name="theValue">
                        <xsl:value-of select="$thePIVL/hl7:period/@value"/>
                    </xsl:with-param>
                    <xsl:with-param name="theUnit">
                        <xsl:value-of select="$thePIVL/hl7:period/@unit"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="SXPR_TS">
        <xsl:param name="theSXPR_TS"/>
        <xsl:for-each select="hl7:comp">
            <xsl:choose>
                <xsl:when test="string(@xsi:type)='IVL_TS'">
                    <xsl:call-template name="IVL_TS">
                        <xsl:with-param name="theIVL" select="."/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="string(@xsi:type)='PIVL_TS'">
                    <xsl:call-template name="PIVL_TS">
                        <xsl:with-param name="thePIVL" select="."/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="@xsi:type='SXPR_TS'">
                    <xsl:call-template name="SXPR_TS">
                        <xsl:with-param name="theSXPR_TS" select="."/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>Niet ondersteund componenttype '</xsl:text>
                    <xsl:value-of select="@xsi:type"/>
                    <xsl:text>'</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="following-sibling::hl7:comp[@operator]">
                <xsl:choose>
                    <xsl:when test="following-sibling::hl7:comp[@operator='A']">
                        <xsl:text> intersectie </xsl:text>
                    </xsl:when>
                    <xsl:when test="following-sibling::hl7:comp[@operator='E']">
                        <xsl:text> behalve </xsl:text>
                    </xsl:when>
                    <xsl:when test="following-sibling::hl7:comp[@operator='H']">
                        <xsl:text> convex hull </xsl:text>
                    </xsl:when>
                    <xsl:when test="following-sibling::hl7:comp[@operator='I']">
                        <xsl:text> en </xsl:text>
                    </xsl:when>
                    <xsl:when test="following-sibling::hl7:comp[@operator='P']">
                        <xsl:text> periodic hull </xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="following-sibling::hl7:comp/@operator"/>
                        <xsl:text> (onbekend type operator) </xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
            <xsl:if test="following-sibling::hl7:comp">
                <br/>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    <xsl:template name="CodedValue">
        <xsl:param name="label"/>
        <table class="values">
            <tr>
                <td class="labelSmall">
                    <xsl:value-of select="concat($label,' ' )"/>
                </td>
                <!-- class attribuut for css wordt gezet tijdens afhandeling -->
                <td>
                    <xsl:choose>
                        <!-- Test of er een codeSystem is -->
                        <xsl:when test="./@code and not(./@codeSystem)">
                            <xsl:attribute name="class">
                                <xsl:value-of select="'value-error'"/>
                            </xsl:attribute>
                            <xsl:call-template name="toolTip">
                                <xsl:with-param name="toolTipText" select="'codeSystem attribuut ontbreekt'"/>
                            </xsl:call-template>
                            <xsl:value-of select="concat(./@code,' : ',./@displayName)"/>
                        </xsl:when>
                        <!-- G-Standaard codes worden niet opgezocht, alleen getoond -->
                        <xsl:when test="./@codeSystem='2.16.840.1.113883.2.4.4.8'">
                            <xsl:attribute name="class">
                                <xsl:value-of select="'value'"/>
                            </xsl:attribute>
                            <xsl:value-of select="concat('G-Standaard Artikel ',./@code,' : ',./@displayName)"/>
                        </xsl:when>
                        <xsl:when test="./@codeSystem='2.16.840.1.113883.2.4.4.7'">
                            <xsl:attribute name="class">
                                <xsl:value-of select="'value'"/>
                            </xsl:attribute>
                            <xsl:value-of select="concat('G-Standaard HPK ',./@code,' : ',./@displayName)"/>
                        </xsl:when>
                        <xsl:when test="./@codeSystem='2.16.840.1.113883.2.4.4.1'">
                            <xsl:attribute name="class">
                                <xsl:value-of select="'value'"/>
                            </xsl:attribute>
                            <xsl:value-of select="concat('G-Standaard GPK ',./@code,' : ',./@displayName)"/>
                        </xsl:when>
                        <xsl:when test="./@codeSystem='2.16.840.1.113883.2.4.4.10'">
                            <xsl:attribute name="class">
                                <xsl:value-of select="'value'"/>
                            </xsl:attribute>
                            <xsl:value-of select="concat('G-Standaard PRK ',./@code,' : ',./@displayName)"/>
                        </xsl:when>
                        <!-- Eigen code op basis van URA -->
                        <xsl:when test="substring(@codeSystem,1,20)='2.16.528.1.1007.3.3.'">
                            <xsl:attribute name="class">
                                <xsl:value-of select="'value'"/>
                            </xsl:attribute>
                            <xsl:value-of select="concat('Interne code ',./@code,' : ',./@displayName)"/>
                        </xsl:when>
                        <!-- nullFlavor -->
                        <xsl:when test="./@nullFlavor">
                            <xsl:attribute name="class">
                                <xsl:value-of select="'value'"/>
                            </xsl:attribute>
                            <xsl:value-of select="concat(./@nullFlavor,' ')"/>
                            <xsl:choose>
                                <xsl:when test="./@nullFlavor='OTH'">
                                    <xsl:value-of select="hl7:originalText"/>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:when>
                        <!-- code opzoeken in vocab directory -->
                        <xsl:otherwise>
                            <xsl:choose>
                                <!-- test of vocab bestand wel bestaat -->
                                <xsl:when test="not(doc-available(concat($vocabPath,./@codeSystem,'.xml')))">
                                    <xsl:attribute name="class">
                                        <xsl:value-of select="'value-warning'"/>
                                    </xsl:attribute>
                                    <xsl:call-template name="toolTip">
                                        <xsl:with-param name="toolTipText" select="concat('Codetabel niet gevoden: ',./@codeSystem)"/>
                                    </xsl:call-template>
                                    <xsl:value-of select="concat(./@code,' : ',./@displayName)"/>
                                </xsl:when>
                                <!-- code opzoeken in vocab bestand -->
                                <xsl:otherwise>
                                    <xsl:variable name="codeValue" select="./@code"/>
                                    <xsl:variable name="codeSystem" select="./@codeSystem"/>
                                    <xsl:variable name="codeSystemName" select="document(concat($vocabPath,$codeSystem,'.xml'))/*/hl7:name[1]"/>
                                    <xsl:variable name="originalDisplayName" select="document(concat($vocabPath,$codeSystem,'.xml'))/*/hl7:code[@code=$codeValue]/@displayName"/>
                                    <xsl:variable name="originalLowerCase">
                                        <xsl:call-template name="lower-case">
                                            <xsl:with-param name="data" select="$originalDisplayName"/>
                                        </xsl:call-template>
                                    </xsl:variable>
                                    <xsl:variable name="messageLowerCase">
                                        <xsl:call-template name="lower-case">
                                            <xsl:with-param name="data" select="@displayName"/>
                                        </xsl:call-template>
                                    </xsl:variable>
                                    <xsl:choose>
                                        <xsl:when test="$codeValue and not($originalDisplayName)">
                                            <xsl:attribute name="class">
                                                <xsl:value-of select="'value-warning'"/>
                                            </xsl:attribute>
                                            <xsl:call-template name="toolTip">
                                                <xsl:with-param name="toolTipText" select="concat('Code: ',./@code,'&lt;br/&gt;Niet gevonden in codetabel ',./@codeSystem,' (',$codeSystemName,')')"/>
                                            </xsl:call-template>
                                            <xsl:value-of select="concat($codeValue,' : ',./@displayName)"/>
                                        </xsl:when>
                                        <xsl:when test="$codeValue and ./@displayName and not(normalize-space($messageLowerCase)=normalize-space($originalLowerCase))">
                                            <xsl:attribute name="class">
                                                <xsl:value-of select="'value-warning'"/>
                                            </xsl:attribute>
                                            <xsl:call-template name="toolTip">
                                                <xsl:with-param name="toolTipText" select="concat('Afwijkende displayName &lt;br/&gt; Bericht: ',./@displayName,'&lt;br/&gt; Codetabel (',$codeSystemName,'): ',$originalDisplayName)"/>
                                            </xsl:call-template>
                                            <xsl:value-of select="concat($codeValue,' : ',./@displayName)"/>
                                        </xsl:when>
                                        <xsl:when test="$originalDisplayName">
                                            <xsl:value-of select="concat($codeValue,' : ',$originalDisplayName)"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <!-- Should not reach this point, but if nothing useful is left, just tell it like it is -->
                                            <xsl:value-of select="concat($codeValue,' : ',$codeSystem)"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:otherwise>
                    </xsl:choose>
                </td>
            </tr>
        </table>
    </xsl:template>
    <!-- template voor CS types, et variabele naam voor code en zonder codesystem en displayName -->
    <xsl:template name="CodedSimple">
        <xsl:param name="label"/>
        <xsl:param name="code"/>
        <xsl:param name="codeSystemOID"/>
        <table class="values">
            <tr>
                <td class="labelSmall">
                    <xsl:value-of select="concat($label,' ' )"/>
                </td>
                <!-- class attribuut for css wordt gezet tijdens afhandeling -->
                <td>
                    <xsl:choose>
                        <!-- test of vocab bestand wel bestaat -->
                        <xsl:when test="not(doc-available(concat($vocabPath,$codeSystemOID,'.xml')))">
                            <xsl:attribute name="class">
                                <xsl:value-of select="'value-warning'"/>
                            </xsl:attribute>
                            <xsl:call-template name="toolTip">
                                <xsl:with-param name="toolTipText" select="concat('Codetabel niet gevoden: ',$codeSystemOID)"/>
                            </xsl:call-template>
                            <xsl:value-of select="$code"/>
                        </xsl:when>
                        <!-- code opzoeken in vocab bestand -->
                        <xsl:otherwise>
                            <xsl:variable name="codeValue" select="$code"/>
                            <xsl:variable name="codeSystem" select="$codeSystemOID"/>
                            <xsl:variable name="details" select="document(concat($vocabPath,$codeSystem,'.xml'))/*/hl7:code[@code=$codeValue]"/>
                            <xsl:choose>
                                <xsl:when test="not($details/@code)">
                                    <xsl:attribute name="class">
                                        <xsl:value-of select="'value-warning'"/>
                                    </xsl:attribute>
                                    <xsl:call-template name="toolTip">
                                        <xsl:with-param name="toolTipText" select="concat('Code: ',$code,'&lt;br/&gt;Niet gevonden in codetabel ', $codeSystemOID)"/>
                                    </xsl:call-template>
                                    <xsl:value-of select="$code"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="concat($codeValue,' : ',$details/@displayName)"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:otherwise>
                    </xsl:choose>
                </td>
            </tr>
        </table>
    </xsl:template>
    <!-- template voor toolTip, maakt gebruik van Boxover javascript -->
    <xsl:template name="toolTip">
        <xsl:param name="toolTipText"/>
        <xsl:attribute name="title">
            <xsl:text>cssbody=[toolTipBody] cssheader=[toolTipHeader]  body=[</xsl:text>
            <xsl:value-of select="$toolTipText"/>
            <xsl:text>]</xsl:text>
        </xsl:attribute>
    </xsl:template>
    <!-- convert to lower case -->
    <xsl:template name="lower-case">
        <xsl:param name="data"/>
        <xsl:if test="$data">
            <xsl:value-of select="translate($data, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"/>
        </xsl:if>
    </xsl:template>
    <!-- convert to upper case -->
    <xsl:template name="upper-case">
        <xsl:param name="data"/>
        <xsl:if test="$data">
            <xsl:value-of select="translate($data,'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>