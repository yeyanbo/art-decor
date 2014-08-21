<!-- 
	DISCLAIMER
	Deze stylesheet en de resulterende html weergave van xml berichten zijn uitsluitend bedoeld voor testdoeleinden.
	Zij zijn uitdrukkelijk niet bedoeld voor gebruik in de medische praktijk.
	
	Auteur: Gerrit Boers
	Copyright: Nictiz
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:hl7="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" exclude-result-prefixes="hl7" version="2.0">
    <xsl:output method="html"/>
    <xsl:include href="datatypes2html.xsl"/>
	<!-- Templates op alfabetische volgorde -->
    <xsl:template match="hl7:act">
        <xsl:variable name="label">
            <xsl:choose>
                <xsl:when test="@classCode='DOCCLIN'">
                    <xsl:value-of select="'Document'"/>
                </xsl:when>
                <xsl:when test="@moodCode='INT'">
                    <xsl:value-of select="'Intentie'"/>
                </xsl:when>
                <xsl:when test="@moodCode='RQO'">
                    <xsl:value-of select="'Verzoek'"/>
                </xsl:when>
                <xsl:when test="@moodCode='PRMS'">
                    <xsl:value-of select="'Toezegging'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'Act'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="$label"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:adverseReaction">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Bijwerking'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:advice">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Voorlichting'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:annotation">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Annotatie'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:appendage/hl7:document">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Toegevoegd document'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:appointmentAbortEvent">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Afspraak annulering'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:asCareSubject">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Niet-medische voorziening'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:asEmployee">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Beroep'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:carePlan">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Zorgplan'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:careProvisionEvent | hl7:CareProvisionEvent ">
        <xsl:call-template name="headingToggle">
            <xsl:with-param name="heading" select="'h2'"/>
            <xsl:with-param name="label" select="'CareProvisionEvent'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:CareProvisionRequest">
        <xsl:call-template name="headingToggle">
            <xsl:with-param name="heading" select="'h2'"/>
            <xsl:with-param name="label" select="'CareProvisionRequest'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:causativeAgent">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Veroorzakend Agens'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:ClinicalDocument/hl7:component/hl7:structuredBody">
        <xsl:call-template name="headingToggle">
            <xsl:with-param name="heading" select="'h2'"/>
            <xsl:with-param name="label" select="'Gestructureerde inhoud'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:ClinicalDocument/hl7:component/hl7:nonXMLBody">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Ongestructureerd inhoud'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:conclusion">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Conclusie'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:condition">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Aandoening'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:Condition">
        <xsl:call-template name="headingToggle">
            <xsl:with-param name="label" select="'Conditie'"/>
            <xsl:with-param name="heading" select="'h2'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:contact">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Contact'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:ContraIndication">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Contra-indicatie'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:consentEvent">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Consent'"/>
            <xsl:with-param name="negationIndLabel" select="'Toestemming geweigerd'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:CoveredParty">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Verzekering'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:delivery">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Bevalling'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:deliveryObservation">
        <xsl:call-template name="careStatement">
            <xsl:with-param name="label" select="'Observatie'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:employerOrganization">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Werkgever'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:encounterAppointment">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Afspraak'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:encounter">
        <xsl:variable name="label">
            <xsl:choose>
                <xsl:when test="string-length(hl7:code/@displayName)&gt;0">
                    <xsl:value-of select="hl7:code/@displayName"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'Contact'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
		<!-- encounter in PrimaryCareProvision in deelcontacten -->
        <xsl:choose>
            <xsl:when test="local-name(../..)='PrimaryCareProvision' and count(distinct-values(hl7:component/hl7:sequenceNumber/@value))&gt;1">
                <xsl:variable name="id" select="generate-id()"/>
                <xsl:variable name="id-toggler" select="concat($id,'-toggler')"/>
                <table class="section">
                    <tr>
                        <xsl:element name="td">
                            <xsl:attribute name="class">
                                <xsl:value-of select="'section-label-toggler'"/>
                            </xsl:attribute>
                            <xsl:attribute name="id">
                                <xsl:value-of select="$id-toggler"/>
                            </xsl:attribute>
                            <xsl:attribute name="onclick">
                                <xsl:value-of select="concat('return toggle(&#34;',$id,'&#34;,&#34;',$id-toggler,'&#34;)')"/>
                            </xsl:attribute>
                            <xsl:value-of select="$label"/>
                        </xsl:element>
                        <xsl:element name="td">
                            <xsl:attribute name="id">
                                <xsl:value-of select="$id"/>
                            </xsl:attribute>
                            <xsl:attribute name="class">
                                <xsl:value-of select="'toggle'"/>
                            </xsl:attribute>
                            <xsl:for-each select="hl7:component">
                                <xsl:sort select="hl7:sequenceNumber/@value" data-type="number"/>
                                <xsl:variable name="currentSequenceNumber" select="hl7:sequenceNumber/@value"/>
                                <xsl:choose>
                                    <xsl:when test="preceding-sibling::hl7:sequenceNumber/@value!=$currentSequenceNumber">
                                        <table class="section">
                                            <tr>
                                                <td class="section-label">
                                                    <xsl:value-of select="'Deelcontact'"/>
                                                </td>
                                                <td>
                                                    <xsl:for-each select="../hl7:component[hl7:sequenceNumber/@value=$currentSequenceNumber]">
                                                        <xsl:apply-templates select="."/>
                                                    </xsl:for-each>
                                                </td>
                                            </tr>
                                        </table>
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:for-each>
                        </xsl:element>
                    </tr>
                </table>
            </xsl:when>
			<!-- andere encounters standaard afhandeling -->
            <xsl:otherwise>
                <xsl:call-template name="sectionToggle">
                    <xsl:with-param name="label" select="$label"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="hl7:encounterEvent | hl7:encounterNoEvent">
        <xsl:call-template name="sectionToggle">
            <xsl:with-param name="label" select="'Contactmoment'"/>
            <xsl:with-param name="negationIndLabel" select="'Niet plaatsgevonden'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:endOfCareEvent">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Beëindiging zorg'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:ClinicalDocument//hl7:section/hl7:entry">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'CDA Level 3'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:entryRelationship">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="concat('Relatie (',@typeCode,')')"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:episodOfCare">
        <xsl:call-template name="sectionToggle">
            <xsl:with-param name="label" select="'Behandelepisode'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:episodOfCare/hl7:component/hl7:actReference">
        <xsl:variable name="idStr" select="concat(hl7:id/@root,'-',hl7:id/@extension)"/>
        <xsl:choose>
			<!-- test of actReference in bericht voorkomt -->
            <xsl:when test="count(//hl7:id[concat(@root,'-',@extension)=$idStr     and local-name(../.)!='actReference' and     string-length($idStr)&gt;1])=0">
                <table>
                    <tr>
                        <td class="labelSmall"> ActReferentie Id </td>
                        <td class="value-error">
                            <xsl:call-template name="toolTip">
                                <xsl:with-param name="toolTipText" select="'Referentie niet gevonden'"/>
                            </xsl:call-template>
                            <xsl:value-of select="$idStr"/>
                        </td>
                    </tr>
                </table>
            </xsl:when>
			<!-- test of actReference uniek is -->
            <xsl:when test="count(//hl7:id[concat(@root,'-',@extension)=$idStr     and local-name(../.)!='actReference'  and local-name(../../.)!='reason' and     string-length($idStr)&gt;1])&gt;1">
                <table>
                    <tr>
                        <td class="labelSmall"> ActReferentie Id </td>
                        <td class="value-error">
                            <xsl:call-template name="toolTip">
                                <xsl:with-param name="toolTipText" select="'Referentie is niet uniek'"/>
                            </xsl:call-template>
                            <xsl:value-of select="$idStr"/>
                        </td>
                    </tr>
                </table>
            </xsl:when>
			<!-- act die gerefereerd wordt tonen -->
            <xsl:otherwise>
                <xsl:apply-templates select="//hl7:id[concat(@root,'-',@extension)=$idStr      and local-name(../.)!='actReference' and local-name(../../.)!='reason']/../."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="hl7:episodeOfCondition">
        <xsl:variable name="label">
            <xsl:choose>
                <xsl:when test="string-length(hl7:text)&gt;0">
                    <xsl:value-of select="hl7:text"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'Zonder titel'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:call-template name="sectionToggle">
            <xsl:with-param name="label" select="$label"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:escort">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Begeleider'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:evaluationEvent">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Evaluatie'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:groupCluster">
        <xsl:call-template name="careStatement">
            <xsl:with-param name="label" select="'Groep'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:guardian">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Voogd'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:heelPrick">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Hielprik'"/>
            <xsl:with-param name="negationIndLabel" select="'Niet uitgevoerd'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:houseMate">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Huisgenoot'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:incubatorAccomodation">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Couveuse'"/>
            <xsl:with-param name="negationIndLabel" select="'Niet gebruikt'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:indication">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Indicatie'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:indication/hl7:reasonOf">
        <table>
            <tr>
                <td class="labelSmall"> Soort interventie </td>
                <td class="value">
                    <xsl:choose>
                        <xsl:when test="hl7:informIntent">Voorlichting </xsl:when>
                        <xsl:when test="hl7:informRequest">Advies, Consultatie/inlichtingen vragen </xsl:when>
                        <xsl:when test="hl7:observationIntent">Extra (medisch) onderzoek </xsl:when>
                        <xsl:when test="hl7:registrationIntent">Melding </xsl:when>
                        <xsl:when test="hl7:referral">Verwijzing </xsl:when>
                    </xsl:choose>
                </td>
            </tr>
        </table>
    </xsl:template>
    <xsl:template match="hl7:informant">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Informatieverstrekker'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:informationControlActEvent">
        <xsl:call-template name="careStatement">
            <xsl:with-param name="label" select="'Informatie'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:inpatientEncounter">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Opname'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:IntoleranceCondition">
        <xsl:call-template name="headingToggle">
            <xsl:with-param name="label" select="'Intolerantie'"/>
            <xsl:with-param name="heading" select="'h2'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:JournalEntry">
        <xsl:variable name="label">
            <xsl:choose>
                <xsl:when test="./hl7:code/@code='S'"> S-regel </xsl:when>
                <xsl:when test="./hl7:code/@code='O'"> O-regel </xsl:when>
                <xsl:when test="./hl7:code/@code='E'"> E-regel </xsl:when>
                <xsl:when test="./hl7:code/@code='P'"> P-regel </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="$label"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:location">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Locatie'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:location/hl7:serviceDeliveryLocation">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Afdeling'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:medication | hl7:MedicationKind">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Medicatie'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:medicationAdministrationRequest">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Toedieningsverzoek'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:medicationDispenseEvent | hl7:MedicationDispenseEvent">
        <xsl:call-template name="headingToggle">
            <xsl:with-param name="heading" select="'h2'"/>
            <xsl:with-param name="label" select="'Medicatieverstrekking'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:MedicationDispenseList">
        <xsl:call-template name="headingToggle">
            <xsl:with-param name="heading" select="'h2'"/>
            <xsl:with-param name="label" select="'Lijst Medicatieverstrekkingen'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:medicationDispenseRequest">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Afleververzoek'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:member/hl7:group">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Woonverband'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:neonateData">
        <xsl:call-template name="sectionToggle">
            <xsl:with-param name="label" select="'Pasgeborene'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:neonateObservations">
        <xsl:call-template name="careStatement">
            <xsl:with-param name="label" select="'Pasgeborene Observatie'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:nonBDSData">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Non-BDS'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:nonEncounterCareActivity">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Contactloze activiteit'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:nonMedicalCareProvision">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Niet-medische voorziening'"/>
            <xsl:with-param name="negationIndLabel" select="'Geen gebruik'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:observation">
        <xsl:call-template name="careStatement">
            <xsl:with-param name="label" select="'Observatie'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:ObservationDx">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Diagnose'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:observationGoal">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Doel'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:observationIntent">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Interventie'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:ObservationIntolerance">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Intolerantie'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:Organization | hl7:representedOrganization | hl7:representedCustodianOrganization">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Organisatie'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:patientCareObservation">
        <xsl:call-template name="careStatement">
            <xsl:with-param name="label" select="'Observatie'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:patientCareProvision">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Ontvangen zorg'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:patientCareProvision/hl7:subject">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Ontvanger van de zorg'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:patientOfOtherProvider">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Zorgrelatie'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:personalRelationship">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Persoonlijke relatie'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:pertainsTo/hl7:categoryInBDS">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'BDS rubriek'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:pertinentAnnotationObsEvent">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Attentieregel'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:policyOrAccount">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Polis'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:pregnancyCondition">
        <xsl:call-template name="sectionToggle">
            <xsl:with-param name="label" select="'Zwangerschap'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:pregnancyObservations">
        <xsl:call-template name="careStatement">
            <xsl:with-param name="label" select="'Observatie'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:prescription|hl7:Prescription">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Medicatievoorschrift'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:PrimaryCareProvision">
        <xsl:call-template name="headingToggle">
            <xsl:with-param name="heading" select="'h2'"/>
            <xsl:with-param name="label" select="'Dossier'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:problem">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Probleem'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:procedure">
        <xsl:variable name="procedureCode">
            <xsl:choose>
                <xsl:when test="@classCode='SPECCOLLECT'">Afnameprocedure</xsl:when>
                <xsl:otherwise>Procedure</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="$procedureCode"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:registrationEvent">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Melding'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:registrationProcess">
        <h2>Verwijsindex registratie <xsl:choose>
                <xsl:when test="//hl7:MFMT_IN002101"> aanmaken</xsl:when>
                <xsl:when test="//hl7:MFMT_IN002102"> bijwerken</xsl:when>
                <xsl:when test="//hl7:MFMT_IN002103"> verwijderen</xsl:when>
            </xsl:choose>
        </h2>
        <div class="level2">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="hl7:referenceRange">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Referentiewaarden'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:registrationScope">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Inperking'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:rubricCluster">
        <xsl:call-template name="careStatement">
            <xsl:with-param name="label" select="'Rubriek'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:scopingOrganization">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Organisatie'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:section">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Sectie'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:severityObservation">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Ernst'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:substanceAdministration">
        <xsl:variable name="label">
            <xsl:choose>
                <xsl:when test="@moodCode='EVN'">
                    <xsl:value-of select="'Medicatietoediening'"/>
                </xsl:when>
                <xsl:when test="@moodCode='RQO'">
                    <xsl:value-of select="'Medicatievoorschrift'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'Medicatie'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="$label"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:substanceAdministrationEvent">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Toediening'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:summary">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Samenvatting'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:symptoms">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Symptomen'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:vaccinations">
        <xsl:call-template name="sectionToggle">
            <xsl:with-param name="label" select="'Rijksvaccinatie'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:vaccinationConsent">
        <xsl:call-template name="section">
            <xsl:with-param name="label" select="'Vaccinatie consent'"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="hl7:vaccinationObservation">
        <xsl:call-template name="careStatement">
            <xsl:with-param name="label" select="'Observatie'"/>
        </xsl:call-template>
    </xsl:template>
	<!-- Named templates voor layout doeleinden -->
	<!-- Template voor heading waarop een div volgt die opengeklikt kan worden -->
    <xsl:template name="headingToggle">
        <xsl:param name="label"/>
        <xsl:param name="heading"/>
        <xsl:variable name="id" select="generate-id()"/>
        <xsl:variable name="id-toggler" select="concat($id,'-toggler')"/>
        <xsl:element name="{$heading}">
            <xsl:attribute name="class">
                <xsl:value-of select="'toggler'"/>
            </xsl:attribute>
            <xsl:attribute name="id">
                <xsl:value-of select="$id-toggler"/>
            </xsl:attribute>
            <xsl:attribute name="onclick">
                <xsl:value-of select="concat('return toggle(&#34;',$id,'&#34;,&#34;',$id-toggler,'&#34;)')"/>
            </xsl:attribute>
            <xsl:value-of select="$label"/>
        </xsl:element>
        <div class="level2">
            <xsl:element name="div">
                <xsl:attribute name="id">
                    <xsl:value-of select="$id"/>
                </xsl:attribute>
                <xsl:attribute name="class">
                    <xsl:value-of select="'toggle'"/>
                </xsl:attribute>
                <xsl:apply-templates/>
            </xsl:element>
        </div>
    </xsl:template>
	<!-- Template voor secties zoals b.v. patiënt, auteur etc.  -->
    <xsl:template name="section">
        <xsl:param name="label"/>
        <xsl:param name="negationIndLabel" select="NIET"/>
        <table class="section">
            <tr>
                <td class="section-label">
                    <xsl:if test="./@negationInd='true'">
                        <xsl:value-of select="$negationIndLabel"/>
                        <div/>
                    </xsl:if>
                    <xsl:value-of select="$label"/>
                </td>
                <td>
                    <xsl:apply-templates/>
                </td>
            </tr>
        </table>
    </xsl:template>
	<!-- Template voor secties waarbij de inhoud 'opengeklikt' kan worden	-->
    <xsl:template name="sectionToggle">
        <xsl:param name="label"/>
        <xsl:param name="negationIndLabel" select="NIET"/>
        <xsl:variable name="id" select="generate-id()"/>
        <xsl:variable name="id-toggler" select="concat($id,'-toggler')"/>
        <table class="section">
            <tr>
                <xsl:element name="td">
                    <xsl:attribute name="class">
                        <xsl:value-of select="'section-label-toggler'"/>
                    </xsl:attribute>
                    <xsl:attribute name="id">
                        <xsl:value-of select="$id-toggler"/>
                    </xsl:attribute>
                    <xsl:attribute name="onclick">
                        <xsl:value-of select="concat('return toggle(&#34;',$id,'&#34;,&#34;',$id-toggler,'&#34;)')"/>
                    </xsl:attribute>
                    <xsl:value-of select="$label"/>
                    <xsl:if test="./@negationInd='true'">
                        <div>
                            <xsl:value-of select="$negationIndLabel"/>
                        </div>
                    </xsl:if>
                </xsl:element>
                <xsl:element name="td">
                    <xsl:attribute name="id">
                        <xsl:value-of select="$id"/>
                    </xsl:attribute>
                    <xsl:attribute name="class">
                        <xsl:value-of select="'toggle'"/>
                    </xsl:attribute>
                    <xsl:apply-templates/>
                </xsl:element>
            </tr>
        </table>
    </xsl:template>
	<!-- Template voor JGZ careStatement Rubrieken, groepen en elementen -->
    <xsl:template name="careStatement">
        <xsl:param name="label"/>
        <table class="section">
            <tr>
                <td class="section-label">
                    <xsl:value-of select="$label"/>
                </td>
                <td>
                    <h4>
                        <xsl:value-of select="./hl7:code/@displayName"/>
                    </h4>
                    <xsl:apply-templates/>
                </td>
            </tr>
        </table>
    </xsl:template>
</xsl:stylesheet>