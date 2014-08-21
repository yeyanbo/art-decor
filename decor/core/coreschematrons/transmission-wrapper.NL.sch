<?xml version="1.0" encoding="UTF-8"?>
<pattern abstract="true" id="transmission-wrapper" xmlns="http://purl.oclc.org/dsdl/schematron">
    <title>Transmission Wrapper Algemeen</title>
    
    <!-- 
        Message id equals every id that is adjacent to hl7:creationTime. 
        This way it works for batches and every message contained, even SOAP wrapped.
    -->
    <rule context="$element/hl7:id">
        <extends rule="II"/>
        <assert role="error" test="@root and @extension"
            >Transmission: id element mist root of extension</assert>
        <!--report role="warning"
            test="not(substring(@root,1,26)='2.16.840.1.113883.2.4.6.6.' or substring(@root,1,20)='2.16.528.1.1007.3.3.' or substring(@root,1,29)='2.16.840.1.113883.2.4.3.11.7.')"
            >Transmission: @root moet bij voorkeur zijn gebaseerd op URA, AORTA applicatie-id of Klantenloket id</report-->
    </rule>
    <!-- creationTime -->
    <rule context="$element/hl7:creationTime">
        <extends rule="TS"/>
        <assert role="error" test="not(@xsi:type) or @xsi:type='TS' or ends-with(@xsi:type,':TS')"
            >Transmission: creationTime moet datatype TS hebben. Gevonden '<value-of select="@xsi:type"/>'</assert>
        <assert role="error" test="string-length(@value)&gt;13"
            >Transmission: creationTime moet minimaal op de seconde nauwkeurig zijn</assert>
    </rule>
    <!-- versionCode -->
    <rule context="$element/hl7:versionCode">
        <extends rule="CS"/>
        <assert role="error" test="@code='NICTIZEd2005-Okt'"
            >Transmission: versionCode '<value-of select="@code"/>' moet 'NICTIZEd2005-Okt' zijn</assert>
    </rule>
    <!-- interactionId -->
    <rule context="$element/hl7:interactionId">
        <extends rule="II"/>
        <let name="interactionId" value="self::node()[@root='2.16.840.1.113883.1.6']/@extension"/>
        <let name="interactionVocabFile" value="'../vocab/2.16.840.1.113883.1.6.xml'"/>
        <let name="interactionName" value="if (doc-available($interactionVocabFile)) then (document($interactionVocabFile)/*/hl7:code[@code=$interactionId]/@displayName) else ()"/>
        
        <assert role="error" test="@root='2.16.840.1.113883.1.6'"
            >Transmission: @root moet '2.16.840.1.113883.1.6' zijn</assert>
        <assert role="error" test="not(@root='2.16.840.1.113883.1.6') or local-name(..)=@extension"
            >Transmission: @extension moet overeenkomen met het startelement van het bericht</assert>
        <assert role="error" test="not(contains(@extension,':'))"
            >Transmission: @extension mag geen namespace prefix bevatten</assert>
        <assert role="error" test="not(doc-available($interactionVocabFile)) or 
            not(document($interactionVocabFile)/*/hl7:code[@code=$interactionId]/hl7:qualifier[@name='Actief']/@value='false')"
            >Transmission: interaction-id <value-of select="$interactionId"/> (<value-of select="$interactionName"/>) is niet (meer) Actief in <value-of select="$interactionVocabFile"/></assert>
    </rule>
    <!-- profileId -->
    <rule context="$element/hl7:profileId">
        <extends rule="II"/>
        <assert role="error" test="@root='2.16.840.1.113883.2.4.3.11.1' and (@extension='810')"
            >Transmission: profileId '<value-of select="@extension"/>' moet gelijk zijn aan 810. </assert>
        <assert role="error" test="not(following-sibling::hl7:profileId)"
            >Transmission: er mag maar één profileId worden gebruikt</assert>
    </rule>
    
    <!-- acknowledgement algemeen, adjacent to hl7:creationTime -->
    <rule context="$element/hl7:acknowledgement">
        <assert role="error" test="local-name(..)='MCCI_IN000002' or @typeCode='AA' or @typeCode='AE' or @typeCode='AR'"
            >Transmission: applicatieantwoorden moeten acknowledgement/@typeCode AA, AE of AR hebben</assert>
        <!-- acknowledgement MCCI_IN000002 -->
        <assert role="warning" test="not(local-name(..)='MCCI_IN000002') or @typeCode='CA' or @typeCode='CE' or @typeCode='CR'"
            >Transmission: ontvangstbevestigingen moeten acknowledgement/@typeCode CA, CE of CR hebben. In slechts sommige gevallen worden 
            toch inhoudelijke antwoorden toegestaan (@typeCode is 'AA', 'AE' or 'AR').</assert>
        <assert role="error" test="hl7:targetMessage/hl7:id[@root and @extension] or hl7:targetTransmission/hl7:id[@root and @extension]"
            >Transmission: in antwoordinteracties moet de interactie waarop wordt geantwoord, worden geïdentificeerd in het element targetTransmission/id</assert>
        <assert role="warning" test="@typeCode='AA' or @typeCode='CA' or hl7:acknowledgementDetail or ../hl7:ControlActProcess/hl7:reason or ../hl7:ControlActProcess/hl7:reasonOf"
            >Transmission: negatieve antwoordberichten moeten ook een reden hebben waarom</assert>
    </rule>
    <!-- acknowledgementDetail/@typeCode -->
    <rule context="$element/hl7:acknowledgement/hl7:acknowledgementDetail">
        <assert role="error" test="not(@typeCode) or @typeCode='E'"
            >Transmission: acknowledgementDetail/@typeCode moet indien aanwezig E (Error) zijn. W (Warning) of I (Information) zijn niet toegestaan</assert>
        <assert role="error" test="hl7:code"
            >Transmission: acknowledgementDetail/code moet een waarde hebben.</assert>
        <assert role="error" test="hl7:code[@code and @displayName] or hl7:text"
            >Transmission: er moet een toelichting op de fout/waarschuwing zijn in hl7:code/@displayName of text</assert>
    </rule>
    
    <rule context="$element/hl7:acknowledgement/hl7:acknowledgementDetail/hl7:code">
        <extends rule="CE"/>
        <assert role="error" test="not(@nulFlavor)"
            >Transmission: code moet een waarde hebben.</assert>
        <assert role="error" test="not(hl7:translation)"
            >Transmission: code mag geen translation bevatten.</assert>
        <report role="warning" test="not(@codeSystem='2.16.840.1.113883.5.1100' or @codeSystem='2.16.840.1.113883.2.4.6.6.1.1000' or @codeSystem='2.16.840.1.113883.5.4') and not(@displayName)"
            >Transmission: als de code niet uit een van de standaardcodesystemen '2.16.840.1.113883.5.1100', '2.16.840.1.113883.2.4.6.6.1.1000', of '2.16.840.1.113883.5.4' komt is het @displayName attribuut verplicht</report>
    </rule>
    
    <rule context="$element/hl7:receiver">
        <assert role="error" test="not(@typeCode) or @typeCode='RCV'"
            >Transmission: receiver/@typeCode moet 'RCV' zijn indien aanwezig</assert>
        <assert role="error" test="count(../hl7:receiver)=1"
            >Transmission: receiver mag slechts éénmaal voorkomen</assert>
    </rule>
    
    <rule context="$element/hl7:respondTo">
        <assert role="error" test="not(@typeCode) or @typeCode='RSP'"
            >Transmission: respondTo/@typeCode moet 'RSP' zijn indien aanwezig</assert>
        <assert role="error" test="count(../hl7:respondTo)=1"
            >Transmission: respondTo mag slechts éénmaal voorkomen</assert>
        <assert role="error" test="count(hl7:entityRsp)=1"
            >Transmission: respondTo/entityRsp mag slechts éénmaal voorkomen</assert>
        
        <let name="entityRspRoot" value="hl7:entityRsp/hl7:id/@root"/>
        <assert role="warning" test="not(hl7:entityRsp/hl7:id/@extension=../hl7:sender/hl7:device/hl7:id[@root=$entityRspRoot]/@extension)"
            >Transmission: waarschuwing: het antwoord moet worden verstuurd aan dezelfde applicatie als de zendende applicatie. In dit geval is respondTo redundant.</assert>
    </rule>
    
    <rule context="$element/hl7:sender">
        <assert role="error" test="not(@typeCode) or @typeCode='SND'"
            >Transmission: sender/@typeCode moet 'SND' zijn indien aanwezig</assert>
    </rule>
    
    <rule context="$element/hl7:attentionLine">
        <let name="interactionId" value="../hl7:interactionId[@root='2.16.840.1.113883.1.6']/@extension"/>
        <let name="interactionVocabFile" value="'../vocab/2.16.840.1.113883.1.6.xml'"/>
        <let name="interactionName" value="if (doc-available($interactionVocabFile)) then (document($interactionVocabFile)/*/hl7:code[@code=$interactionId]/@displayName) else ()"/>
        
        <assert role="warning" test="not(doc-available($interactionVocabFile)) or 
            document($interactionVocabFile)/*/hl7:code[@code=$interactionId]/hl7:qualifier[@name='AttentionLineMetBsn']/@value='true' or
            ../hl7:ControlActProcess/hl7:authorOrPerformer/hl7:participant/hl7:AssignedPerson/hl7:code[@codeSystem='2.16.840.1.113883.2.4.3.11.8'] or
            ../hl7:ControlActProcess/hl7:authorOrPerformer/hl7:participant/hl7:AssignedPerson/hl7:code[@codeSystem='2.16.840.1.113883.2.4.3.11.6']"
            >Transmission: interaction-id <value-of select="$interactionId"/> (<value-of select="$interactionName"/>) is niet geconfigureerd voor gebruik van het element <value-of select="local-name()"/> in <value-of select="$interactionVocabFile"/> en afzender is niet GBK of GBP</assert>
    </rule>
    <!-- receiver or sender device or respondTo id -->
    <!-- respondTo - voor het eerst toegepast in Sgl (Signaleringen) -->
    <rule context="$element/hl7:*[local-name()='receiver' or local-name()='sender']/hl7:device/hl7:id | hl7:respondTo/hl7:entityRsp/hl7:id">
        <extends rule="II"/>
        <assert role="error" test="@root='2.16.840.1.113883.2.4.6.6' and @extension"
            >Transmission: <value-of select="local-name(../..)"/>/<value-of select="local-name(..)"/>/id/@root moet 2.16.840.1.113883.2.4.6.6 zijn</assert>
    </rule>

    <!-- receiver or sender device -->
    <rule context="$element/hl7:*[local-name()='receiver' or local-name()='sender']/hl7:device/hl7:desc">
        <assert role="error" test="not(.)"
            >Transmission: <value-of select="local-name(..)"/>/device/descr mag niet gebruikt worden.</assert>
    </rule>
    <rule context="$element/hl7:*[local-name()='receiver' or local-name()='sender']/hl7:device/hl7:existenceTime">
        <assert role="error" test="not(.)"
            >Transmission: <value-of select="local-name(..)"/>/device/existenceTime mag niet gebruikt worden.</assert>
    </rule>
    <rule context="$element/hl7:*[local-name()='receiver' or local-name()='sender']/hl7:manufacturerModelName">
        <assert role="warning" test="not(.)"
            >Transmission: <value-of select="local-name(..)"/>/device/manufacturerModelName niet gebruiken.</assert>
    </rule>
    <rule context="$element/hl7:*[local-name()='receiver' or local-name()='sender']/hl7:device/hl7:agencyFor">
        <assert role="error" test="not(@classCode) or @classCode='AGNT'"
            >Transmission: <value-of select="local-name(../..)"/>/<value-of select="local-name(..)"/>/agencyFor/@classCode moet, indien aanwezig de waarde "AGNT" bevatten</assert>
    </rule>
    <rule context="$element/hl7:*[local-name()='receiver' or local-name()='sender']/hl7:device/hl7:agencyFor/hl7:representedOrganization">
        <assert role="error" test="not(@classCode) or @classCode='ORG'"
            >Transmission: <value-of select="local-name(../../..)"/>/<value-of select="local-name(../..)"/>/agencyFor/representedOrganization/@classCode moet, indien aanwezig de waarde "ORG" bevatten</assert>
        <assert role="error" test="not(@determinerCode) or @determinerCode='INSTANCE'"
            >Transmission: <value-of select="local-name(../../..)"/>/<value-of select="local-name(../..)"/>/agencyFor/representedOrganization/@determinerCode moet, indien aanwezig de waarde "INSTANCE" bevatten</assert>
        <assert role="error" test="count(hl7:id)=1"
            >Transmission: <value-of select="local-name(../../..)"/>/<value-of select="local-name(../..)"/>/agencyFor/representedOrganization/id mag maar één maal voorkomen</assert>
    </rule>
    <!-- May be RIVM nowadays...unknown how to check, not important enough to pursue -->
    <!--rule context="$element/hl7:*[local-name()='receiver' or local-name()='sender']/hl7:device/hl7:agencyFor/hl7:representedOrganization/hl7:id">
        <extends rule="II"/>
        <assert role="error" test="(@root='2.16.528.1.1007.3.3' and @extension) or (@root='2.16.840.1.113883.2.4.3.11' and @extension='7')"
            >Transmission: <value-of select="local-name(../../../..)"/>/<value-of select="local-name(../../..)"/>/agencyFor/representedOrganization/id moet een UZI-registerabonneenummer zijn of het Klantenloket</assert>
    </rule-->
    <rule context="$element/hl7:*[local-name()='receiver' or local-name()='sender']/hl7:device/hl7:agencyFor/hl7:representedOrganization/hl7:name">
        <extends rule="ON"/>
    </rule>
    <rule context="$element/hl7:*[local-name()='receiver' or local-name()='sender']/hl7:device/hl7:agencyFor/hl7:representedOrganization/hl7:telecom">
        <extends rule="TEL"/>
    </rule>
    <rule context="$element/hl7:*[local-name()='receiver' or local-name()='sender']/hl7:device/hl7:location">
        <assert role="error" test="not(.)"
            >Transmission: <value-of select="local-name(..)"/>/device/location mag niet gebruikt worden.</assert>
    </rule>
    
    <title>Transmission Wrapper, geen batch MCCI_IN200101</title>
    <rule context="$element/hl7:processingCode">
        <extends rule="CS"/>
        <assert role="warning" test="@code='P' or document(document-uri(/))/processing-instruction('nictiz')"
            >Transmission: processingCode moet in productie altijd gelijk zijn aan P (productie). D (debug) en T (training) zijn dan niet toegestaan</assert>

        <assert role="error" test="@code='P' or @code='T' or @code='D'"
            >Transmission: processingCode moet de waarde P (productie). D (debug) of T (training) bevatten</assert>
    </rule>
    <rule context="$element/hl7:processingModeCode">
        <extends rule="CS"/>
        <assert role="error" test="@code='T'"
            >Transmission: processingModeCode moet gelijk zijn aan T (Current processing). A (Archive), I (Initial load), en R (Restore from archive) zijn niet toegestaan</assert>
    </rule>
    
    <!-- checking the exact value for acceptAckCode is interaction specific - please handle in main schematron -->
    <rule context="$element/hl7:acceptAckCode">
        <extends rule="CS"/>
        <assert role="error" test="@code='NE' or @code='AL'"
            >Transmission: acceptAckCode moet gelijk zijn aan NE (never) of AL (always)</assert>
    </rule>
</pattern>
